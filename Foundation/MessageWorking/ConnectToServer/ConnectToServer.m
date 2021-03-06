//
//  ConnectToServer.m
//  Client
//
//  Created by xiaerfei on 15/10/27.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import "ConnectToServer.h"
#import "RYChatAPIManager.h"
#import "MessageTool.h"
#import "AppDelegate.h"

@interface ConnectToServer ()<PomeloDelegate>

@property (nonatomic, copy) NSString *hostStr;
@property (nonatomic, copy) NSString *portStr;


@end

@implementation ConnectToServer

@synthesize pomeloClient;

+ (instancetype)shareInstance {
    static id _f;
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        _f = [[ConnectToServer alloc] init];
    });
    return _f;
}

#pragma mark - public methods

- (void)chatClientDisconnect
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.connectTimer invalidate];
    delegate.connectTimer = nil;
    
    [pomeloClient disconnectWithCallback:^(id arg , NSString *route) {
        [MessageTool setConnectStatus:@"0"];
        if ([_delegate respondsToSelector:@selector(connectToServerFailureWithData:)]) {
            [_delegate connectToServerFailureWithData:arg];
        }
    }];
}
/**
 *   @author xiaerfei, 15-10-27 16:10:45
 *
 *   连接 gate 服务器
 */

- (void)connectToSeverGate
{
    //－1表示正在连接中
    if ([[MessageTool connectStatus] isEqualToString:@"-1"]) {
        return;
    }else {
        [MessageTool setConnectStatus:@"-1"];
    }
    
    [pomeloClient connectToHost:[RYChatAPIManager host] onPort:[[RYChatAPIManager port] intValue] withCallback:^(id callback, NSString *route) {
        
        [pomeloClient requestWithRoute:[RYChatAPIManager routeWithType:RouteGateTypeQueryEntry] andParams:[RYChatAPIManager parametersWithType:YES] andCallback:^(id arg , NSString *route) {
            
            //断开gate服务器，连接connector服务器
            //断开连接（必须做的操作，否则浪费gate服务器资源）
            //[weakClient disconnect];webSocket
            
            [pomeloClient disconnectWithCallback:^(id callback, NSString *route) {
                
                NSDictionary *queryEntryResult = (NSDictionary *)arg;
                //code:状态码（200:获取成功;401:用户未登录;500或其他:错误）
                
                if ([[NSString stringWithFormat:@"%@",queryEntryResult[@"code"]] isEqualToString:[NSString stringWithFormat:@"%d",(int)ResultCodeTypeSuccess]]) {
                    
                    self.hostStr = arg[@"host"];
                    self.portStr = arg[@"port"];
                    
                    [self connectToServerChat];
                    
                }else{
                    
                    [MessageTool setConnectStatus:@"0"];
                    
                    if ([_delegate respondsToSelector:@selector(connectToServerFailureWithData:)]) {
                        [_delegate connectToServerFailureWithData:arg];
                    }
                }
                
            }];
            
        }];
    }];
}
#pragma mark - private methods
/**
 *   @author xiaerfei, 15-10-27 16:10:05
 *
 *   连接 Chat 服务器
 */
- (void)connectToServerChat {
    
    if (self.hostStr && self.portStr) {
        
        [pomeloClient connectToHost:self.hostStr onPort:[self.portStr intValue] withCallback:^(id arg, NSString *route) {
            
            [MessageTool setConnectStatus:@"1"];
            
            if ([_delegate respondsToSelector:@selector(connectToServerSuccessWithData:)]) {
                [_delegate connectToServerSuccessWithData:arg];
            }
            
        }];
    }
}


@end
