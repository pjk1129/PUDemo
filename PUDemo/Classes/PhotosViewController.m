//
//  PhotosViewController.m
//  PUDemo
//
//  Created by JK.Peng on 13-11-2.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "PhotosViewController.h"
#import "PUPhoto.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "PUPhotoBrowserView.h"

@interface PhotosViewController ()<PUPhotoBrowserViewDelegate>

@property (nonatomic, strong) NSArray   *urlArray;

@end

@implementation PhotosViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"图片列表";
    
    // 0.图片链接
    _urlArray = @[@"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"];
    
	// 1.创建9个UIImageView
    UIImage *placeholder = [UIImage imageNamed:@"timeline_image_loading.png"];
    CGFloat width = 70;
    CGFloat height = 70;
    CGFloat margin = 20;
    CGFloat startX = (self.view.frame.size.width - 3 * width - 2 * margin) * 0.5;
    CGFloat startY = 100;
    for (int i = 0; i<[_urlArray count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.view addSubview:imageView];
        
        // 计算位置
        int row = i/3;
        int column = i%3;
        CGFloat x = startX + column * (width + margin);
        CGFloat y = startY + row * (height + margin);
        imageView.frame = CGRectMake(x, y, width, height);
        
        // 下载图片
        [imageView setImageWithURLString:_urlArray[i] placeholderImage:placeholder];
        // 事件监听
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
        
        // 内容模式
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
}


- (void)tapImage:(UITapGestureRecognizer *)tap
{
    NSInteger count = _urlArray.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [[_urlArray objectAtIndex:i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        PUPhoto *photo = [[PUPhoto alloc] init];
        photo.middleUrl = url; // 图片路径
        photo.thumbnailUrl = [_urlArray objectAtIndex:i];
        [photos addObject:photo];
    }


    
    PUPhotoBrowserView  *photoBrowser = [[PUPhotoBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    photoBrowser.currentPhotoIndex = tap.view.tag;
    photoBrowser.photosArray = photos;
    photoBrowser.delegate = self;
    [photoBrowser showFromView:tap.view];
}

#pragma mark - PUPhotoBrowserDelegate
- (void)photoBrowser:(PUPhotoBrowserView *)photoBrowser pageAtCurrentIndex:(NSUInteger)index;
{
    NSLog(@"%lu",index);
    
}


@end
