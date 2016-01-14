//
//  AttFrameParserConfig.m
//  RongYu100
//
//  Created by xiaerfei on 15/11/16.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "AttFrameParserConfig.h"

@implementation AttFrameParserConfig

- (id)init {
    self = [super init];
    if (self) {
        _width = 200.0f;
        _fontSize = 14.0f;
        _lineSpace = 3.0f;
        //        _textColor = [UIColor colorWithRed:108.0f/255.0 green:108.0f/255.0 blue:108.0f/255.0 alpha:1.0];
        _textColor = [UIColor whiteColor];
    }
    return self;
}

@end
