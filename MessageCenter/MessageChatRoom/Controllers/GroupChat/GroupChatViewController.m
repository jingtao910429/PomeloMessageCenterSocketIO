//
//  GroupChatViewController.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/20.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "GroupChatViewController.h"
#import "GroupChatCell.h"
#import "RYChatHandler.h"
#import "UIViewExt.h"
#import "GetMembersAPICmd.h"
#import "UIImageView+WebCache.h"
#import "UserInfoViewController.h"

@interface GroupChatViewController ()<UITableViewDataSource,UITableViewDelegate,GroupChatCellDelegate,RYChatHandlerDelegate,APICmdApiCallBackDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIButton *quitButton;
/// 消息免打扰
@property (nonatomic, strong) RYChatHandler *disturbedHandler;
/// 消息免打扰请求Id
@property (nonatomic, assign) NSInteger disturbedRequestId;
/// 消息置顶
@property (nonatomic, strong) RYChatHandler *topChatHandler;
/// 消息置顶请求Id
@property (nonatomic, assign) NSInteger topChatRequestId;
/// 获取组和组成员信息
@property (nonatomic, strong) RYChatHandler *getGroupInfoChatHandler;

@property (nonatomic, strong) GetMembersAPICmd *getMembersAPICmd;

@property (nonatomic, copy) NSMutableDictionary *groupChatInfo;
@property (nonatomic, copy) NSMutableArray *userInfoArray;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation GroupChatViewController

#pragma mark - Lift Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configData];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark viewDidLoad methods
- (void)configData
{
    _groupChatInfo = [[NSMutableDictionary alloc] init];
    _groupChatInfo[kGroupChatCellGroupName] = _groupName;
    _groupChatInfo[kGroupChatCellChatTop]   = @(_isTop);
    _groupChatInfo[kGroupChatCellInfoNotDisturb] = @(_isDisturb);
    
//    [self.getGroupInfoChatHandler chat];
    [self.getMembersAPICmd loadData];
}

- (void)configUI
{
    [Tool backButton:self btnText:@"群聊信息" action:@selector(gotoBack) addTarget:self];
    ////////////配置tableView footer///////////////
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    [footerView addSubview:self.quitButton];
    self.tableView.tableFooterView = footerView;
    
//    self.tableView.tableHeaderView = self.headerView;
}

#pragma mark - System Delegate
#pragma mark UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupChatCell *cell = nil;
    switch (indexPath.section) {
        case 0:
            cell = [self tableView:tableView reuseIdentifier:kGroupChatCellGroupName];
            break;
        case 1:
            if (indexPath.row == 0) {
                cell = [self tableView:tableView reuseIdentifier:kGroupChatCellChatTop];
            } else {
                cell = [self tableView:tableView reuseIdentifier:kGroupChatCellInfoNotDisturb];
            }
            cell.delegate = self;
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - Customer Delegate
#pragma mark GroupChatCellDelegate
- (void)switchValueChange:(BOOL)valueChange reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([reuseIdentifier isEqualToString:kGroupChatCellChatTop]) {
        if (valueChange == YES) {
            self.topChatHandler.parameters = @{@"groupId":self.groupId};
            _groupChatInfo[kGroupChatCellChatTop]   = @(valueChange);
        } else {
            self.topChatHandler.parameters = @{@"groupId":@""};
        }
        [self.topChatHandler chat];
    } else {
        self.disturbedHandler.parameters = @{@"userId":self.userId,
                                         @"isDisturbed":valueChange == YES?@(YES):@(NO)};
       _disturbedRequestId = [self.disturbedHandler chat];
        _groupChatInfo[kGroupChatCellInfoNotDisturb] = @(valueChange);
    }
}
#pragma mark RYChatHandlerDelegate
- (void)connectToChatSuccess:(RYChatHandler *)chatHandler result:(id)data  requestId:(NSInteger)requestId
{
    if (chatHandler.chatServerType == RouteChatTypeDisturbed) {
        NSLog(@"RouteChatTypeDisturbed:%@",data);
    } else if (chatHandler.chatServerType == RouteChatTypeTop) {
        NSLog(@"RouteChatTypeTop:%@",data);
    } else if (chatHandler.chatServerType == RouteChatTypeGetGroupInfo) {
        
    }
}

- (void)connectToChatFailure:(RYChatHandler *)chatHandler result:(id)error  requestId:(NSInteger)requestId
{
    if (chatHandler.chatServerType == RouteChatTypeTop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        GroupChatCell *cell = (GroupChatCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell updateData:@(NO) reuseIdentifier:kGroupChatCellChatTop];
        _groupChatInfo[kGroupChatCellChatTop]   = @(NO);
    } else if (chatHandler.chatServerType == RouteChatTypeDisturbed) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
        GroupChatCell *cell = (GroupChatCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell updateData:@(NO) reuseIdentifier:kGroupChatCellInfoNotDisturb];
        _groupChatInfo[kGroupChatCellInfoNotDisturb] = @(NO);
    }
}

