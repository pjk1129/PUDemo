//
//  PUPhotoBrowser.h
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  PUPhotoBrowserDelegate;

@interface PUPhotoBrowser : UIViewController<UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<PUPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

// 显示
- (void)showFromView:(UIView *)fromView;
@end

@protocol PUPhotoBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(PUPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;
- (void)photoBrowserDidDone:(PUPhotoBrowser *)photoBrowser;

@end