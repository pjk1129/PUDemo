//
//  PUPhotoView.m
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "PUPhotoView.h"
#import "PUPhoto.h"
#import "PUPhotoLoadingView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utilities.h"

@interface PUPhotoView (){
    PUPhotoLoadingView *_photoLoadingView;
    BOOL   _doubleTap;
}

@end

@implementation PUPhotoView

- (void)dealloc{
    // 取消请求
    [_imageView resetImage];
    _imageView = nil;
    _photoViewDelegate = nil;
    _photo = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // 图片
		_imageView = [[UIImageView alloc] init];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
        
        // 进度条
        _photoLoadingView = [[PUPhotoLoadingView alloc] init];
        
        // 监听点击
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:singleTap];
        


    }
    return self;
}

- (void)resetPhotoView
{
    [_imageView resetImage];
    _photoViewDelegate = nil;
}

#pragma mark - photoSetter
- (void)setPhoto:(PUPhoto *)photo {
    _photo = photo;
    
    [self showImage];
}

#pragma mark 显示图片
- (void)showImage
{    
    [self photoStartLoad];
    
    // 调整frame参数
    [self adjustFrame];
}

#pragma mark 开始加载图片
- (void)photoStartLoad
{
    UIImage  *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_photo.middleUrl];
    if (image) {
        self.scrollEnabled = YES;
        _imageView.image = image;
    } else {
        self.scrollEnabled = NO;
        // 直接显示进度条
        [_photoLoadingView showLoading];
        [self addSubview:_photoLoadingView];
                
        __weak PUPhotoView  *thisSelf = self;
        
        UIImage  *placeholder = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_photo.thumbnailUrl];
        if (placeholder == nil) {
            placeholder = [UIImage imageNamed:@"PUPhotoBrowser.bundle/icon_placeholder.png"];
        }
        
        [_imageView setImageWithURLString:_photo.middleUrl
                         placeholderImage:placeholder
                                  options:SDWebImageRetryFailed|SDWebImageLowPriority
                                 progress:^(NSUInteger receivedSize, long long expectedSize) {
                                     
                                     if (receivedSize > kMinProgress) {
                                         NSNumber  *percentValue = [NSNumber numberWithFloat:(float)receivedSize/expectedSize];
                                         PUPhotoView  *pView = thisSelf;
                                         [pView performSelectorOnMainThread:@selector(updateLoadingProgress:) withObject:percentValue waitUntilDone:YES];
                                         
                                     }
                                 } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     PUPhotoView  *photoView = thisSelf;
                                     [photoView photoDidFinishLoadWithImage:image];
                                 }];
    }
}

- (void)updateLoadingProgress:(NSNumber *)progress
{
    _photoLoadingView.progress = [progress floatValue];
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image) {
        self.scrollEnabled = YES;
        [_photoLoadingView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    } else {
        [self addSubview:_photoLoadingView];
        [_photoLoadingView showFailure];
    }
    
    // 设置缩放比例
    [self adjustFrame];
}
#pragma mark 调整frame
- (void)adjustFrame
{
	if (_imageView.image == nil) return;
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
	
	// 设置伸缩比例
    CGFloat minScale = boundsWidth / imageWidth;
	if (minScale > 1) {
		minScale = 1.0;
	}
	CGFloat maxScale = 2.0;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    // 内容尺寸
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    // y值
    if (imageFrame.size.height < boundsHeight) {
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
	} else {
        imageFrame.origin.y = 0;
	}
    _imageView.frame = imageFrame;

}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

#pragma mark - 手势处理
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = NO;
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.0];

}


- (void)hide
{
    if (_doubleTap) {
        return;
    }
    
    // 移除进度条
    [_photoLoadingView removeFromSuperview];
    self.contentOffset = CGPointZero;
    
    [_imageView resetImage];
    // 通知代理
    if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        [self.photoViewDelegate photoViewSingleTap:self];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = YES;
    
    CGPoint touchPoint = [tap locationInView:self];
	if (self.zoomScale == self.maximumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
	}
}

@end