#pragma mark APICmdApiCallBackDelegate
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd responseData:(id)responseData
{
    NSArray *infoArray = responseData;
    if ([infoArray isKindOfClass:[NSArray class]]) {
        if (infoArray.count == 0) {
            return;
        }
        [self createGroupUIWithData:infoArray];
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


- (void)toucheAction:(UIControl *)control
{
    NSInteger index = control.tag - 1211;
    NSDictionary *info = _userInfoArray[index];
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
    userInfoVC.userInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    userInfoVC.isGroupPush = YES;
    userInfoVC.isUserSelf  = [info[@"UserId"] isEqualToString:_userId];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

#pragma mark - private methods
- (GroupChatCell *)tableView:(UITableView *)tableView reuseIdentifier:(NSString *)cellIdentifier
{
    GroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[GroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell updateData:_groupChatInfo[cellIdentifier] reuseIdentifier:cellIdentifier];
    
    return cell;
}
/**
 *   @author xiaerfei, 15-11-03 13:11:19
 *
 *   创建组 UI
 *
 *   @param usersArray
 */
- (void)createGroupUIWithData:(NSArray *)usersArray
{
    if (usersArray.count == 0) {
        return;
    }
    
    // 去掉 103：融誉管理 106：融誉运营
    _userInfoArray = [NSMutableArray array];
    for (NSDictionary *info in usersArray) {
        NSNumber *userRole = info[@"UserRole"];
        if (!(userRole.integerValue == 103 || userRole.integerValue == 106)) {
            [_userInfoArray addObject:info];
        }
    }
    
    ////////////配置tableView header///////////////
    NSInteger count = _userInfoArray.count;
    
    CGFloat lY = 20,pading = 30;
    CGFloat width = 60;
    if (SCREEN_BOUND_HEIGHT < 600 && SCREEN_BOUND_HEIGHT > 480) {
        pading = 20;
    } else if (SCREEN_BOUND_HEIGHT < 490) {
        pading = 15;
    }
    CGFloat leading = ([UIScreen mainScreen].bounds.size.width - 4*width - 3*pading)/2.0f;
    for (int i = 0; i < count; i++) {
        NSDictionary *info = _userInfoArray[i];
        if (i%4 == 0 && i != 0) {
            lY += (width +10+15);
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leading + (width + pading)*(i%4), lY, width, width)];
        imageView.userInteractionEnabled = YES;
        imageView.backgroundColor = RGB(224, 224, 224);
        [imageView sd_setImageWithURL:[NSURL URLWithString:info[@"Avatar"]]];
        [self.headerView addSubview:imageView];
        
        UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(imageView.left-pading/2, imageView.bottom +5, width + pading, 15)];
        userName.userInteractionEnabled = YES;
        userName.font = [UIFont systemFontOfSize:12];
        userName.text = info[@"MsgGroupMemberName"];
        userName.textAlignment = NSTextAlignmentCenter;
        [self.headerView addSubview:userName];
        
        
        UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(imageView.left, imageView.top, imageView.width,userName.bottom - imageView.top)];
        control.tag = 1211 + i;
        [control addTarget:self action:@selector(toucheAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:control];
        
    }
    CGFloat height = lY + width +5+15+20+10;
    self.headerView.height = height;
    [self.tableView beginUpdates];
    [self.tableView setTableHeaderView:self.headerView];
    [self.tableView endUpdates];
}

#pragma mark - getters

- (UIButton *)quitButton
{
    if (_quitButton == nil) {
        _quitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_quitButton setTitle:@"系统群无法退出" forState:UIControlStateNormal];
        _quitButton.frame = CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width-40, 40);
        _quitButton.backgroundColor = [UIColor colorWithRed:168.0f/225.0f green:167.0f/225.0f blue:173.0f/225.0f alpha:1];
        [_quitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _quitButton.layer.masksToBounds = YES;
        _quitButton.layer.cornerRadius  = 2;
    }
    return _quitButton;
}

- (UIView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_BOUND_WIDTH, 100)];
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _headerView;
}

- (GetMembersAPICmd *)getMembersAPICmd
{
    if (_getMembersAPICmd == nil) {
        _getMembersAPICmd = [[GetMembersAPICmd alloc] init];
        _getMembersAPICmd.delegate = self;
        _getMembersAPICmd.path = [NSString stringWithFormat:@"api_v2/MsgGroupMemberInfo/%@/getMembers",_groupId.lowercaseString];
    }
    return _getMembersAPICmd;
}

- (RYChatHandler *)disturbedHandler {
    if (!_disturbedHandler) {
        _disturbedHandler = [[RYChatHandler alloc] initWithDelegate:self];
        _disturbedHandler.chatServerType = RouteChatTypeDisturbed;
    }
    return _disturbedHandler;
}

- (RYChatHandler *)topChatHandler {
    if (!_topChatHandler) {
        _topChatHandler = [[RYChatHandler alloc] initWithDelegate:self];
        _topChatHandler.chatServerType = RouteChatTypeTop;
        
        
    }
    return _topChatHandler;
}

- (RYChatHandler *)getGroupInfoChatHandler {
    if (!_getGroupInfoChatHandler) {
        _getGroupInfoChatHandler = [[RYChatHandler alloc] initWithDelegate:self];
        _getGroupInfoChatHandler.chatServerType = RouteChatTypeGetGroupInfo;
    }
    _getGroupInfoChatHandler.parameters = @{@"groupId":self.groupId};
    return _getGroupInfoChatHandler;
}
@end
