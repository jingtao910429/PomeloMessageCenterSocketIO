//
//  AttLinkData.h
//  RongYu100
//
//  Created by xiaerfei on 15/11/16.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AttLinkDataType) {
    AttLinkDataTypePhoneNumber  = 0,
    AttLinkDataTypeURL          = 1,
    AttLinkDataTypeEmail        = 2,
};


@interface AttLinkData : NSObject

@property (nonatomic, copy)   NSString * text;
@property (nonatomic, assign) NSRange  range;
@property (nonatomic, assign) AttLinkDataType  attLinkDataType;

@end
