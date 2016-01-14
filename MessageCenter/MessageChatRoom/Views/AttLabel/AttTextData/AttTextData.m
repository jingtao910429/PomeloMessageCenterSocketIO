//
//  AttTextData.m
//  RongYu100
//
//  Created by xiaerfei on 15/11/16.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "AttTextData.h"

@implementation AttTextData

- (void)setCtFrame:(CTFrameRef)ctFrame {
    if (_ctFrame != ctFrame) {
        if (_ctFrame != nil) {
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
    }
}

- (void)dealloc {
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

@end
