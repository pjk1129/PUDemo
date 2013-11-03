//
//  PUPhotoBrowserView.h
//  PUDemo
//
//  Created by JK.Peng on 13-11-3.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PUPhotoBrowserViewDelegate;

@interface PUPhotoBrowserView : UIView

@property (nonatomic, strong) NSArray    *photosArray;
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
@property (nonatomic, weak) id<PUPhotoBrowserViewDelegate>  delegate;
- (void)showFromView:(UIView *)fromView;

@end

@protocol PUPhotoBrowserViewDelegate <NSObject>

@optional
- (void)photoBrowser:(PUPhotoBrowserView *)photoBrowser pageAtCurrentIndex:(NSUInteger)index;

@end
