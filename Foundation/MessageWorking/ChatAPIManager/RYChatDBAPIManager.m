//
//  RYChatDBAPIManager.m
//  Client
//
//  Created by wwt on 15/10/29.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import "RYChatDBAPIManager.h"
#import "MessageTool.h"

static RYChatDBAPIManager *shareManager = nil;

@interface RYChatDBAPIManager ()

@property (nonatomic, copy) NSArray  *tablesName;

//表名对应的字段
@property (nonatomic, copy) NSArray  *UserCols;
@property (nonatomic, copy) NSArray  *UserMessageCols;
@property (nonatomic, copy) NSArray  *UserMessageNoSendCols;
@property (nonatomic, copy) NSArray  *MsgMetadataCols;

//需要integer的字段数组
@property (nonatomic, copy) NSArray  *integerArr;
//需要text的字段数组
@property (nonatomic, copy) NSArray  *textArr;

//主键
@property (nonatomic, copy) NSArray  *keys;


@end

@implementation RYChatDBAPIManager

+ (instancetype)shareManager {
    
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        shareManager = [[RYChatDBAPIManager alloc] init];
    });
    return shareManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initDatas];
    }
    return self;
}

#pragma mark 数据初始化

- (void)initDatas {
    
    //UserId区分用户（误区）
    
    self.dbName = @"messageCenter.db";
    self.tablesName = @[@"User",@"UserMessage",@"MsgMetadata"];
    self.keys = @[@"MID",@"UserMessageId",@"MsgMetadataId"];
    
    self.UserCols = @[@"UserId",@"PersonName",@"UserRole",@"Avatar",@"AvatarCache",@"UserName",@"UserType",@"PhoneNo"];
    self.UserMessageCols = @[@"accountId",@"UserId",@"MessageId",@"GroupId",@"MsgContent",@"CreateTime",@"Status",@"clientMsgId",@"type",@"creditApplicationStatus"];
    self.MsgMetadataCols = @[@"AccountId",@"GroupId",@"GroupName",@"Avatar",@"AvatarCache",@"GroupType",@"CompanyName",@"ApproveStatus",@"LastedReadMsgId",@"LastedReadTime",@"LastedMsgId",@"LastedMsgSenderName",@"LastedMsgTime",@"LastedMsgContent",@"UnReadMsgCount",@"CreateTime",@"isTop"];
    
    self.integerArr = @[@"UnReadMsgCount"];
    self.textArr    = @[@"MsgContent",@"LastedMsgContent"];
    
}

- (NSString *)tableNameWithTableType:(MessageCenterDBManagerType)type {
    return self.tablesName[type];
}

- (NSString *)createTableSQLWithTableType:(MessageCenterDBManagerType)type {
    
    return [self getSQLPartStrWithType:SQLTypeCreate DBType:type key:@""];
}

- (NSString *)addTableSQLWithTableType:(MessageCenterDBManagerType)type {
    
    return [self getSQLPartStrWithType:SQLTypeAdd DBType:type key:@""];
}


- (NSString *)updateTableSQLWithTableType:(MessageCenterDBManagerType)type key:(NSString *)keyStr{
    
    return [self getSQLPartStrWithType:SQLTypeUpdate DBType:type key:(NSString *)keyStr];
}

- (NSString *)selectTableSQLWithTableType:(MessageCenterDBManagerType)type key:(NSString *)keyStr {
    
    return [self getSQLPartStrWithType:SQLTypeSelect DBType:type key:keyStr];
    
}

- (NSString *)getSQLPartStrWithType:(SQLType)type DBType:(MessageCenterDBManagerType)DBType key:(NSString *)keyStr{
    
    NSString *commonSQL = @"";
    
    switch (DBType) {
        case MessageCenterDBManagerTypeUSER:{
            commonSQL = [self getColStrWithArr:self.UserCols type:type DBType:DBType key:keyStr];
        }
            break;
        case MessageCenterDBManagerTypeMESSAGE:{
            commonSQL = [self getColStrWithArr:self.UserMessageCols type:type DBType:DBType key:keyStr];
        }
            break;
        case MessageCenterDBManagerTypeMETADATA:{
            commonSQL = [self getColStrWithArr:self.MsgMetadataCols type:type DBType:DBType key:keyStr];
        }
            break;
        default:
            break;
    }
    
    return commonSQL;
}

