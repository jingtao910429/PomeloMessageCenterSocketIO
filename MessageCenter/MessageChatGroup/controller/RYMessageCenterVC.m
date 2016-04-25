//
//  RYMessageCenterVC.m
//  RYMessageCenter
//
//  Created by gqq on 15/10/19.
//  Copyright (c) 2015年 __RongYu100__. All rights reserved.
//

#import "RYMessageCenterVC.h"
#import "PomeloMessageCenterDBManager.h"
#import "MessageTool.h"
#import "ConnectToServer.h"
#import "RYChatHandler.h"
#import "ChatViewRoomController.h"
#import "RDVTabBarController.h"
#import "MJRefresh.h"
#import "TabBarRootViewController.h"
#import "NSString+Extension.h"
#import "ConnectToServer.h"
#import "RYChatHandler.h"
#import "AppDelegate.h"
#import "MSCMoreOptionTableViewCell.h"
#import "RDVTabBarController.h"
#import "MessageTool.h"

#define Header_Height 65
#define Connect_TableHeight (64 + 44 + 49)
#define DisConnect_TableHeight (64 + 44 + 49 + 40)
#define kBTNSELECTBACK_COLOR [UIColor colorWithRed:0/255.0 green:121.0/255.0 blue:199.0/255.0 alpha:1.0]
#define kBTNNORMALBACK_COLOR [UIColor darkGrayColor]

@interface RYMessageCenterVC ()<RYChatHandlerDelegate>

@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) RYChatHandler *topChatHandler;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, retain) UIRefreshControl *refreshControl;

@property (nonatomic, assign) NSInteger PageIndex;
//获取组信息（如果本地数据已过期）
@property (nonatomic, strong) RYChatHandler *getGroupsChat;

@property (nonatomic, strong) NSMutableArray *unreadDataSource;
@property (nonatomic, strong) NSMutableArray *readDataSource;

@property (nonatomic, assign) BOOL groupRequestFinished;

@end

@implementation RYMessageCenterVC

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //断开服务注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ConnectStateNotificationStr:) name:[MessageTool ConnectStateNotificationStr] object:nil];
     
    [self setBodyUI];
    [self initData];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate.rdvtabBarController setTabBarHidden:NO animated:YES];
    [delegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
    [MessageTool setDBChange:@"YES"];
    
    [self getGroupWithTypeNeedAllData:[NSNumber numberWithBool:YES]];
    
    if (![[MessageTool connectStatus] isEqualToString:@"0"]) {
        [self showConnectUI];
    }else {
        [self showDisConnect];
    }
    
    
    [self addEmptyView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[MessageTool ConnectStateNotificationStr] object:nil];
}


#pragma mark viewDidLoad methods

- (void)initData{
    
    self.groupType            = 1;
    self.PageIndex            = 1;
    self.groupRequestFinished = YES;
    self.dataSource           = [[NSMutableArray alloc] initWithCapacity:20];
}

- (void)setBodyUI{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //断开连接提示
    self.disConnectLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_BOUND_WIDTH, 40)];
    self.disConnectLabel.backgroundColor = [UIColor grayColor];
    self.disConnectLabel.text = @"暂时无法连接服务，不能获取最新消息";
    self.disConnectLabel.textAlignment = NSTextAlignmentCenter;
    self.disConnectLabel.textColor = [UIColor whiteColor];
    self.disConnectLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.disConnectLabel];
    self.disConnectLabel.hidden = YES;

    [self addHeadView:self.headView];
    [self.view addSubview:self.allTableViewInfo];
    [self.view addSubview:self.readTableViewInfo];
    [self.view addSubview:self.unReadTableViewInfo];
    
    self.readTableViewInfo.hidden = YES;
    self.unReadTableViewInfo.hidden = YES;
    
    [self.allTableViewInfo addSubview:self.refreshControl];

    //上拉加载
    self.allTableViewInfo.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pollUpReloadData)];
}

