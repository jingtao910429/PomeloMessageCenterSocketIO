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
            break;
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
        case NotifyTypeOnAddUser:
            notifyStr = @"onAddUser";
            break;
        default:
            break;
    }
    return notifyStr;
}

+ (NSDictionary *)parametersWithType:(BOOL)isConnectInit {
    
    if (![MessageTool token]) {
        
        NSArray *cookies = [Tool getCookies];
        
        NSString *tokenStr = nil;
        
        for (int i = 0; i < cookies.count; i ++) {
            
            NSString *cookieName = [(NSHTTPCookie *)cookies[i] name];
            
            if ([cookieName isEqualToString:@"Token"]) {
                tokenStr = [(NSHTTPCookie *)cookies[i] value];
            }
        }
        
        if (tokenStr) {
            [MessageTool setToken:tokenStr];
        }else {
            return [NSDictionary new];
        }
        
    }
    
    if (![MessageTool token] || [[MessageTool token] isEqualToString:@""] || [[MessageTool token] isKindOfClass:[NSNull class]]) {
        return [NSDictionary new];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[MessageTool token],@"token", nil];
}

+ (NSString *)host {
    //测试环境
    //return @"testmsg.rongyu100.com";
    //正式环境
    return @"msg.rongyu100.com";
}

+ (NSString *)port {
    //测试环境
    //return @"13014";
    //正式环境
    return @"3014";
}


@end
