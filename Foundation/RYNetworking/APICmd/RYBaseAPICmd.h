//
//  RYBaseAPICmd.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//
/*
 每一个API需要建一个类 如：LoginAPICmd，遵守协议 RYBaseAPICmdDelegate并实现协议，决定该请求的方式：
 
 - (RYBaseAPICmdRequestType)requestType
 {
    return RYBaseAPICmdRequestTypePost;
 }
 - (NSString *)apiCmdDescription 
 {
    return @"对该API功能的描述";
 }
 ---------------------------------------------------------------------------------
                                 设置API以及参数
 ---------------------------------------------------------------------------------
 使用之前需要设置path（API）和reformParams（参数）：
 
 loginAPICmd.path = @"api_v2/Customer/Login";
 loginAPICmd.reformParams = [NSDictionary dictionaryWithObjectsAndKeys:name, @"userName",depwd, @"password",nil];
 
 持有者实现 APICmdApiCallBackDelegate
 loginAPICmd.delegate = self;
 ---------------------------------------------------------------------------------
                                  开始请求数据
 ---------------------------------------------------------------------------------
 开始请求数据：
 [[RYAPIManager manager] performCmd:loginAPICmd]; 
    或者
 [loginAPICmd loadData]（推荐使用）;
 
 均可
 ---------------------------------------------------------------------------------
                                    数据回调
 ---------------------------------------------------------------------------------
 数据回调  同一类多个请求 请判断baseAPICmd
 - (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd responseData:(NSDictionary *)responseData
 {
    if (baseAPICmd == loginAPICmd) {
 
    }
 
    或者
    if ([baseAPICmd isKindOfClass:[loginAPICmd class]]) {
    
    }
    都可以
 }
 ---------------------------------------------------------------------------------
                                    拦截器
 ---------------------------------------------------------------------------------
 APICmdInterceptor 用于拦截网络数据的回调
 //开始请求数据
 - (void)apiCmdStartLoadData:(RYBaseAPICmd *)apiCmd;
 // 数据请求成功回调之前
 - (void)apiCmd:(RYBaseAPICmd *)apiCmd beforePerformSuccessWithResponse:(NSURLResponse *)response;
 // 数据请求成功回调之后
 - (void)apiCmd:(RYBaseAPICmd *)apiCmd afterPerformSuccessWithResponse:(NSURLResponse *)response;
 // 数据请求失败回调之前
 - (void)apiCmd:(RYBaseAPICmd *)apiCmd beforePerformFailWithResponse:(NSURLResponse *)response;
 // 数据请求失败回调之后
 - (void)apiCmd:(RYBaseAPICmd *)apiCmd afterPerformFailWithResponse:(NSURLResponse *)response;
 // 请求参数 验证参数
 - (BOOL)apiCmd:(RYBaseAPICmd *)apiCmd shouldCallAPIWithParams:(NSDictionary *)params;
 // 请求参数之后
 - (void)apiCmd:(RYBaseAPICmd *)apiCmd afterCallingAPIWithParams:(NSDictionary *)params;
 
 使用方法：重载 APICmd 的 init 方法
 - (instancetype)init
 {
     self = [super init];
     if (self) {
        //设置代理
        self.interceptor = self;
     }
     return self;
 }
 
 也可以在controller里面设置
 ---------------------------------------------------------------------------------
                              查询当前API的请求状态
 ---------------------------------------------------------------------------------
 查询当前API是否在loading：
 [[RYAPIManager manager] isLoadingWithRequestID:loginAPICmd.requestId];
 或
 loginAPICmd.isLoading(推荐使用)
 
 取消当前的请求：
 [[RYAPIManager manager] cancelRequestWithRequestID:loginAPICmd.requestId];
 或
 [loginAPICmd cancelRequest]; (推荐使用)
 （默认API 调用dealloc 时  取消当前请求）
 
 ---------------------------------------------------------------------------------
                                    注意
 ---------------------------------------------------------------------------------
 1.尽量少使用 RYAPIManager 以防发生不必要的错误（除cancelAllRequest方法）
 2.禁止重载 RYBaseAPICmd 里的方法
 */