//设置顶部选项栏
- (void)addHeadView:(UIView *)headView{
    
    
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_BOUND_WIDTH, 44)];
    self.headView.backgroundColor = [UIColor whiteColor];
    NSArray *btnTitleArr = @[@"全部",@"已读",@"未读"];
    CGFloat btnWidth = (SCREEN_BOUND_WIDTH - 40)/btnTitleArr.count;
    
    for (int j = 0; j<btnTitleArr.count; j++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20+btnWidth*j, 0, btnWidth, CGRectGetHeight(self.headView.frame)-2)];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:btnTitleArr[j] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 10+j;
        j == 0 ? ([btn setTitleColor:kBTNSELECTBACK_COLOR forState:UIControlStateNormal]) : ([btn setTitleColor:kBTNNORMALBACK_COLOR forState:UIControlStateNormal]);
        [self.headView addSubview:btn];
    }
    
    self.lineView.frame = CGRectMake(20, CGRectGetHeight(self.headView.frame)-2, btnWidth, 2);
    [self.headView addSubview:self.lineView];
    
    [self.view addSubview:self.headView];
}
#pragma mark - SystemDelegate
#pragma mark  UITableViewDataSource,UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.allTableViewInfo]) {
        
        return self.dataSource.count;
    }
    else if ([tableView isEqual:self.readTableViewInfo] ) {
        return self.readDataSource.count;
    }
    else{
        return self.unreadDataSource.count;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 79.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:self.allTableViewInfo]) {
        static NSString *identifier = @"MessageCell";
        MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MSCMoreOptionTableViewCell" owner:self options:nil][0];
            cell.delegate = self;
        }
        
        if (self.dataSource && self.dataSource.count > indexPath.row) {
            MessageCenterMetadataModel *model = self.dataSource[indexPath.row];
            [cell updateUIWithRYMessageCenterModel:model];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if ([tableView isEqual:self.readTableViewInfo]) {
        static NSString *identifier = @"MessageCell";
        MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MSCMoreOptionTableViewCell" owner:self options:nil][0];
            cell.delegate = self;
        }
        
        if (self.readDataSource && self.readDataSource.count > indexPath.row) {
            MessageCenterMetadataModel *model = self.readDataSource[indexPath.row];
            [cell updateUIWithRYMessageCenterModel:model];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else {
        static NSString *identifier = @"MessageCell";
        MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MSCMoreOptionTableViewCell" owner:self options:nil][0];
            cell.delegate = self;
        }
        
        if (self.unreadDataSource && self.unreadDataSource.count > indexPath.row) {
            MessageCenterMetadataModel *model = self.unreadDataSource[indexPath.row];
            [cell updateUIWithRYMessageCenterModel:model];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
   
}
//删除组操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
            if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
                [cell hideDeleteConfirmation];
                NSLog(@"删除删除删除删除");
                MessageCenterMetadataModel *model = [[MessageCenterMetadataModel alloc]init] ;
                if ([tableView isEqual:self.allTableViewInfo]) {
                    model = self.dataSource[indexPath.row];
                    [self.allTableViewInfo setEditing:NO animated:NO];
                }
                else if ([tableView isEqual:self.readTableViewInfo]){
                    model = self.readDataSource[indexPath.row];
                    [self.readTableViewInfo setEditing:NO animated:NO];
                }else{
                    model = self.unreadDataSource[indexPath.row];
                    [self.unReadTableViewInfo setEditing:NO animated:NO];
                }
                [[PomeloMessageCenterDBManager shareInstance] deleteDataWithTableWithType:MessageCenterDBManagerTypeMETADATA SQLvalue:model.groupId];
                
                [MessageTool setDBChange:@"YES"];
                [self getGroupWithTypeNeedAllData:[NSNumber numberWithBool:YES]];
                
            }
        }];
        
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatViewRoomController *chatRoomController = [[ChatViewRoomController alloc]init];
    if ([tableView isEqual:self.allTableViewInfo]) {
        MessageCenterMetadataModel *model = self.dataSource[indexPath.row];
        chatRoomController.metaModel = model;
        chatRoomController.groupId = model.groupId;
    }
    else if([tableView isEqual:self.readTableViewInfo])
    {
        MessageCenterMetadataModel *model = self.readDataSource[indexPath.row];
        chatRoomController.metaModel = model;
        chatRoomController.groupId = model.groupId;
    }
    else
    {
        MessageCenterMetadataModel *model = self.unreadDataSource[indexPath.row];
        chatRoomController.metaModel = model;
        chatRoomController.groupId = model.groupId;
    }
    [self.navigationController pushViewController:chatRoomController animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

#pragma mark - MSCMoreOptionTableViewCellDelegate
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return @"  删   除  ";
}

