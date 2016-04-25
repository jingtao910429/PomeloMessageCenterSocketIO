//
//  PomeloDBRecord.m
//  Client
//
//  Created by wwt on 15/10/20.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import "PomeloMessageCenterDBManager.h"
#import "RYDataBaseStore.h"
#import "MessageCenterUserModel.h"
#import "MessageCenterMessageModel.h"
#import "MessageCenterMetadataModel.h"
#import "RYChatDBAPIManager.h"
#import "MessageTool.h"
#import "RYChatHandler.h"
#import "ConnectToServer.h"
#import "RefreshUIManager.h"
#import "NSString+Extension.h"
#import "MessageModel.h"

@interface PomeloMessageCenterDBManager ()

@property (nonatomic, strong) RYDataBaseStore *dataBaseStore;
@property (nonatomic, strong) RYChatDBAPIManager *DBAPIManager;

@property (nonatomic, strong) RYChatHandler *getGroupInfoChatHandler;

@end

@implementation PomeloMessageCenterDBManager

+ (instancetype)shareInstance{
    
    static id _dbRecord;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _dbRecord = [[PomeloMessageCenterDBManager alloc] init];
    });
    return _dbRecord;
}

- (instancetype)init {
    if (self = [super init]) {
        _DBAPIManager = [RYChatDBAPIManager shareManager];
        [self createTables];
        
    }
    return self;
}

/*
 
 self.UserCols = @[@"UserId",@"PersonName",@"UserRole",@"Avatar",@"AvatarCache",@"UserName",@"UserType",@"PhoneNo"];
 self.UserMessageCols = @[@"accountId",@"UserId",@"MessageId",@"GroupId",@"MsgContent",@"CreateTime",@"Status",@"clientMsgId",@"type",@"creditApplicationStatus"];
 self.MsgMetadataCols = @[@"AccountId",@"GroupId",@"GroupName",@"Avatar",@"AvatarCache",@"GroupType",@"CompanyName",@"ApproveStatus",@"LastedReadMsgId",@"LastedReadTime",@"LastedMsgId",@"LastedMsgSenderName",@"LastedMsgTime",@"LastedMsgContent",@"UnReadMsgCount",@"CreateTime",@"isTop"];
 
 
 */



#pragma mark 数据库操作

//数据库初始化
- (void)createTables {
    
    _dataBaseStore = [[RYDataBaseStore alloc] initDBWithName:[_DBAPIManager dbName]];
    
    
    //➢ 用户信息表(User)
    [_dataBaseStore createTableWithName:[_DBAPIManager tableNameWithTableType:MessageCenterDBManagerTypeUSER] sqlString:
     [_DBAPIManager createTableSQLWithTableType:MessageCenterDBManagerTypeUSER]
     ];
    
    //➢	消息列表(Message)
    
    [_dataBaseStore createTableWithName:[_DBAPIManager tableNameWithTableType:MessageCenterDBManagerTypeMESSAGE] sqlString:
     [_DBAPIManager createTableSQLWithTableType:MessageCenterDBManagerTypeMESSAGE]];
    
    //➢	消息Metadata(MsgMetadata)
    
    [_dataBaseStore createTableWithName:[_DBAPIManager tableNameWithTableType:MessageCenterDBManagerTypeMETADATA] sqlString:
     [_DBAPIManager createTableSQLWithTableType:MessageCenterDBManagerTypeMETADATA]];
    
    //处理上传失败而且保留一个星期的数据
    [self clearHistoryFailedMessage];
}


- (void)addNoSendMessageToTableWithType:(MessageCenterDBManagerType)tableType data:(NSArray *)datas {
    
    NSString *SQLStr = [_DBAPIManager addTableSQLWithTableType:MessageCenterDBManagerTypeMESSAGE];
    
    for (int i = 0; i < datas.count; i++) {
        
        if (tableType == MessageCenterDBManagerTypeMESSAGE) {
            
            MessageCenterMessageModel *messageCenterMessageModel = datas[i];
            
            messageCenterMessageModel.accountId = [MessageTool getUserID];
            messageCenterMessageModel.Status    = @"0";
            
            [_dataBaseStore updateDataWithSql:SQLStr,
             messageCenterMessageModel.accountId,
             messageCenterMessageModel.userId,
             messageCenterMessageModel.messageId,
             messageCenterMessageModel.groupId,
             messageCenterMessageModel.msgContent,
             messageCenterMessageModel.createTime,
             messageCenterMessageModel.Status,
             messageCenterMessageModel.clientMsgId,
             messageCenterMessageModel.type,
             messageCenterMessageModel.creditApplicationStatus];
        }
        
    }
}

- (void)addDataToTableWithType:(MessageCenterDBManagerType)tableType data:(NSArray *)datas {
    
    NSString *SQLStr = nil;
    
    switch (tableType) {
        case MessageCenterDBManagerTypeUSER:
            SQLStr = [_DBAPIManager addTableSQLWithTableType:MessageCenterDBManagerTypeUSER];
            break;
        case MessageCenterDBManagerTypeMESSAGE:
            SQLStr = [_DBAPIManager addTableSQLWithTableType:MessageCenterDBManagerTypeMESSAGE];
            break;
        case MessageCenterDBManagerTypeMETADATA:
            SQLStr = [_DBAPIManager addTableSQLWithTableType:MessageCenterDBManagerTypeMETADATA];
            break;
        default:
            break;
    }
    
    if (SQLStr) {
        [self addDataWithSQL:SQLStr type:tableType datas:datas];
    }
    
}