#import <Foundation/Foundation.h>

@class RYBaseAPICmd;
typedef NS_ENUM (NSUInteger, RYBaseAPICmdRequestType){
    RYBaseAPICmdRequestTypeGet,
    RYBaseAPICmdRequestTypePost,
};

typedef NS_ENUM (NSUInteger, RYBaseAPICmdErrorType){
    RYBaseAPICmdErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    RYBaseAPICmdErrorTypeTimeout,       //请求超时。设置的是20秒超时。
    RYBaseAPICmdErrorTypeNoNetWork      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

static NSTimeInterval kNetworkingTimeoutSeconds = 15.0f;


/*************************************************************************************************/
/*                                         RTAPIManager                                          */
/*************************************************************************************************/
/*
 RYBaseAPICmd的派生类必须符合这些protocal
 */
@protocol RYBaseAPICmdDelegate <NSObject>
@required
//返回请求的类型
- (RYBaseAPICmdRequestType)requestType;
//api功能描述
- (NSString *)apiCmdDescription;

@optional

- (NSString *)apiHost;
- (NSDictionary *)apiCookie;
- (BOOL)isCacelRequest;

@end

/*************************************************************************************************/
/*                               APIManagerApiCallBackDelegate                                   */
/*************************************************************************************************/
//api回调 返回数据，由controller或者持有者实现
@protocol APICmdApiCallBackDelegate <NSObject>
@required
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd responseData:(id)responseData;
- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd error:(NSError *)error;
@end
/*************************************************************************************************/
/*                               APICmdParamSourceDelegate                                       */
/*************************************************************************************************/
@protocol APICmdParamSourceDelegate <NSObject>
@required
- (void)paramsForApi:(RYBaseAPICmd *)manager;
@end

/*************************************************************************************************/
/*                                    APIManagerInterceptor                                      */
/*************************************************************************************************/
/*
 APIBaseManager的派生类必须符合这些protocal
 拦截器
 
 */
@protocol APICmdInterceptor <NSObject>

@optional

- (void)apiCmdStartLoadData:(RYBaseAPICmd *)apiCmd;

- (void)apiCmd:(RYBaseAPICmd *)apiCmd beforePerformSuccessWithResponse:(NSURLResponse *)response;
- (void)apiCmd:(RYBaseAPICmd *)apiCmd afterPerformSuccessWithResponse:(NSURLResponse *)response;

- (void)apiCmd:(RYBaseAPICmd *)apiCmd beforePerformFailWithResponse:(NSURLResponse *)response;
- (void)apiCmd:(RYBaseAPICmd *)apiCmd afterPerformFailWithResponse:(NSURLResponse *)response;

- (BOOL)apiCmd:(RYBaseAPICmd *)apiCmd shouldCallAPIWithParams:(NSDictionary *)params;
- (void)apiCmd:(RYBaseAPICmd *)apiCmd afterCallingAPIWithParams:(NSDictionary *)params;

@end



@interface RYBaseAPICmd : NSObject

@property (nonatomic, weak) NSObject<RYBaseAPICmdDelegate> *child;
@property (nonatomic, weak) id<APICmdApiCallBackDelegate> delegate;
@property (nonatomic, weak) id<APICmdInterceptor> interceptor;
@property (nonatomic, weak) id<APICmdParamSourceDelegate> paramSource;

@property (nonatomic, copy) id reformParams;
@property (nonatomic, copy) NSString *path;

@property (nonatomic, readonly, assign) NSInteger requestId;
@property (nonatomic, readonly, copy) NSString *absouteUrlString;
@property (nonatomic, readonly, copy) NSDictionary *cookie;
/// 查询当前是否loading
@property (nonatomic, readonly, assign) BOOL isLoading;

/// 开始请求数据
- (void)loadData;
/// 取消当前的请求
- (void)cancelRequest;



@end
