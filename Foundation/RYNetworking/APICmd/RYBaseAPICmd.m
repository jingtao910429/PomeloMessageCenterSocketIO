//
//  RYBaseAPICmd.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYBaseAPICmd.h"
#import "RYAPIManager.h"

@interface RYBaseAPICmd ()
@property (nonatomic, copy,readwrite) NSString *absouteUrlString;
@property (nonatomic, assign,readwrite) NSInteger requestId;
@property (nonatomic, copy,readwrite) NSDictionary *cookie;
@property (nonatomic, assign,readwrite) BOOL isLoading;
@end

@implementation RYBaseAPICmd

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(RYBaseAPICmdDelegate)]) {
            self.child = (id<RYBaseAPICmdDelegate>) self;
        } else {
#ifdef DEBUGLOGGER
            NSAssert(0, @"子类必须要实现APIManager这个protocol。");
#endif
        }
    }
    return self;
}

- (NSString *)absouteUrlString
{
    _absouteUrlString = [[NSString stringWithFormat:@"%@%@",self.host,self.path] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return _absouteUrlString;
}

- (NSString *)host
{
    if ([self.child respondsToSelector:@selector(apiHost)]) {
        return [self.child apiHost];
    }
    return api_domain;
}
/**
 *   @author xiaerfei, 15-09-08 11:09:14
 *
 *   isLoading
 *
 *   @return
 */
- (BOOL)isLoading
{
    _isLoading = [[RYAPIManager manager] isLoadingWithRequestID:self.requestId];
    return _isLoading;
}
/**
 *   @author xiaerfei, 15-09-08 11:09:59
 *
 *   取消当前的请求
 */
- (void)cancelRequest
{
    [[RYAPIManager manager] cancelRequestWithRequestID:self.requestId];
}

/**
 *   @author xiaerfei, 15-08-25 14:08:51
 *
 *   加载cookie
 *
 *   @return
 */
- (NSDictionary *)cookie
{
    if ([self.child respondsToSelector:@selector(apiCookie)]) {
        return [self.child apiCookie];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"]) {
        
        NSArray *arcCookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"]];
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        for (NSHTTPCookie *cookie in arcCookies){
            [cookieStorage setCookie: cookie];
        }
        NSDictionary *sheaders = [NSHTTPCookie requestHeaderFieldsWithCookies:arcCookies];
        _cookie = sheaders;
        
    }
    return _cookie;
}
/**
 *   @author xiaerfei, 15-08-25 14:08:05
 *
 *   开始请求数据
 */
- (void)loadData
{
    if ([self.paramSource respondsToSelector:@selector(paramsForApi:)]) {
        [self.paramSource paramsForApi:self];
    }
    self.requestId = [[RYAPIManager manager] performCmd:self];
}

- (void)dealloc
{
    if ([self.child respondsToSelector:@selector(isCancelled)]) {
        if ([self.child isCacelRequest]) {
            [self cancelRequest];
        }
    } else {
        [self cancelRequest];
    }
}
@end
