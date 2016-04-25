//
//  ChatViewController.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/7/28.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageCenterMetadataModel.h"
#import "MoreMessageView.h"
#import "ApplicationStatusView.h"
#import "ChatInputBar.h"
#import "ApplyForProgressDetail.h"
#import "MessageCell.h"
#import "MessageModel.h"
#import "GetMembersAPICmd.h"
#import "CustomerApplysModel.h"

@interface ChatViewRoomController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) MessageCenterMetadataModel *metaModel;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) BOOL isTop;

@property (nonatomic, strong) GetMembersAPICmd *getMembersAPICmd;

@property (nonatomic, strong) ChatInputBar *chatInputBar;
/// 更多消息
@property (nonatomic, strong) MoreMessageView *moreMessageView;
/// 申请状态View
@property (nonatomic, strong) ApplicationStatusView *applicationStatusView;

@property (nonatomic, strong) ApplyForProgressDetail *applyForProgressDetail;

/// 消息列表数组
@property (nonatomic, copy) NSMutableArray *messageDataModelArray;

/// 无法连接服务时，弹出的提示框
@property (nonatomic, strong) UILabel *disconnectTipLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *touchEndEidt;

- (void)refreshTableView;
@end
