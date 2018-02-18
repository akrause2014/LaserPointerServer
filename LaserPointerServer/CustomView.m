//
//  CustomView.m
//  LaserPointerServer
//
//  Created by Amy Krause on 17/02/2018.
//  Copyright © 2018 Amy Krause. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor clearColor] set];
    NSRectFill([self frame]);
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    [circlePath appendBezierPathWithOvalInRect: dirtyRect];
    [[NSColor blueColor] setFill];
    [circlePath fill];
}

@end