- (void)addDataWithSQL:(NSString *)SQLStr type:(MessageCenterDBManagerType)tableType datas:(NSArray *)datas{
    
    //如果是添加，首先判断是否存在该数据，如果存在，则调用更新
    
    for (int i = 0; i < datas.count; i++) {
        
        NSString *markID = @"";
        NSDictionary *tempDict = (NSDictionary *)datas[i];
        
        if (tableType == MessageCenterDBManagerTypeUSER) {
            
            MessageCenterUserModel *messageCenterUserModel = [[MessageCenterUserModel alloc] init];
            [messageCenterUserModel setValuesForKeysWithDictionary:datas[i]];
            
            markID = messageCenterUserModel.userId;
            
        }else if (tableType == MessageCenterDBManagerTypeMESSAGE){
            
            MessageCenterMessageModel *messageCenterMessageModel = [[MessageCenterMessageModel alloc] init];
            [messageCenterMessageModel setValuesForKeysWithDictionary:datas[i]];
            markID = messageCenterMessageModel.messageId;
            
        }else if (tableType == MessageCenterDBManagerTypeMETADATA) {
            
            MessageCenterMetadataModel *messageCenterMetadataModel = [[MessageCenterMetadataModel alloc] init];
            [messageCenterMetadataModel setValuesForKeysWithDictionary:datas[i]];
            
            
            
            markID = messageCenterMetadataModel.groupId;
            
        }
        
        if (tableType == MessageCenterDBManagerTypeMESSAGE) {
            
            MessageCenterMessageModel *messageCenterMessageModel = [[MessageCenterMessageModel alloc] init];
            [messageCenterMessageModel setValuesForKeysWithDictionary:datas[i]];
            
            if ([self existTableWithType:tableType markID:markID]) {
                
                [self updateTableWithType:tableType SQLvalue:markID data:[NSArray arrayWithObjects:tempDict, nil]];
                
            }else{
                
                if (messageCenterMessageModel.clientMsgId && ![messageCenterMessageModel.clientMsgId isEqualToString:@"(null)"]) {
                    
                    NSString *deleteDataSQLStr = [NSString stringWithFormat:@"delete from UserMessage where AccountId = '%@' and groupId = '%@' and clientMsgId = '%@'",[MessageTool getUserID],messageCenterMessageModel.groupId,messageCenterMessageModel.clientMsgId];
                    
                    [_dataBaseStore updateDataWithSql:deleteDataSQLStr];
                }
                
                messageCenterMessageModel.accountId = [MessageTool getUserID];
                messageCenterMessageModel.Status = @"1";
                
                [_dataBaseStore updateDataWithSql:SQLStr,
                 messageCenterMessageModel.accountId,
                 messageCenterMessageModel.userId,
                 messageCenterMessageModel.messageId,
                 messageCenterMessageModel.groupId,
                 messageCenterMessageModel.msgContent,
                 messageCenterMessageModel.createTime,
                 messageCenterMessageModel.Status,
                 messageCenterMessageModel.clientMsgId,
                 messageCenterMessageModel.type,
                 messageCenterMessageModel.creditApplicationStatus];
                
            }
            
            
            
        }else{
            
            if ([self existTableWithType:tableType markID:markID]) {
                
                [self updateTableWithType:tableType SQLvalue:markID data:[NSArray arrayWithObjects:tempDict, nil]];
                
            }else{
                
                if (tableType == MessageCenterDBManagerTypeUSER) {
                    
                    MessageCenterUserModel *messageCenterUserModel = [[MessageCenterUserModel alloc] init];
                    [messageCenterUserModel setValuesForKeysWithDictionary:datas[i]];
                    
                    [_dataBaseStore updateDataWithSql:SQLStr,
                     messageCenterUserModel.userId,
                     messageCenterUserModel.personName,
                     messageCenterUserModel.userRole,
                     messageCenterUserModel.avatar,
                     messageCenterUserModel.avatarCache,
                     messageCenterUserModel.userName,
                     messageCenterUserModel.userType,
                     messageCenterUserModel.PhoneNo];
                    
                }else if (tableType == MessageCenterDBManagerTypeMETADATA) {
                    
                    MessageCenterMetadataModel *messageCenterMetadataModel = [[MessageCenterMetadataModel alloc] init];
                    [messageCenterMetadataModel setValuesForKeysWithDictionary:datas[i]];
                    
                    /*
                    if (!messageCenterMetadataModel.approveStatus || [messageCenterMetadataModel.approveStatus isKindOfClass:[NSNull class]] || 0 == [messageCenterMetadataModel.approveStatus length]) {
                        //如果不是系统的消息，则正常更新
                        
                        //这里使用用户ID，而不是聊天中的userID
                        messageCenterMetadataModel.accountId = [MessageTool getUserID];
                        
                        [_dataBaseStore updateDataWithSql:SQLStr,
                         messageCenterMetadataModel.accountId,
                         messageCenterMetadataModel.groupId,
                         messageCenterMetadataModel.groupName,
                         messageCenterMetadataModel.avatar,
                         messageCenterMetadataModel.avatarCache,
                         messageCenterMetadataModel.groupType,
                         messageCenterMetadataModel.companyName,
                         messageCenterMetadataModel.approveStatus,
                         messageCenterMetadataModel.lastedReadMsgId,
                         messageCenterMetadataModel.lastedReadTime,
                         messageCenterMetadataModel.lastedMsgId,
                         messageCenterMetadataModel.lastedMsgSenderName,
                         messageCenterMetadataModel.lastedMsgTime,
                         messageCenterMetadataModel.lastedMsgContent,
                         messageCenterMetadataModel.unReadMsgCount,
                         messageCenterMetadataModel.createTime,
                         messageCenterMetadataModel.isTop];
                        
                    }else{
                        
                        SQLStr = [NSString stringWithFormat:@"update MsgMetadata set approveStatus = '%@' where GroupId = '%@' and accountId = '%@'",messageCenterMetadataModel.approveStatus,messageCenterMetadataModel.groupId,[MessageTool getUserID]];
                        
                        [_dataBaseStore updateDataWithSql:SQLStr];
                    }
                     
                     */
                    
                    //这里使用用户ID，而不是聊天中的userID
                    messageCenterMetadataModel.accountId = [MessageTool getUserID];
                    
                    [_dataBaseStore updateDataWithSql:SQLStr,
                     messageCenterMetadataModel.accountId,
                     messageCenterMetadataModel.groupId,
                     messageCenterMetadataModel.groupName,
                     messageCenterMetadataModel.avatar,
                     messageCenterMetadataModel.avatarCache,
                     messageCenterMetadataModel.groupType,
                     messageCenterMetadataModel.companyName,
                     messageCenterMetadataModel.approveStatus,
                     messageCenterMetadataModel.lastedReadMsgId,
                     messageCenterMetadataModel.lastedReadTime,
                     messageCenterMetadataModel.lastedMsgId,
                     messageCenterMetadataModel.lastedMsgSenderName,
                     messageCenterMetadataModel.lastedMsgTime,
                     messageCenterMetadataModel.lastedMsgContent,
                     messageCenterMetadataModel.unReadMsgCount,
                     messageCenterMetadataModel.createTime,
                     messageCenterMetadataModel.isTop];
                    
                }
                
            }
        }
        
    }
    
    [MessageTool setDBChange:@"YES"];
    
}

