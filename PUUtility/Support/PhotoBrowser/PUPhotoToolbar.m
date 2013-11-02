//
//  PUPhotoToolbar.m
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "PUPhotoToolbar.h"
#import "PUPhoto.h"
#import "MBProgressHUD+Addition.h"
#import "SDImageCache.h"

@interface PUPhotoToolbar (){
    // 显示页码
    UILabel *_indexLabel;
    UIButton *_saveImageBtn;
}

@property (nonatomic, strong) UILabel   *indexLabel;
@property (nonatomic, strong) UIButton  *saveImageBtn;

@end

@implementation PUPhotoToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self addSubview:self.indexLabel];
        [self addSubview:self.saveImageBtn];
    }
    return self;
}

- (void)saveImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PUPhoto *photo = [_photos objectAtIndex:_currentPhotoIndex];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photo.middleUrl];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD showSuccess:@"保存失败" toView:nil];
    } else {
        PUPhoto *photo = [_photos objectAtIndex:_currentPhotoIndex];
        photo.save = YES;
        self.saveImageBtn.enabled = NO;
        [MBProgressHUD showSuccess:@"成功保存到相册" toView:nil];
    }
}

#pragma mark - setter
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    // 更新页码
    self.indexLabel.text = [NSString stringWithFormat:@"%lu / %lu", _currentPhotoIndex + 1, (unsigned long)_photos.count];
    
    PUPhoto *photo = [_photos objectAtIndex:_currentPhotoIndex];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photo.middleUrl];
    // 按钮
    self.saveImageBtn.enabled = (image != nil && !photo.save);
}

#pragma mark - getter
- (UILabel *)indexLabel{
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] initWithFrame:self.bounds];
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
        _saveImageBtn.frame = CGRectMake(20, floor((CGRectGetHeight(self.frame)-img.size.height)/2), img.size.width, img.size.height);
        _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_saveImageBtn setImage:img forState:UIControlStateNormal];
        [_saveImageBtn setImage:[UIImage imageNamed:@"PUPhotoBrowser.bundle/save_icon_highlighted.png"] forState:UIControlStateHighlighted];
        [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveImageBtn;
}

@end
