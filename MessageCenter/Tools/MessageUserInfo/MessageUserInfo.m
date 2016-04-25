//
//  MessageUserInfo.m
//  RongYu100
//
//  Created by xiaerfei on 15/11/17.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "MessageUserInfo.h"
#import "GetMembersOfUserInfoAPICmd.h"
#import "PomeloMessageCenterDBManager.h"
#import "MessageCenterUserModel.h"


#define isEmptyDict(string) ((string == nil || string.count == 0) ? YES : NO)
#define isEmptyString(string) ((string == nil || string.length == 0) ? YES : NO)

@interface MessageUserInfo ()<APICmdApiCallBackDelegate>

@property (nonatomic, strong) GetMembersOfUserInfoAPICmd *getMembersOfUserInfoAPICmd;
@property (nonatomic, copy) NSMutableDictionary *userInfo;
@property (nonatomic, copy) NSString *userId;
@end

@implementation MessageUserInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configData];
    }
    return self;
}

- (void)configData
{
    _userInfo = [[NSMutableDictionary alloc] init];
}


- (void)userInfoWithGroupId:(NSString *)groupId userId:(NSString *)userId completionBlock:(MessageUserInfoCompletionBlock)block;
{
    _userId = userId;
    NSDictionary *dict = _userInfo[userId];
    if (isEmptyDict(dict)) {
        dict = [self fetchDataFromDataBase];
        if (!isEmptyDict(dict)) {
            block(dict);
            [_userInfo setValue:dict forKey:_userId];
            return;
        }
    } else {
        block(dict);
        return;
    }
    
    self.block = block;
    self.getMembersOfUserInfoAPICmd.path = [NSString stringWithFormat:@"api_v2/User/getViewUserPersons?userIds=%@",userId.lowercaseString];
    [self.getMembersOfUserInfoAPICmd loadData];
}

#pragma mark - APICmdApiCallBackDelegate

- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd responseData:(id)responseData
{
    NSDictionary *result = responseData[0];
    if ([result isKindOfClass:[NSDictionary class]]) {
        if (result.count == 0) {
            return;
        }
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        NSString *userId = result[@"UserId"];
        if (isEmptyString(userId)) {
            return;
        }
        tempDict[@"UserId"]     = userId;
        tempDict[@"UserRole"]   = result[@"UserRole"] == nil?@"":result[@"UserRole"];
        tempDict[@"PersonName"] = result[@"MsgGroupMemberName"] == nil?@"":result[@"MsgGroupMemberName"];
        
        tempDict[@"UserType"]   = result[@"UserType"] == nil?@"":result[@"UserType"];
        tempDict[@"PhoneNo"]    = result[@"PhoneNo"] == nil?@"":result[@"PhoneNo"];
        tempDict[@"Avatar"]     = result[@"Avatar"] == nil?@"":result[@"Avatar"];
        
        NSDictionary *fetchInfo = [self fetchDataFromDataBase];
        if (isEmptyDict(fetchInfo)) {
            [[PomeloMessageCenterDBManager shareInstance] addDataToTableWithType:MessageCenterDBManagerTypeUSER data:@[tempDict]];
            self.block(tempDict);
            [_userInfo setValue:tempDict forKey:_userId];
        } else {
            self.block(fetchInfo);
            [_userInfo setValue:fetchInfo forKey:_userId];
        }
        

    }
}

- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd error:(NSError *)error
{
    
}


#pragma mark - private methods
- (NSDictionary *)fetchDataFromDataBase
{
    NSArray *array = [[PomeloMessageCenterDBManager shareInstance] fetchDataInfosWithType:MessageCenterDBManagerTypeUSER conditionName:@"UserId" SQLvalue:_userId];
    if (array.count != 0) {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        MessageCenterUserModel *userModel = array.lastObject;
        tempDict[@"UserId"]     = userModel.userId;
        tempDict[@"UserRole"]   = userModel.userRole;
        tempDict[@"PersonName"] = userModel.personName;
        tempDict[@"Avatar"]     = userModel.avatar==nil?@"":userModel.avatar;
        return tempDict;
    }
    return nil;
}

#pragma mark - getters
- (GetMembersOfUserInfoAPICmd *)getMembersOfUserInfoAPICmd
{
    if (_getMembersOfUserInfoAPICmd == nil) {
        _getMembersOfUserInfoAPICmd = [[GetMembersOfUserInfoAPICmd alloc] init];
        _getMembersOfUserInfoAPICmd.delegate = self;
    }
    return _getMembersOfUserInfoAPICmd;
}

@end
