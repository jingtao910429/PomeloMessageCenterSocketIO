//
//  RefreshUIManager.m
//  RongYu100
//
//  Created by wwt on 15/11/13.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "RefreshUIManager.h"
#import "PomeloMessageCenterDBManager.h"
#import "MessageTool.h"
#import "AppDelegate.h"
#import "TabBarRootViewController.h"
#import "RYMessageCenterVC.h"

@implementation RefreshUIManager

+(instancetype)defaultManager{
    
    static RefreshUIManager *refreshUIManager = nil;
    @synchronized(self){
        if (refreshUIManager == nil) {
            refreshUIManager = [[RefreshUIManager alloc]init];
        }
    }
    
    return refreshUIManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataBaseFreshTimer = [NSTimer timerWithTimeInterval:1.2 target:self selector:@selector(dataBaseFreshTimerControl) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_dataBaseFreshTimer forMode:NSRunLoopCommonModes];
        [_dataBaseFreshTimer fire];
    }
    return self;
}

- (void)dataBaseFreshTimerControl {
    
    if ([[MessageTool DBChange] isEqualToString:@"YES"]) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        TabBarRootViewController *tabBarRootViewController = (TabBarRootViewController *)([appDelegate.rdvtabBarController.viewControllers[2] viewControllers][0]);
        RYMessageCenterVC *rYMessageCenterVC = tabBarRootViewController.viewControllers[0];
        [rYMessageCenterVC refreshTableView];
        
    }
    
}

@end
