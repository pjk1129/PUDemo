//
//  MBProgressHUD+Addition.h
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Addition)

+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view;

+ (void)showTipsView:(NSString *)tips atView:(UIView *)view;

+ (void)showTipsView:(NSString *)tips
              atView:(UIView *)view
          afterDelay:(NSTimeInterval)delay;

+ (void)showTipsView:(NSString *)tips
              atView:(UIView *)view
          afterDelay:(NSTimeInterval)delay
             yOffset:(CGFloat)yOffset;

+ (void)showTipsView:(NSString *)tips
              atView:(UIView *)view
           withImage:(UIImage *)image;

+ (void)showTipsView:(NSString *)tips
              atView:(UIView *)view
           withImage:(UIImage *)image
          afterDelay:(NSTimeInterval)delay;
@end
