//
//  RYRouteHandler.m
//  Client
//
//  Created by wwt on 15/10/22.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import "RYNotifyHandler.h"
#import "PomeloClient.h"
#import "RYChatAPIManager.h"
#import "ConnectToServer.h"
#import "MessageTool.h"
#import "PomeloMessageCenterDBManager.h"
#import "RYChatHandler.h"
#import "MessageCenterUserModel.h"
#import "GetMembersAPICmd.h"
#import "GetGroupMemberAPICmd.h"
#import "LZAudioTool.h"
#import "NSString+Extension.h"
#import "MessageCenterMetadataModel.h"

static RYNotifyHandler *shareHandler = nil;

@interface RYNotifyHandler () <APICmdApiCallBackDelegate>

@property (nonatomic, strong) RYChatHandler *getGroupInfoChatHandler;
@property (nonatomic, strong) RYChatHandler *findUserChatHandler;

//获取组成员
@property (nonatomic, strong) GetMembersAPICmd *getMembersAPICmd;
//获取组单个成员信息
@property (nonatomic, strong) GetGroupMemberAPICmd *getGroupMemberAPICmd;

@end

@implementation RYNotifyHandler

+ (instancetype)shareHandler {
    
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        shareHandler = [[RYNotifyHandler alloc] init];
    });
    return shareHandler;
}

