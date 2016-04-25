//
//  TabBarRootViewController.m
//  RongYu100
//
//  Created by gqq on 15/11/13.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "TabBarRootViewController.h"
#import "RYMessageCenterVC.h"
#import "RDVTabBarController.h"
#import "RDVTabBarController.h"
#import "MessageTool.h"

@interface TabBarRootViewController ()<CustomerTabBarDelegate>


@end

@implementation TabBarRootViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //注册有无未读消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveUnreadMessage:) name:UnReadMessage_Notification object:nil];
    [self updateUI];
    self.title = @"消息";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  viewDidLoad Methods

-(void)updateUI
{
    
    self.tabBar.hidden = YES;
    
    [Tool backButton:self btnText:@"消息" action:@selector(sliderClick) addTarget:self iconName:@"ryback_main_topBar_Icon_black"];
    self.tabBarView = [[CustomerTabBarView alloc] initWithFrame:CGRectMake(0, SCREEN_BOUND_HEIGHT - 113, SCREEN_BOUND_WIDTH, 49)];
    
    self.tabBarView.delegate = self;
    self.tabBarView.backgroundColor = [Tool getBackgroundColor];
    
    [self.view addSubview:self.tabBarView];
    if ([[MessageTool unReadMessage] isEqualToString:@"YES"]) {
        self.tabBarView.dotLabel.hidden = NO;
    }
    else
    {
        self.tabBarView.dotLabel.hidden = YES;
    }
    
    
}

#pragma mark - CustomDelegate 
#pragma mark  CustomerTabBarDelegate
-(void)tabBar:(CustomerTabBarView *)tabBar selectedFrom:(NSInteger)from to:(NSInteger)to
{
    self.selectedIndex = 0;
}


- (void)sliderClick
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
//有无未读消息通知
- (void)haveUnreadMessage:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *resultStr = (NSString *)notification.object;

        if ([resultStr isEqualToString:@"YES"]) {
            self.tabBarView.dotLabel.hidden = NO;
        }
        else
        {
            self.tabBarView.dotLabel.hidden = YES;
        }
    });
    
}
@end
