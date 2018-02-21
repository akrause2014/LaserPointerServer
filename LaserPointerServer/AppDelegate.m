//
//  AppDelegate.m
//  LaserPointerServer
//
//  Created by Amy Krause on 17/02/2018.
//  Copyright © 2018 Amy Krause. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString * const TRANSFER_SERVICE_UUID = @"B07172BF-BDD4-4B1A-9F45-D72B3AFF3207";
NSString * const TRANSFER_CHARACTERISTIC_UUID = @"4C0FA8BE-45C9-4D8A-B529-CCCF5E7A50B8";

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)connectBluetooth:(id)sender {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"Connection successfull to peripheral: %@",peripheral);
    [self.centralManager stopScan];
    //Do somenthing after successfull connection.
    peripheral.delegate = self;
    
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service");
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSArray *components = [stringFromData componentsSeparatedByString:@","];
//    NSLog(@"Received data: %@", stringFromData);
    if ([components count] != 3) return;
    double roll = [components[0] doubleValue];
    double pitch = [components[1] doubleValue];
    double yaw = [components[2] doubleValue];
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];

    double x = screenVisibleFrame.size.width/2 - sin(yaw) * screenVisibleFrame.size.width;
    double y = screenVisibleFrame.size.height/2 + sin(pitch) * screenVisibleFrame.size.height;
//    NSLog(@"Coordinates: (%f, %f)", x, y);
    
    NSWindow *window = [[[NSApplication sharedApplication]windows]firstObject];
    NSLog(@"%@", [[[NSApplication sharedApplication]windows]firstObject]);
    NSRect windowFrame = [window frame];
    NSPoint newOrigin = windowFrame.origin;
    newOrigin.x = fmax(0, fmin(screenVisibleFrame.size.width-windowFrame.size.width, x));
    newOrigin.y = fmax(0, fmin(screenVisibleFrame.size.height-windowFrame.size.height, y));
    
    // Don't let window get dragged up under the menu bar
    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
        newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
    }
    NSRect newFrame = windowFrame;
    newFrame.origin = newOrigin;
    
    [window setFrame:newFrame display:YES animate:YES];
//    NSLog(@"New window origin: (%f, %f)", newOrigin.x, newOrigin.y);
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Connection failed to peripheral: %@",peripheral);
    
    //Do something when a connection to a peripheral failes.
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    NSLog(@"CBCentralManager did update state");
    
    switch (central.state) {
        case CBManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
//            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            break;
    }

}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    self.discoveredPeripheral = peripheral;
    NSLog(@"Discovered peripheral: %@", self.discoveredPeripheral.name);
    [self.centralManager connectPeripheral:self.discoveredPeripheral options:nil];
}


@end