- (NSArray *)fetchDataInfosWithType:(MessageCenterDBManagerType)tableType conditionName:(NSString *)conditionName SQLvalue:(NSString *)SQLvalue messageModel:(MessageCenterMessageModel *)messageModel number:(NSInteger)number{
    
    NSString       *SQLStr      = nil;
    NSMutableArray *resultDatas = [[NSMutableArray alloc] init];
    
    if (tableType == MessageCenterDBManagerTypeMESSAGE) {
        
        NSArray *groupArr = [self fetchDataInfosWithType:MessageCenterDBManagerTypeMETADATA conditionName:conditionName SQLvalue:SQLvalue];
        
        if (groupArr.count != 0) {
            MessageCenterMetadataModel *messageCenterMetadataModel = groupArr[0];
            
            if ([messageCenterMetadataModel.unReadMsgCount intValue] > number) {
                
                SQLStr = [NSString stringWithFormat:@"select * from (select * from (select * from UserMessage where %@ = '%@' and accountId = '%@' order by CreateTime desc) limit %d,%d) order by CreateTime",conditionName,SQLvalue,[MessageTool getUserID],0,[messageCenterMetadataModel.unReadMsgCount intValue]];
                
            }else{
                
                if (!messageModel) {
                    
                    SQLStr = [NSString stringWithFormat:@"select * from (select * from (select * from UserMessage where %@ = '%@' and accountId = '%@' order by CreateTime desc) limit %d,%d) order by CreateTime",conditionName,SQLvalue,[MessageTool getUserID],0,(int)number];
                    
                }else{
                    
                    SQLStr = [NSString stringWithFormat:@"select * from (select * from (select * from UserMessage where %@ = '%@' and accountId = '%@' and  CreateTime < '%@' order by CreateTime desc) limit %d,%d) order by CreateTime",conditionName,SQLvalue,[MessageTool getUserID],messageModel.createTime,0,(int)number];
                }
            }
        }else{
            SQLStr = [NSString stringWithFormat:@"select * from (select * from (select * from UserMessage where %@ = '%@' and accountId = '%@' order by CreateTime desc) limit %d,%d) order by CreateTime",conditionName,SQLvalue,[MessageTool getUserID],0,(int)number];
        }
        
        
        
        
        [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
            
            MessageCenterMessageModel *messageCenterMessageModel = [[MessageCenterMessageModel alloc] init];
            messageCenterMessageModel.userMessageId = [set stringForColumn:@"UserMessageId"];
            messageCenterMessageModel.userId        = [set stringForColumn:@"UserId"];
            messageCenterMessageModel.messageId     = [set stringForColumn:@"MessageId"];
            messageCenterMessageModel.msgContent    = [set stringForColumn:@"MsgContent"];
            messageCenterMessageModel.createTime    = [set stringForColumn:@"CreateTime"];
            messageCenterMessageModel.Status        = [set stringForColumn:@"Status"];
            messageCenterMessageModel.clientMsgId   = [set stringForColumn:@"clientMsgId"];
            messageCenterMessageModel.type          = [set stringForColumn:@"type"];
            messageCenterMessageModel.creditApplicationStatus = [set stringForColumn:@"creditApplicationStatus"];
            
            [resultDatas addObject:messageCenterMessageModel];
            
        } Sql:SQLStr];
    }
    
    return resultDatas;
}

- (NSArray *)fetchDataInfosWithType:(MessageCenterDBManagerType)tableType conditionName:(NSString *)conditionName SQLvalue:(NSString *)SQLvalue{
    
    NSMutableArray *resultDatas = [[NSMutableArray alloc] init];
    NSString       *SQLStr      = nil;
    
    
    if (tableType == MessageCenterDBManagerTypeMESSAGE) {
        
        //群组取出消息(根据groupid或者targetid查找消息，然后根据消息查找对应用户（获取用户信息）)
        
        SQLStr = [NSString stringWithFormat:@"select * from UserMessage join User on UserMessage.UserId = User.UserId where %@ = '%@'",conditionName,SQLvalue];
        
        [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
            
            MessageCenterMessageModel *messageCenterMessageModel = [[MessageCenterMessageModel alloc] init];
            messageCenterMessageModel.userMessageId = [set stringForColumn:@"UserMessageId"];
            messageCenterMessageModel.accountId    = [set stringForColumn:@"AccountId"];
            messageCenterMessageModel.userId       = [set stringForColumn:@"UserId"];
            messageCenterMessageModel.messageId    = [set stringForColumn:@"MessageId"];
            messageCenterMessageModel.msgContent   = [set stringForColumn:@"MsgContent"];
            messageCenterMessageModel.createTime   = [set stringForColumn:@"CreateTime"];
            messageCenterMessageModel.Status       = [set stringForColumn:@"Status"];
            messageCenterMessageModel.personName   = [set stringForColumn:@"PersonName"];
            messageCenterMessageModel.avatar       = [set stringForColumn:@"Avatar"];
            messageCenterMessageModel.clientMsgId  = [set stringForColumn:@"clientMsgId"];
            messageCenterMessageModel.type         = [set stringForColumn:@"type"];
            messageCenterMessageModel.creditApplicationStatus = [set stringForColumn:@"creditApplicationStatus"];
            
            [resultDatas addObject:messageCenterMessageModel];
            
        } Sql:SQLStr];
        
    }else if (tableType == MessageCenterDBManagerTypeUSER) {
        
        SQLStr = [NSString stringWithFormat:@"select * from User where %@ = '%@'",conditionName,SQLvalue];
        
        [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
            
            MessageCenterUserModel *messageCenterUserModel = [[MessageCenterUserModel alloc] init];
            messageCenterUserModel.mID      = [set stringForColumn:@"MID"];
            messageCenterUserModel.userId   = [set stringForColumn:@"UserId"];
            messageCenterUserModel.personName = [set stringForColumn:@"PersonName"];
            messageCenterUserModel.userRole = [set stringForColumn:@"UserRole"];
            messageCenterUserModel.avatar     = [set stringForColumn:@"Avatar"];
            messageCenterUserModel.avatarCache = [set stringForColumn:@"AvatarCache"];
            messageCenterUserModel.userName    = [set stringForColumn:@"UserName"];
            messageCenterUserModel.userType    = [set stringForColumn:@"UserType"];
            messageCenterUserModel.PhoneNo     = [set stringForColumn:@"PhoneNo"];
            
            [resultDatas addObject:messageCenterUserModel];
            
        } Sql:SQLStr];
        
    }else if (tableType == MessageCenterDBManagerTypeMETADATA) {
        
        SQLStr = [NSString stringWithFormat:@"select * from MsgMetadata where %@ = '%@' and AccountId = '%@'",conditionName,SQLvalue,[MessageTool getUserID]];
        
        
        [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
            
            MessageCenterMetadataModel *messageCenterMetadataModel = [[MessageCenterMetadataModel alloc] init];
            messageCenterMetadataModel.msgMetadataId = [set stringForColumn:@"MsgMetadataId"];
            messageCenterMetadataModel.accountId = [set stringForColumn:@"AccountId"];
            messageCenterMetadataModel.groupId = [set stringForColumn:@"GroupId"];
            messageCenterMetadataModel.groupName = [set stringForColumn:@"GroupName"];
            messageCenterMetadataModel.avatar = [set stringForColumn:@"Avatar"];
            messageCenterMetadataModel.avatarCache = [set stringForColumn:@"AvatarCache"];
            messageCenterMetadataModel.groupType = [set stringForColumn:@"GroupType"];
            messageCenterMetadataModel.companyName = [set stringForColumn:@"CompanyName"];
            messageCenterMetadataModel.approveStatus = [set stringForColumn:@"ApproveStatus"];
            messageCenterMetadataModel.lastedReadMsgId = [set stringForColumn:@"LastedReadMsgId"];
            messageCenterMetadataModel.lastedReadTime = [set stringForColumn:@"LastedReadTime"];
            messageCenterMetadataModel.lastedMsgId = [set stringForColumn:@"LastedMsgId"];
            messageCenterMetadataModel.lastedMsgSenderName = [set stringForColumn:@"LastedMsgSenderName"];
            messageCenterMetadataModel.lastedMsgTime = [set stringForColumn:@"LastedMsgTime"];
            messageCenterMetadataModel.lastedMsgContent = [set stringForColumn:@"LastedMsgContent"];
            messageCenterMetadataModel.unReadMsgCount = [set stringForColumn:@"UnReadMsgCount"];
            messageCenterMetadataModel.createTime = [set stringForColumn:@"CreateTime"];
            messageCenterMetadataModel.isTop = [set stringForColumn:@"isTop"];
            
            [resultDatas addObject:messageCenterMetadataModel];
            
            
        } Sql:SQLStr];
        
        
    }
    
    return resultDatas;
    
}

