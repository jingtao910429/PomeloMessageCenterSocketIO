//
//  UserInfoCell.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "UserInfoCell.h"
#import "UIImageView+WebCache.h"

@implementation UserInfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configData:(NSDictionary *)data
{
    self.groupName.text = data[@"MsgGroupMemberName"];
    self.phoneInfo.text = data[@"PhoneNo"];
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:data[@"Avatar"]]];
}

@end

/*
 {
 Avatar = "<null>";
 CreateTime = "2015-11-10T09:42:21.36";
 CustomerServiceNo = "<null>";
 Gender = "\U5973";
 GroupMemberInfoId = "eb32d06e-afe2-4a92-a19f-7d28bdf63188";
 IsCreator = 0;
 MsgGroupId = "4d3f8221-1cd7-44bc-80a6-c8bed5afe904";
 MsgGroupMemberName = "\U878d\U8a89\U6e20\U9053\U6bd5\U61ff\U6f84";
 PhoneNo = 15021503868;
 UserId = "beb790c0-6f91-41e7-a1e6-13ee8db02bf1";
 UserRole = 101;
 UserType = 1;
 };
 */


