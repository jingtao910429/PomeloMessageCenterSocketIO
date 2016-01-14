//
//  RYAPIManager.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYAPIManager.h"
#import "RYBaseAPICmd.h"
#import "AFNetworking.h"
#import "RYAPILogger.h"

@interface RYAPIManager ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpRequestOperationManager;

@end

@implementation RYAPIManager
#pragma mark - life cycle
+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    static RYAPIManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[RYAPIManager alloc] init];
    });
    return manager;
}
#pragma mark - public metods
- (NSInteger)performCmd:(RYBaseAPICmd *)baseAPICmd
{
    NSInteger requestId = 0;
    if (baseAPICmd) {
        NSString *urlString = [baseAPICmd absouteUrlString];
        if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmdStartLoadData:)]) {
            [baseAPICmd.interceptor apiCmdStartLoadData:baseAPICmd];
        }
        if ([self isReachable]) {
            switch (baseAPICmd.child.requestType) {
                case RYBaseAPICmdRequestTypeGet:
                    requestId = [self callGETWithParams:baseAPICmd.reformParams urlString:urlString baseAPICmd:baseAPICmd];
                    
                    break;
                case RYBaseAPICmdRequestTypePost:
                    requestId = [self callPOSTWithParams:baseAPICmd.reformParams urlString:urlString baseAPICmd:baseAPICmd];
                    break;
                default:
                    break;
            }
        } else {
            if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformFailWithResponse:)]) {
                [baseAPICmd.interceptor apiCmd:baseAPICmd beforePerformFailWithResponse:nil];
            }
            if ([baseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:error:)]) {
                [baseAPICmd.delegate apiCmdDidFailed:baseAPICmd error:nil];
            }
            if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformFailWithResponse:)]) {
                [baseAPICmd.interceptor apiCmd:baseAPICmd afterPerformFailWithResponse:nil];
            }
        }
    }
    return requestId;
}

- (void)cancelRequestWithRequestID:(NSInteger)requestID
{
    AFHTTPRequestOperation *operation = self.dispatchTable[@(requestID)];
    [operation cancel];
    [self.dispatchTable removeObjectForKey:@(requestID)];
}

- (void)cancelAllRequest
{
    for (NSNumber *requestId in self.dispatchTable.allKeys) {
        [self cancelRequestWithRequestID:[requestId integerValue]];
    }
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:[requestId integerValue]];
    }
}


- (BOOL)isLoadingWithRequestID:(NSInteger)requestID
{
    if (self.dispatchTable[@(requestID)]) {
        return YES;
    }
    return NO;
}

#pragma mark - APICall
- (NSInteger)callGETWithParams:(id)params urlString:(NSString *)urlString baseAPICmd:(RYBaseAPICmd *)baseAPICmd
{
    NSNumber *requestId = [self generateRequestId];
    __weak __typeof(baseAPICmd) weakBaseAPICmd = baseAPICmd;
    AFHTTPRequestOperation *requestOperation = [self.httpRequestOperationManager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof(weakBaseAPICmd) strongBaseAPICmd = weakBaseAPICmd;
        strongBaseAPICmd.reformParams = nil;
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            // 请求已经完成，将requestId移除
            [self.dispatchTable removeObjectForKey:requestId];
        }
#ifdef DEBUGLOGGER
        [RYAPILogger logDebugInfoWithURL:urlString requestHeader:operation.request.allHTTPHeaderFields responseHeader:operation.response.allHeaderFields requestParams:params responseParams:responseObject httpMethod:@"GET" requestId:requestId apiCmdDescription:strongBaseAPICmd.child.apiCmdDescription apiName:NSStringFromClass([strongBaseAPICmd class])];
#endif
        if ([strongBaseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformSuccessWithResponse:)]) {
            [strongBaseAPICmd.interceptor apiCmd:strongBaseAPICmd beforePerformSuccessWithResponse:operation.response];
        }
        if ([strongBaseAPICmd.delegate respondsToSelector:@selector(apiCmdDidSuccess:responseData:)]) {
            [strongBaseAPICmd.delegate apiCmdDidSuccess:strongBaseAPICmd responseData:responseObject];
        }
        if ([strongBaseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformSuccessWithResponse:)]) {
            [strongBaseAPICmd.interceptor apiCmd:strongBaseAPICmd afterPerformSuccessWithResponse:operation.response];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong __typeof(weakBaseAPICmd) strongBaseAPICmd = weakBaseAPICmd;
        strongBaseAPICmd.reformParams = nil;
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
#ifdef DEBUGLOGGER
        [RYAPILogger logDebugInfoWithURL:urlString requestHeader:operation.request.allHTTPHeaderFields responseHeader:operation.response.allHeaderFields requestParams:params httpMethod:@"GET" error:error requestId:requestId apiCmdDescription:strongBaseAPICmd.child.apiCmdDescription apiName:NSStringFromClass([strongBaseAPICmd class])];
#endif
        if ([strongBaseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformFailWithResponse:)]) {
            [strongBaseAPICmd.interceptor apiCmd:strongBaseAPICmd beforePerformFailWithResponse:operation.response];
        }
        if ([strongBaseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:error:)]) {
            [strongBaseAPICmd.delegate apiCmdDidFailed:strongBaseAPICmd error:error];
        }
        if ([strongBaseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformFailWithResponse:)]) {
            [strongBaseAPICmd.interceptor apiCmd:strongBaseAPICmd afterPerformFailWithResponse:operation.response];
        }
    }];
    if (baseAPICmd.cookie) {
        [(NSMutableURLRequest *)requestOperation.request setAllHTTPHeaderFields:baseAPICmd.cookie];
    }
    self.dispatchTable[requestId] = requestOperation;
    return [requestId integerValue];
}