/**
 *  更新数据库
 *
 *  @param tableType 表名
 *  @param markID    指定ID
 *  @param datas     需要更新的数据
 */

- (void)updateTableWithType:(MessageCenterDBManagerType)tableType SQLvalue:(NSString *)SQLvalue data:(NSArray *)datas{
    
    NSString*     SQLStr = nil;
    
    for (int i = 0; i < datas.count; i ++) {
        
        NSDictionary *tempDict = datas[i];
        
        //更新
        if (tableType == MessageCenterDBManagerTypeMESSAGE) {
            
            MessageCenterMessageModel *messageCenterMessageModel = [[MessageCenterMessageModel alloc] init];
            [messageCenterMessageModel setValuesForKeysWithDictionary:tempDict];
            
            messageCenterMessageModel.accountId = [MessageTool getUserID];
            
            SQLStr = [NSString stringWithFormat:
                      [_DBAPIManager updateTableSQLWithTableType:MessageCenterDBManagerTypeMESSAGE key:@"MessageId"],SQLvalue,[MessageTool getUserID]];

            [_dataBaseStore updateDataWithSql:SQLStr,
             messageCenterMessageModel.accountId,
             messageCenterMessageModel.userId,
             messageCenterMessageModel.messageId,
             messageCenterMessageModel.groupId,
             messageCenterMessageModel.msgContent,
             messageCenterMessageModel.createTime,
             messageCenterMessageModel.Status,
             messageCenterMessageModel.clientMsgId,
             messageCenterMessageModel.type,
             messageCenterMessageModel.creditApplicationStatus
             ];
            
            
        }else if (tableType == MessageCenterDBManagerTypeUSER) {
            
            MessageCenterUserModel *messageCenterUserModel = [[MessageCenterUserModel alloc] init];
            [messageCenterUserModel setValuesForKeysWithDictionary:tempDict];
            
            
            SQLStr = [NSString stringWithFormat:[_DBAPIManager updateTableSQLWithTableType:MessageCenterDBManagerTypeUSER key:@"UserId"],SQLvalue];
            
            [_dataBaseStore updateDataWithSql:SQLStr,
             messageCenterUserModel.userId,
             messageCenterUserModel.personName,
             messageCenterUserModel.userRole,
             messageCenterUserModel.avatar,
             messageCenterUserModel.avatarCache,
             messageCenterUserModel.userName,
             messageCenterUserModel.userType,
             messageCenterUserModel.PhoneNo];
            
        }else if (tableType == MessageCenterDBManagerTypeMETADATA) {
            
            MessageCenterMetadataModel *messageCenterMetadataModel = [[MessageCenterMetadataModel alloc] init];
            [messageCenterMetadataModel setValuesForKeysWithDictionary:tempDict];
            
            SQLStr = [NSString stringWithFormat:
                      [_DBAPIManager updateTableSQLWithTableType:MessageCenterDBManagerTypeMETADATA key:@"GroupId"],SQLvalue,[MessageTool getUserID]];
            
            //同上
            messageCenterMetadataModel.accountId = [MessageTool getUserID];
            
            [_dataBaseStore updateDataWithSql:SQLStr,
             messageCenterMetadataModel.accountId,
             messageCenterMetadataModel.groupId,
             messageCenterMetadataModel.groupName,
             messageCenterMetadataModel.avatar,
             messageCenterMetadataModel.avatarCache,
             messageCenterMetadataModel.groupType,
             messageCenterMetadataModel.companyName,
             messageCenterMetadataModel.approveStatus,
             messageCenterMetadataModel.lastedReadMsgId,
             messageCenterMetadataModel.lastedReadTime,
             messageCenterMetadataModel.lastedMsgId,
             messageCenterMetadataModel.lastedMsgSenderName,
             messageCenterMetadataModel.lastedMsgTime,
             messageCenterMetadataModel.lastedMsgContent,
             messageCenterMetadataModel.createTime,
             messageCenterMetadataModel.isTop
             ];
            

            [MessageTool setDBChange:@"YES"];
            
            
        }
    }
}

- (void)markTopTableWithType:(MessageCenterDBManagerType)tableType SQLvalue:(NSString *)SQLvalue{
    
    if (tableType == MessageCenterDBManagerTypeMETADATA) {
        
        NSString *SQLStr = [NSString stringWithFormat:@"update MsgMetadata set isTop = 'NO' where accountId = '%@'",[MessageTool getUserID]];
        [_dataBaseStore updateDataWithSql:SQLStr];
        
        if (SQLvalue) {
            SQLStr = [NSString stringWithFormat:@"update MsgMetadata set isTop = '%@' where GroupId = '%@' and accountId = '%@' ",@"YES",SQLvalue,[MessageTool getUserID]];
            [_dataBaseStore updateDataWithSql:SQLStr];
        }
    }
    
    [MessageTool setDBChange:@"YES"];
    
    
}

