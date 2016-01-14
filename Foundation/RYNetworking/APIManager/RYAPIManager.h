//
//  RYAPIManager.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RYBaseAPICmd;

@interface RYAPIManager : NSObject

+ (instancetype)manager;

- (void)cancelRequestWithRequestID:(NSInteger)requestID;
- (void)cancelAllRequest;

- (BOOL)isLoadingWithRequestID:(NSInteger)requestID;

- (NSInteger)performCmd:(RYBaseAPICmd *)RYBaseAPICmd;
@end
