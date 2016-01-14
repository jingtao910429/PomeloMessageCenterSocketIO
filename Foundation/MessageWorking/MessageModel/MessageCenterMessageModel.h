//
//  MessageCenterMessageModel.h
//  Client
//
//  Created by wwt on 15/10/21.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import "CommonModel.h"

@interface MessageCenterMessageModel : CommonModel

@property (nonatomic, copy) NSString *userMessageId; //主键
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *userId;        //发送者
@property (nonatomic, copy) NSString *accountId;     //区别用户
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *msgContent;    //发送的信息文本
@property (nonatomic, copy) NSString *createTime;    //消息创建时间

//表示该消息是否发送
@property (nonatomic, copy) NSString *Status;

//如果关联User表，需要记录UserId的其他信息，用于聊天列表显示
@property (nonatomic, copy) NSString *personName;
@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *clientMsgId;    //1970年至今-sessionId；为发送消息的时间精确到毫秒；sessionId: 客户端连接消息中心服务器时，服务器返回给客户端的sessionId;
@property (nonatomic, copy) NSString *creditApplicationStatus;
@property (nonatomic, copy) NSString *type;           //消息类型1: 文本消息；101：信贷申请状态变更；
@end
