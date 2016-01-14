//
//  ConnectToServer.h
//  Client
//
//  Created by xiaerfei on 15/10/27.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PomeloClient.h"

@protocol ConnectToServerDelegate <NSObject>

//连接gate和connector服务器失败与成功
@optional
- (void)connectToServerSuccessWithData:(id)data;

- (void)connectToServerFailureWithData:(id)data;

- (void)connectToServerDisconnectSuccessWithData:(id)data;

@end

@interface ConnectToServer : NSObject

@property (nonatomic, weak)            id<ConnectToServerDelegate> delegate;

@property (nonatomic, strong)          PomeloClient *pomeloClient;

+ (instancetype)shareInstance;
/// 连接服务器
- (void)connectToSeverGate;
/// 断开连接
- (void)chatClientDisconnect;

@end