- (NSString *)getColStrWithArr:(NSArray *)colsArr type:(SQLType)type DBType:(MessageCenterDBManagerType)DBType  key:(NSString *)keyStr{
    NSMutableString *tempStr = nil;
    
    switch (type) {
        case SQLTypeCreate:{
            
            if (DBType == MessageCenterDBManagerTypeUSER) {
                
                tempStr = [[NSMutableString alloc] initWithFormat:@"(%@ integer PRIMARY KEY autoincrement,",self.keys[0]];
                
            }else if (DBType == MessageCenterDBManagerTypeMESSAGE) {
                tempStr = [[NSMutableString alloc] initWithFormat:@"(%@ integer PRIMARY KEY autoincrement,",self.keys[1]];
            }else {
                tempStr = [[NSMutableString alloc] initWithFormat:@"(%@ integer PRIMARY KEY autoincrement,",self.keys[2]];
            }
            
            
            for (int i = 0; i < colsArr.count; i ++) {
                
                if (i != colsArr.count - 1) {
                    
                    if ([self containsKeyWithArray:self.integerArr key:colsArr[i]]) {
                        [tempStr appendFormat:@"%@    integer,",colsArr[i]];
                    }else if ([self containsKeyWithArray:self.textArr key:colsArr[i]]) {
                        [tempStr appendFormat:@"%@    TEXT,",colsArr[i]];
                    }else{
                        [tempStr appendFormat:@"%@    varchar(100),",colsArr[i]];
                    }
                    
                }else{
                    
                    if ([self containsKeyWithArray:self.integerArr key:colsArr[i]]) {
                        [tempStr appendFormat:@"%@    integer);",colsArr[i]];
                    }else if ([self containsKeyWithArray:self.textArr key:colsArr[i]]) {
                        [tempStr appendFormat:@"%@    TEXT);",colsArr[i]];
                    }else{
                        [tempStr appendFormat:@"%@    varchar(100));",colsArr[i]];
                    }
                }
            }
            
        }
            break;
        case SQLTypeAdd:{
            
            tempStr = [[NSMutableString alloc] initWithString:@"insert into %@ "];
            
            switch (DBType) {
                case MessageCenterDBManagerTypeUSER:
                    tempStr = [[NSMutableString alloc] initWithFormat:tempStr,self.tablesName[MessageCenterDBManagerTypeUSER]];
                    break;
                case MessageCenterDBManagerTypeMESSAGE:
                    tempStr = [[NSMutableString alloc] initWithFormat:tempStr,self.tablesName[MessageCenterDBManagerTypeMESSAGE]];
                    break;
                case MessageCenterDBManagerTypeMETADATA:
                    tempStr = [[NSMutableString alloc] initWithFormat:tempStr,self.tablesName[MessageCenterDBManagerTypeMETADATA]];
                    break;
                default:
                    break;
            }
            
            NSMutableString *foreAddStr = [[NSMutableString alloc] initWithString:@" ("];
            
            for (int i = 0 ; i < colsArr.count ; i ++) {
                
                if (i != colsArr.count - 1) {
                    [foreAddStr appendFormat:@"%@,",colsArr[i]];
                }else{
                    [foreAddStr appendFormat:@"%@) ",colsArr[i]];
                }
            }
            
            NSMutableString *backAddStr = [[NSMutableString alloc] initWithString:@" values ("];
            
            for (int i = 0 ; i < colsArr.count ; i ++) {
                
                if (i != colsArr.count - 1) {
                    [backAddStr appendString:@"?,"];
                }else{
                    [backAddStr appendString:@"?);"];
                }
            }
            
            [tempStr appendFormat:@"%@%@",foreAddStr,backAddStr];
        }
            break;
        case SQLTypeUpdate:{
            
            tempStr = [[NSMutableString alloc] initWithString:@"update %@ "];
            
            switch (DBType) {
                case MessageCenterDBManagerTypeUSER:
                    tempStr = [[NSMutableString alloc] initWithFormat:tempStr,self.tablesName[MessageCenterDBManagerTypeUSER]];
                    break;
                case MessageCenterDBManagerTypeMESSAGE:
                    tempStr = [[NSMutableString alloc] initWithFormat:tempStr,self.tablesName[MessageCenterDBManagerTypeMESSAGE]];
                    break;
                case MessageCenterDBManagerTypeMETADATA:
                    tempStr = [[NSMutableString alloc] initWithFormat:tempStr,self.tablesName[MessageCenterDBManagerTypeMETADATA]];
                    break;
                default:
                    break;
            }
            NSMutableString *foreUpdateStr = [[NSMutableString alloc] initWithString:@"set "];
            
            for (int i = 0 ; i < colsArr.count ; i ++) {
                
                if (![colsArr[i] isEqualToString:@"UnReadMsgCount"]) {
                    if (i != colsArr.count - 1) {
                        [foreUpdateStr appendFormat:@"%@ = ?,",colsArr[i]];
                    }else{
                        [foreUpdateStr appendFormat:@"%@ = ?",colsArr[i]];
                    }
                }
                
            }
            
            
            
            NSMutableString *backUpdateStr = [[NSMutableString alloc] initWithFormat:@" where %@ = ",keyStr];
            
            if (DBType != MessageCenterDBManagerTypeUSER) {
                
                [backUpdateStr appendString:@"'%@' and accountId = '%@'"];
                
            }else{
                
                [backUpdateStr appendString:@"'%@'"];
                
            }
            [tempStr appendFormat:@"%@%@",foreUpdateStr,backUpdateStr];
            
            
        }
            break;
        case SQLTypeSelect:{
            
            tempStr = [[NSMutableString alloc] initWithString:@"select * from %@"];
            
            switch (DBType) {
                case MessageCenterDBManagerTypeUSER:
                    tempStr = [[NSMutableString alloc] initWithFormat:tempStr,self.tablesName[MessageCenterDBManagerTypeUSER]];
                    break;
                case MessageCenterDBManagerTypeMESSAGE:
                    tempStr = [[NSMutableString alloc] initWithFormat:tempStr,self.tablesName[MessageCenterDBManagerTypeMESSAGE]];
                    break;
                case MessageCenterDBManagerTypeMETADATA:
                    tempStr = [[NSMutableString alloc] initWithFormat:tempStr,self.tablesName[MessageCenterDBManagerTypeMETADATA]];
                    break;
                default:
                    break;
            }
            
            NSMutableString *backSelectStr = [[NSMutableString alloc] initWithFormat:@" where %@ = ",keyStr];
            
            if (DBType != MessageCenterDBManagerTypeUSER) {
                [backSelectStr appendString:@"'%@' and accountId = '%@'"];
            }else{
                [backSelectStr appendString:@"'%@'"];
            }
            
            
            [tempStr appendFormat:@"%@",backSelectStr];
            
        }
            break;
        default:
            break;
    }
    
    return tempStr;
}

- (BOOL)containsKeyWithArray:(NSArray *)array key:(NSString *)key {
    
    for (NSString *subStr in array) {
        if ([subStr isEqualToString:key]) {
            return YES;
        }
    }
    
    return NO;
}

@end
