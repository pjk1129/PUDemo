//
//  TestManager.h
//  PUDemo
//
//  Created by JK.Peng on 13-11-3.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TestManagerDelegate <NSObject>

@optional
- (void)testManagerAPIStrollSuggestDidSuccess:(NSArray *)result;

@end

@interface TestManager : NSObject

@property (nonatomic, weak) id<TestManagerDelegate> delegate;

- (void)requestApiStrollSuggest;
@end