- (void)onAllNotify {
    
    NSArray *tempNotifyArr = @[[NSNumber numberWithInt:NotifyTypeOnChat],
                               [NSNumber numberWithInt:NotifyTypeOnRead],
                               [NSNumber numberWithInt:NotifyTypeOnTop],
                               [NSNumber numberWithInt:NotifyTypeOnDisturbed],
                               [NSNumber numberWithInt:NotifyTypeOnGroupMsgList],
                               [NSNumber numberWithInt:NotifyTypeOnChatHistory],
                               [NSNumber numberWithInt:NotifyTypeOnApproveStatusChanged],
                               [NSNumber numberWithInt:NotifyTypeOnRemoveUser],
                               [NSNumber numberWithInt:NotifyTypeOnAddUser]];
    
    for (NSNumber *subNumber in tempNotifyArr) {
        
        ConnectToServer *connectToServer = [ConnectToServer shareInstance];
        
        self.notifyType = [subNumber intValue];
        
        __block RYNotifyHandler *weakSelf = self;
        
        [connectToServer.pomeloClient onRoute:[RYChatAPIManager notifyWithType:self.notifyType] withCallback:^(id arg , NSString *route) {
            
            [MessageTool setConnectStatus:@"1"];
            
            if ([route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnChat]]) {
                
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:arg];
                
                [weakSelf storeMessageWithDict:tempDict];
                
                /*
                dispatch_queue_t queue = dispatch_queue_create([[NSString stringWithFormat:@"route%d",arc4random()] UTF8String], NULL);
                dispatch_async(queue, ^{
                    [weakSelf storeMessageWithDict:tempDict];
                });
                 */
                
            }else if ([route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnChatHistory]]) {
                
                NSArray *messages = [[NSArray alloc] initWithArray:arg];
                
                for (int i = 0; i < [messages count]; i ++ ) {
                    
                    NSString *typeStr = [NSString stringWithFormat:@"%@",messages[i][@"type"]];
                    
                    if ([typeStr isEqualToString:@"103"] || [typeStr isEqualToString:@"104"] ||[typeStr isEqualToString:@"101"] || [typeStr isEqualToString:@"105"]) {
                        
                        // 103/104/105特殊处理
                        [self dealSpecialGroupAndGroupInfosWithGroupCondition:messages[i]];
                        
                    }else {
                        
                        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                        
                        [tempDict setValue:[NSString stringWithFormat:@"%@",messages[i][@"_id"]]     forKey:@"MessageId"];
                        [tempDict setValue:[NSString stringWithFormat:@"%@",messages[i][@"time"]]    forKey:@"CreateTime"];
                        [tempDict setValue:[NSString stringWithFormat:@"%@",messages[i][@"from"]]    forKey:@"UserId"];
                        
                        [tempDict setValue:[NSString stringWithFormat:@"%@",messages[i][@"toGroupId"]] forKey:@"GroupId"];
                        [tempDict setValue:[NSString stringWithFormat:@"%@",messages[i][@"content"]] forKey:@"MsgContent"];
                        [tempDict setValue:@"1"               forKey:@"Status"];
                        
                        [tempDict setValue:[MessageTool getUserID] forKey:@"accountId"];
                        [tempDict setValue:[NSString stringWithFormat:@"%@",messages[i][@"clientMsgId"]] forKey:@"clientMsgId"];
                        [tempDict setValue:typeStr forKey:@"type"];
                        
                        //存储信息
                        [[PomeloMessageCenterDBManager shareInstance] addDataToTableWithType:MessageCenterDBManagerTypeMESSAGE data:[NSArray arrayWithObjects:tempDict, nil]];
                        
                        //未读消息加1
                        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"UnReadMsgCount + '1'",@"UnReadMsgCount", nil];
                        
                        [[PomeloMessageCenterDBManager shareInstance] updateGroupLastedMessageWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:[NSString stringWithFormat:@"%@",tempDict[@"GroupId"]] parameters:resultDict];
                        
                    }
                    
                }
                
                
            }else if ([route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnTop]]) {
                
                //置顶操作
                NSString *groupID = arg[@"groupId"];
                
                if (groupID && ![groupID isKindOfClass:[NSNull class]]) {
                    
                    [MessageTool setTopGroupId:groupID];
                    //如果groupid存在，则为置顶组
                    [[PomeloMessageCenterDBManager shareInstance] markTopTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:groupID];
                }else {
                    
                    [MessageTool setTopGroupId:@"NULL"];
                    //如果groupid不存在，则为取消置顶
                    [[PomeloMessageCenterDBManager shareInstance] markTopTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:nil];
                    
                }
                
            }else if ([route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnDisturbed]]) {
                //全局设置
                
                if ([arg[@"userId"] isEqualToString:[MessageTool getUserID]]) {
                    if (1 == [arg[@"isDisturbed"] intValue]) {
                        [MessageTool setDisturbed:@"YES"];
                    }else {
                        [MessageTool setDisturbed:@"NO"];
                    }
                }
                
            }else if ([route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnApproveStatusChanged]]
                      || [route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnRemoveUser]]
                      || [route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnRead]]
                      || [route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnAddUser]]) {
                
                //NotifyTypeOnApproveStatusChanged
                //信贷申请状态变更
                
                
                //NotifyTypeOnRemoveUser
                //移除组和组信息
                
                //NotifyTypeOnRead
                //标记已读
                
                //NotifyTypeOnAddUser
                //人员添加
                [self dealSpecialGroupAndGroupInfosWithGroupCondition:arg];
                
            }
            
            if ([route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnChat]]
                || [route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnApproveStatusChanged]]
                || [route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnRemoveUser]]
                || [route isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnAddUser]]
                ) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:[MessageTool PushGlobalNotificationStr] object:arg userInfo:@{@"route":route}];
                });
                
            }
            
            [MessageTool setDBChange:@"YES"];
            
        }];
    }
    
}

- (void)offNotify {
    [self.client offRoute:[RYChatAPIManager notifyWithType:self.notifyType]];
}

#pragma mark APICmdApiCallBackDelegate

- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd responseData:(id)responseData {
    
    if (baseAPICmd == self.getMembersAPICmd) {
        
        //保存用户信息
        
        NSArray *users = (NSArray *)responseData;

        if ([users isKindOfClass:[NSArray class]] && [users count] != 0) {
            
            NSMutableArray *tempUsers = [[NSMutableArray alloc] initWithCapacity:20];
            
            for (NSDictionary *subDict in users) {
                
                NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithCapacity:20];
                [userDict setValue:[NSString stringWithFormat:@"%@",subDict[@"MsgGroupMemberName"]] forKey:@"PersonName"];
                [userDict setValue:[NSString stringWithFormat:@"%@",subDict[@"UserId"]] forKey:@"UserId"];
                [userDict setValue:[NSString stringWithFormat:@"%@",subDict[@"UserRole"]] forKey:@"UserRole"];
                [userDict setValue:[NSString stringWithFormat:@"%@",subDict[@"PhoneNo"]] forKey:@"PhoneNo"];
                [userDict setValue:[NSString stringWithFormat:@"%@",subDict[@"Avatar"]] forKey:@"Avatar"];
                
                [tempUsers addObject:userDict];
            }
            
            //增加userid
            [[PomeloMessageCenterDBManager shareInstance] addDataToTableWithType:MessageCenterDBManagerTypeUSER data:tempUsers];
            
        }
    }else if (baseAPICmd == self.getGroupMemberAPICmd) {
        
        NSDictionary *userDict = responseData[@"Result"];
        
        if (userDict && ![userDict isKindOfClass:[NSNull class]]) {
            
            NSMutableDictionary *tempUserDict = [[NSMutableDictionary alloc] initWithCapacity:20];
            [tempUserDict setValue:[NSString stringWithFormat:@"%@",userDict[@"MsgGroupMemberName"]] forKey:@"PersonName"];
            [tempUserDict setValue:[NSString stringWithFormat:@"%@",userDict[@"UserId"]] forKey:@"UserId"];
            [tempUserDict setValue:[NSString stringWithFormat:@"%@",userDict[@"UserRole"]] forKey:@"UserRole"];
            [tempUserDict setValue:[NSString stringWithFormat:@"%@",userDict[@"PhoneNo"]] forKey:@"PhoneNo"];
            [tempUserDict setValue:[NSString stringWithFormat:@"%@",userDict[@"Avatar"]] forKey:@"Avatar"];
            
            //增加userid
            [[PomeloMessageCenterDBManager shareInstance] addDataToTableWithType:MessageCenterDBManagerTypeUSER data:[NSArray arrayWithObjects:tempUserDict, nil]];
        }
        
    }
    
}

- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd error:(NSError *)error {
    
}

#pragma mark private method

//单个信息处理

- (NSMutableDictionary *)storeSingleMessageWithDict:(NSDictionary *)dict {
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    [tempDict setValue:[NSString stringWithFormat:@"%@",dict[@"_id"]]     forKey:@"MessageId"];
    [tempDict setValue:[NSString stringWithFormat:@"%@",dict[@"time"]]    forKey:@"CreateTime"];
    [tempDict setValue:[NSString stringWithFormat:@"%@",dict[@"from"]]    forKey:@"UserId"];
    
    [tempDict setValue:[NSString stringWithFormat:@"%@",dict[@"toGroupId"]] forKey:@"GroupId"];
    [tempDict setValue:[NSString stringWithFormat:@"%@",dict[@"content"]] forKey:@"MsgContent"];
    [tempDict setValue:@"1"               forKey:@"Status"];
    
    [tempDict setValue:[MessageTool getUserID] forKey:@"accountId"];
    [tempDict setValue:[NSString stringWithFormat:@"%@",dict[@"clientMsgId"]] forKey:@"clientMsgId"];
    [tempDict setValue:[NSString stringWithFormat:@"%@",dict[@"type"]] forKey:@"type"];
    
    [MessageTool setLastedReadTime:[NSString stringWithFormat:@"%@",tempDict[@"CreateTime"]]];
    
    //存储信息
    [[PomeloMessageCenterDBManager shareInstance] addDataToTableWithType:MessageCenterDBManagerTypeMESSAGE data:[NSArray arrayWithObjects:tempDict, nil]];
    
    return tempDict;
    
}