- (UIColor *)tableView:(UITableView *)tableView backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIColor colorWithRed:228.0/225.0 green:14.0/225.0 blue:25.0/225.0 alpha:1.0];
}
//置顶组操作
- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
            if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
                [cell hideDeleteConfirmation];
                NSLog(@"置顶置顶置顶置顶");
                MessageCenterMetadataModel *model = [[MessageCenterMetadataModel alloc]init];
                //判断数据源
                if ([tableView isEqual:self.allTableViewInfo]) {
                    model = self.dataSource[indexPath.row];
                }
                else if ([tableView isEqual:self.readTableViewInfo])
                {
                    model = self.readDataSource[indexPath.row];
                }else
                {
                    model = self.unreadDataSource[indexPath.row];
                }

                //判断是否有置顶
                if ([model.isTop isEqualToString:@"YES"] && indexPath.row == 0) {
                    self.topChatHandler.parameters = @{@"groupId":@""};
                }
                else{
                    self.topChatHandler.parameters = @{@"groupId":model.groupId};
                }
                [self.topChatHandler chat];
            }
        }];
}

- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MessageCenterMetadataModel *model = [[MessageCenterMetadataModel alloc]init];
    if ([tableView isEqual:self.allTableViewInfo]) {
        model = self.dataSource[indexPath.row];
    }
    else if([tableView isEqual:self.readTableViewInfo])
    {
        model = self.readDataSource[indexPath.row];
    }
    else
    {
        model = self.unreadDataSource[indexPath.row];
    }
    if (indexPath.row == 0 && [model.isTop isEqualToString:@"YES"]) {
        return @"  取消置顶  ";
    }
    return @"  置   顶  ";
}

- (UIColor *)tableView:(UITableView *)tableView backgroundColorForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIColor colorWithRed:24.0/225.0 green:141.0/225.0 blue:204.0/225.0 alpha:1.0];
}

#pragma mark - CustomDelegate

#pragma mark RYChatHandlerDelegate

- (void)connectToChatSuccess:(RYChatHandler *)chatHandler result:(id)data requestId:(NSInteger)requestId{
    
    [self.allTableViewInfo.footer endRefreshing];
    if (_refreshControl && _refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
    }
    
    if (chatHandler == self.getGroupsChat) {
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:data];
        
        if (tempDict[@"groups"] && ![tempDict[@"groups"] isKindOfClass:[NSNull class]]) {
            
            NSArray *datas = [[PomeloMessageCenterDBManager shareInstance] fetchGroupsWithGroupReadType:GroupReadTypeAll currentPage:(self.PageIndex + 1) isNeedAllData:YES];
            
            if (datas && datas.count != 0) {
                
                //添加数据库数据
                self.dataSource = [[NSMutableArray alloc] initWithArray:datas];
                
            }else{
                
                //如果添加数据库数据失败，获取本地
                
            }
            
            if (datas.count != 0 && datas.count % GROUP_LIST_NUMBER == 0) {
                self.PageIndex ++;
            }
        
        }
        
        
        self.groupRequestFinished = YES;
        [self seperateDatas];
        [self refreshUI];
    }
    
}

- (void)connectToChatFailure:(RYChatHandler *)chatHandler result:(id)error requestId:(NSInteger)requestId{
    
    if (chatHandler == self.getGroupsChat) {
        [self.allTableViewInfo.footer endRefreshing];
        if (_refreshControl && _refreshControl.isRefreshing) {
            [_refreshControl endRefreshing];
        }
    }
    
}


#pragma mark - event response
#pragma mark 头部点击按钮事件

