//
//  GroupChatCell.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/20.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kGroupChatCellGroupName;
extern NSString *const kGroupChatCellChatTop;
extern NSString *const kGroupChatCellInfoNotDisturb;


@protocol GroupChatCellDelegate <NSObject>

- (void)switchValueChange:(BOOL)valueChange reuseIdentifier:(NSString *)reuseIdentifier;

@end

@interface GroupChatCell : UITableViewCell

@property (nonatomic, weak) id<GroupChatCellDelegate> delegate;


- (void)updateData:(id)data reuseIdentifier:(NSString *)reuseIdentifier;


@end
