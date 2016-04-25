//
//  MessageTool.h
//  Client
//
//  Created by xiaerfei on 15/10/27.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageTool : NSObject

//设置token
+ (void)setToken:(NSString *)token;
+ (NSString *)token;
//服务器推送通知
+ (NSString *)PushGlobalNotificationStr;
//数据库更改通知
+ (NSString *)DBChangeNotificationStr;
//失去连接通知
+ (NSString *)ConnectStateNotificationStr;

//设置当前连接状态 (//1表示链接成功 0 表示连接失败 －1表示正在连接)
+ (NSString *)connectStatus;
+ (void)setConnectStatus:(NSString *)connectStatus;

//消息免打扰（全局disable）-------区分用户
+ (void)setDisturbed:(NSString *)disturbedStr;
+ (NSString *)getDisturbed;

+ (void)setUserID:(NSString *)userID;
+ (NSString *)getUserID;

//会话sessionId
+ (void)setSessionId:(NSString *)sessionId;
+ (NSString *)sessionId;

//本地消息是否过期
+ (void)setClientCacheExprired:(NSString *)clientCacheExprired;
+ (NSString *)clientCacheExprired;
//客户端最新消息时间
+ (void)setLastedReadTime:(NSString *)lastedReadTime;
+ (NSString *)lastedReadTime;

+ (void)setDBChange:(NSString *)isChanged;
+ (NSString *)DBChange;

//置顶groupid
+ (void)setTopGroupId:(NSString *)topGroupId;
+ (NSString *)topGroupId;

+ (void)setUnReadMessage:(NSString *)unReadMessage;
+ (NSString *)unReadMessage;

//查看时间间隔
+ (void)setInterval:(NSString *)intervalStr;
+ (NSString *)getInterval;

//断开重连时间间隔
+ (void)setDisconnectInterval:(NSString *)disconnectInterval;
+ (NSString *)getDisconnectInterval;

//appclient
+ (void)setAppClient:(NSString *)appClient;
+ (NSString *)appClient;

//deviceToken
+ (void)setDeviceToken:(NSString *)deviceToken;
+ (NSString *)deviceToken;

+ (NSDictionary *)dealDataWithDict:(NSDictionary *)tempDict;
//格式化时间
+ (NSDateFormatter *)shareDateForMatter;
@end
