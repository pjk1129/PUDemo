//
//  MBProgressHUD+Addition.m
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "MBProgressHUD+Addition.h"

@implementation MBProgressHUD (Addition)

#pragma mark - 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.0f];
}

+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    return hud;
}

+ (void)showMessages:(NSString *)messgae atView:(UIView *)view
{
    [self showMessages:messgae atView:view afterDelay:2.5f yOffset:0.0];
}

+ (void)showMessages:(NSString *)messgae
              atView:(UIView *)view
          afterDelay:(NSTimeInterval)delay
{
    [self showMessages:messgae atView:view afterDelay:delay yOffset:0.0f];
}

+ (void)showMessages:(NSString *)messgae
              atView:(UIView *)view
          afterDelay:(NSTimeInterval)delay
             yOffset:(CGFloat)yOffset
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.detailsLabelText = messgae;
	hud.margin = 10.f;
	hud.yOffset = yOffset;
	hud.removeFromSuperViewOnHide = YES;
	
	[hud hide:YES afterDelay:delay];
}

+ (void)showMessages:(NSString *)messgae
              atView:(UIView *)view
           withImage:(UIImage *)image
{
    [self showMessages:messgae atView:view withImage:image afterDelay:1.0f];
}

+ (void)showMessages:(NSString *)messgae
              atView:(UIView *)view
           withImage:(UIImage *)image
          afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:view];
	[view addSubview:HUD];
    
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
    HUD.customView = [[UIImageView alloc] initWithImage:image];
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
	
    HUD.labelText = messgae;
	
    [HUD show:YES];
	[HUD hide:YES afterDelay:delay];
}

#pragma mark - 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

@end