- (void)updateDataTableWithType:(MessageCenterDBManagerType)tableType SQLvalue:(NSString *)SQLvalue parameters:(NSDictionary *)parameters {
    
    if (tableType == MessageCenterDBManagerTypeMETADATA) {
        
        
//        if (![self existTableWithType:tableType markID:SQLvalue]) {
//            
//
//            //如果不存在这条数据
//            
//            [self addDataToTableWithType:tableType data:[[NSArray alloc] initWithObjects:parameters, nil]];
//            
//            
//        }else{
        
            NSMutableString *resultSQLStr = [[NSMutableString alloc] initWithString:@"update MsgMetadata set "];
        
            NSArray *keysArr = parameters.allKeys;
            
            for (int i = 0; i < keysArr.count; i ++ ) {
                
                NSString *keyStr = keysArr[i];
                NSString *valueStr = parameters[keyStr];
                
                if (i != keysArr.count - 1) {
                    
                    if ([keyStr isEqualToString:@"UnReadMsgCount"]) {
                        if (![valueStr isEqualToString:@"-1"]) {
                            [resultSQLStr appendFormat:@"%@ = %@, ",keyStr,valueStr];
                        }
                    }else{
                        if (![valueStr isEqualToString:@"-1"]) {
                            [resultSQLStr appendFormat:@"%@ = '%@', ",keyStr,valueStr];
                        }
                        
                    }
                    
                }else{
                    
                    if ([keyStr isEqualToString:@"UnReadMsgCount"]) {
                        
                        if (![valueStr isEqualToString:@"-1"]) {
                            [resultSQLStr appendFormat:@"%@ = %@",keyStr,valueStr];
                        }
                        
                    }else{
                        
                        if (![valueStr isEqualToString:@"-1"]) {
                            [resultSQLStr appendFormat:@"%@ = '%@'",keyStr,valueStr];
                        }
                        
                    }
                    
                }
                
            }
            
            [resultSQLStr appendFormat:@"where GroupId = '%@' and accountId = '%@'",SQLvalue,[MessageTool getUserID]];
            
            [_dataBaseStore updateDataWithSql:resultSQLStr];
        
            /*
            if (!parameters[@"ApproveStatus"] || [parameters[@"ApproveStatus"] isKindOfClass:[NSNull class]] || 0 == [parameters[@"ApproveStatus"] length]) {
                
                NSArray *keysArr = parameters.allKeys;
                
                for (int i = 0; i < keysArr.count; i ++ ) {
                    
                    NSString *keyStr = keysArr[i];
                    NSString *valueStr = parameters[keyStr];
                    
                    if (i != keysArr.count - 1) {
                        
                        if ([keyStr isEqualToString:@"UnReadMsgCount"]) {
                            if (![valueStr isEqualToString:@"-1"]) {
                                [resultSQLStr appendFormat:@"%@ = %@, ",keyStr,valueStr];
                            }
                        }else{
                            if (![valueStr isEqualToString:@"-1"]) {
                                [resultSQLStr appendFormat:@"%@ = '%@', ",keyStr,valueStr];
                            }
                            
                        }
                        
                    }else{
                        
                        if ([keyStr isEqualToString:@"UnReadMsgCount"]) {
                            
                            if (![valueStr isEqualToString:@"-1"]) {
                                [resultSQLStr appendFormat:@"%@ = %@",keyStr,valueStr];
                            }
                            
                        }else{
                            
                            if (![valueStr isEqualToString:@"-1"]) {
                                [resultSQLStr appendFormat:@"%@ = '%@'",keyStr,valueStr];
                            }
                            
                        }
                        
                    }
                    
                }
                
                [resultSQLStr appendFormat:@"where GroupId = '%@' and accountId = '%@'",SQLvalue,[MessageTool getUserID]];
                
                [_dataBaseStore updateDataWithSql:resultSQLStr];

                
            }else{
                
                resultSQLStr = [NSMutableString stringWithFormat:@"update MsgMetadata set approveStatus = '%@' where GroupId = '%@' and accountId = '%@'",parameters[@"ApproveStatus"],SQLvalue,[MessageTool getUserID]];
                
                [_dataBaseStore updateDataWithSql:resultSQLStr];
                
            }
             */
        
//        }
        
    }
    
    [MessageTool setDBChange:@"YES"];
    
}

- (void)markReadTableWithType:(MessageCenterDBManagerType)tableType SQLvalue:(NSString *)SQLvalue parameters:(NSDictionary *)parameters {
    
    [self updateDataTableWithType:tableType SQLvalue:SQLvalue parameters:parameters];
    
}

- (void)updateGroupLastedMessageWithTableWithType:(MessageCenterDBManagerType)tableType SQLvalue:(NSString *)SQLvalue parameters:(NSDictionary *)parameters {
    
    [self updateDataTableWithType:tableType SQLvalue:SQLvalue parameters:parameters];
    
}

- (void)deleteDataWithTableWithType:(MessageCenterDBManagerType)tableType SQLvalue:(NSString *)SQLvalue {
    
    if (tableType == MessageCenterDBManagerTypeMETADATA) {
        
        NSString *SQLStr = [NSString stringWithFormat:@"delete from MsgMetadata where groupId = '%@' and AccountId = '%@'",SQLvalue,[MessageTool getUserID]];
        
        [_dataBaseStore updateDataWithSql:SQLStr];
        
    }else if (tableType == MessageCenterDBManagerTypeMESSAGE) {
        
        NSString *SQLStr = [NSString stringWithFormat:@"delete from UserMessage where groupId = '%@' and AccountId = '%@'",SQLvalue,[MessageTool getUserID]];
        [_dataBaseStore updateDataWithSql:SQLStr];
        
    }
    
    [MessageTool setDBChange:@"YES"];
}

- (NSArray *)deleteDataWithTableWithType:(MessageCenterDBManagerType)tableType groupReadType:(GroupReadType)readType  SQLvalue:(NSString *)SQLvalue currentPage:(NSInteger)currentPage isNeedAllData:(BOOL)isNeedAllData{
    
    NSArray *newDataArr = [[NSArray alloc] init];
    
    if (tableType == MessageCenterDBManagerTypeMETADATA) {
        
        [self deleteDataWithTableWithType:tableType SQLvalue:SQLvalue];
        
        newDataArr = [self fetchGroupsWithGroupReadType:readType currentPage:currentPage isNeedAllData:(BOOL)isNeedAllData];
    }
    
    [MessageTool setDBChange:@"YES"];
    
    return newDataArr;
}

