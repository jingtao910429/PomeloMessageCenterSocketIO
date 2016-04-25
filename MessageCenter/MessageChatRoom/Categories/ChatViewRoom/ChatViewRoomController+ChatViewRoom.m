//
//  ChatViewRoomController+ChatViewRoom.m
//  RongYu100
//
//  Created by xiaerfei on 15/12/9.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "ChatViewRoomController+ChatViewRoom.h"
#import "MJRefresh.h"
#import "PomeloMessageCenterDBManager.h"
#import "MessageChatBarSetTool.h"

@implementation ChatViewRoomController (ChatViewRoom)

- (void)configNavigationBar
{
    ////////////去掉导航栏最下面那条线///////////////
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)configNavigationBarItemWithActions:(NSArray *)actions
{
    UIImage *backImg = [UIImage imageNamed:@"ryback_topBar_Icon"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, backImg.size.width, backImg.size.height);
    [btn setBackgroundImage:backImg forState:UIControlStateNormal];
    [btn addTarget:self action:NSSelectorFromString(actions[0]) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    UIImage *image = [[UIImage imageNamed:@"groupinfo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:NSSelectorFromString(actions[1])];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)configNavigationBarWithTitles:(NSArray *)titles
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    groupName.text = titles.firstObject;
    groupName.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:groupName];
    
    UILabel *groupInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 200, 20)];
    groupInfo.text = titles.lastObject;
    groupInfo.textColor = [UIColor colorWithRed:111.0f/255.0f green:111.0f/255.0f blue:111.0f/255.0f alpha:1];
    groupInfo.font = [UIFont systemFontOfSize:12];
    groupInfo.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:groupInfo];
    self.navigationItem.titleView = titleView;
    
    
}

- (void)configTableViewWithTapAction:(NSString *)action
{
    UITableView *tableView = [self valueForKey:@"tableView"];
    tableView.top = 33;
    tableView.allowsSelection = NO;
    tableView.width = SCREEN_BOUND_WIDTH;
    tableView.height = SCREEN_BOUND_HEIGHT - 40 - 64 - 33;
    tableView.backgroundColor = [UIColor colorWithRed:237.0/255 green:238.0/255 blue:244.0/255 alpha:1.0];
    tableView.contentInset = UIEdgeInsetsMake(15, 0, 15, 0);
}

- (void)addHeaderRefreshWithAction:(NSString *)action
{
    UITableView *tableView = [self valueForKey:@"tableView"];
    MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:NSSelectorFromString(action)];
    refreshHeader.lastUpdatedTimeLabel.hidden = YES;
    refreshHeader.stateLabel.hidden = YES;
    tableView.header = refreshHeader;
}

