//
//  RYChatDBAPIManager.h
//  Client
//
//  Created by wwt on 15/10/29.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PomeloMessageCenterDBManager.h"


typedef NS_ENUM(NSInteger, SQLType){
    /// 创建表SQL
    SQLTypeCreate = 11,
    /// 添加SQL
    SQLTypeAdd    = 13,
    /// 更新SQL
    SQLTypeUpdate = 17,
    /// 获取SQL
    SQLTypeSelect = 19
};

@interface RYChatDBAPIManager : NSObject

//数据库名
@property (nonatomic, copy) NSString *dbName;

+ (instancetype)shareManager;

- (NSString *)tableNameWithTableType:(MessageCenterDBManagerType)type;

- (NSString *)createTableSQLWithTableType:(MessageCenterDBManagerType)type;

- (NSString *)addTableSQLWithTableType:(MessageCenterDBManagerType)type;

- (NSString *)updateTableSQLWithTableType:(MessageCenterDBManagerType)type key:(NSString *)keyStr;

- (NSString *)selectTableSQLWithTableType:(MessageCenterDBManagerType)type key:(NSString *)keyStr;

@end
