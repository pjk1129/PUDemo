//
//  TestManager.m
//  PUDemo
//
//  Created by JK.Peng on 13-11-3.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "TestManager.h"
#import "PUHttpRequest.h"
#import "APIDefine.h"
#import "PUUtil.h"
#import "QiuShi.h"

@implementation TestManager


- (void)requestApiStrollSuggest
{
    [PUHttpRequest requestWithURLStr:api_stroll_suggest(30, 1)
                               param:nil
                          httpMethod:HttpMethodGet
                              isAsyn:YES
                     completionBlock:^(ASIHTTPRequest *request) {
                         NSDictionary  *dic = [PUUtil convertJSONToDict:request.responseString];
                         
                         NSArray *array = [dic objectForKey:@"items"];
                         NSMutableArray  *strollArray = [NSMutableArray arrayWithCapacity:[array count]];
                         for (int i = 0; i < [array count]; i++) {
                             NSDictionary *qiushiDic = [array objectAtIndex:i];
                             QiuShi *qs = [[QiuShi alloc] initWithQiuShiDictionary:qiushiDic];
                             [strollArray addObject:qs];
                         }
                         if ([_delegate respondsToSelector:@selector(testManagerAPIStrollSuggestDidSuccess:)]) {
                             [_delegate testManagerAPIStrollSuggestDidSuccess:strollArray];
                         }
                         
                     } failedBlock:^(ASIHTTPRequest *request) {
   
                     }];
}

@end
