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

+ (void)showMessages:(NSString *)messgae atView:(UIView *)view;

+ (void)showMessages:(NSString *)messgae
              atView:(UIView *)view
          afterDelay:(NSTimeInterval)delay;

+ (void)showMessages:(NSString *)messgae
              atView:(UIView *)view
          afterDelay:(NSTimeInterval)delay
             yOffset:(CGFloat)yOffset;

+ (void)showMessages:(NSString *)messgae
              atView:(UIView *)view
           withImage:(UIImage *)image;

+ (void)showMessages:(NSString *)messgae
              atView:(UIView *)view
           withImage:(UIImage *)image
          afterDelay:(NSTimeInterval)delay;

@end
