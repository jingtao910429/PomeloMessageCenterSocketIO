//
//  ApplicationStatusView.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/11/5.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplicationStatusView : UIView

@property (nonatomic, copy) void (^ApplicationStatusViewBlock) ();

- (void)updateAplicationStatusText:(NSString *)text;

@end
