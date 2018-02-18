//
//  CustomWindow.h
//  LaserPointerServer
//
//  Created by Amy Krause on 17/02/2018.
//  Copyright © 2018 Amy Krause. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomWindow : NSWindow {
    NSPoint initialLocation;
}

@property (assign) NSPoint initialLocation;

@end
