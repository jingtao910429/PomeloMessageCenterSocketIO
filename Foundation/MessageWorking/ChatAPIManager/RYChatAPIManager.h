//
//  RYBaseAPIManage.h
//  Client
//
//  Created by wwt on 15/10/17.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  服务器种类
 *
 *  connector：frontend前端服务器，承载连接，并把请求转发到后端的服务器群
 *
 *  gate：客户端线连接gate服务器，然后再由gate决定客户端和哪个connector连接
 *
 *  chat：backend后端服务器，真正处理业务逻辑的地方
 *
 */


/**
 *  连接gate服务器的路由
 *
 *  RouteGateTypeName 路由种类
 *
 */
typedef NS_ENUM(NSInteger, RouteGateTypeName){
    //询问（连接）gate服务器（产生结果为需要连接的connector服务器）
    RouteGateTypeQueryEntry = 0,
};

/**
 *  连接connector服务器的路由
 *
 *  RouteConnectorTypeName
 */
typedef NS_ENUM(NSInteger, RouteConnectorTypeName){
    /// 用于连接到分配的连接服务器(初始化的同时并返回给web/app端用户信息；初始化后，消息中心会异步推送老消息和消息列表给客户端)
    RouteConnectorTypeInit  =  1,
    /// 推送消息
    RouteConnectorTypePush  =  1 << 1,
    ///
    RouteConnectorTypeProto =  1 << 2,
};

/**
 *  连接chat服务器的路由
 *
 *  RouteChatTypeName
 */
typedef NS_ENUM(NSInteger, RouteChatTypeName){
    /// 用于App连接到消息中心后，存储App Client信息
    RouteChatTypeWriteClientInfo  = 3 << 0,
    /// 用于用户或系统发送消息给用户
    RouteChatTypeSend             = 3 << 1,
    /// 用于保存用户读取消息的情况
    RouteChatTypeRead             = 3 << 2,
    /// 用于保存用户消息置顶的情况
    RouteChatTypeTop              = 3 << 3,
    /// 用于保存用户消息免打扰的情况
    RouteChatTypeDisturbed        = 3 << 4,
    /// 获取组和组成员信息
    RouteChatTypeGetGroupInfo     = 3 << 5,
    /// 获取一对一聊天组
    RouteChatTypeGetGroupId       = 3 << 6,
    /// Web端消息中心获取组列表(不需要)
    RouteChatTypeGetGroups        = 3 << 7,
    /// 进入群组后取当前群组的n条消息，下拉获取之前的n条消息
    RouteChatTypeGetMsg           = 3 << 8,
    /// 查找用户信息（参数userId单个，参数userIds多个）
    RouteChatTypeFindUser         = 3 << 9,
    /// 查找多个用户信息
    RouteChatTypeFindUsers         = 3 << 10
};

//获取成功或失败之后枚举值

typedef NS_ENUM(NSInteger, ResultCodeType){
    /// 获取成功
    ResultCodeTypeSuccess = 200,
    /// 用户未登录
    ResultCodeTypeNoLogin = 401,
    /// 用户未登录
    ResultCodeTypeOtherError = 500
};

//列表类型0:全部组;1:未读组;2:已读组

typedef NS_ENUM(NSInteger, GroupReadType){
    /// 0:全部组
    GroupReadTypeAll    = 111,
    /// 1:未读组
    GroupReadTypeNoRead = 222,
    /// 2:已读组
    GroupReadTypeRead   = 333
    
};

/**
 *
 *  消息推送
 *
 */

typedef NS_ENUM(NSInteger, NotifyType){
    
    /**
     *  推送消息到客户端
     *  推送消息给客户端；推送新消息时，判断老消息是否已全部推送完，否则不推送新消息
     */
    
    NotifyTypeOnChat           = 5 << 1,
    
    /**
     *  推送消息已读情况到客户端
     */
    
    NotifyTypeOnRead           = 5 << 2,
    
    /**
     *  推送消息置顶情况到客户端
     */
    
    NotifyTypeOnTop            = 5 << 3,
    
    /**
     *  推送消息免打扰到客户端
     */
    NotifyTypeOnDisturbed      = 5 << 4,
    
    /**
     *  推送消息列表给客户端，用于客户端刚刚登陆时
     */
    
    NotifyTypeOnGroupMsgList   = 7 << 1,
    
    /**
     *  信贷申请状态变更
     */
    
    NotifyTypeOnApproveStatusChanged = 7 << 2,
    
    /**
     *  删除组和组消息
     */
    
    NotifyTypeOnRemoveUser    = 7 << 3,
    
    /**
     *  接收历史消息
     */
    
    NotifyTypeOnChatHistory    = 7 << 4
    
};


//有关聊天接口管理类
@interface RYChatAPIManager : NSObject

//connector服务器需要连接的host和port端口
@property (nonatomic, copy) NSString *hostConnector;
@property (nonatomic, copy) NSString *portConnector;

+ (instancetype)shareManager;

/// 根据不同类型返回路由字符串
+ (NSString *)routeWithType:(NSInteger)type;
/// 根据不同类型返回通知路由字符串
+ (NSString *)notifyWithType:(NSInteger)type;

/// 连接服务器需要的参数设置
/// 根据是否连接gate服务器获取参数（如果是gate服务器，则参数形式为@{@"uid":@""},如果连接为connector服务器，则参数为@{@"token":@""}）
+ (NSDictionary *)parametersWithType:(BOOL)isConnectInit;

/// 连接gate服务器的host
+ (NSString *)host;

/// 连接gate服务器的端口号
+ (NSString *)port;

@end
