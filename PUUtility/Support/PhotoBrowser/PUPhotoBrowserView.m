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
#import "PUPhotoView.h"

#define kPBVPadding 10

#define kFramePrePhotoView    CGRectMake(kPBVPadding, 0, CGRectGetWidth(self.photoScrollView.frame)-2*kPBVPadding, CGRectGetHeight(self.photoScrollView.frame))
#define kFrameCurPhotoView    CGRectMake(kPBVPadding+CGRectGetWidth(self.photoScrollView.frame), 0, CGRectGetWidth(self.photoScrollView.frame)-2*kPBVPadding, CGRectGetHeight(self.photoScrollView.frame))
#define kFrameNextPhotoView   CGRectMake(kPBVPadding+2*CGRectGetWidth(self.photoScrollView.frame), 0, CGRectGetWidth(self.photoScrollView.frame)-2*kPBVPadding, CGRectGetHeight(self.photoScrollView.frame))


@interface PUPhotoBrowserView ()<UIScrollViewDelegate,PUPhotoViewDelegate>{
    
    BOOL      _statusBarHiddenInited;
    CGRect    _fromRect;
}

@property (nonatomic, strong) UIScrollView   *photoScrollView;
@property (nonatomic, strong) UIView         *toolBarView;
@property (nonatomic, strong) UILabel        *indexLabel;
@property (nonatomic, strong) UIButton       *saveImageBtn;
@property (nonatomic, strong) PUPhotoView    *prePhotoView;
@property (nonatomic, strong) PUPhotoView    *curPhotoView;
@property (nonatomic, strong) PUPhotoView    *nextPhotoView;

@end

@implementation PUPhotoBrowserView

- (void)dealloc{
    [_prePhotoView resetPhotoView];
    [_curPhotoView resetPhotoView];
    [_nextPhotoView resetPhotoView];
    _prePhotoView = nil;
    _curPhotoView = nil;
    _nextPhotoView = nil;
    
    self.photosArray = nil;
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
    _fromRect = [fromView convertRect:fromView.bounds toView:nil];
    self.alpha = 0.0f;
    self.frame = _fromRect;
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

#pragma mark - PUPhotoViewDelegate
- (void)photoViewSingleTap:(PUPhotoView *)photoView
{
    
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    [_prePhotoView resetPhotoView];
    [_curPhotoView resetPhotoView];
    [_nextPhotoView resetPhotoView];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         self.frame = _fromRect;
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];

                     }];
    
    
}

- (void)photoViewImageFinishLoad:(PUPhotoView *)photoView
{
    self.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    
    //scrollview结束滚动时判断是否已经换页
	if (self.photoScrollView.contentOffset.x > self.photoScrollView.bounds.size.width) {
        [self nextPage];
        
	} else if (self.photoScrollView.contentOffset.x < self.photoScrollView.bounds.size.width) {
        [self forwardPage];
	}
}

- (void)nextPage
{
    PUPhotoView  *temp = nil;
    temp = self.curPhotoView;
    self.curPhotoView = self.nextPhotoView;
    self.nextPhotoView = self.prePhotoView;
    self.prePhotoView = temp;
    
    self.prePhotoView.frame = kFramePrePhotoView;
    self.curPhotoView.frame = kFrameCurPhotoView;
    self.nextPhotoView.frame = kFrameNextPhotoView;
    
    [self.photoScrollView setContentOffset:CGPointMake(self.photoScrollView.bounds.size.width, 0.0)];
    
    if (self.currentPhotoIndex >= [_photosArray count]-1) {
        self.currentPhotoIndex = 0;
    }else{
        self.currentPhotoIndex = self.currentPhotoIndex+1;
    }
    
    [self loadImageNearIndex:self.currentPhotoIndex];
}

- (void)forwardPage
{
    PUPhotoView  *temp = nil;
    temp = self.curPhotoView;
    self.curPhotoView = self.prePhotoView;
    self.prePhotoView = self.nextPhotoView;
    self.nextPhotoView = temp;
    
    self.prePhotoView.frame = kFramePrePhotoView;
    self.curPhotoView.frame = kFrameCurPhotoView;
    self.nextPhotoView.frame = kFrameNextPhotoView;

    [self.photoScrollView setContentOffset:CGPointMake(self.photoScrollView.bounds.size.width, 0.0)];
    
    if (self.currentPhotoIndex <= 0) {
        self.currentPhotoIndex = [_photosArray count]-1;
    }else{
        self.currentPhotoIndex = self.currentPhotoIndex-1;
    }
    
    [self loadImageNearIndex:self.currentPhotoIndex];

}