- (void)onSelectClick:(UIButton*)sender{
    
    [UIView animateWithDuration:0.05 animations:^{
        CGRect tampFrame = self.lineView.frame;
        tampFrame.origin.x = CGRectGetMinX(sender.frame);
        self.lineView.frame = tampFrame;
    }];
    
    [sender setTitleColor:kBTNSELECTBACK_COLOR forState:UIControlStateNormal];
    for (UIView *view in self.headView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)view;
            if (btn != sender) {
                [btn setTitleColor:kBTNNORMALBACK_COLOR forState:UIControlStateNormal];
            }
        }
    }
    
    if (sender.tag != 10) {
        [self seperateDatas];
    }
    
    switch (sender.tag) {
        case 10://全部
            self.allTableViewInfo.hidden = NO;
            self.readTableViewInfo.hidden = YES;
            self.unReadTableViewInfo.hidden = YES;
            self.groupType = 1;
            [self.allTableViewInfo reloadData];
            break;
        case 11://已读
            self.allTableViewInfo.hidden = YES;
            self.readTableViewInfo.hidden = NO;
            self.unReadTableViewInfo.hidden = YES;
            self.groupType = 2;
            [self.readTableViewInfo reloadData];

            break;
            
        case 12://未读
            self.allTableViewInfo.hidden = YES;
            self.readTableViewInfo.hidden = YES;
            self.unReadTableViewInfo.hidden = NO;
            self.groupType = 3;
            [self.unReadTableViewInfo reloadData];
            break;
            
        default:
            break;
    }
    [self addEmptyView];
}
- (void)gotoBack
{
    POP;
}

//上拉加载
- (void)pollUpReloadData {
    
    if (!self.groupRequestFinished) {
        return;
    }
    
    self.PageIndex = self.dataSource.count / GROUP_LIST_NUMBER + 1;
    
    NSArray *datas = [[PomeloMessageCenterDBManager shareInstance] fetchGroupsWithGroupReadType:GroupReadTypeAll currentPage:self.PageIndex isNeedAllData:NO];
    
    if (!datas || datas.count == 0) {
        
        if (self.groupRequestFinished) {
            self.groupRequestFinished = NO;
            [self.getGroupsChat chat];
        }
        
    }else{
        
        self.groupRequestFinished = YES;
    
        if (1 == self.PageIndex && self.dataSource.count != 0) {
            [self.dataSource removeAllObjects];
        }
        
        self.dataSource = [[NSMutableArray alloc] initWithArray:[self.dataSource arrayByAddingObjectsFromArray:datas]];
        
        [self seperateDatas];
        
        [self.allTableViewInfo reloadData];
        [self.allTableViewInfo.footer endRefreshing];
    }
    
}

#pragma mark - private methods
//获取全部、已读、未读列表
//（self.groupType = 1 全部     2 已读  3 未读）
-(void)getGroupWithTypeNeedAllData:(id)isNeedAllData
{
    
    if ([[MessageTool DBChange] isEqualToString:@"YES"]) {
        
        [MessageTool setDBChange:@"NO"];
        
        self.dataSource = [[NSMutableArray alloc] initWithArray:[[PomeloMessageCenterDBManager shareInstance] fetchGroupsWithGroupReadType:GroupReadTypeAll currentPage:self.PageIndex isNeedAllData:[isNeedAllData boolValue]]];

        if (!self.dataSource || self.dataSource.count == 0) {
            [self.getGroupsChat chat];
            [_refreshControl endRefreshing];

        }else{
            
            if (_refreshControl && _refreshControl.isRefreshing) {
                [_refreshControl endRefreshing];
            }
            
            [self seperateDatas];
            
            [self refreshUI];
        }
    }
    
}

