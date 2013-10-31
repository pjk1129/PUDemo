//
//  PUHttpRequest.h
//  PUDemo
//
//  Created by JK.Peng on 13-10-31.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "ASIFormDataRequest.h"

typedef enum HttpMethod{
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodDelete,
}HttpMethod;

#if NS_BLOCKS_AVAILABLE
typedef void (^ASIRequsetBlock)(ASIHTTPRequest *request);
#endif

@interface PUHttpRequest : ASIFormDataRequest{
    //带ASIHttprequest对象的block
	ASIRequsetBlock _completionReqBlock;
	ASIRequsetBlock _failureReqBlock;
}


+ (PUHttpRequest *)requestWithURLStr:(NSString *)initURLString
                               param:(NSDictionary *)param
                          httpMethod:(HttpMethod)httpMethod
                              isAsyn:(BOOL)isAsyn
                     completionBlock:(ASIRequsetBlock)aCompletionReqBlock
                         failedBlock:(ASIRequsetBlock)aFailedReqBlock;

+ (PUHttpRequest*)requestWithURLStr:(NSString *)initURLString
                              param:(NSDictionary *)param
                         httpMethod:(HttpMethod)httpMethod
                             isAsyn:(BOOL)isAsyn
                           userInfo:(NSDictionary*)userInfo
                    completionBlock:(ASIRequsetBlock)aCompletionReqBlock
                        failedBlock:(ASIRequsetBlock)aFailedReqBlock;

+ (NSMutableDictionary *)commonParams;

#if NS_BLOCKS_AVAILABLE
- (void)setCompletionReqBlock:(ASIRequsetBlock)aCompletionBlock;
- (void)setFailedReqBlock:(ASIRequsetBlock)aFailedBlock;
#endif

@end
