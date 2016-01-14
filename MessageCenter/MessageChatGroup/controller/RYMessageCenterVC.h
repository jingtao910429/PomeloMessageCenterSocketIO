//
//  RYMessageCenterVC.h
//  RYMessageCenter
//
//  Created by gqq on 15/10/19.
//  Copyright (c) 2015年 __RongYu100__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCMoreOptionTableViewCell.h"


@interface RYMessageCenterVC : RYBaseViewController<UITableViewDataSource,UITableViewDelegate,MSCMoreOptionTableViewCellDelegate>

@property (nonatomic, strong) UITableView *allTableViewInfo;
@property (nonatomic,strong)  UITableView *readTableViewInfo;
@property (nonatomic,strong)  UITableView *unReadTableViewInfo;

@property (nonatomic,assign)  NSInteger groupType;
@property (nonatomic,strong)  UILabel *disConnectLabel;

//显示连接后的状态
-(void)showConnectUI;
- (void)refreshTableView;
-(void)getGroupWithTypeNeedAllData:(id)isNeedAllData;

@end
