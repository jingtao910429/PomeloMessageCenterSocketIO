//
//  UserInfoViewController.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoCell.h"
#import "GetMembersOfUserInfoAPICmd.h"
#import "PomeloMessageCenterDBManager.h"
#import "MessageCenterUserModel.h"

@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,APICmdApiCallBackDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIButton *quitButton;
@property (nonatomic, strong) GetMembersOfUserInfoAPICmd *getMembersOfUserInfoAPICmd;

@end

@implementation UserInfoViewController

#pragma mark - Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configData];
    [self configUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark viewDidLoad methods
- (void)configData
{
    if (_isGroupPush == NO) {
        _userInfo = [[NSMutableDictionary alloc] init];
        NSArray *array = [[PomeloMessageCenterDBManager shareInstance] fetchDataInfosWithType:MessageCenterDBManagerTypeUSER conditionName:@"UserId" SQLvalue:_userId];
        if (array.count != 0) {
            MessageCenterUserModel *userModel = array.lastObject;
            _userInfo[@"UserId"] = userModel.userId;
            _userInfo[@"UserRole"] = userModel.userRole == nil ? @"":userModel.userRole;
            _userInfo[@"UserType"] = userModel.userType == nil ? @"":userModel.userType;
            _userInfo[@"PhoneNo"] = userModel.PhoneNo == nil ? @"":userModel.PhoneNo;
            _userInfo[@"MsgGroupMemberName"] = userModel.personName == nil ? @"":userModel.personName;
            _userInfo[@"Avatar"] = userModel.avatar == nil ? @"":userModel.avatar;
        }
    }

    [self.getMembersOfUserInfoAPICmd loadData];
}

- (void)configUI
{
    ////////////配置navigation///////////////
    [Tool backButton:self btnText:@"用户信息" action:@selector(gotoBack) addTarget:self];
    ////////////配置tableView footer///////////////
    if (_isUserSelf == NO) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-80-40-64)];
        self.tableView.tableFooterView = footerView;
        [footerView addSubview:self.quitButton];
    }
}
#pragma mark - System Delegate
#pragma mark UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"userInfocell";
    UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"UserInfoCell" owner:nil options:nil];
        cell = [array lastObject];
    }
    [cell configData:_userInfo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
#pragma mark APICmdApiCallBackDelegate
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd responseData:(id)responseData
{
    if ([responseData[@"Status"] integerValue] == 1) {
        [_userInfo addEntriesFromDictionary:responseData[@"Result"]];
        [self.tableView reloadData];
    }
}

- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd error:(NSError *)error
{

}

#pragma mark - event responses
/**
 *   @author xiaerfei, 15-11-06 15:11:59
 *
 *   返回上一页
 */
- (void)gotoBack
{
    POP;
}
#pragma mark - getters

- (UIButton *)quitButton
{
    if (_quitButton == nil) {
        _quitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_quitButton setTitle:@"无法加为好友" forState:UIControlStateNormal];
        _quitButton.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height-80-40-64-80, [UIScreen mainScreen].bounds.size.width-40, 40);
        _quitButton.backgroundColor = [UIColor colorWithRed:168.0f/225.0f green:167.0f/225.0f blue:173.0f/225.0f alpha:1];
        [_quitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _quitButton.layer.masksToBounds = YES;
        _quitButton.layer.cornerRadius  = 2;
    }
    return _quitButton;
}

- (GetMembersOfUserInfoAPICmd *)getMembersOfUserInfoAPICmd
{
    if (_getMembersOfUserInfoAPICmd == nil) {
        _getMembersOfUserInfoAPICmd = [[GetMembersOfUserInfoAPICmd alloc] init];
        _getMembersOfUserInfoAPICmd.delegate = self;
        _getMembersOfUserInfoAPICmd.path = [NSString stringWithFormat:@"api_v2/User/getViewUserPersons?userId=%@",_userId.lowercaseString];
    }
    return _getMembersOfUserInfoAPICmd;
}

@end
