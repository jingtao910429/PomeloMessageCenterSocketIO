//
//  ChatViewController.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/7/28.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "ChatViewRoomController.h"

#import "NSString+Extension.h"
#import "UIViewExt.h"
#import "RegexKitLite.h"

#import "GroupChatViewController.h"
#import "UserInfoViewController.h"

#import "RYChatHandler.h"
#import "RYNotifyHandler.h"
#import "ConnectToServer.h"
#import "PomeloMessageCenterDBManager.h"
#import "MessageTool.h"
#import "MJRefresh.h"
#import "NSString+Extension.h"

#import "ChatViewRoomController+ChatViewRoom.h"

@interface ChatViewRoomController ()<UITableViewDataSource, UITableViewDelegate,ChatInputBarDelegate,MessageCellDelegate>
{
    UIAlertView *_dismissAlertView;
}

@property (nonatomic, strong) RYChatHandler *sendChatHandler;
@property (nonatomic, strong) RYChatHandler *readChatHandler;
//getMsg
@property (nonatomic, strong) RYChatHandler *getMsgChatHandler;
/// 消息列表数组
@property (nonatomic, copy) NSMutableArray *messageDataModelArray;
@property (nonatomic, copy) NSMutableArray *reSendMessageArray;
/// 发送时 messageId 和 Model 对应
@property (nonatomic, copy) NSMutableDictionary *sendMessageDict;
/// 判断是否是自己发送的消息
@property (nonatomic, copy) NSMutableDictionary *isSelfSendmessageDict;
/// 记录该用户的userId
@property (nonatomic, copy) NSString *userId;
/// 记录最上面的一条消息的messageId 以备从服务器拉取数据
@property (nonatomic, copy) NSString *fetchUserMessageId;
/// 记录最上面的一条消息的messageTime 以备从本地DB拉取数据
@property (nonatomic, copy) NSString *fetchUserMessageTime;
/// 记录重新发送的Model
@property (nonatomic, strong) MessageModel *reSendMessageModel;
/// 记录更多消息最上面的一条
@property (nonatomic, strong) MessageModel *moreMessageModelFirst;
/// 标识本地DB的历史消息是否已经拉取完成
@property (nonatomic, assign) BOOL isLocalHistoryMessageOver;
/// 记录是否第一次拉取完成数据，以便tableView最后一条数据能展示出来
/// 1:本地拉取数据20条 2:去服务器拉取数据 3:第一次拉取完成
@property (nonatomic, assign) NSInteger isFirstLoadMessage;
/// 拉取数据的数量
@property (nonatomic, assign) NSInteger fetchDataNumber;
/// 是否被删除
@property (nonatomic, assign) BOOL isDelete;
/// 是否连接成功
@property (nonatomic, assign) BOOL isConnect;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)touchEndEidt:(id)sender;


@end

@implementation ChatViewRoomController

#pragma mark - Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configData];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.shadowImage = nil;
    [_dismissAlertView dismissWithClickedButtonIndex:0 animated:NO];
    [self readMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[MessageTool PushGlobalNotificationStr] object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[MessageTool ConnectStateNotificationStr] object:nil];
}
#pragma mark viewDidLoad methods
- (void)configData
{
    ////////////注册通知///////////////
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushGlobalNotificationStr:) name:[MessageTool PushGlobalNotificationStr] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disConnectNotificationStr:) name:[MessageTool ConnectStateNotificationStr] object:nil];

    ////////////初始化数组///////////////
    _sendMessageDict       = [[NSMutableDictionary alloc] init];
    _isSelfSendmessageDict = [[NSMutableDictionary alloc] init];
    _reSendMessageArray    = [[NSMutableArray alloc] init];
    _messageDataModelArray = [[NSMutableArray alloc] init];
    ////////////初始化变量///////////////
    _userId  = [MessageTool getUserID];
    _fetchDataNumber = kFetchMessageNumber;
    
    self.isConnect = [[MessageTool connectState] boolValue];
    
