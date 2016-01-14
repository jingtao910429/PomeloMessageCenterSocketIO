//
//  AttLinkUtils.h
//  RongYu100
//
//  Created by xiaerfei on 15/11/16.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AttLinkData;
@class AttTextData;
@interface AttLinkUtils : NSObject

+ (AttLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point attTextData:(AttTextData *)attTextData;


@end