- (void)seperateDatas {
    
    self.unreadDataSource = [[NSMutableArray alloc]init];
    self.readDataSource = [[NSMutableArray alloc]init];
    //根据未读消息个数区别已读和未读
    for (MessageCenterMetadataModel *model in self.dataSource) {
        
        //全部、已读、未读，都需要置顶元素
        if ([model.isTop isEqualToString:@"YES"]) {
            [self.unreadDataSource addObject:model];
            [self.readDataSource addObject:model];
            continue;
        }
        
        if ([model.unReadMsgCount integerValue] > 0) {
            //未读群组数据源
            [self.unreadDataSource addObject:model];
        }else{
            
            //已读群组数据源
            [self.readDataSource addObject:model];
            
        }
    }
    
    //判断是否有未读消息
    if (self.unreadDataSource.count != 0) {
        
        MessageCenterMetadataModel *model = self.unreadDataSource[0];
        
        if (self.unreadDataSource.count == 1 && [model.unReadMsgCount integerValue] <= 0) {
            
            [MessageTool setUnReadMessage:@"NO"];
            //消息中心tabbar消息未读提示
            [(TabBarRootViewController *)self.tabBarController tabBarView].dotLabel.hidden = YES;
            //主tabbar上的消息未读提示
            
            self.rdv_tabBarController.tabBar.dotLabel.hidden = YES;

        }else{
            
            [MessageTool setUnReadMessage:@"YES"];
            [(TabBarRootViewController *)self.tabBarController tabBarView].dotLabel.hidden = NO;
            self.rdv_tabBarController.tabBar.dotLabel.hidden = NO;

        }
        
    }else{
        
        [MessageTool setUnReadMessage:@"NO"];
        [(TabBarRootViewController *)self.tabBarController tabBarView].dotLabel.hidden = YES;
        self.rdv_tabBarController.tabBar.dotLabel.hidden = YES;
    }
    
}

- (void)refreshUI {
    
    if (self.groupType == 1) {
        [self.allTableViewInfo reloadData];
    }
    else if (self.groupType == 2){
        [self.readTableViewInfo reloadData];
    }
    else{
        [self.unReadTableViewInfo reloadData];
    }
    
}

//数据变化通知
-(void)refreshTableView
{
    
    if ([[MessageTool DBChange] isEqualToString:@"YES"]) {
        
        [MessageTool setDBChange:@"NO"];
        
        self.dataSource = [[NSMutableArray alloc] initWithArray:[[PomeloMessageCenterDBManager shareInstance] fetchGroupsWithGroupReadType:GroupReadTypeAll currentPage:self.PageIndex isNeedAllData:YES]];
        
        [self seperateDatas];
        
        [self refreshUI];
    }

}

//下拉刷新

//下拉刷新
- (void)reload:(__unused id)sender {
    if (!self.disConnectLabel.hidden) {
        [_refreshControl endRefreshing];
        return;
    }
    self.PageIndex = 1;
    [MessageTool setDBChange:@"YES"];
    [self getGroupWithTypeNeedAllData:[NSNumber numberWithBool:YES]];
}

-(void)showDisConnect
{
    self.disConnectLabel.hidden = NO;
    self.headView.frame = CGRectMake(0, CGRectGetMaxY(self.disConnectLabel.frame), SCREEN_BOUND_WIDTH, 44);
    self.allTableViewInfo.frame = CGRectMake(0, CGRectGetMaxY(self.headView.frame), SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - DisConnect_TableHeight) ;
    self.readTableViewInfo.frame = CGRectMake(0, CGRectGetMaxY(self.headView.frame), SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - DisConnect_TableHeight) ;
    self.unReadTableViewInfo.frame = CGRectMake(0, CGRectGetMaxY(self.headView.frame), SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - DisConnect_TableHeight) ;

}

//重新连接处理
-(void)showConnectUI
{
    self.disConnectLabel.hidden = YES;
    self.headView.frame = CGRectMake(0, 0, SCREEN_BOUND_WIDTH, 44);
    self.allTableViewInfo.frame = CGRectMake(0, CGRectGetMaxY(self.headView.frame), SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - Connect_TableHeight);
    self.readTableViewInfo.frame = CGRectMake(0, CGRectGetMaxY(self.headView.frame), SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - Connect_TableHeight);
    self.unReadTableViewInfo.frame = CGRectMake(0, CGRectGetMaxY(self.headView.frame), SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - Connect_TableHeight);
}

