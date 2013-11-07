//
//  PUPhoto.h
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUPhoto : NSObject

@property (nonatomic, strong) NSString  *middleUrl;
@property (nonatomic, strong) NSString  *thumbnailUrl;

// 是否已经保存到相册
@property (nonatomic, assign) BOOL save;
@property (nonatomic, assign) NSInteger index; // 索引

@end