- (NSInteger)callPOSTWithParams:(id)params urlString:(NSString *)urlString baseAPICmd:(RYBaseAPICmd *)baseAPICmd
{

    NSNumber *requestId = [self generateRequestId];
    __weak __typeof(baseAPICmd) weakBaseAPICmd = baseAPICmd;
    AFHTTPRequestOperation *requestOperation = [self.httpRequestOperationManager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof(weakBaseAPICmd) strongBaseAPICmd = weakBaseAPICmd;
        strongBaseAPICmd.reformParams = nil;
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            // 请求已经完成，将requestId移除
            [self.dispatchTable removeObjectForKey:requestId];
        }
#ifdef DEBUGLOGGER
        [RYAPILogger logDebugInfoWithURL:urlString requestHeader:operation.request.allHTTPHeaderFields responseHeader:operation.response.allHeaderFields requestParams:params responseParams:responseObject httpMethod:@"POST" requestId:requestId apiCmdDescription:strongBaseAPICmd.child.apiCmdDescription apiName:NSStringFromClass([strongBaseAPICmd class])];
#endif
        if ([strongBaseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformSuccessWithResponse:)]) {
            [strongBaseAPICmd.interceptor apiCmd:strongBaseAPICmd beforePerformSuccessWithResponse:operation.response];
        }
        if ([strongBaseAPICmd.delegate respondsToSelector:@selector(apiCmdDidSuccess:responseData:)]) {
            [strongBaseAPICmd.delegate apiCmdDidSuccess:strongBaseAPICmd responseData:responseObject];
        }
        if ([strongBaseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformSuccessWithResponse:)]) {
            [strongBaseAPICmd.interceptor apiCmd:strongBaseAPICmd afterPerformSuccessWithResponse:operation.response];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong __typeof(weakBaseAPICmd) strongBaseAPICmd = weakBaseAPICmd;
        strongBaseAPICmd.reformParams = nil;
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
#ifdef DEBUGLOGGER
        [RYAPILogger logDebugInfoWithURL:urlString requestHeader:operation.request.allHTTPHeaderFields responseHeader:operation.response.allHeaderFields requestParams:params httpMethod:@"POST" error:error requestId:requestId apiCmdDescription:strongBaseAPICmd.child.apiCmdDescription apiName:NSStringFromClass([strongBaseAPICmd class])];
#endif
        if ([strongBaseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformFailWithResponse:)]) {
            [strongBaseAPICmd.interceptor apiCmd:strongBaseAPICmd beforePerformFailWithResponse:operation.response];
        }
        if ([strongBaseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:error:)]) {
            [strongBaseAPICmd.delegate apiCmdDidFailed:strongBaseAPICmd error:error];
        }
        if ([strongBaseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformFailWithResponse:)]) {
            [strongBaseAPICmd.interceptor apiCmd:strongBaseAPICmd afterPerformFailWithResponse:operation.response];
        }
    }];
    if (baseAPICmd.cookie) {
        [(NSMutableURLRequest *)requestOperation.request setAllHTTPHeaderFields:baseAPICmd.cookie];
    }
    self.dispatchTable[requestId] = requestOperation;
    return [requestId integerValue];
}


#pragma mark - private methods
- (NSNumber *)generateRequestId
{
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

#pragma mark - getters

- (NSMutableDictionary *)dispatchTable
{
    if (!_dispatchTable) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPRequestOperationManager *)httpRequestOperationManager
{
    if (_httpRequestOperationManager == nil) {
        _httpRequestOperationManager = [AFHTTPRequestOperationManager manager];
        _httpRequestOperationManager.operationQueue.maxConcurrentOperationCount = 10;
        _httpRequestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _httpRequestOperationManager.requestSerializer.timeoutInterval = kNetworkingTimeoutSeconds;
    }
    return _httpRequestOperationManager;

}



@end
