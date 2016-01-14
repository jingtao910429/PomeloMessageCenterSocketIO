//
//  GroupChatViewController.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/20.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatViewController : UIViewController

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *groupName;

@property (nonatomic, assign) BOOL isTop;
@property (nonatomic, assign) BOOL isDisturb;

@end
