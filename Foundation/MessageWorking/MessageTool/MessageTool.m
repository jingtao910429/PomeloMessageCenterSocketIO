//
//  MessageTool.m
//  Client
//
//  Created by xiaerfei on 15/10/27.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import "MessageTool.h"
@implementation MessageTool


+ (void)setToken:(NSString *)token {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:token forKey:@"token"];
    [settings synchronize];
}

+ (NSString *)token {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"token"];
}

+ (NSString *)PushGlobalNotificationStr {
    return @"PushGlobalNotification";
}

+ (NSString *)DBChangeNotificationStr {
    return @"DBChangeNotification";
}

+ (NSString *)ConnectStateNotificationStr {
    return @"disConnectNotificationStr";
}

+ (void)setConnectState:(NSString *)connectState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:connectState forKey:[NSString stringWithFormat:@"%@connectState",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)connectState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@connectState",[Tool getOwerUserID]]];
}


+ (void)setDisturbed:(NSString *)disturbedStr {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:disturbedStr forKey:[NSString stringWithFormat:@"%@disturb",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)getDisturbed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@disturb",[Tool getOwerUserID]]];
}

+ (void)setUserID:(NSString *)userID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:userID forKey:[NSString stringWithFormat:@"%@userID",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)getUserID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@userID",[Tool getOwerUserID]]];
}

+ (void)setSessionId:(NSString *)sessionId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:sessionId forKey:[NSString stringWithFormat:@"%@sessionId",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)sessionId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@sessionId",[Tool getOwerUserID]]];
}

+ (void)setClientCacheExprired:(NSString *)clientCacheExprired {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:clientCacheExprired forKey:[NSString stringWithFormat:@"%@clientCacheExprired",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)clientCacheExprired {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@clientCacheExprired",[Tool getOwerUserID]]];
}

+ (void)setLastedReadTime:(NSString *)lastedReadTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:lastedReadTime forKey:[NSString stringWithFormat:@"%@lastedReadTime",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)lastedReadTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@lastedReadTime",[Tool getOwerUserID]]];
}

+ (void)setDBChange:(NSString *)isChanged {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:isChanged forKey:[NSString stringWithFormat:@"%@isChanged",[Tool getOwerUserID]]];
    [defaults synchronize];

}

+ (NSString *)DBChange {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@isChanged",[Tool getOwerUserID]]];
}

//置顶groupid
+ (void)setTopGroupId:(NSString *)topGroupId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:topGroupId forKey:[NSString stringWithFormat:@"%@topGroupId",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)topGroupId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@topGroupId",[Tool getOwerUserID]]];
}
//区别有无未读消息
+ (void)setUnReadMessage:(NSString *)unReadMessage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:unReadMessage forKey:[NSString stringWithFormat:@"%@unReadMessage",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)unReadMessage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@unReadMessage",[Tool getOwerUserID]]];
}

+ (void)setInterval:(NSString *)intervalStr {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:intervalStr forKey:[NSString stringWithFormat:@"%@Interval",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)getInterval {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@Interval",[Tool getOwerUserID]]];
}

+ (void)setDisconnectInterval:(NSString *)disconnectInterval {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:disconnectInterval forKey:[NSString stringWithFormat:@"%@disconnectInterval",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)getDisconnectInterval {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@disconnectInterval",[Tool getOwerUserID]]];
}

+ (void)setAppClient:(NSString *)appClient {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:appClient forKey:@"appClient"];
    [defaults synchronize];

}

+ (NSString *)appClient {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"appClient"];
}

+ (void)setDeviceToken:(NSString *)deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:deviceToken forKey:@"deviceToken"];
    [defaults synchronize];

}

+ (NSString *)deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"deviceToken"];
}

+ (void)setActiveDisconnect:(NSString *)activeDisconnect {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:activeDisconnect forKey:[NSString stringWithFormat:@"%@activeDisconnect",[Tool getOwerUserID]]];
    [defaults synchronize];
}

+ (NSString *)activeDisconnect {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@activeDisconnect",[Tool getOwerUserID]]];
}

+ (NSDictionary *)dealDataWithDict:(NSDictionary *)tempDict {
    
    NSMutableDictionary *groupInfo = [[NSMutableDictionary alloc] init];
    
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"createTime"]] forKey:@"CreateTime"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"companyName"]] forKey:@"CompanyName"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"groupName"]] forKey:@"GroupName"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"groupType"]] forKey:@"GroupType"];
    [groupInfo setValue:[MessageTool getUserID] forKey:@"AccountId"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"groupId"]] forKey:@"GroupId"];
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"approveStatus"]] forKey:@"ApproveStatus"];
    
    if (tempDict[@"lastedMsg"] && ![tempDict[@"lastedMsg"] isKindOfClass:[NSNull class]]) {
        
        [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"lastedMsg"][@"msgId"]] forKey:@"LastedMsgId"];
        [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"lastedMsg"][@"sender"]] forKey:@"LastedMsgSenderName"];
        
        if (tempDict[@"lastedMsg"][@"time"]) {
            [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"lastedMsg"][@"time"]] forKey:@"LastedMsgTime"];
        }else{
            [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"createTime"]] forKey:@"LastedMsgTime"];
        }
        [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"lastedMsg"][@"content"]] forKey:@"LastedMsgContent"];
        
    }else{
        [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"createTime"]] forKey:@"LastedMsgTime"];
    }
    
    [groupInfo setValue:[NSString stringWithFormat:@"%@",tempDict[@"unReadMsgCount"]?tempDict[@"unReadMsgCount"]:@"0"] forKey:@"UnReadMsgCount"];
    
    if ([[MessageTool topGroupId] isEqualToString:tempDict[@"groupId"]]) {
        [groupInfo setObject:@"YES" forKey:@"isTop"];
    }
    
    return groupInfo;
}


+ (NSDateFormatter *)shareDateForMatter
{
    static NSDateFormatter * sharedDateFormatter;
    if(sharedDateFormatter == nil) {
        sharedDateFormatter = [[NSDateFormatter alloc] init];
    }
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [sharedDateFormatter setTimeZone:timeZone];
    return sharedDateFormatter;
}

@end
