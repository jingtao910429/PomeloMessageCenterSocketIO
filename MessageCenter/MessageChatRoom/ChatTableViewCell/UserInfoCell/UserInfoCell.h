//
//  UserInfoCell.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UILabel *groupName;

@property (weak, nonatomic) IBOutlet UILabel *phoneInfo;


- (void)configData:(NSDictionary *)data;

@end
