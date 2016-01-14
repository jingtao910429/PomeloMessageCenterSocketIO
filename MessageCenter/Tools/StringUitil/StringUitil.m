//
//  StringUitil.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/19.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "StringUitil.h"

@implementation StringUitil

+ (BOOL)stringIsNull:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if (!string || [string isKindOfClass:[NSNull class]] || string.length == 0 || [string isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)stringIsAllWhiteSpace:(NSString *)string
{
    if ([self stringIsNull:string]) {
        return YES;
    }else{
        
        NSString *trimString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (trimString.length > 0) {
            return NO;
        }else{
            return YES;
        }
    }
}



@end