- (NSArray *)fetchGroupsWithGroupReadType:(GroupReadType)readType currentPage:(NSInteger)currentPage isNeedAllData:(BOOL)isNeedAllData {
    
    //按最新消息时间
    
    NSString *SQLStr = @"";
    NSMutableArray *resultDatas = [[NSMutableArray alloc] init];
    
    switch (readType) {
        case GroupReadTypeAll:
            
            if (isNeedAllData) {
                SQLStr = [NSString stringWithFormat:@"select * from (select * from MsgMetadata where accountId = '%@' order by LastedMsgTime desc) limit %d,%d",[MessageTool getUserID],0,((int)currentPage) * GROUP_LIST_NUMBER];
            }else{
                SQLStr = [NSString stringWithFormat:@"select * from (select * from MsgMetadata where accountId = '%@' order by LastedMsgTime desc) limit %d,%d",[MessageTool getUserID],((int)currentPage - 1) * GROUP_LIST_NUMBER,GROUP_LIST_NUMBER];
            }
            
            break;
        case GroupReadTypeNoRead:
            break;
        case GroupReadTypeRead:
            break;
        default:
            break;
    }
    
    MessageCenterMetadataModel *topMessageModel = [[MessageCenterMetadataModel alloc] init];
    
    BOOL isNeedTop = NO;
    
    if ((isNeedAllData || (!isNeedAllData && currentPage == 1)) && !([[MessageTool topGroupId] isEqualToString:@"NULL"] || [[MessageTool topGroupId] isKindOfClass:[NSNull class]])) {
        //置顶
        
        NSString *topSQL = [NSString stringWithFormat:@"select * from MsgMetadata where accountId = '%@' and groupId = '%@'",[MessageTool getUserID],[MessageTool topGroupId]];
        
        [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
            
            topMessageModel.msgMetadataId = [set stringForColumn:@"MsgMetadataId"];
            topMessageModel.accountId = [set stringForColumn:@"AccountId"];
            topMessageModel.groupId = [set stringForColumn:@"GroupId"];
            topMessageModel.groupName = [set stringForColumn:@"GroupName"];
            topMessageModel.avatar = [set stringForColumn:@"Avatar"];
            topMessageModel.avatarCache = [set stringForColumn:@"AvatarCache"];
            topMessageModel.groupType = [set stringForColumn:@"GroupType"];
            topMessageModel.companyName = [set stringForColumn:@"CompanyName"];
            topMessageModel.approveStatus = [set stringForColumn:@"ApproveStatus"];
            topMessageModel.lastedReadMsgId = [set stringForColumn:@"LastedReadMsgId"];
            topMessageModel.lastedReadTime = [set stringForColumn:@"LastedReadTime"];
            topMessageModel.lastedMsgId = [set stringForColumn:@"LastedMsgId"];
            topMessageModel.lastedMsgSenderName = [set stringForColumn:@"LastedMsgSenderName"];
            topMessageModel.lastedMsgTime = [set stringForColumn:@"LastedMsgTime"];
            topMessageModel.lastedMsgContent = [set stringForColumn:@"LastedMsgContent"];
            topMessageModel.unReadMsgCount = [set stringForColumn:@"UnReadMsgCount"];
            topMessageModel.createTime = [set stringForColumn:@"CreateTime"];
            topMessageModel.isTop = [set stringForColumn:@"isTop"];
            
        } Sql:topSQL];
        
        if (topMessageModel.groupId) {
            isNeedTop = YES;
        }
        
    }
    
    if (isNeedTop) {
        
        NSMutableArray *topTempArr = [[NSMutableArray alloc] initWithObjects:topMessageModel, nil];
        
        for (int i = 0; i < resultDatas.count; i ++) {
            
            MessageCenterMetadataModel *subModel = resultDatas[i];
            
            if (![topMessageModel.groupId isEqualToString:subModel.groupId]) {
                [topTempArr addObject:resultDatas[i]];
            }
        }
        
        resultDatas = [[NSMutableArray alloc] initWithArray:topTempArr];
        
    }
    
    
    [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
        
        MessageCenterMetadataModel *messageCenterMetadataModel = [[MessageCenterMetadataModel alloc] init];
        
        messageCenterMetadataModel.msgMetadataId = [set stringForColumn:@"MsgMetadataId"];
        messageCenterMetadataModel.accountId = [set stringForColumn:@"AccountId"];
        messageCenterMetadataModel.groupId = [set stringForColumn:@"GroupId"];
        messageCenterMetadataModel.groupName = [set stringForColumn:@"GroupName"];
        messageCenterMetadataModel.avatar = [set stringForColumn:@"Avatar"];
        messageCenterMetadataModel.avatarCache = [set stringForColumn:@"AvatarCache"];
        messageCenterMetadataModel.groupType = [set stringForColumn:@"GroupType"];
        messageCenterMetadataModel.companyName = [set stringForColumn:@"CompanyName"];
        messageCenterMetadataModel.approveStatus = [set stringForColumn:@"ApproveStatus"];
        messageCenterMetadataModel.lastedReadMsgId = [set stringForColumn:@"LastedReadMsgId"];
        messageCenterMetadataModel.lastedReadTime = [set stringForColumn:@"LastedReadTime"];
        messageCenterMetadataModel.lastedMsgId = [set stringForColumn:@"LastedMsgId"];
        messageCenterMetadataModel.lastedMsgSenderName = [set stringForColumn:@"LastedMsgSenderName"];
        messageCenterMetadataModel.lastedMsgTime = [set stringForColumn:@"LastedMsgTime"];
        messageCenterMetadataModel.lastedMsgContent = [set stringForColumn:@"LastedMsgContent"];
        messageCenterMetadataModel.unReadMsgCount = [set stringForColumn:@"UnReadMsgCount"];
        messageCenterMetadataModel.createTime = [set stringForColumn:@"CreateTime"];
        messageCenterMetadataModel.isTop = [set stringForColumn:@"isTop"];
        
        //如果有置顶信息，不添加
        if (![messageCenterMetadataModel.isTop isEqualToString:@"YES"] && ![messageCenterMetadataModel.groupId isEqualToString:topMessageModel.groupId]) {
            [resultDatas addObject:messageCenterMetadataModel];
        }
        
        
    } Sql:SQLStr];
    
    
    //如果本地缓存不足GROUP_LIST_NUMBER条数据，需要重新从服务器返回
    if (resultDatas.count != GROUP_LIST_NUMBER && !isNeedAllData) {
        return nil;
    }
    
    //本操作在于，查询数据库每个组的最新消息，如果该消息时间比组数据记录的最新消息时间早，说明组消息记录的最新消息不正确，需要纠正
    for (int i = 0; i < resultDatas.count; i ++) {
        
        MessageCenterMetadataModel *tempMetadataModel = resultDatas[i];
        
        NSString *selectMessageSQL = [NSString stringWithFormat:@"select * from (select * from UserMessage where GroupId = '%@' and accountId = '%@' and Status = '1' order by CreateTime desc) limit %d,%d",tempMetadataModel.groupId,tempMetadataModel.accountId,0,1];
        
        MessageCenterMessageModel *messageModel = [[MessageCenterMessageModel alloc] init];
        
        [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
            
            messageModel.groupId = [set stringForColumn:@"GroupId"];
            messageModel.userMessageId = [set stringForColumn:@"UserMessageId"];
            messageModel.accountId     = [set stringForColumn:@"AccountId"];
            messageModel.userId        = [set stringForColumn:@"UserId"];
            messageModel.messageId     = [set stringForColumn:@"MessageId"];
            messageModel.msgContent    = [set stringForColumn:@"MsgContent"];
            messageModel.createTime    = [set stringForColumn:@"CreateTime"];
            messageModel.Status        = [set stringForColumn:@"Status"];
            messageModel.clientMsgId   = [set stringForColumn:@"clientMsgId"];
            messageModel.type          = [set stringForColumn:@"type"];
            messageModel.creditApplicationStatus = [set stringForColumn:@"creditApplicationStatus"];
            
        } Sql:selectMessageSQL];
        
        if (messageModel.accountId) {
            
            //如果改message存在
            
            //更新数据库数据
            NSString *updateMetadataSQLStr = [NSString stringWithFormat:
                                              [_DBAPIManager updateTableSQLWithTableType:MessageCenterDBManagerTypeMESSAGE key:@"MessageId"],messageModel.messageId,[MessageTool getUserID]];
            
            [_dataBaseStore updateDataWithSql:updateMetadataSQLStr,
             messageModel.accountId,
             messageModel.userId,
             messageModel.messageId,
             messageModel.groupId,
             messageModel.msgContent,
             messageModel.createTime,
             messageModel.Status,
             messageModel.clientMsgId,
             messageModel.type,
             messageModel.creditApplicationStatus
             ];
            
            tempMetadataModel.lastedMsgId = messageModel.messageId;
            tempMetadataModel.lastedMsgContent = messageModel.msgContent;
            tempMetadataModel.lastedMsgTime = messageModel.createTime;
            
        }
        
        NSString *systemMessageSQL = [NSString stringWithFormat:@"select * from (select * from UserMessage where GroupId = '%@' and accountId = '%@' and type = '101' order by CreateTime desc) limit %d,%d",tempMetadataModel.groupId,tempMetadataModel.accountId,0,1];
        
        MessageCenterMessageModel *systemMessageModel = [[MessageCenterMessageModel alloc] init];
        
        [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
            
            systemMessageModel.groupId = [set stringForColumn:@"GroupId"];
            systemMessageModel.userMessageId = [set stringForColumn:@"UserMessageId"];
            systemMessageModel.accountId     = [set stringForColumn:@"AccountId"];
            systemMessageModel.userId        = [set stringForColumn:@"UserId"];
            systemMessageModel.messageId     = [set stringForColumn:@"MessageId"];
            systemMessageModel.msgContent    = [set stringForColumn:@"MsgContent"];
            systemMessageModel.createTime    = [set stringForColumn:@"CreateTime"];
            systemMessageModel.Status        = [set stringForColumn:@"Status"];
            systemMessageModel.clientMsgId   = [set stringForColumn:@"clientMsgId"];
            systemMessageModel.type          = [set stringForColumn:@"type"];
            systemMessageModel.creditApplicationStatus = [set stringForColumn:@"creditApplicationStatus"];
            
        } Sql:systemMessageSQL];
        
        if (systemMessageModel.accountId && systemMessageModel.creditApplicationStatus && ![systemMessageModel.creditApplicationStatus isEqualToString:@"(null)"]) {
            
            //更新数据库数据approveStatus
            NSString *systemUpdateMetadataSQLStr = [NSMutableString stringWithFormat:@"update MsgMetadata set approveStatus = '%@' where GroupId = '%@' and accountId = '%@'",systemMessageModel.creditApplicationStatus,systemMessageModel.groupId,[MessageTool getUserID]];
            
            [_dataBaseStore updateDataWithSql:systemUpdateMetadataSQLStr];
            
        }
        
    }
    
    
    
    //2015-11-10T01:16:26.000Z
    //系统群为结束状态（-1，-5，-6，7）60天，60后前端不保留，自动删除
    //消息群如被激活后，连续3天未有访问，前端不保留，自动删除
    
    /*
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (int i = 0; i < resultDatas.count; i ++) {
        
        MessageCenterMetadataModel *model = resultDatas[i];
        
        if (-1 == [self compareModel:model]) {
            [tempArr addObject:model];
        }
    }
    
    resultDatas = [[NSMutableArray alloc] initWithArray:tempArr];
    
    int pos = -1;
    
    for (int i = 0 ; i < resultDatas.count ; i ++) {
        
        MessageCenterMetadataModel *model = resultDatas[i];
        
        if ([model.isTop isEqualToString:@"YES"]) {
            pos = i;
            break;
        }
        
    }
    
    if (pos != -1) {
        [resultDatas exchangeObjectAtIndex:0 withObjectAtIndex:pos];
    }
     
     */
    
    return resultDatas;
}