- (void)loadImageNearIndex:(NSInteger)index
{
    PUPhoto *preObj = nil;
    PUPhoto *nextObj = nil;
    if (index <= 0) {
        preObj = [_photosArray lastObject];
        nextObj = [_photosArray objectAtIndex:_currentPhotoIndex+1];
    }else if(index >= [_photosArray count]-1){
        preObj = [_photosArray objectAtIndex:_currentPhotoIndex - 1];
        nextObj = [_photosArray objectAtIndex:0];
    }else{
        preObj = [_photosArray objectAtIndex:_currentPhotoIndex-1];
        nextObj = [_photosArray objectAtIndex:_currentPhotoIndex + 1];
    }
    self.prePhotoView.photo = preObj;
    self.nextPhotoView.photo = nextObj;
    
    if ([_delegate respondsToSelector:@selector(photoBrowser:pageAtCurrentIndex:)]) {
        [_delegate photoBrowser:self pageAtCurrentIndex:index];
    }
}

#pragma mark - setter
- (void)setPhotosArray:(NSArray *)photosArray{
    _photosArray = photosArray;
    
    [[_photoScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if ([_photosArray count]>0) {
        if ([_photosArray count]==1) {
            _currentPhotoIndex = 0;
            self.curPhotoView.frame = kFrameCurPhotoView;
            [self.photoScrollView addSubview:self.curPhotoView];
            
        }else if([_photosArray count]>1){
            self.prePhotoView.frame = kFramePrePhotoView;
            self.curPhotoView.frame = kFrameCurPhotoView;
            self.nextPhotoView.frame = kFrameNextPhotoView;
            
            [self.photoScrollView addSubview:self.prePhotoView];
            [self.photoScrollView addSubview:self.curPhotoView];
            [self.photoScrollView addSubview:self.nextPhotoView];
            
            PUPhoto *preObj = nil;
            PUPhoto *nextObj = nil;
            if (_currentPhotoIndex <= 0) {
                _currentPhotoIndex = 0;
                preObj = [_photosArray lastObject];
                nextObj = [_photosArray objectAtIndex:_currentPhotoIndex+1];
            }else if(_currentPhotoIndex >= [_photosArray count]-1){
                _currentPhotoIndex = [_photosArray count]-1;
                preObj = [_photosArray objectAtIndex:_currentPhotoIndex - 1];
                nextObj = [_photosArray objectAtIndex:0];
            }else{
                preObj = [_photosArray objectAtIndex:_currentPhotoIndex-1];
                nextObj = [_photosArray objectAtIndex:_currentPhotoIndex + 1];
            }
            self.prePhotoView.photo = preObj;
            self.nextPhotoView.photo = nextObj;
        }
        
        self.curPhotoView.photo = [_photosArray objectAtIndex:_currentPhotoIndex];

        self.currentPhotoIndex = _currentPhotoIndex;
        
        if ([_photosArray count]<=1) {
            self.photoScrollView.contentOffset = CGPointMake(0, 0);
            self.photoScrollView.contentSize = CGSizeMake(self.photoScrollView.bounds.size.width,
                                                       self.photoScrollView.bounds.size.height);
        }else{
            self.photoScrollView.contentOffset = CGPointMake(self.photoScrollView.bounds.size.width, 0);
            self.photoScrollView.contentSize = CGSizeMake(3*self.photoScrollView.bounds.size.width,
                                                       self.photoScrollView.bounds.size.height);
        }
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex{
    _currentPhotoIndex = currentPhotoIndex;
    
    if ([_photosArray count]>0) {
        self.indexLabel.text = [NSString stringWithFormat:@"%u / %lu", _currentPhotoIndex + 1, (unsigned long)_photosArray.count];

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

- (PUPhotoView *)prePhotoView{
    if (!_prePhotoView) {
        _prePhotoView = [[PUPhotoView alloc] initWithFrame:kFramePrePhotoView];
        _prePhotoView.photoViewDelegate = self;
        _prePhotoView.userInteractionEnabled = YES;
    }
    return _prePhotoView;
}
- (PUPhotoView *)curPhotoView{
    if (!_curPhotoView) {
        _curPhotoView = [[PUPhotoView alloc] initWithFrame:kFrameCurPhotoView];
        _curPhotoView.photoViewDelegate = self;
        _curPhotoView.userInteractionEnabled = YES;
    }
    return _curPhotoView;
}
- (PUPhotoView *)nextPhotoView{
    if (!_nextPhotoView) {
        _nextPhotoView = [[PUPhotoView alloc] initWithFrame:kFrameNextPhotoView];
        _nextPhotoView.photoViewDelegate = self;
        _nextPhotoView.userInteractionEnabled = YES;
    }
    return _nextPhotoView;
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
