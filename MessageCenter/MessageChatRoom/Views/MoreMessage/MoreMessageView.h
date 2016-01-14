//
//  MoreMessageView.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/11/3.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreMessageView : UIView

@property (nonatomic, assign, readonly) NSInteger unReadMessageNumber;

- (void)addTarget:(id)target action:(SEL)action;

- (void)unReadMessageNumber:(NSString *)number;

@end
