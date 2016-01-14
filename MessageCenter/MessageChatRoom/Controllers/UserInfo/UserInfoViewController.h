//
//  UserInfoViewController.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoViewController : UIViewController

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, assign) BOOL isUserSelf;

@property (nonatomic, assign) BOOL isGroupPush;

@property (nonatomic, copy) NSMutableDictionary *userInfo;


@end
