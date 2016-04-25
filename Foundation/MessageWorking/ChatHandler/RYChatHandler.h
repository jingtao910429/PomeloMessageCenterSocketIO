//
//  RYBaseChatAPI.h
//  Client
//
//  Created by wwt on 15/10/17.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RYChatAPIManager.h"
#import "PomeloClient.h"


@class RYChatHandler;
@class CommonModel;

typedef void (^RefreshUserSuccess)();

/*---------------------------------RYChatHandlerDelegate------------------------------------*/

//连接chat服务器之后，不论是何种请求，返回结果和chatHandler即可，具体viewController处理
@protocol RYChatHandlerDelegate <NSObject>

@required
- (void)connectToChatSuccess:(RYChatHandler *)chatHandler result:(id)data  requestId:(NSInteger)requestId;
@required
- (void)connectToChatFailure:(RYChatHandler *)chatHandler result:(id)error  requestId:(NSInteger)requestId;

@end




//pomelo开源框架
@interface RYChatHandler : NSObject

//chat服务器请求所需要的参数
@property (nonatomic, copy)   NSDictionary *parameters;
//chat请求类型
@property (nonatomic, assign) NSInteger chatServerType;
//chat数据模型
@property (nonatomic, strong) CommonModel *commonModel;
//消息推送,如果存在groupID,则更新表数据，首先获取user信息，如果user信息获取到，则更新，如果获取不到，则需要服务器获取信息，然后再更新！
@property (nonatomic, copy) RefreshUserSuccess RefreshUserSuccess;


- (instancetype)initWithDelegate:(id)delegate;

//开始聊天
- (NSInteger)chat;

@end
