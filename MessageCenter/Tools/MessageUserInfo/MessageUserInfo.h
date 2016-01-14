//
//  MessageUserInfo.h
//  RongYu100
//
//  Created by xiaerfei on 15/11/17.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MessageUserInfoCompletionBlock)(NSDictionary *userInfo);

@interface MessageUserInfo : NSObject

@property (nonatomic, copy) MessageUserInfoCompletionBlock block;

- (void)userInfoWithGroupId:(NSString *)groupId userId:(NSString *)userId completionBlock:(MessageUserInfoCompletionBlock)block;

@end
