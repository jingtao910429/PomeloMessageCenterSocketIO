//
//  ChatViewRoomController+ChatViewRoom.h
//  RongYu100
//
//  Created by xiaerfei on 15/12/9.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "ChatViewRoomController.h"

@interface ChatViewRoomController (ChatViewRoom)
/**
 *   @author xiaerfei, 15-12-09 16:12:06
 *
 *   去掉导航栏最下面那条线
 */
- (void)configNavigationBar;
/**
 *   @author xiaerfei, 15-12-09 16:12:06
 *
 *   配置导航栏的左右items
 *
 *   @param actions [0]:左边  [1]:右边
 */
- (void)configNavigationBarItemWithActions:(NSArray *)actions;
/**
 *   @author xiaerfei, 15-12-09 16:12:30
 *
 *   配置导航栏的titles
 *
 *   @param titles [0]:群组名称  [1]:公司名称
 */
- (void)configNavigationBarWithTitles:(NSArray *)titles;
/**
 *   @author xiaerfei, 15-12-09 17:12:10
 *
 *   配置tableviewframe  添加手势
 *
 *   @param action
 */
- (void)configTableViewWithTapAction:(NSString *)action;
/**
 *   @author xiaerfei, 15-12-09 16:12:48
 *
 *   添加 下拉刷新
 *
 *   @param action
 */
- (void)addHeaderRefreshWithAction:(NSString *)action;
/**
 *   @author xiaerfei, 15-12-09 17:12:45
 *
 *   add subviews applicationStatusView、disconnectTipLabel、moreMessageView、chatInputBar
 *
 *   @param info
 */
- (void)addSubViewsWithInfo:(NSDictionary *)info;

/**
 *   @author xiaerfei, 15-12-09 17:12:53
 *
 *   dequeueReusableCell
 *
 *   @param tableView
 *   @param cellIdentifier
 *
 *   @return MessageCell
 */
- (MessageCell *)tableView:(UITableView *)tableView reuseIdentifier:(NSString *)cellIdentifier;
/**
 *   @author xiaerfei, 15-11-19 13:11:59
 *
 *   获取 _messageDataModelArray 中的第一个 或最后一个
 *
 *   @param isLastOne
 *
 *   @return
 */
- (MessageModel *)selectModelOfMessageSendArray:(BOOL)isLastOne;
/**
 *   @author xiaerfei, 15-12-04 14:12:17
 *
 *   检测同一账号不同设备发出的 消息列表中是否重复包含
 *
 *   @param model model
 *
 *   @return BOOL
 */
- (BOOL)removeRepeatModel:(MessageModel *)model;
/**
 *   @author xiaerfei, 15-11-04 09:11:30
 *
 *   add 单个的Model 加入时间轴
 *
 *   @param model
 */
- (void)messageDataModelArrayAddModel:(MessageModel*)model;
/**
 *   @author xiaerfei, 15-11-04 09:11:54
 *
 *   加入多个Model
 *
 *   @param modelArray
 */
- (void)messageDataModelArrayAddModels:(NSArray *)modelArray completeFinishBlock:(void (^)())block;
/**
 *   @author xiaerfei, 15-10-30 16:10:24
 *
 *   刷新发送消息的状态 去掉菊花 或者 显示发送失败
 *
 *   @param status YES:成功   NO:失败
 *   @param model
 */
- (void)refreshSendMessageStatus:(BOOL)status model:(MessageModel *)model;
/**
 *   @author xiaerfei, 15-11-19 09:11:20
 *
 *   发送消息的过程中 网络断开 设置所有发送中的消息为失败
 */
- (void)messageSendFailedOfNetDisconnect;
/**
 *   @author xiaerfei, 15-12-14 18:12:13
 *
 *   是否显示 断开连接
 *
 *   @param hide
 */
- (void)disconnectViewHide:(BOOL)hide;
/**
 *   @author xiaerfei, 15-12-15 10:12:11
 *
 *   tableview scroll to top 
 */
- (void)tableViewScrollToTop;

/**
 *   @author xiaerfei, 15-10-26 14:10:44
 *
 *   键盘发生改变 通知
 *
 *   @param note
 */
- (void)keyboardWillChange:(NSNotification *)note;
@end