//    self.isDelete = YES;
    ////////////载入消息///////////////
    [self loadNewData];
}
- (void)configUI
{
//    self.view.backgroundColor = [UIColor greenColor];
    NSDictionary *dict = [MessageModel messageCenterStatusWithGroupId:_groupId];
    ////////////去掉导航栏最下面那条线///////////////
    [self configNavigationBar];
    ////////////创建 导航栏右边Item///////////////
    [self configNavigationBarItemWithActions:@[@"gotoBack",@"chatInfoAction"]];
    ////////////配置 导航栏title///////////////
    [self configNavigationBarWithTitles:@[dict[@"groupName"],dict[@"companyName"]]];
    ////////////创建 申请状态View///////////////
    [self.applicationStatusView updateAplicationStatusText:[Tool getApplyingStatus:[dict[@"approveStatus"] intValue]]];
    ////////////调整tableView frame///////////////
    [self configTableViewWithTapAction:@"tapKeyEvent"];
    /**
     *  addsubViews 
     *  applicationStatusView、disconnectTipLabel、moreMessageView、chatInputBar
     **/
    [self addSubViewsWithInfo:dict];
    ////////////配置下拉刷新///////////////
    [self addHeaderRefreshWithAction:@"loadNewData"];
    
    self.moreMessageView.hidden = self.isConnect;
    [self disconnectViewHide:self.isConnect];
}

#pragma mark - System Delegate
#pragma mark UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isDelete) {
        return 1;
    } else {
        return _messageDataModelArray.count;
    }
}

- (MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = nil;
    if (self.isDelete) {
        self.chatInputBar.isCanSendMessage = NO;
        self.moreMessageView.hidden = YES;
        self.tableView.scrollEnabled = NO;
        cell = [self tableView:tableView reuseIdentifier:kMessageCellDelete];
    } else {
        MessageModel *message = _messageDataModelArray[indexPath.row];
        
        if (message.messageType == MessageTypeTime) {
            cell = [self tableView:tableView reuseIdentifier:kMessageCellTime];
            [cell configData:message reuseIdentifier:kMessageCellTime];
        } else if (message.messageType == MessageTypeChat) {
            cell = [self tableView:tableView reuseIdentifier:kMessageCellChat];
            cell.delegate = self;
            [cell configData:message reuseIdentifier:kMessageCellChat];
        } else {
            cell = [self tableView:tableView reuseIdentifier:kMessageCellSystem];
            [cell configData:message reuseIdentifier:kMessageCellSystem];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isDelete) {
        return SCREEN_BOUND_HEIGHT - 64 - 40 - 40;
    } else {
        MessageModel *message = _messageDataModelArray[indexPath.row];
        if (message.messageType == MessageTypeTime) {
            return 44;
        } else {
            return message.cellHeght;
        }
    }
}
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        _reSendMessageModel.isSendFail = NO;
        _reSendMessageModel.animateStatus = YES;
        [self reloadDataWithModel:_reSendMessageModel];
    } else {
        _reSendMessageModel = nil;
    }
}

#pragma mark - Customer Delegate
#pragma mark RYChatHandlerDelegate
- (void)connectToChatSuccess:(RYChatHandler *)chatHandler result:(id)data requestId:(NSInteger)requestId
{
    if (chatHandler.chatServerType == RouteChatTypeGetMsg) {
        NSArray *msgs = data[@"msgs"];
        NSArray *rever = [[msgs reverseObjectEnumerator] allObjects];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *info in rever) {
            MessageModel *model = nil;
            if ((info[@"from"] != nil) && ([info[@"from"] isEqualToString:_userId])) {
                
                model = [MessageModel parseNotifyData:info modelType:MessageModelTypeMe];
            } else {
                model = [MessageModel parseNotifyData:info modelType:MessageModelTypeOther];
            }
            if (model != nil) {
                [array addObject:model];
            }
        }

        [self messageDataModelArrayAddModels:array completeFinishBlock:^{
            if (_messageDataModelArray.count >= 1) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                if (_isFirstLoadMessage == 2) {
                    _isFirstLoadMessage = 3;
                    indexPath = [NSIndexPath indexPathForItem:_messageDataModelArray.count - 1 inSection:0];
                }
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }];
        
        if (self.tableView.header.isRefreshing) {
            [self.tableView.header endRefreshing];
        }
    }
}
- (void)connectToChatFailure:(RYChatHandler *)chatHandler result:(id)error requestId:(NSInteger)requestId
{
    [self messageSendFailedOfNetDisconnect];
    if (self.tableView.header.isRefreshing) {
        [self.tableView.header endRefreshing];
    }
}