//断开服务通知
- (void)ConnectStateNotificationStr:(NSNotification *)notification
{

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *resultStr = (NSString *)notification.object;
        if (([resultStr isEqualToString:@"1"] || [resultStr isEqualToString:@"-1"]) && self.headView.origin.y != 0) {
            [self showConnectUI];
        }else if ([resultStr isEqualToString:@"0"] && self.headView.origin.y == 0) {
            [self.allTableViewInfo.footer endRefreshing];

            [self showDisConnect];
        }
    });
     
}
//处理空页面
-(void)addEmptyView
{
    if (self.groupType == 2) {
        if (self.readDataSource.count == 0) {
            if (![self.readTableViewInfo viewWithTag:2222]) {
                
                [self createCustomerEmptyView:@"暂无已读消息" withFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame) - 44, SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - Connect_TableHeight) withView:self.readTableViewInfo] ;
            }
        }
        else
        {
            UIView *emptyView = [self.readTableViewInfo viewWithTag:2222];
            [emptyView removeFromSuperview];
        }
        
    }
    else if (self.groupType == 3)
    {
        if (self.unreadDataSource.count == 0) {
            if (![self.unReadTableViewInfo viewWithTag:2222]) {
                
                [self createCustomerEmptyView:@"暂无未读消息" withFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame) - 44, SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - Connect_TableHeight) withView:self.unReadTableViewInfo] ;
            }
        }
        else
        {
            UIView *emptyView = [self.unReadTableViewInfo viewWithTag:2222];
            [emptyView removeFromSuperview];
        }
        
    }
    else
    {
        if (self.dataSource.count == 0) {
            if (![self.allTableViewInfo viewWithTag:2222]) {
                
                [self createCustomerEmptyView:@"暂无消息" withFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame) - 44, SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - Connect_TableHeight) withView:self.allTableViewInfo] ;
            }
        }
        else
        {
            UIView *emptyView = [self.allTableViewInfo viewWithTag:2222];
            [emptyView removeFromSuperview];
        }
    }
}
#pragma mark - getters and setters

- (UITableView *)allTableViewInfo{
    
    if (!_allTableViewInfo) {
        _allTableViewInfo = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame), SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - Connect_TableHeight) style:UITableViewStyleGrouped];
        _allTableViewInfo.backgroundColor = [Tool getBackgroundColor];
        _allTableViewInfo.delegate = self;
        _allTableViewInfo.dataSource = self;
    }
    
    return _allTableViewInfo;
}

- (UIRefreshControl *)refreshControl {
    
    if (!_refreshControl) {
        
        _refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _allTableViewInfo.frame.size.width, -Header_Height)];
        [_refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (UITableView *)readTableViewInfo{
    
    if (!_readTableViewInfo) {
        _readTableViewInfo = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame), SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - Connect_TableHeight) style:UITableViewStyleGrouped];
        _readTableViewInfo.backgroundColor = [Tool getBackgroundColor];
        _readTableViewInfo.delegate = self;
        _readTableViewInfo.dataSource = self;
    }
    
    return _readTableViewInfo;
}
- (UITableView *)unReadTableViewInfo{
    
    if (!_unReadTableViewInfo) {
        _unReadTableViewInfo = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame), SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT - Connect_TableHeight) style:UITableViewStyleGrouped];
        _unReadTableViewInfo.backgroundColor = [Tool getBackgroundColor];
        _unReadTableViewInfo.delegate = self;
        _unReadTableViewInfo.dataSource = self;
    }
    
    return _unReadTableViewInfo;
}
- (UIView *)lineView{
    
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithRed:0/255.0 green:121.0/255.0 blue:199.0/255.0 alpha:1.0];
    }
    
    return _lineView;
}

- (RYChatHandler *)topChatHandler {
    if (!_topChatHandler) {
        _topChatHandler = [[RYChatHandler alloc] initWithDelegate:self];
        _topChatHandler.chatServerType = RouteChatTypeTop;
        
    }
    return _topChatHandler;
}

- (RYChatHandler *)getGroupsChat {
    
    if (!_getGroupsChat) {
        _getGroupsChat = [[RYChatHandler alloc] initWithDelegate:self];
        _getGroupsChat.chatServerType = RouteChatTypeGetGroups;
    }
    _getGroupsChat.parameters = @{@"skipCount":[NSNumber numberWithInteger:(self.PageIndex - 1) * GROUP_LIST_NUMBER],@"readType":[NSNumber numberWithInteger:0],@"count":[NSNumber numberWithInteger:GROUP_LIST_NUMBER]};
    
    return _getGroupsChat;
}

@end