- (void)loadDataWhenPushHistoryMessage {
    
    NSMutableArray *tempDataSource = [[NSMutableArray alloc] init];
    
    NSString *selectStr = [NSString stringWithFormat:@"select GroupId,count(*) as TNumbers from UserMessage group by GroupId"];
    
    [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
        
        MessageCenterMetadataModel *metaDataModel = [[MessageCenterMetadataModel alloc] init];
        metaDataModel.groupId = [set stringForColumn:@"GroupId"];
        metaDataModel.TNumbers = [set stringForColumn:@"TNumbers"];
        
        [tempDataSource addObject:metaDataModel];
        
    } Sql:selectStr];

    
    //获取组信息 GroupId
    
    for (int i = 0; i < tempDataSource.count; i ++) {
        
        MessageCenterMetadataModel *metaDataModel = tempDataSource[i];
        
        //组未读消息设置(无论有没有组全部更新)
        
        NSString *selectSql = [NSString stringWithFormat:@"select * from (select * from UserMessage where GroupId = '%@' and accountId = '%@' order by CreateTime desc) limit %d,%d",metaDataModel.groupId,[MessageTool getUserID],0,1];
        
        NSString *numbers = metaDataModel.TNumbers;
        
        NSMutableArray *resultDatas = [[NSMutableArray alloc] init];
        
        [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
            
            MessageCenterMessageModel *messageCenterMessageModel = [[MessageCenterMessageModel alloc] init];
            messageCenterMessageModel.userMessageId = [set stringForColumn:@"UserMessageId"];
            messageCenterMessageModel.accountId     = [set stringForColumn:@"AccountId"];
            messageCenterMessageModel.userId        = [set stringForColumn:@"UserId"];
            messageCenterMessageModel.messageId     = [set stringForColumn:@"MessageId"];
            messageCenterMessageModel.msgContent    = [[set stringForColumn:@"MsgContent"] unescape];
            messageCenterMessageModel.createTime    = [set stringForColumn:@"CreateTime"];
            messageCenterMessageModel.Status        = [set stringForColumn:@"Status"];
            messageCenterMessageModel.clientMsgId   = [set stringForColumn:@"clientMsgId"];
            messageCenterMessageModel.type          = [set stringForColumn:@"type"];
            messageCenterMessageModel.creditApplicationStatus = [set stringForColumn:@"creditApplicationStatus"];
            
            [resultDatas addObject:messageCenterMessageModel];
            
        } Sql:selectSql];
        
        if (resultDatas.count > 0) {
            
            MessageCenterMessageModel *messageCenterMessageModel  = resultDatas[0];
            
            //如果没有组，则获取组信息
            if ([[[PomeloMessageCenterDBManager shareInstance] fetchDataInfosWithType:MessageCenterDBManagerTypeMETADATA conditionName:@"GroupId" SQLvalue:metaDataModel.groupId] count] == 0) {
                
                [self addDataToTableWithType:MessageCenterDBManagerTypeMETADATA data:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",metaDataModel.groupId],@"GroupId",numbers,@"UnReadMsgCount",[NSString stringWithFormat:@"%@",messageCenterMessageModel.messageId],@"LastedMsgId",[NSString stringWithFormat:@"%@",@""],@"LastedMsgSenderName",[NSString stringWithFormat:@"%@",messageCenterMessageModel.createTime],@"LastedMsgTime",[NSString stringWithFormat:@"%@",messageCenterMessageModel.msgContent],@"LastedMsgContent", nil], nil]];
                
                self.getGroupInfoChatHandler.parameters = @{@"groupId":metaDataModel.groupId};
                
                [self.getGroupInfoChatHandler chat];
                
            }else{
                
                //是否是纯历史的消息
                //当前计数 ＋ numbers
                
                [self updateGroupLastedMessageWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:[NSString stringWithFormat:@"%@",messageCenterMessageModel.groupId] parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"UnReadMsgCount + '%@'",numbers],@"UnReadMsgCount",[NSString stringWithFormat:@"%@",messageCenterMessageModel.messageId],@"LastedMsgId",[NSString stringWithFormat:@"%@",@""],@"LastedMsgSenderName",[NSString stringWithFormat:@"%@",messageCenterMessageModel.createTime],@"LastedMsgTime",[NSString stringWithFormat:@"%@",messageCenterMessageModel.msgContent],@"LastedMsgContent", nil]];
                
            }
            
        }
        
    }
    
    
    
}

