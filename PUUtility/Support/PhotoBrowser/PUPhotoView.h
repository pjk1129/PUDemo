//
//  PUPhotoView.h
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PUPhotoBrowser, PUPhoto, PUPhotoView;

@protocol PUPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(PUPhotoView *)photoView;
- (void)photoViewSingleTap:(PUPhotoView *)photoView;
- (void)photoViewDidEndZoom:(PUPhotoView *)photoView;
@end

@interface PUPhotoView : UIScrollView<UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) PUPhoto *photo;
// 代理
@property (nonatomic, weak) id<PUPhotoViewDelegate> photoViewDelegate;

@end
