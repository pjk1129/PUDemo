//
//  PUPhotoBrowserView.m
//  PUDemo
//
//  Created by JK.Peng on 13-11-3.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "PUPhotoBrowserView.h"
#import "MBProgressHUD+Addition.h"
#import "PUPhoto.h"
#import "SDImageCache.h"

#define kPBVPadding 10

@interface PUPhotoBrowserView ()<UIScrollViewDelegate>{
    
    BOOL      _statusBarHiddenInited;
    CGRect    _fromRect;
}

@property (nonatomic, strong) UIScrollView   *photoScrollView;
@property (nonatomic, strong) UIView         *toolBarView;
@property (nonatomic, strong) UILabel        *indexLabel;
@property (nonatomic, strong) UIButton       *saveImageBtn;

@end

@implementation PUPhotoBrowserView

- (void)dealloc{
    self.photosArray = nil;
    
    for (UIView  *v in [self.photoScrollView subviews]) {
        [v removeFromSuperview];
    }
    self.photoScrollView = nil;
    self.indexLabel = nil;
    self.saveImageBtn = nil;
    self.toolBarView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.9];
        
        [self addSubview:self.photoScrollView];
        [self addSubview:self.toolBarView];
        [self.toolBarView addSubview:self.indexLabel];
        [self.toolBarView addSubview:self.saveImageBtn];
    }
    return self;
}

- (void)showFromView:(UIView *)fromView
{
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self.alpha = 0.0f;
    self.frame = [fromView convertRect:fromView.bounds toView:window];
    _fromRect = self.frame;
    [window addSubview:self];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = window.bounds;
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    [self updateTollbarState];
}

- (void)updateTollbarState
{
    _currentPhotoIndex = self.photoScrollView.contentOffset.x / self.photoScrollView.frame.size.width;
    self.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - setter
- (void)setPhotosArray:(NSArray *)photosArray{
    _photosArray = photosArray;
    
    
    self.currentPhotoIndex = _currentPhotoIndex;
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex{
    _currentPhotoIndex = currentPhotoIndex;
    
    if ([_photosArray count]>0) {
        self.indexLabel.text = [NSString stringWithFormat:@"%lu / %lu", _currentPhotoIndex + 1, (unsigned long)_photosArray.count];

    }
}

#pragma mark - getter
- (UIScrollView *)photoScrollView{
    if (!_photoScrollView) {
        CGRect frame = self.bounds;
        frame.origin.x -= kPBVPadding;
        frame.size.width += (2 * kPBVPadding);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
    }
    return _photoScrollView;
}

- (UIView *)toolBarView{
    if (!_toolBarView) {
        _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44)];
        _toolBarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _toolBarView.backgroundColor = [UIColor clearColor];
        
    }
    return _toolBarView;
}

- (UILabel *)indexLabel{
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] initWithFrame:self.toolBarView.bounds];
        _indexLabel.font = [UIFont systemFontOfSize:20];
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _indexLabel;
}

- (UIButton *)saveImageBtn{
    if (!_saveImageBtn) {
        // 保存图片按钮
        UIImage  *img = [UIImage imageNamed:@"PUPhotoBrowser.bundle/save_icon.png"];
        _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveImageBtn.frame = CGRectMake(20, floor((CGRectGetHeight(self.toolBarView.frame)-img.size.height)/2), img.size.width, img.size.height);
        _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_saveImageBtn setImage:img forState:UIControlStateNormal];
        [_saveImageBtn setImage:[UIImage imageNamed:@"PUPhotoBrowser.bundle/save_icon_highlighted.png"] forState:UIControlStateHighlighted];
        [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveImageBtn;
}

#pragma mark - 保存图片
- (void)saveImage
{
    if (_currentPhotoIndex >=[_photosArray count]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PUPhoto *photo = [self.photosArray objectAtIndex:_currentPhotoIndex];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photo.middleUrl];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD showSuccess:@"保存失败" toView:nil];
    } else {
        PUPhoto *photo = [self.photosArray objectAtIndex:_currentPhotoIndex];
        photo.save = YES;
        self.saveImageBtn.enabled = NO;
        [MBProgressHUD showSuccess:@"成功保存到相册" toView:nil];
    }
}

@end
