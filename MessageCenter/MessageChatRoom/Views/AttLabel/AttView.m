//
//  AttView.m
//  RongYu100
//
//  Created by xiaerfei on 15/11/16.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "AttView.h"
#import "AttLinkUtils.h"
#import "AttLinkData.h"

@interface AttView ()



@end

@implementation AttView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupEvents];
    }
    return self;
}

- (void)setupEvents
{
    [self addGestureRecognizer:self.gestureTap];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    if (self.attTextData) {
        CTFrameDraw(self.attTextData.ctFrame, context);
    }
}


#pragma mark - events response

- (void)gestureTapAction:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    AttLinkData *attLinkData = [AttLinkUtils touchLinkInView:self atPoint:point attTextData:self.attTextData];
    if ([self.delegate respondsToSelector:@selector(attViewTouch:attLinkData:)]) {
        [self.delegate attViewTouch:self attLinkData:attLinkData];
    }
}

#pragma mark - getters

- (UITapGestureRecognizer *)gestureTap
{
    if (_gestureTap == nil) {
        _gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapAction:)];
    }
    return _gestureTap;
}


@end
