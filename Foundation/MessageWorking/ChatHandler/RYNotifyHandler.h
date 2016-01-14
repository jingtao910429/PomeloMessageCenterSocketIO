//
//  RYRouteHandler.h
//  Client
//
//  Created by wwt on 15/10/22.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RYChatAPIManager.h"

@class PomeloClient;
@class RYNotifyHandler;

@interface RYNotifyHandler : NSObject

@property (nonatomic, assign) NotifyType notifyType;
@property (nonatomic, strong) PomeloClient *client;

- (void)onAllNotify;

@end