- (void)storeMessageWithDict:(NSDictionary *)dict {
    
    NSMutableDictionary *tempDict = [self storeSingleMessageWithDict:dict];
    
    if (![[PomeloMessageCenterDBManager shareInstance] existTableWithType:MessageCenterDBManagerTypeMETADATA markID:tempDict[@"GroupId"]]) {
        
        //获取组
        
        if ([dict[@"from"] isEqualToString:[MessageTool getUserID]]) {
            
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempDict[@"GroupId"],@"GroupId",[MessageTool getUserID],@"accountId",@"0",@"UnReadMsgCount",[NSString stringWithFormat:@"%@",tempDict[@"MessageId"]],@"LastedMsgId",[NSString stringWithFormat:@"%@",tempDict[@"UserId"]],@"LastedMsgSenderName",[NSString stringWithFormat:@"%@",tempDict[@"CreateTime"]],@"LastedMsgTime",[NSString stringWithFormat:@"%@",tempDict[@"MsgContent"]],@"LastedMsgContent", nil];
            
            if ([[MessageTool topGroupId] isEqualToString:tempDict[@"GroupId"]]) {
                [resultDict setObject:@"YES" forKey:@"isTop"];
            }
            
            [[PomeloMessageCenterDBManager shareInstance] addDataToTableWithType:MessageCenterDBManagerTypeMETADATA data:[NSArray arrayWithObjects:resultDict, nil]];
            
        }else{
            
            //如果是YES，则为免打扰模式
            if ([[MessageTool getDisturbed] isEqualToString:@"NO"] || ![MessageTool getDisturbed] || [[MessageTool getDisturbed] isKindOfClass:[NSNull class]]) {
#if TARGET_IPHONE_SIMULATOR
                
                //模拟器
                
#elif TARGET_OS_IPHONE
                
                //真机  
                //声音播放
                [LZAudioTool playMusic:@"msg.mp3"];
#endif

            }
            
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempDict[@"GroupId"],@"GroupId",[MessageTool getUserID],@"accountId",@"1",@"UnReadMsgCount",[NSString stringWithFormat:@"%@",tempDict[@"MessageId"]],@"LastedMsgId",[NSString stringWithFormat:@"%@",tempDict[@"UserId"]],@"LastedMsgSenderName",[NSString stringWithFormat:@"%@",tempDict[@"CreateTime"]],@"LastedMsgTime",[NSString stringWithFormat:@"%@",tempDict[@"MsgContent"]],@"LastedMsgContent", nil];
            
            if ([[MessageTool topGroupId] isEqualToString:tempDict[@"GroupId"]]) {
                [resultDict setObject:@"YES" forKey:@"isTop"];
            }
            
            [[PomeloMessageCenterDBManager shareInstance] addDataToTableWithType:MessageCenterDBManagerTypeMETADATA data:[NSArray arrayWithObjects:resultDict, nil]];
            
        }
        
        self.getGroupInfoChatHandler.parameters = @{@"groupId":tempDict[@"GroupId"]};
        [self.getGroupInfoChatHandler chat];
        
        //获取组成员
        self.getMembersAPICmd.path = [NSString stringWithFormat:GetMembers,tempDict[@"GroupId"]];
        [self.getMembersAPICmd loadData];
        
        
    }else {
        
        //不管对应用户在不在，都需要＋1操作，如果拿到用户信息，再反过来更新（数据库操作）
        
        if ([dict[@"from"] isEqualToString:[MessageTool getUserID]]) {
            
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"UnReadMsgCount + '0'",@"UnReadMsgCount",[NSString stringWithFormat:@"%@",tempDict[@"MessageId"]],@"LastedMsgId",[NSString stringWithFormat:@"%@",tempDict[@"UserId"]],@"LastedMsgSenderName",[NSString stringWithFormat:@"%@",tempDict[@"CreateTime"]],@"LastedMsgTime",[NSString stringWithFormat:@"%@",tempDict[@"MsgContent"]],@"LastedMsgContent", nil];
            
            [[PomeloMessageCenterDBManager shareInstance] updateGroupLastedMessageWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:[NSString stringWithFormat:@"%@",tempDict[@"GroupId"]] parameters:resultDict];
            
        }else{
            
            //如果是YES，则为免打扰模式
            if ([[MessageTool getDisturbed] isEqualToString:@"NO"] || ![MessageTool getDisturbed] || [[MessageTool getDisturbed] isKindOfClass:[NSNull class]]) {
#if TARGET_IPHONE_SIMULATOR
                //模拟器
#elif TARGET_OS_IPHONE
                //真机  
                //声音播放
                [LZAudioTool playMusic:@"msg.mp3"];
#endif

            }
            
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"UnReadMsgCount + '1'",@"UnReadMsgCount",[NSString stringWithFormat:@"%@",tempDict[@"MessageId"]],@"LastedMsgId",[NSString stringWithFormat:@"%@",tempDict[@"UserId"]],@"LastedMsgSenderName",[NSString stringWithFormat:@"%@",tempDict[@"CreateTime"]],@"LastedMsgTime",[NSString stringWithFormat:@"%@",tempDict[@"MsgContent"]],@"LastedMsgContent", nil];
            
            [[PomeloMessageCenterDBManager shareInstance] updateGroupLastedMessageWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:[NSString stringWithFormat:@"%@",tempDict[@"GroupId"]] parameters:resultDict];
        }
        
        NSArray *users =  [[PomeloMessageCenterDBManager shareInstance] fetchDataInfosWithType:MessageCenterDBManagerTypeUSER conditionName:@"UserId" SQLvalue:tempDict[@"UserId"]];
        
        if (users.count == 0) {
            //获取成员
            self.getGroupMemberAPICmd.path = [NSString stringWithFormat:GetGroupMember,tempDict[@"UserId"]];
            [self.getGroupMemberAPICmd loadData];
        }

    }
    
}