/**
 *
 *  删除本地缓存
 *
 */
- (void)clearLocalDBData {
    
    //删除message表重新建立
    //删除MsgMetadata表重新建立
    
    //删除已发送的消息，发送失败保留一个星期 Status = '0'
    
    NSString *messageSQL = [NSString stringWithFormat:@"delete from UserMessage where accountId = '%@' and Status = '1'",[MessageTool getUserID]];
    
    NSString *msgMetadataSql = [NSString stringWithFormat:@"delete from MsgMetadata where accountId = '%@'",[MessageTool getUserID]];
    [_dataBaseStore updateDataWithSql:messageSQL];
    [_dataBaseStore updateDataWithSql:msgMetadataSql];
    
    [MessageTool setDBChange:@"YES"];
    
}

/**
 *  清除过时失败消息
 *
 *  @return void
 */

- (void)clearHistoryFailedMessage {
    
    //处理上传失败而且保留一个星期的数据
    
    NSTimeInterval weekSinceNowTimeInterval = [[NSDate date] timeIntervalSince1970];
    weekSinceNowTimeInterval -= 24 * 60 * 60 * 7;
    NSDate *beforeWeekDate = [NSDate dateWithTimeIntervalSince1970:weekSinceNowTimeInterval];
    
    NSDateFormatter *formatter = [MessageTool shareDateForMatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
    
    NSString *timeStr = [formatter stringFromDate:beforeWeekDate];
    
    NSString *messageSQL = [NSString stringWithFormat:@"delete from UserMessage where accountId = '%@' and  Status = '0' and CreateTime < '%@'",[MessageTool getUserID],timeStr];
    
    [_dataBaseStore updateDataWithSql:messageSQL];
    
    [MessageTool setDBChange:@"YES"];
    
}


/**
 *  判断数据库中是否存在指定ID的数据
 *
 *  @param tableType 表类型
 *  @param markID    userid或者MessageId或者groupid
 *
 *  @return BOOL
 *
 */
- (BOOL)existTableWithType:(MessageCenterDBManagerType)tableType markID:(NSString *)markID{
    
    NSString*     SQLStr = nil;
    
    if (tableType == MessageCenterDBManagerTypeMESSAGE) {
        
        SQLStr = [NSString stringWithFormat:[_DBAPIManager selectTableSQLWithTableType:MessageCenterDBManagerTypeMESSAGE key:@"MessageId"],markID,[MessageTool getUserID]];
        
    }else if (tableType == MessageCenterDBManagerTypeUSER) {
        
        SQLStr = [NSString stringWithFormat:[_DBAPIManager selectTableSQLWithTableType:MessageCenterDBManagerTypeUSER key:@"UserId"],markID];
        
    }else if (tableType == MessageCenterDBManagerTypeMETADATA) {
        
        SQLStr = [NSString stringWithFormat:[_DBAPIManager selectTableSQLWithTableType:MessageCenterDBManagerTypeMETADATA key:@"groupId"],markID,[MessageTool getUserID]];
        
    }
    
    NSMutableArray *resultDatas = [[NSMutableArray alloc] init];
    
    [_dataBaseStore getDataFromTableWithResultSet:^(FMResultSet *set) {
        
        NSObject *object = [[NSObject alloc] init];
        [resultDatas addObject:object];
        
        
    } Sql:SQLStr];
    
    if (resultDatas.count != 0) {
        return YES;
    }
    
    return NO;
}

- (NSInteger)compareModel:(MessageCenterMetadataModel *)model{
    
    NSTimeInterval  oneDay = 24*60*60*1;
    
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    
    //2015-11-10T01:16:26.000Z
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"TZ."];
    
    NSArray *times = [model.createTime componentsSeparatedByCharactersInSet:characterSet];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *createDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",times[0],times[1]]];
    
    NSTimeInterval createTimeInterval = [createDate timeIntervalSince1970];
    
    
    if (model.approveStatus && [model.approveStatus length] != 0) {
        if (-1 == [model.approveStatus intValue] || -5 == [model.approveStatus intValue] || -6 == [model.approveStatus intValue] || 7 == [model.approveStatus intValue]) {
            
            if ((nowTimeInterval - createTimeInterval) >= 60 * oneDay) {
                //大于60天
                return 1;
            }
            
        }else{
            
            
            if ((nowTimeInterval - createTimeInterval) >= 3 * oneDay) {
                //大于3天
                return 2;
            }
        }
        
    }
    
    return -1;
}


- (RYChatHandler *)getGroupInfoChatHandler {
    if (!_getGroupInfoChatHandler) {
        _getGroupInfoChatHandler = [[RYChatHandler alloc] initWithDelegate:[[ConnectToServer shareInstance] delegate]];
        _getGroupInfoChatHandler.chatServerType = RouteChatTypeGetGroupInfo;
    }
    return _getGroupInfoChatHandler;
}

@end