- (void)addSubViewsWithInfo:(NSDictionary *)info
{
    UITableView *tableView = [self valueForKey:@"tableView"];
    __weak typeof(self)  weakSelf = self;
    self.applicationStatusView.ApplicationStatusViewBlock = ^ () {
        ApplyForProgressDetail *applyForProgressDetail = [[ApplyForProgressDetail alloc] init];
        applyForProgressDetail.approveStatus = [info[@"approveStatus"] integerValue];
        applyForProgressDetail.isHideSection = YES;
        [weakSelf.navigationController pushViewController:applyForProgressDetail animated:YES];
    };
    [self.view addSubview:self.applicationStatusView];
    ////////////链接中断提示///////////////
    self.disconnectTipLabel.top = self.applicationStatusView.bottom;
    [self.view addSubview:self.disconnectTipLabel];
    
    ////////////创建 未读信息/////////////////////
    self.moreMessageView.frame = CGRectMake(SCREEN_BOUND_WIDTH-130, self.applicationStatusView.bottom + 20, 150, 30);
    [self.moreMessageView unReadMessageNumber:info[@"unReadMsgCount"]];
    [self.view addSubview:self.moreMessageView];
    
    ////////////配置底部输入框View///////////////
    self.chatInputBar.top = tableView.bottom;
    [self.view addSubview:self.chatInputBar];
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIControl class]]){
        return NO;
    }
    if ([touch.view isKindOfClass:[UITableView class]] && self.touchEndEidt != gestureRecognizer) {
        return NO;
    }
    return YES;
}
#pragma mark - APICmdApiCallBackDelegate
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd responseData:(id)responseData
{
    if (baseAPICmd == self.getMembersAPICmd) {
        NSArray *infoArray = responseData;
        if ([infoArray isKindOfClass:[NSArray class]]) {
            if (infoArray.count == 0) {
                return;
            }
            NSMutableArray *userInfoArray = [[NSMutableArray alloc] init];
            for (NSDictionary *userInfo in infoArray) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                NSString *userId = userInfo[@"UserId"];
                if (isEmptyString(userId)) {
                    return;
                }
                tempDict[@"UserId"]     = userId;
                tempDict[@"UserRole"]   = userInfo[@"UserRole"] == nil?@"":userInfo[@"UserRole"];
                tempDict[@"PersonName"] = userInfo[@"MsgGroupMemberName"] == nil?@"":userInfo[@"MsgGroupMemberName"];
                tempDict[@"UserType"]   = userInfo[@"UserType"] == nil?@"":userInfo[@"UserType"];
                tempDict[@"PhoneNo"]    = userInfo[@"PhoneNo"]  == nil?@"":userInfo[@"PhoneNo"];
                tempDict[@"Avatar"]     = userInfo[@"Avatar"]   == nil?@"":userInfo[@"Avatar"];
                [userInfoArray addObject:tempDict];
            }
            [[PomeloMessageCenterDBManager shareInstance] addDataToTableWithType:MessageCenterDBManagerTypeUSER data:userInfoArray];
            [self refreshTableView];
        }
    }
}

- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd error:(NSError *)error
{
    
}


#pragma mark - private methods
- (MessageCell *)tableView:(UITableView *)tableView reuseIdentifier:(NSString *)cellIdentifier
{
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.tapBack = self.touchEndEidt;
    }
    return cell;
}

- (MessageModel *)selectModelOfMessageSendArray:(BOOL)isLastOne
{
    NSMutableArray *messageDataModelArray = [self valueForKey:@"messageDataModelArray"];
    
    MessageModel *messageModel = nil;
    NSArray *tempArray = nil;
    if (isLastOne) {
        tempArray = [[messageDataModelArray reverseObjectEnumerator] allObjects];
    } else {
        tempArray = messageDataModelArray;
    }
    for (MessageModel *model in tempArray) {
        if (model.messageType == MessageTypeChat || model.messageType == MessageTypeSystem) {
            messageModel = model;
            break;
        }
    }
    return messageModel;
}

- (BOOL)removeRepeatModel:(MessageModel *)model
{
    NSMutableArray *messageDataModelArray = [self valueForKey:@"messageDataModelArray"];
    if (messageDataModelArray.count < 10) {
        for (MessageModel *sourceModel in messageDataModelArray) {
            if ([sourceModel.messageId isEqualToString:model.messageId]) {
                return YES;
            }
        }
        return NO;
    } else {
        NSRange range = NSMakeRange(messageDataModelArray.count-10,10);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        NSArray *repeatArray = [messageDataModelArray objectsAtIndexes:indexSet];
        for (MessageModel *sourceModel in repeatArray) {
            if ([sourceModel.messageId isEqualToString:model.messageId]) {
                return YES;
            }
        }
        return NO;
    }
}

- (void)messageDataModelArrayAddModel:(MessageModel*)model
{
    if (model == nil) {
        return;
    }
    NSMutableArray *messageDataModelArray = [self valueForKey:@"messageDataModelArray"];
    [MessageModel getTimeIntervalCurrentModel:model lastModel:messageDataModelArray.lastObject destinationArray:messageDataModelArray atIndex:messageDataModelArray.count];
    [messageDataModelArray addObject:model];
    [self setValue:[[self selectModelOfMessageSendArray:NO] messageId] forKey:@"fetchUserMessageId"];
}

