//
//  AppDelegate.h
//  LaserPointerServer
//
//  Created by Amy Krause on 17/02/2018.
//  Copyright © 2018 Amy Krause. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;

extern NSString * const TRANSFER_SERVICE_UUID;
extern NSString * const TRANSFER_SERVICE_CHARACTERISTIC;

@end

