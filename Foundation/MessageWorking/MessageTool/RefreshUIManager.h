//
//  RefreshUIManager.h
//  RongYu100
//
//  Created by wwt on 15/11/13.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RefreshUIManager : NSObject

//标志是否是推送未读消息
@property (nonatomic, assign) BOOL isPushNoReadMessage;
//timer设置刷新页面时间
@property (nonatomic, strong)  NSTimer *timer;
//设置数据库刷新时间
@property (nonatomic, strong)  NSTimer *dataBaseFreshTimer;

+(instancetype)defaultManager;

@end