- (void)messageDataModelArrayAddModels:(NSMutableArray *)modelArray completeFinishBlock:(void (^)())block
{
    if (modelArray.count == 0) {
        block();
        return;
    }
    //1.在该数组里加入时间轴
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < modelArray.count; i++) {
        MessageModel *lastModel = modelArray[i];
        [tempArray addObject:lastModel];
        if ((i+1) > (modelArray.count-1)) {
            break;
        }
        MessageModel *currentModel = modelArray[i+1];
        [MessageModel getTimeIntervalCurrentModel:currentModel lastModel:lastModel destinationArray:tempArray atIndex:tempArray.count];
    }
    UITableView *tableView = [self valueForKey:@"tableView"];
    //2.在临界点加入时间轴
    MessageModel *lastModel = tempArray.lastObject;
    NSMutableArray *messageDataModelArray = [self valueForKey:@"messageDataModelArray"];
    MessageModel *currentModel = messageDataModelArray.firstObject;
    [MessageModel getTimeIntervalCurrentModel:currentModel lastModel:lastModel destinationArray:tempArray atIndex:tempArray.count];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[tempArray count])];
    
    [messageDataModelArray insertObjects:tempArray atIndexes:indexes];
    [self setValue:[[self selectModelOfMessageSendArray:NO] messageId] forKey:@"fetchUserMessageId"];
    [tableView reloadData];
    block();
}

- (void)messageSendFailedOfNetDisconnect
{
    NSMutableDictionary *sendMessageDict = [self valueForKey:@"sendMessageDict"];
    if (sendMessageDict.count != 0) {
        NSArray *allKeys = sendMessageDict.allKeys;
        for (NSString *key in allKeys) {
            MessageModel *model = sendMessageDict[key];
            model.animateStatus = NO;
            model.isSendFail    = YES;
        }
        [sendMessageDict removeAllObjects];
    }
    UITableView *tableView = [self valueForKey:@"tableView"];
    [tableView reloadData];
}

- (void)disconnectViewHide:(BOOL)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (hide) {
            self.disconnectTipLabel.hidden = YES;
        } else {
            self.disconnectTipLabel.hidden = NO;
            [self messageSendFailedOfNetDisconnect];
            UITableView *tableView = [self valueForKey:@"tableView"];
            if (tableView.header.isRefreshing) {
                [tableView.header endRefreshing];
            }
        }
    });           
}

- (void)tableViewScrollToTop
{
    NSMutableArray *messageDataModelArray = [self valueForKey:@"messageDataModelArray"];
    UITableView *tableView = [self valueForKey:@"tableView"];
    
    if (messageDataModelArray.count > 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:messageDataModelArray.count inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}

#pragma mark - event responses

- (void)keyboardWillChange:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y;
    
    BOOL isAnimate = YES;
    if (moveY != 0) {
        [MessageChatBarSetTool setChatBarFrameSet:NSStringFromCGRect(keyFrame)];
    }else {
        isAnimate = NO;
        keyFrame = CGRectFromString([MessageChatBarSetTool chatBarFrameSet]);
    }
    
    moveY = keyFrame.origin.y;
    
    NSMutableArray *messageDataModelArray = [self valueForKey:@"messageDataModelArray"];
    UITableView *tableView = [self valueForKey:@"tableView"];
    [UIView animateWithDuration:duration animations:^{
        self.chatInputBar.top = moveY - self.chatInputBar.height-64;
        tableView.height = self.chatInputBar.top - 30;
    } completion:^(BOOL finished) {
        if (messageDataModelArray.count != 0) {
            NSIndexPath *lastPath = [NSIndexPath indexPathForRow:messageDataModelArray.count inSection:0];
            [tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:isAnimate];
        }
    }];
}

#pragma mark - ovrride system methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.chatInputBar textViewResignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

@end
