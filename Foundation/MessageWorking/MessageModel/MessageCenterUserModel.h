//
//  MessageCenterUserModel.h
//  Client
//
//  Created by wwt on 15/10/21.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonModel.h"

@interface MessageCenterUserModel : CommonModel

//主键
@property (nonatomic, copy) NSString *mID;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *personName;
@property (nonatomic, copy) NSString *userRole;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *avatarCache;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userType;
@property (nonatomic, copy) NSString *PhoneNo;


@end
