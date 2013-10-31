//
//  PUHttpRequest.m
//  PUDemo
//
//  Created by JK.Peng on 13-10-31.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "PUHttpRequest.h"

#define DEBUG_USEPROXY 0


#ifdef DEBUG
#define PUHttpReq_Log(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define PUHttpReq_Log(xx, ...)  ((void)0)
#endif

@interface ASIHTTPRequest(protected)

- (void)releaseBlocksOnMainThread;
- (void)reportFinished;
- (void)reportFailure;

@end

@interface PUHttpRequest()

@end

@implementation PUHttpRequest

+ (PUHttpRequest *)requestWithURLStr:(NSString *)initURLString
                               param:(NSDictionary *)param
                          httpMethod:(HttpMethod)httpMethod
                              isAsyn:(BOOL)isAsyn
                     completionBlock:(ASIRequsetBlock)aCompletionBlock
                         failedBlock:(ASIRequsetBlock)aFailedBlock{
    
    return [self requestWithURLStr:initURLString
                             param:param
                        httpMethod:httpMethod
                            isAsyn:isAsyn
                          userInfo:nil
                   completionBlock:aCompletionBlock
                       failedBlock:aFailedBlock];
    
}

+ (PUHttpRequest*)requestWithURLStr:(NSString *)initURLString
                              param:(NSDictionary *)param
                         httpMethod:(HttpMethod)httpMethod
                             isAsyn:(BOOL)isAsyn
                           userInfo:(NSDictionary*)userInfo
                    completionBlock:(ASIRequsetBlock)aCompletionBlock
                        failedBlock:(ASIRequsetBlock)aFailedBlock
{

    
    NSMutableDictionary  *mParams = [PUHttpRequest commonParams];
    [mParams addEntriesFromDictionary:param];
    
    PUHttpRequest *aRequest = [[PUHttpRequest alloc] initWithURL:nil];
    
    // https请求，不验证证书的有效性
    [aRequest setValidatesSecureCertificate:NO];
    
    // 设置超时时间
    [aRequest setTimeOutSeconds:30];
    
    //添加userInfo
    [aRequest setUserInfo:userInfo];
    
#if DEBUG_USEPROXY
    // 设置请求代理
    aRequest.proxyHost = @"127.0.0.1";
    aRequest.proxyPort = 8080;
#endif
    
    NSString *requestUrlStr = initURLString;
    if (httpMethod==HttpMethodPost) {
        [aRequest setRequestMethod:@"POST"];
        
        [mParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSURL class]]) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:[(NSURL *)obj path]]) {
                    // 添加上传的文件
                    [aRequest addFile:[(NSURL*)obj path] forKey:key];
                }
            }else if ([obj isKindOfClass:[UIImage class]]){
                // 添加上传的图片
                NSString *fileName = [key hasSuffix:@".png"] ? key : [NSString stringWithFormat:@"%@.png", key];
                [aRequest addData:UIImagePNGRepresentation(obj) withFileName:fileName andContentType:@"image/png" forKey:key];
            }else{
                [aRequest addPostValue:obj forKey:key];
            }
        }];
    }else if(httpMethod==HttpMethodGet) {
        [aRequest setRequestMethod:@"GET"];
        
        NSMutableString *postString = [NSMutableString stringWithCapacity:0];
        [mParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj respondsToSelector:@selector(stringValue)]) {
                obj = [obj stringValue];
            }
            if ([obj isKindOfClass:[NSString class]]) {
                [postString appendString:[NSString stringWithFormat:@"%@=%@&", key, obj] ];
            }
        }];
        
        NSInteger questLocation = [initURLString rangeOfString:@"?"].location;
        if (NSNotFound!=questLocation) {
            requestUrlStr = [NSString stringWithFormat:@"%@%@", initURLString, postString];
        }else{
            requestUrlStr = [NSString stringWithFormat:@"%@?%@", initURLString, postString];
        }
    }else if(httpMethod==HttpMethodDelete) {
        [aRequest setRequestMethod:@"DELETE"];
        
        if (mParams&&[mParams count]>0) {
            NSMutableString *postStr = [NSMutableString stringWithCapacity:0];
            [mParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj respondsToSelector:@selector(stringValue)]) {
                    obj = [obj stringValue];
                }
                if ([obj isKindOfClass:[NSString class]]) {
                    [postStr appendString:[NSString stringWithFormat:@"%@=%@&", key, obj] ];
                }
            }];
            
            [aRequest appendPostData:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    
    [aRequest setURL:[NSURL URLWithString:requestUrlStr]];
    
    [aRequest setCompletionReqBlock:aCompletionBlock];
    [aRequest setFailedReqBlock:aFailedBlock];
    
    
    if (isAsyn) {
        [aRequest startAsynchronous];
    }else{
        [aRequest startSynchronous];
    }
    
#if DEBUG
    if (httpMethod==HttpMethodGet) {
        PUHttpReq_Log(@"URL:%@", requestUrlStr);
    }else{
        NSString *postStr = [[NSString alloc] initWithData:aRequest.postBody encoding:NSUTF8StringEncoding];
        PUHttpReq_Log(@"URL:%@, params(POST):%@", requestUrlStr, postStr);
    }
#endif
    return aRequest;
}


#if NS_BLOCKS_AVAILABLE
- (void)setCompletionReqBlock:(ASIRequsetBlock)aCompletionBlock{
	_completionReqBlock = [aCompletionBlock copy];
}

- (void)setFailedReqBlock:(ASIRequsetBlock)aFailedBlock{
	_failureReqBlock = [aFailedBlock copy];
}


- (void)releaseBlocksOnMainThread
{
	NSMutableArray *blocks = [NSMutableArray array];
	if (_completionReqBlock) {
		[blocks addObject:_completionReqBlock];
		_completionReqBlock = nil;
	}
	if (_failureReqBlock) {
		[blocks addObject:_failureReqBlock];
		_failureReqBlock = nil;
	}
    
    [[self class] performSelectorOnMainThread:@selector(releaseBlocks:) withObject:blocks waitUntilDone:[NSThread isMainThread]];
    [super releaseBlocksOnMainThread];
}

#endif


- (void)handleSessionTimeout
{
    // session失效，通知观察者    
}

- (void)reportFinished
{
#if NS_BLOCKS_AVAILABLE
	if(_completionReqBlock){
		_completionReqBlock(self);
	}
    
    [self handleSessionTimeout];
#endif
    [super reportFinished];
}

- (void)reportFailure
{
#if NS_BLOCKS_AVAILABLE
    if(_failureReqBlock){
        _failureReqBlock(self);
    }
    [self handleSessionTimeout];
    
#endif
    [super reportFailure];
}

#pragma mark - getter/setter
+ (NSMutableDictionary *)commonParams
{
    NSMutableDictionary *commonParams = [NSMutableDictionary dictionaryWithCapacity:0];
    
    return commonParams;
}

@end
