//
//  AttView.h
//  RongYu100
//
//  Created by xiaerfei on 15/11/16.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttTextData.h"

@class AttView;
@class AttLinkData;

@protocol AttViewDelegate <NSObject>

- (void)attViewTouch:(AttView *)attView attLinkData:(AttLinkData *)attLinkData;

@end

@interface AttView : UIView

@property (nonatomic, weak)   id<AttViewDelegate> delegate;

@property (nonatomic,strong) UITapGestureRecognizer *gestureTap;
@property (nonatomic, strong) AttTextData *attTextData;

@end
