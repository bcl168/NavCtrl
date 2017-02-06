//
//  UIImage+Resize.m
//  NavCtrl
//
//  Created by bl on 1/29/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import "UIImage+Resize.h"


@implementation UIImage (resize)

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called to scale an image while maintaining the aspect ratio.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)scaleToSize:(CGSize)newSize
{
    CGFloat scaleFactor;
    CGRect canvas;
    
    // If the image is already a square then ...
    if (self.size.width == self.size.height)
        // use newSize as is
        canvas = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
    
    // Otherwise, recalculate newSize to maintain aspect ratio.
    // If the image is wider than it is tall than ...
    else if (self.size.width > self.size.height)
    {
        // Calculate scaling factor using width
        scaleFactor = newSize.width / self.size.width;
        
        // Rescale height to match
        CGFloat newScaledHeight = self.size.height * scaleFactor;
        
        // Vertically center image as well
        canvas = CGRectMake(0.0, (newSize.height - newScaledHeight) / 2.0, newSize.width, newScaledHeight);
    }
    // Otherwise, ...
    else
    {
        // Calculate scaling factor using height
        scaleFactor = newSize.height / self.size.height;
        
        // Rescale width to match
        CGFloat newScaledWidth = self.size.width * scaleFactor;
        
        // Horizontally center image as well
        canvas = CGRectMake((newSize.width - newScaledWidth) / 2.0, 0.0, newScaledWidth, newSize.height);
    }
    
    // Create a resized copy of the image
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [self drawInRect:canvas];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
