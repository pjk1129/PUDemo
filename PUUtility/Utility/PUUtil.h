//
//  PUUtil.h
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUUtil : NSObject

#pragma mark - 获取Dictionary中的元素
+ (id)getElementForKey:(id)key fromDict:(NSDictionary *)dict;
+ (id)getElementForKey:(id)key fromDict:(NSDictionary *)dict forClass:(Class)forClass;

#pragma mark - 根据16进制获取UIColor
+ (UIColor *)getColorByHexadecimalColor:(NSString *)hexColor;

#pragma mark - UTF8 Encode
+ (NSString *)encodeUTF8Str:(NSString *)encodeStr;

#pragma mark - JSON Convert
+ (NSDictionary *)convertJSONToDict:(NSString *)string;
+ (BOOL)isSuccessWithReponseDic:(NSDictionary *)responseDic;

/*
 *  Dictionary or Array转换成JSON
 */
+ (NSString *)convertObjectToJSON:(id)object;

#pragma mark - String Utility
+ (NSString *)stringWithSourceString:(NSString *)aString;
+ (BOOL)stringIsNullAndEmpty:(NSString *)aString;

#pragma mark - NSArray Utility
+ (BOOL)arrayIsNullAndEmpty:(NSArray *)array;

#pragma mark - NSDictionary Utility
+ (BOOL)dictionaryIsNullAndEmpty:(NSDictionary *)dic;

@end