#pragma mark ChatInputBarDelegate
- (void)chatInputBar:(ChatInputBar *)chatInputBar changeHeigh:(CGFloat)changeHeigh
{
    self.tableView.height = self.chatInputBar.top - 30;
}
/**
 *   @author xiaerfei, 15-10-30 13:10:05
 *
 *   发送消息处理
 *
 *   @param chatInputBar
 *   @param message
 */
- (void)chatInputBar:(ChatInputBar *)chatInputBar sendMessage:(NSString *)message
{
    self.tableView.height = self.chatInputBar.top - 30;
    MessageModel *messageModel = [MessageModel sendMessageWithContent:message];
    messageModel.fromId  = _userId;
    messageModel.groupId = _groupId;
    [self sendMessage:messageModel];
}

#pragma mark MessageCellDelegate

- (void)messageCell:(MessageCell *)cell touchData:(MessageModel *)model
{
    if (model.isSendFail == YES) {
        _reSendMessageModel = model;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"重发该消息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        _dismissAlertView = alertView;
        [alertView show];
    }
}

- (void)messageCell:(MessageCell *)cell iconTouchData:(MessageModel *)model
{
    UserInfoViewController *userInfo = [[UserInfoViewController alloc] init];
    userInfo.groupId = _groupId;
    userInfo.userId  = model.fromId;
    if ([model.fromId isEqualToString:_userId]) {
        userInfo.isUserSelf = YES;
    }
    [self.navigationController pushViewController:userInfo animated:YES];
}

#pragma mark - events response
/**
 *   @author xiaerfei, 15-11-02 15:11:22
 *
 *   推送的消息处理
 *
 *   @param notification
 */
