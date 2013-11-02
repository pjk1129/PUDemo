//
//  UIImage+Utilities.m
//  PUDemo
//
//  Created by JK.Peng on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "UIImage+Utilities.h"

@implementation UIImage (Utilities)

- (UIImage *)captureImageInView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
