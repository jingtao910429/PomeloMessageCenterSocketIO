//
//  RYBaseAPIManage.m
//  Client
//
//  Created by wwt on 15/10/17.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import "RYChatAPIManager.h"
#import "MessageTool.h"

static RYChatAPIManager *shareManager = nil;

@implementation RYChatAPIManager

+ (instancetype)shareManager {
    
    static dispatch_once_t onceInstance;
    dispatch_once(&onceInstance, ^{
        shareManager = [[RYChatAPIManager alloc] init];
    });
    return shareManager;
}

+ (NSString *)routeWithType:(NSInteger)type {
    
    NSString *routeStr = @"";
    
    switch (type) {
        case RouteGateTypeQueryEntry:
            routeStr = @"gate.gateHandler.queryEntry";
            break;
        case RouteConnectorTypeInit:
            routeStr = @"connector.entryHandler.init";
            break;
        case RouteChatTypeWriteClientInfo:
            routeStr = @"chat.chatHandler.writeClientInfo";
            break;
        case RouteChatTypeGetGroupId:
            routeStr = @"chat.chatHandler.getGroupId";
            break;
        case RouteChatTypeSend:
            routeStr = @"chat.chatHandler.send";
            break;
        case RouteChatTypeRead:
            routeStr = @"chat.chatHandler.read";
            break;
        case RouteChatTypeTop:
            routeStr = @"chat.chatHandler.top";
            break;
        case RouteChatTypeDisturbed:
            routeStr = @"chat.chatHandler.Disturbed";
            break;
        case RouteChatTypeGetGroups:
            routeStr = @"chat.chatHandler.getGroups";
            break;
        case RouteChatTypeGetMsg:
            routeStr = @"chat.chatHandler.getMsg";
            break;
        case RouteChatTypeGetGroupInfo:
            routeStr = @"chat.chatHandler.getGroupInfo";
            break;
        case RouteChatTypeFindUser:
            routeStr = @"chat.chatHandler.findUser";
            break;
        case RouteChatTypeFindUsers:
            routeStr = @"chat.chatHandler.findUsers";
        default:
            break;
    }
    return routeStr;
}

+ (NSString *)notifyWithType:(NSInteger)type {
    
    NSString *notifyStr = @"";
    
    switch (type) {
        case NotifyTypeOnChat:
            notifyStr = @"onChat";
            break;
        case NotifyTypeOnRead:
            notifyStr = @"onRead";
            break;
        case NotifyTypeOnTop:
            notifyStr = @"onTop";
            break;
        case NotifyTypeOnDisturbed:
            notifyStr = @"onDisturbed";
            break;
        case NotifyTypeOnGroupMsgList:
            notifyStr = @"onGroupMsgList";
            break;
        case NotifyTypeOnChatHistory:
            notifyStr = @"onChatHistory";
            break;
        case NotifyTypeOnApproveStatusChanged:
            notifyStr = @"onApproveStatusChanged";
            break;
        case NotifyTypeOnRemoveUser:
            notifyStr = @"onRemoveUser";
            break;
        default:
            break;
    }
    return notifyStr;
}

+ (NSDictionary *)parametersWithType:(BOOL)isConnectInit {
    
    if (isConnectInit) {
        return @{@"token":[MessageTool token]}; 
    }
    return @{@"token":[MessageTool token]};
}

+ (NSString *)host {
    return @"192.168.253.35";
}

+ (NSString *)port {
    return @"3014";
}


@end
