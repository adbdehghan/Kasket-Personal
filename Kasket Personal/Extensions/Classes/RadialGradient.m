//
//  RadialGradient.m
//  Kasket Personal
//
//  Created by adb on 4/9/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "RadialGradient.h"

@implementation RadialGradient
- (void)drawRect:(CGRect)rect
{
    // Setup view
    CGFloat colorComponents[] = {0.9, 0.9, 0.9, 0.3,   // First color:  R, G, B, ALPHA (currently opaque black)
        0.9, 0.9, 0.9, 0};  // Second color: R, G, B, ALPHA (currently transparent black)
    CGFloat locations[] = {0, 1}; // {0, 1) -> from center to outer edges, {1, 0} -> from outer edges to center
    CGFloat radius = MIN((self.bounds.size.height / 2), (self.bounds.size.width / 2));
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    // Prepare a context and create a color space
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create gradient object from our color space, color components and locations
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, 2);
    
    // Draw a gradient
    CGContextDrawRadialGradient(context, gradient, center, 0.0, center, radius, 0);
    CGContextRestoreGState(context);
    
    // Release objects
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}
@end
