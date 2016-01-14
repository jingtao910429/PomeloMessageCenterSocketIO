//
//  AttLinkUtils.m
//  RongYu100
//
//  Created by xiaerfei on 15/11/16.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "AttLinkUtils.h"
#import "AttLinkData.h"
#import "AttTextData.h"
#import "UIViewExt.h"
#import <CoreText/CoreText.h>

@implementation AttLinkUtils

+ (AttLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point attTextData:(AttTextData *)attTextData
{
    AttLinkData *linkData = nil;
    CTFrameRef textFrame = attTextData.ctFrame;
    
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) return nil;
    // 获得每一行的 origin 坐标
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);

    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        // 获得每一行的 CGRect 信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (CGRectContainsPoint(rect, point)) {
            // 将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            // 获得当前点击坐标对应的字符串偏移
            CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
            // 判断这个偏移是否在我们的链接列表中
            linkData = [self linkAtIndex:idx linkArray:attTextData.linkArray];
        }
    }
    return linkData;
}


+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

+ (AttLinkData *)linkAtIndex:(CFIndex)i linkArray:(NSArray *)linkArray {
    AttLinkData *link = nil;
    for (AttLinkData *data in linkArray) {
        if (NSLocationInRange(i, data.range)) {
            link = data;
            break;
        }
    }
    return link;
}

@end
