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
#import "ChatViewRoomController.h"
#import "RYMessageCenterVC.h"

@interface RefreshUIManager ()

@property (nonatomic, strong) ChatViewRoomController *chatViewRoomController;
@property (nonatomic, strong) RYMessageCenterVC *rYMessageCenterVC;

@end

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
        
        if (![[Tool getUserType] isEqualToString:@"2"]) {
            _dataBaseFreshTimer = [NSTimer timerWithTimeInterval:1.2 target:self selector:@selector(dataBaseFreshTimerControl) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_dataBaseFreshTimer forMode:NSRunLoopCommonModes];
            [_dataBaseFreshTimer fire];
        }
        
    }
    return self;
}

- (void)dataBaseFreshTimerControl {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        @try {
            
            if ([[MessageTool DBChange] isEqualToString:@"YES"]) {
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                UINavigationController *subVC = appDelegate.rdvtabBarController.viewControllers[2];
                
                UINavigationController *selectVC = (UINavigationController *)appDelegate.rdvtabBarController.selectedViewController;
                
                NSArray *subVCChildVCs = [subVC childViewControllers];
                
                if ([selectVC isKindOfClass:[UINavigationController class]] && [[MessageTool clientCacheExprired] isEqualToString:@"YES"]) {
                    
                    NSArray *selectVCSubs = selectVC.childViewControllers;
                    
                    if ([selectVCSubs[selectVCSubs.count - 1] isKindOfClass:[ChatViewRoomController class]]) {
                        
                        self.chatViewRoomController = (ChatViewRoomController *)selectVCSubs[selectVCSubs.count - 1];
                        
                        [self.chatViewRoomController refreshTableView];
                        
                    }
                    
                }
                
                if ([subVCChildVCs count] > 0 && [subVCChildVCs[subVCChildVCs.count - 1] isKindOfClass:[TabBarRootViewController class]]) {
                    
                    NSArray *messageTabBarChildVCs = [[subVC childViewControllers][[subVC childViewControllers].count - 1] childViewControllers];
                    
                    if ([messageTabBarChildVCs count] > 0 && [messageTabBarChildVCs[0] isKindOfClass:[RYMessageCenterVC class]]) {
                        self.rYMessageCenterVC = (RYMessageCenterVC *)messageTabBarChildVCs[0];
                        [self.rYMessageCenterVC refreshTableView];
                    }
                    
                }else if ([subVCChildVCs count] > 0 && [subVCChildVCs[subVCChildVCs.count - 1] isKindOfClass:[ChatViewRoomController class]] && [[MessageTool clientCacheExprired] isEqualToString:@"YES"]) {
                    
                    self.chatViewRoomController = (ChatViewRoomController *)subVCChildVCs[subVCChildVCs.count - 1];
                    
                    [self.chatViewRoomController refreshTableView];
                    
                }else {
                    
                }
                
                if ([[MessageTool clientCacheExprired] isEqualToString:@"YES"]) {
                    [MessageTool setClientCacheExprired:@"NO"];
                }
                
                [MessageTool setDBChange:@"NO"];
            }
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
    });
    
}

@end