- (void)pushGlobalNotificationStr:(NSNotification *)notification
{
    id callBackData = notification.object;
    NSDictionary *userInfo = notification.userInfo;
    //去除不是一个群组的消息
    if (![callBackData[@"toGroupId"] isEqualToString:_groupId]) {
        return;
    }
    
    if (userInfo[@"route"] && [userInfo[@"route"] isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnApproveStatusChanged]]) {
        
        if (callBackData[@"creditApplicationStatus"] && ![callBackData[@"creditApplicationStatus"] isKindOfClass:[NSNull class]]) {
            // 信贷申请审核状态
            int type = [callBackData[@"creditApplicationStatus"] intValue];
            NSString *appStatusStr = [Tool getApplyingStatus:type];
            [self.applicationStatusView updateAplicationStatusText:appStatusStr];
        }
    }else if (userInfo[@"route"] && [userInfo[@"route"] isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnRemoveUser]]) {
        
        if (callBackData[@"type"] != nil && ([callBackData[@"type"] integerValue] == 103 || [callBackData[@"type"] integerValue] == 104)) {
            NSArray *toUsers = [NSArray arrayWithArray:callBackData[@"toUsers"]];
            [toUsers enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
                if ([obj isEqualToString:_userId]) {
                    // 如果是该用户则显示 被删除界面
                    [_messageDataModelArray removeAllObjects];
                    self.isDelete = YES;
                    [self.tableView reloadData];
                } else {
                    // 如果不是该用户则 重新拉取信息
                    _isLocalHistoryMessageOver = NO;
                    [_messageDataModelArray removeAllObjects];
                    [self.tableView reloadData];
                    [self loadNewData];
                }
            }];
        }
    }else if (userInfo[@"route"] && [userInfo[@"route"] isEqualToString:[RYChatAPIManager notifyWithType:NotifyTypeOnChat]]) {
        if (_messageDataModelArray.count > 0) {
            MessageModel *lastModel = _messageDataModelArray[_messageDataModelArray.count - 1];
            if ([lastModel.messageId isEqualToString:callBackData[@"_id"]]) {
                return;
            }
        }

        // 判断是否是不同设备 同一账号发送的消息
        if ((callBackData[@"from"] != nil) && (![callBackData[@"from"] isEqualToString:_userId])) {
            // 不是同一账号
            [self messageDataModelArrayAddModel:[MessageModel parseNotifyData:callBackData modelType:MessageModelTypeOther]];
            [self.tableView reloadData];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tableViewScrollToTop) object:nil];
            [self performSelector:@selector(tableViewScrollToTop) withObject:nil afterDelay:0.3];
            [_isSelfSendmessageDict removeObjectForKey:callBackData[@"_id"]];
        } else {
            MessageModel *model = _sendMessageDict[callBackData[@"clientMsgId"]];
            if (model == nil) {
                MessageModel *model = [MessageModel parseNotifyData:callBackData modelType:MessageModelTypeMe];
                if ([self removeRepeatModel:model]) {
                    return;
                }
                // 是同一账号 别的设备发出的
                [self messageDataModelArrayAddModel:model];
                [self.tableView reloadData];
            } else {
                //是同一账号 本设备发出的
                model.messageTime  = callBackData[@"time"];
                model.messageId =  callBackData[@"_id"];
                NSArray *time       = [MessageModel parseTime:callBackData[@"time"]];
                model.yearAndMoth   = [time firstObject];
                model.time          = [time lastObject];

                [self performSelector:@selector(delayMessageRefreshAction:) withObject:@{@"status":@(YES),@"model":model} afterDelay:0.5f];
                [_sendMessageDict removeObjectForKey:callBackData[@"clientMsgId"]];
                if ([model.clientMsgId isEqualToString:_reSendMessageModel.clientMsgId]) {
                    [self.tableView reloadData];
                    _reSendMessageModel = nil;
                }
            }
            [self tableViewScrollToTop];
        }
    }
}
/**
 *   @author xiaerfei, 15-11-18 16:11:48
 *
 *   断开链接通知
 *
 *   @param notification
 */
- (void)disConnectNotificationStr:(NSNotification *)notification
{
    self.isConnect = [notification.object boolValue];
    [self disconnectViewHide:self.isConnect];
}
/**
 *   @author xiaerfei, 15-10-20 18:10:08
 *
 *   未读消息 响应事件处理
 */
- (void)moreMessageAction
{
    self.moreMessageView.hidden = YES;
    NSInteger unReadMessageNumber = self.moreMessageView.unReadMessageNumber;
    if (unReadMessageNumber > 60) {
        _fetchDataNumber = 60;
    } else if (unReadMessageNumber < kFetchMessageNumber){
        _fetchDataNumber = kFetchMessageNumber;
    }
    [self.tableView.header beginRefreshing];
}
/**
 *   @author xiaerfei, 15-10-26 14:10:39
 *
 *   点击取消键盘响应  处理
 *
 *   @param sender
 */
- (IBAction)touchEndEidt:(id)sender {

    [self.chatInputBar textViewResignFirstResponder];
}

- (void)tapKeyEvent
{
    [self.chatInputBar textViewResignFirstResponder];
}
/**
 *   @author xiaerfei, 15-10-20 12:10:00
 *
 *   跳转到群聊
 */
- (void)chatInfoAction
{
    NSDictionary *info = [MessageModel messageCenterStatusWithGroupId:_groupId];
    GroupChatViewController *groupChat = [[GroupChatViewController alloc] init];
    groupChat.userId  = _userId;
    groupChat.groupId = _groupId;
    groupChat.isTop   = [info[@"isTop"] boolValue];
    groupChat.groupName = info[@"groupName"];
    groupChat.isDisturb = [[MessageTool getDisturbed] boolValue];
    
    [self.navigationController pushViewController:groupChat animated:YES];
}

