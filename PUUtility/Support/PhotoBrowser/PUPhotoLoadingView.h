//
//  PUPhotoLoadingView.h
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinProgress 0.0001

@class PUPhotoBrowser;
@class PUPhoto;

@interface PUPhotoLoadingView : UIView

@property (nonatomic, assign) CGFloat progress;

- (void)showLoading;
- (void)showFailure;

@end
