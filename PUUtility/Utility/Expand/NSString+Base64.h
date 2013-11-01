//
//  NSString+Base64.h
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

+ (NSString *)base64StringFromData:(NSData *)data length:(NSUInteger)length;

@end