/*
- (void)updateMetedateTableWithDict:(NSDictionary *)tempDict {
    
    NSArray *users =  [[PomeloMessageCenterDBManager shareInstance] fetchDataInfosWithType:MessageCenterDBManagerTypeUSER conditionName:@"UserId" SQLvalue:tempDict[@"UserId"]];
    
    if (users.count != 0) {
        
        //如果存在用户信息，则使用用户信息更新METADATA表
        MessageCenterUserModel *userModel = (MessageCenterUserModel *)users[0];
        
        [[PomeloMessageCenterDBManager shareInstance] updateGroupLastedMessageWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:tempDict[@"GroupId"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:tempDict[@"MessageId"],@"LastedMsgId",userModel.personName,@"LastedMsgSenderName",tempDict[@"CreateTime"],@"LastedMsgTime",tempDict[@"MsgContent"],@"LastedMsgContent", nil]];
        
    }
}
 */

//移除组/组消息
- (void)dealSpecialGroupAndGroupInfosWithGroupCondition:(NSDictionary *)conditionDict{
    
    if ([[NSString stringWithFormat:@"%@",conditionDict[@"type"]] isEqualToString:@"103"]) {
        
        if ([conditionDict[@"toUsers"] isKindOfClass:[NSString class]]) {
            
            if ([conditionDict[@"toUsers"]  isEqualToString:[MessageTool getUserID]]) {
                //如果消息type为103
                NSString *groupId = conditionDict[@"groupId"];
                [[PomeloMessageCenterDBManager shareInstance] deleteDataWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:groupId];
                [[PomeloMessageCenterDBManager shareInstance] deleteDataWithTableWithType:MessageCenterDBManagerTypeMESSAGE SQLvalue:groupId];
            }
            
        }else {
            
            for (NSString *removeUserStr in conditionDict[@"toUsers"]) {
                if ([removeUserStr  isEqualToString:[MessageTool getUserID]]) {
                    //如果消息type为103
                    NSString *groupId = conditionDict[@"groupId"];
                    [[PomeloMessageCenterDBManager shareInstance] deleteDataWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:groupId];
                    [[PomeloMessageCenterDBManager shareInstance] deleteDataWithTableWithType:MessageCenterDBManagerTypeMESSAGE SQLvalue:groupId];
                }
            }
            
        }
        
    }else if([[NSString stringWithFormat:@"%@",conditionDict[@"type"]] isEqualToString:@"104"]){
        
        //如果消息type为104
        NSArray *usersArr = conditionDict[@"toUsers"];
        
        BOOL isExit = NO;
        
        for (NSString *userId in usersArr) {
            
            if ([userId isEqualToString:[MessageTool getUserID]]) {
                isExit = YES;
                break;
            }
            
        }
        
        NSArray *groups = [[PomeloMessageCenterDBManager shareInstance] fetchDataInfosWithType:MessageCenterDBManagerTypeMETADATA conditionName:@"groupType" SQLvalue:conditionDict[@"groupType"]];
        
        for (MessageCenterMetadataModel *metaDataModel in groups) {
            
            [[PomeloMessageCenterDBManager shareInstance] deleteDataWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:metaDataModel.groupId];
            [[PomeloMessageCenterDBManager shareInstance] deleteDataWithTableWithType:MessageCenterDBManagerTypeMESSAGE SQLvalue:metaDataModel.groupId];
            
        }
        
    }else if ([[NSString stringWithFormat:@"%@",conditionDict[@"type"]] isEqualToString:@"105"]){
        
        //如果消息type为105
        NSArray *usersArr = conditionDict[@"toUsers"];
        NSString *groupId = nil;
        
        BOOL isExit = NO;
        
        for (NSString *userId in usersArr) {
            
            if ([userId isEqualToString:[MessageTool getUserID]]) {
                isExit = YES;
                groupId = userId;
                break;
            }
            
        }
        
        if (isExit) {
            //已读
            //设置未读消息
            [MessageTool setLastedReadTime:conditionDict[@"time"]];
            
            [[PomeloMessageCenterDBManager shareInstance] markReadTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:conditionDict[@"groupId"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:conditionDict[@"msgId"],@"LastedReadMsgId",conditionDict[@"time"],@"LastedReadTime",@"0",@"UnReadMsgCount",nil]];
            
        }

    }else if ([[NSString stringWithFormat:@"%@",conditionDict[@"type"]] isEqualToString:@"101"] || ([[NSString stringWithFormat:@"%@",conditionDict[@"type"]] isEqualToString:@"106"])) {
        
        //106 onAddUser
        //101 信贷申请相关
        
        //更新信贷申请状态
        [[PomeloMessageCenterDBManager shareInstance] updateGroupLastedMessageWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:conditionDict[@"groupId"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:conditionDict[@"_id"],@"LastedMsgId",conditionDict[@"time"],@"LastedMsgTime",conditionDict[@"content"],@"LastedMsgContent",[NSString stringWithFormat:@"%@",conditionDict[@"creditApplicationStatus"]],@"ApproveStatus",nil]];
        
        if ([[NSString stringWithFormat:@"%@",conditionDict[@"type"]] isEqualToString:@"101"]) {
            
            NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] initWithDictionary:conditionDict];
            [messageDict setValue:[NSString stringWithFormat:@"%@",messageDict[@"groupId"]] forKey:@"toGroupId"];
            
            [self storeMessageWithDict:messageDict];
            
        }else {
            
            NSDictionary *resultDict = (NSDictionary *)conditionDict;
            
            NSArray *users = resultDict[@"AddedUsers"];
            
            NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] initWithDictionary:resultDict];
            
            NSMutableString *nameStr = [[NSMutableString alloc] init];
            
            for (int i = 0; i < users.count; i ++) {
                
                NSDictionary *userDict = users[i];
                
                if (i != users.count - 1) {
                    [nameStr appendFormat:@"%@,",userDict[@"userName"]];
                }else {
                    [nameStr appendFormat:@"%@",userDict[@"userName"]];
                }
                
            }
            
            [messageDict setValue:[NSString stringWithFormat:@"%@加入群组",nameStr] forKey:@"content"];
            [messageDict setValue:[NSString stringWithFormat:@"%@",resultDict[@"groupId"]] forKey:@"toGroupId"];
            [self storeSingleMessageWithDict:messageDict];
        }
    }
    
}

