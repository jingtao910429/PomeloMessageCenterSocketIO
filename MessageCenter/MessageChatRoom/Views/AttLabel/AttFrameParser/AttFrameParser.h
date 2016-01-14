//
//  AttFrameParser.h
//  RongYu100
//
//  Created by xiaerfei on 15/11/16.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttTextData.h"
#import "AttLinkData.h"
#import "AttFrameParserConfig.h"

@interface AttFrameParser : NSObject

+ (AttTextData *)parseWithContentString:(NSString *)contentString config:(AttFrameParserConfig*)config;


@end
