//
//  PUPhotoBrowserView.h
//  PUDemo
//
//  Created by JK.Peng on 13-11-3.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PUPhotoBrowserView : UIView

@property (nonatomic, strong) NSArray    *photosArray;
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

- (void)showFromView:(UIView *)fromView;

@end