#pragma mark getters & setters

- (RYChatHandler *)findUserChatHandler {
    
    if (!_findUserChatHandler) {
        _findUserChatHandler = [[RYChatHandler alloc] initWithDelegate:[[ConnectToServer shareInstance] delegate]];
        _findUserChatHandler.chatServerType = RouteChatTypeFindUser;
    }
    return _findUserChatHandler;
}

- (RYChatHandler *)getGroupInfoChatHandler {
    if (!_getGroupInfoChatHandler) {
        _getGroupInfoChatHandler = [[RYChatHandler alloc] initWithDelegate:[[ConnectToServer shareInstance] delegate]];
        _getGroupInfoChatHandler.chatServerType = RouteChatTypeGetGroupInfo;
    }
    return _getGroupInfoChatHandler;
}

- (GetMembersAPICmd *)getMembersAPICmd {
    if (!_getMembersAPICmd) {
        _getMembersAPICmd = [[GetMembersAPICmd alloc] init];
        _getMembersAPICmd.delegate = self;
    }
    return _getMembersAPICmd;
}

- (GetGroupMemberAPICmd *)getGroupMemberAPICmd {
    if (!_getGroupMemberAPICmd) {
        _getGroupMemberAPICmd = [[GetGroupMemberAPICmd alloc] init];
        _getGroupMemberAPICmd.delegate = self;
    }
    return _getGroupMemberAPICmd;
}


@end
