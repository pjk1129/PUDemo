//
//  PUUtil.m
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "PUUtil.h"

@implementation PUUtil

#pragma mark - 获取Dictionary中的元素
+ (id)getElementForKey:(id)key fromDict:(NSDictionary *)dict
{
    if(![dict isKindOfClass:[NSDictionary class]])
        return nil;
    
    id obj = [dict objectForKey:key];
    if ([obj isKindOfClass:[NSString class]] && [obj isEqual:@""]) {
        return nil; //空字符串
    } else if ([obj isKindOfClass:[NSNull class]]) {
        return nil; //空类
    }
    return obj;
}

+ (id)getElementForKey:(id)key fromDict:(NSDictionary *)dict forClass:(Class)forClass
{
    if(![dict isKindOfClass:[NSDictionary class]])
        return nil;
    
    id obj = [dict objectForKey:key];
    if ([obj isKindOfClass:forClass]) {
        if ([obj isKindOfClass:[NSString class]] && [obj isEqual:@""]) {
            return nil;
        } else {
            return obj;
        }
    }
    return nil;
}

#pragma mark - 根据16进制获取UIColor
+ (UIColor *)getColorByHexadecimalColor:(NSString *)hexColor
{
    unsigned int redInt_, greenInt_, blueInt_;
	NSRange rangeNSRange_;
	rangeNSRange_.length = 2;  // 范围长度为2
	
	// 取红色的值
	rangeNSRange_.location = 0;
	[[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]] scanHexInt:&redInt_];
    
	// 取绿色的值
	rangeNSRange_.location = 2;
	[[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]] scanHexInt:&greenInt_];
	
	// 取蓝色的值
	rangeNSRange_.location = 4;
	[[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]] scanHexInt:&blueInt_];
	
	return [UIColor colorWithRed:(float)(redInt_/255.0f) green:(float)(greenInt_/255.0f) blue:(float)(blueInt_/255.0f) alpha:1.0f];
    
}

#pragma mark - UTF8 Encode
+ (NSString *)encodeUTF8Str:(NSString *)encodeStr
{
    CFStringRef nonAlphaNumValidChars = CFSTR("![        DISCUZ_CODE_1        ]’()*+,-./:;=?@_~");
    CFStringRef  prepStrRef = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)encodeStr, CFSTR(""), kCFStringEncodingUTF8);
    NSString  *preprocessedString = (__bridge NSString *)prepStrRef;
    CFRelease(prepStrRef);
    
    CFStringRef  newStrRef = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)preprocessedString,NULL,nonAlphaNumValidChars,kCFStringEncodingUTF8);
    
    NSString *newStr = (__bridge NSString *)newStrRef;
    
    if (newStr) {
        return newStr;
    }
    return @"";
}

#pragma mark - JSON Convert
+ (NSDictionary *)convertJSONToDict:(NSString *)string
{
    NSError *error = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data || data == nil) {
        return nil;
    }
    NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (nil == error){
        return respDict;
    }else{
        return nil;
    }
}

+ (BOOL)isSuccessWithReponseDic:(NSDictionary *)responseDic;
{
    return NO;
}

+ (NSString *)convertObjectToJSON:(id)object;
{
    NSError *error = nil;
    NSData  *data = nil;
    if (object) {
        data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    }
    
    if (data == nil) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - String Utility
+ (NSString *)stringWithSourceString:(NSString *)aString
{
    if ([aString length]<=0) {
        return @"";
    }
    
    return aString;
}

+ (BOOL)stringIsNullAndEmpty:(NSString *)aString;
{
    if ([aString length]<=0) {
        return YES;
    }
    return NO;
}

#pragma mark - NSArray Utility
+ (BOOL)arrayIsNullAndEmpty:(NSArray *)array
{
    if (array == nil || [array count]<=0) {
        return YES;
    }
    return NO;
}

#pragma mark - NSDictionary Utility
+ (BOOL)dictionaryIsNullAndEmpty:(NSDictionary *)dic
{
    if (dic == nil || [dic count]<=0) {
        return YES;
    }
    return NO;
}

@end
