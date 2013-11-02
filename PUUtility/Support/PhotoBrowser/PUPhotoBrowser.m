//
//  PUPhotoBrowser.m
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "PUPhotoBrowser.h"
#import <QuartzCore/QuartzCore.h>
#import "PUPhoto.h"
#import "PUPhotoView.h"
#import "PUPhotoToolbar.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "MBProgressHUD+Addition.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface PUPhotoBrowser ()<PUPhotoViewDelegate>{
    // 所有的图片view
	NSMutableSet *_visiblePhotoViews;
    NSMutableSet *_reusablePhotoViews;
    
    // 一开始的状态栏
    BOOL _statusBarHiddenInited;
    
    CGRect    _fromRect;

}

@property (nonatomic, strong) UIScrollView   *photoScrollView;
@property (nonatomic, strong) PUPhotoToolbar *toolbar;

@end

@implementation PUPhotoBrowser

- (void)dealloc{
    self.photoScrollView = nil;
    self.toolbar = nil;
    self.photos = nil;
    _visiblePhotoViews = nil;
    _reusablePhotoViews = nil;
}

#pragma mark - Lifecycle
- (void)loadView{
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)showFromView:(UIView *)fromView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self.view.alpha = 0.0f;
    self.view.frame = [fromView convertRect:fromView.bounds toView:window];
    _fromRect = self.view.frame;
    [window addSubview:self.view];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = window.bounds;
                         self.view.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         [window.rootViewController addChildViewController:self];
                         [self showPhotos];
                     }];


}


#pragma mark - PUPhotoViewDelegate
- (void)photoViewSingleTap:(PUPhotoView *)photoView
{
    self.view.alpha = 1.0f;
    
//    UIView *toView = [UIApplication sharedApplication].keyWindow;
    
//    CGRect toRect = _fromRect;
//    toRect.origin = CGPointMake((toView.bounds.size.width-toRect.size.width)/2,
//                                (toView.bounds.size.height-toRect.size.height)/2);
    
    __weak UIView  *myView = self.view;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         myView.frame = _fromRect;
                         myView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
                         myView.backgroundColor = [UIColor clearColor];
                         
                         // 移除工具条
//                         [_toolbar removeFromSuperview];
                         
//                         [myView removeFromSuperview];
//                         [self removeFromParentViewController];
                     }];
    
    
//    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
//    self.view.backgroundColor = [UIColor clearColor];
//    
//    // 移除工具条
//    [_toolbar removeFromSuperview];
//    
//    [self.view removeFromSuperview];
//    [self removeFromParentViewController];
}

- (void)photoViewImageFinishLoad:(PUPhotoView *)photoView
{
    self.toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - 显示照片
- (void)showPhotos
{
    // 只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
	NSInteger firstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
	NSInteger lastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = _photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = _photos.count - 1;
	
	// 回收不再显示的ImageView
    NSInteger photoViewIndex;
	for (PUPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
		if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
			[_reusablePhotoViews addObject:photoView];
			[photoView removeFromSuperview];
		}
	}
    
	[_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
	
	for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
		if (![self isShowingPhotoViewAtIndex:index]) {
			[self showPhotoViewAtIndex:index];
		}
	}
}

#pragma mark - 显示一个图片view
- (void)showPhotoViewAtIndex:(NSInteger)index
{
    PUPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[PUPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    PUPhoto *photo = [_photos objectAtIndex:index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visiblePhotoViews addObject:photoView];
    [self.photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

#pragma mark - 加载index附近的图片
- (void)loadImageNearIndex:(NSInteger)index
{
    if (index > 0) {
        PUPhoto *photo = [_photos objectAtIndex:index-1];
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:photo.middleUrl]
                                                   options:SDWebImageRetryFailed|SDWebImageLowPriority
                                                  progress:^(NSUInteger receivedSize, long long expectedSize) {
                                                  } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                  }];
    }
    
    if (index < _photos.count - 1) {
        PUPhoto *photo = [_photos objectAtIndex:index + 1];
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:photo.middleUrl]
                                                   options:SDWebImageRetryFailed|SDWebImageLowPriority
                                                  progress:^(NSUInteger receivedSize, long long expectedSize) {
                                                  } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                  }];
    }
}

#pragma mark - index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
	for (PUPhotoView *photoView in _visiblePhotoViews) {
		if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
	return  NO;
}

- (PUPhotoView *)photoViewAtIndex:(NSUInteger)index
{
    for (PUPhotoView *photoView in _visiblePhotoViews) {
		if (kPhotoViewIndex(photoView) == index) {
            return photoView;
        }
    }
    return nil;
}

#pragma mark - 循环利用某个view
- (PUPhotoView *)dequeueReusablePhotoView
{
    PUPhotoView *photoView = [_reusablePhotoViews anyObject];
	if (photoView) {
		[_reusablePhotoViews removeObject:photoView];
	}
	return photoView;
}

#pragma mark - 更新toolbar状态
- (void)updateTollbarState
{
    _currentPhotoIndex = self.photoScrollView.contentOffset.x / self.photoScrollView.frame.size.width;
    self.toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self showPhotos];
    [self updateTollbarState];
}

#pragma mark - getter/setter
- (PUPhotoToolbar *)toolbar{
    if (!_toolbar) {
        _toolbar = [[PUPhotoToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:_toolbar];
    }
    return _toolbar;
}

- (UIScrollView *)photoScrollView{
    if (!_photoScrollView) {
        CGRect frame = self.view.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_photoScrollView];
    }
    return _photoScrollView;
}

- (void)setPhotos:(NSArray *)photos{
    _photos = photos;
    
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    
    for (int i = 0; i<_photos.count; i++) {
        PUPhoto *photo = [_photos objectAtIndex:i];
        photo.index = i;
        photo.firstShow = (i == _currentPhotoIndex);
    }
    
    self.photoScrollView.contentSize = CGSizeMake(self.photoScrollView.frame.size.width * _photos.count, 0);
    self.photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * self.photoScrollView.frame.size.width, 0);
    self.toolbar.photos = _photos;
    self.toolbar.currentPhotoIndex = _currentPhotoIndex;
    [self updateTollbarState];
    
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    for (int i = 0; i<_photos.count; i++) {
        PUPhoto *photo = [_photos objectAtIndex:i];
        photo.firstShow = (i == currentPhotoIndex);
    }
    
    if ([self isViewLoaded]) {
        self.photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}

@end
