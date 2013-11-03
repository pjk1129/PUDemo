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
#import "LolayGridView.h"
#import "PhotoViewCell.h"

#define GRID_COLUMNS 3
#define GRID_HEIGHT 105
#define GRID_WEIDTH 105

@interface PhotosViewController ()<PUPhotoBrowserViewDelegate,LolayGridViewDataSource,LolayGridViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray   *urlArray;
@property (nonatomic, strong) LolayGridView *gridView;

@end

@implementation PhotosViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"图片列表";
    
    // 0.图片链接
    NSArray  *array = @[@"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",@"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",@"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"];
    
    self.urlArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i<[array count]; i++) {
        // 替换为中等尺寸图片
        NSString *url = [[array objectAtIndex:i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        PUPhoto *photo = [[PUPhoto alloc] init];
        photo.middleUrl = url; // 图片路径
        photo.thumbnailUrl = [array objectAtIndex:i];
        [self.urlArray addObject:photo];
    }
    
    [self.gridView reloadData];
    
}

#pragma mark - PUPhotoBrowserDelegate
- (void)photoBrowser:(PUPhotoBrowserView *)photoBrowser pageAtCurrentIndex:(NSUInteger)index;
{
    NSLog(@"%lu",index);
    
}

#pragma mark - getter
- (LolayGridView *)gridView{
    if (!_gridView) {
        _gridView = [[LolayGridView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
        _gridView.clipsToBounds = YES;
        _gridView.backgroundColor = [UIColor clearColor];
        _gridView.dataSource = self;
        _gridView.dataDelegate = self;
        _gridView.delegate = self;
        _gridView.showsHorizontalScrollIndicator = NO;
        _gridView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_gridView];
    }
    return _gridView;
}

#pragma mark- LolayGridViewDataSource
- (NSInteger)numberOfRowsInGridView:(LolayGridView*)gridView
{
    return ceil((CGFloat)_urlArray.count / (CGFloat)GRID_COLUMNS);
}

- (NSInteger)numberOfColumnsInGridView:(LolayGridView*)gridView
{
    return GRID_COLUMNS;
}

- (LolayGridViewCell*)gridView:(LolayGridView*)gridView cellForRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex
{
    NSInteger index = gridRowIndex*GRID_COLUMNS+gridColumnIndex;
    if (index>[self.urlArray count]-1) {
        return nil;
    }

    static NSString *gridViewIdentifier = @"gridViewIdentifier";
    PhotoViewCell *gridCell = (PhotoViewCell *)[gridView dequeueReusableGridCellWithIdentifier:gridViewIdentifier];
    if (!gridCell)
    {
        gridCell = [[PhotoViewCell alloc] initWithFrame:CGRectMake(0, 0, GRID_WEIDTH, GRID_HEIGHT) reuseIdentifier:gridViewIdentifier];
    }
    gridCell.photo = [self.urlArray objectAtIndex:index];
    return gridCell;
}

- (void)gridView:(LolayGridView*)gridView didReuseCell:(LolayGridViewCell*)gridCell
{
    
}


#pragma mark- LolayGridViewDelegate
- (CGFloat)heightForGridViewRows:(LolayGridView*)gridView
{
    return GRID_HEIGHT;
}

- (CGFloat)widthForGridViewColumns:(LolayGridView*)gridView
{
    return GRID_WEIDTH;
}


- (void)gridView:(LolayGridView*)gridView didSelectCellAtRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex
{
    NSInteger index = gridRowIndex*GRID_COLUMNS+gridColumnIndex;
    if (index < [self.urlArray count]) {
        
        PhotoViewCell  *cell = (PhotoViewCell *)[gridView cellForRow:gridRowIndex atColumn:gridColumnIndex];
        
        PUPhotoBrowserView  *photoBrowser = [[PUPhotoBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        photoBrowser.currentPhotoIndex = index;
        photoBrowser.photosArray = self.urlArray;
        photoBrowser.delegate = self;
        [photoBrowser showFromView:cell];
        
    }

}


- (UIView *)headerIndicatorViewForGridView:(LolayGridView *)gridView
{
    return nil;
}

-(UIView *)footerIndicatorViewForGridView:(LolayGridView *)gridView
{
    return nil;
}

- (UIView *)headerViewForGridView:(LolayGridView *)gridView
{
    return nil;
}

- (UIView *)footerViewForGridView:(LolayGridView *)gridView
{
    return nil;
}


@end
