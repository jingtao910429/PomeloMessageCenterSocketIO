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
#import "CDRTranslucentSideBar.h"
#import "MessageTool.h"


@interface TabBarRootViewController ()<CustomerTabBarDelegate>


@end

@implementation TabBarRootViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [Tool backButton:self btnText:@"消息" action:@selector(sliderClick) addTarget:self iconName:@"original_back_main_topBar_Icon"];
    self.tabBarView = [[CustomerTabBarView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 113, SCREEN_WIDTH, 49)];
    
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
    [self.rdv_tabBarController.sideBar startShow:SCREEN_BOUND_WIDTH - SCREEN_BOUND_WIDTH/3];
    [self.rdv_tabBarController.sideBar showAnimatedFrom:YES deltaX:SCREEN_BOUND_WIDTH - SCREEN_BOUND_WIDTH/3];
    self.rdv_tabBarController.sideBar.isCurrentPanGestureTarget = YES;
    
}

@end