/**
 *   @author xiaerfei, 15-11-02 17:11:22
 *
 *   下拉刷新
 */
- (void)loadNewData
{
    if (_isLocalHistoryMessageOver) {
        MessageModel *model = [self selectModelOfMessageSendArray:NO];
        [self getHistoryMessageWithCount:kFetchMessageNumber messageId:model.messageId==nil?@"":model.messageId];
        return;
    }
    NSMutableArray *historyArray = [MessageModel fectchHistoryMessageWithGroupId:_groupId userId:_userId number:_fetchDataNumber userMessageTime:_fetchUserMessageTime];
    BOOL isFirstLoad = NO;
    if (_fetchUserMessageTime == nil) {
        isFirstLoad = YES;
    }
    _fetchUserMessageTime = [historyArray.firstObject messageTime];
    if (historyArray.count == 0) {
        _fetchUserMessageId = [[self selectModelOfMessageSendArray:NO] messageId];
    } else {
        _fetchUserMessageId   = [historyArray.firstObject messageId];
    }
    
    if (historyArray.count < _fetchDataNumber) {
        [self getHistoryMessageWithCount:(_fetchDataNumber - historyArray.count) messageId:_fetchUserMessageId==nil?@"":_fetchUserMessageId];
        _isLocalHistoryMessageOver = YES;
        _isFirstLoadMessage = (_isFirstLoadMessage == 3?3:2);
    } else {
        _isFirstLoadMessage = (_isFirstLoadMessage == 3?3:1);
    }
    _fetchDataNumber = kFetchMessageNumber;
    [self.tableView.header endRefreshing];
    [self messageDataModelArrayAddModels:historyArray completeFinishBlock:^{
        if (isFirstLoad) {
            if (_messageDataModelArray.count >= 1) {
                if (_isFirstLoadMessage == 1) {
                    _isFirstLoadMessage = 3;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_messageDataModelArray.count -1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
                [self readMessage];
            }
        } else {
            self.moreMessageView.hidden = YES;
        }
    }];
}
/**
 *   @author xiaerfei, 15-11-06 15:11:19
 *
 *   返回上一页
 */
- (void)gotoBack
{
    POP;
}
#pragma mark - private methods
/**
 *   @author xiaerfei, 15-11-19 09:11:56
 *
 *   消息失败后重新发送
 *
 *   @param model
 */
- (void)reloadDataWithModel:(MessageModel *)model
{
    MessageModel *messageModel = [MessageModel sendMessageWithContent:model.text];
    messageModel.clientMsgId = model.clientMsgId;
    messageModel.fromId  = _userId;
    messageModel.groupId = _groupId;
    [_messageDataModelArray removeObject:model];
    [self sendMessage:messageModel];
}
/**
 *   @author xiaerfei, 15-11-13 11:11:55
 *
 *   设置消息已读
 */
- (void)readMessage
{
    if (_messageDataModelArray.count > 0 && self.isConnect == YES) {
        MessageModel *model = [self selectModelOfMessageSendArray:YES];
        if (!isEmptyString(model.messageId) && !isEmptyString(model.messageTime)) {
            self.readChatHandler.parameters = @{@"groupId":_groupId,
                                                @"lastedReadMsgId":model.messageId,
                                                @"time":model.messageTime};
            [self.readChatHandler chat];
        }
    }
}
/**
 *   @author xiaerfei, 15-11-13 11:11:43
 *
 *   发送消息 发送和重新发送
 *
 *   @param messageModel
 */
- (void)sendMessage:(MessageModel *)messageModel
{
    if (isEmptyString(messageModel.clientMsgId)) {
        messageModel.clientMsgId = [MessageModel createClientMsgId];
        messageModel.type        = @"1";
        [MessageModel sendMessageAddToDBWithModel:messageModel];
    }
    [self messageDataModelArrayAddModel:messageModel];
    [self.tableView reloadData];
    [_sendMessageDict setValue:messageModel forKey:messageModel.clientMsgId];
    
    if (self.isConnect == NO) {
        [self messageSendFailedOfNetDisconnect];
        return;
    }
    
    self.sendChatHandler.parameters = @{@"toGroupId":_groupId,
                                        @"content":[messageModel.text escape],
                                        @"type":@(1),
                                        @"clientMsgId":messageModel.clientMsgId};
    [self.sendChatHandler chat];
    
    
}
/**
 *   @author xiaerfei, 15-11-18 11:11:58
 *
 *   从服务器获取历史消息
 *
 *   @param count
 */
- (void)getHistoryMessageWithCount:(NSInteger)count messageId:(NSString *)messageId
{
    if (count == 0) {
        return;
    }
    
    if (self.isConnect == NO) {
        return;
    }
    
    if (self.tableView.header.isRefreshing) {
        return;
    }
    
    NSDictionary *requestInfo =
                      @{@"groupId":_groupId,
                        @"lastMsgId":messageId,
                        @"count":@(count)};
    self.getMsgChatHandler.parameters = requestInfo;
    [self.getMsgChatHandler chat];
}
/**
 *   @author xiaerfei, 15-11-18 17:11:26
 *
 *   发送消息 后 刷新菊花 状态
 *
 *   @param obj
 */
- (void)delayMessageRefreshAction:(id)obj
{
    NSDictionary *info = obj;
    BOOL status = [info[@"status"] boolValue];
    MessageModel *model = info[@"model"];
    [self refreshSendMessageStatus:status model:model];
    [self.tableView reloadData];
}
#pragma mark - getters
- (ChatInputBar *)chatInputBar
{
    if (_chatInputBar == nil) {
        _chatInputBar = [[ChatInputBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
        _chatInputBar.backgroundColor = [UIColor whiteColor];
        _chatInputBar.delegate = self;
    }
    return _chatInputBar;
}

- (MoreMessageView *)moreMessageView
{
    if (_moreMessageView == nil) {
        _moreMessageView = [[MoreMessageView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        [_moreMessageView addTarget:self action:@selector(moreMessageAction)];
    }
    return _moreMessageView;
}

- (ApplicationStatusView *)applicationStatusView
{
    if (_applicationStatusView == nil) {
       _applicationStatusView = [[ApplicationStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
    }
    return _applicationStatusView;
}

- (ApplyForProgressDetail *)applyForProgressDetail {
    if (!_applyForProgressDetail) {
        _applyForProgressDetail = [[ApplyForProgressDetail alloc] init];
    }
    return _applyForProgressDetail;
}

- (UILabel *)disconnectTipLabel
{
    if (_disconnectTipLabel == nil) {
        _disconnectTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
        _disconnectTipLabel.text = @"暂时无法连接服务，不能获取最新消息";
        _disconnectTipLabel.textColor = [UIColor whiteColor];
        _disconnectTipLabel.backgroundColor = COLOR(0, 0, 0, 0.5);
        _disconnectTipLabel.textAlignment = NSTextAlignmentCenter;
        _disconnectTipLabel.font = [UIFont systemFontOfSize:16];
        _disconnectTipLabel.hidden = YES;
    }
    return _disconnectTipLabel;
}

- (RYChatHandler *)sendChatHandler {
    if (!_sendChatHandler) {
        _sendChatHandler = [[RYChatHandler alloc] initWithDelegate:self];
        _sendChatHandler.chatServerType = RouteChatTypeSend;
    }
    return _sendChatHandler;
}

- (RYChatHandler *)readChatHandler {
    if (!_readChatHandler) {
        _readChatHandler = [[RYChatHandler alloc] initWithDelegate:self];
        _readChatHandler.chatServerType = RouteChatTypeRead;
    }
    return _readChatHandler;
}

- (RYChatHandler *)getMsgChatHandler
{
    if (_getMsgChatHandler == nil) {
        _getMsgChatHandler = [[RYChatHandler alloc] initWithDelegate:self];
        _getMsgChatHandler.chatServerType = RouteChatTypeGetMsg;
    }
    return _getMsgChatHandler;
}

@end

