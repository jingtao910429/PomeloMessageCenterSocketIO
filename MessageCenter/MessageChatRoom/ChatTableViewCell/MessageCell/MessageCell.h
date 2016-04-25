//
//  MessageCell.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/20.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//
#import <UIKit/UIKit.h>



extern NSString * const kMessageCellChat;
extern NSString * const kMessageCellThough;
extern NSString * const kMessageCellTime;
extern NSString * const kMessageCellTopTime;
extern NSString * const kMessageCellSystem;
extern NSString * const kMessageCellDelete;

@class MessageModel;
@class MessageCell;
@protocol MessageCellDelegate <NSObject>
@optional
/**
 *   @author xiaerfei, 15-11-02 09:11:20
 *
 *   点击用户头像
 *
 *   @param cell
 *   @param model  对应的Model
 */
- (void)messageCell:(MessageCell *)cell iconTouchData:(MessageModel *)model;
/**
 *   @author xiaerfei, 15-11-02 09:11:53
 *
 *   点击消息
 *
 *   @param cell
 *   @param model 对应的Model
 */
- (void)messageCell:(MessageCell *)cell touchData:(MessageModel *)model;
@end


@interface MessageCell : UITableViewCell


@property (nonatomic, weak) id<MessageCellDelegate> delegate;
@property (nonatomic, weak) UITapGestureRecognizer *tapBack;
/**
 *   @author xiaerfei, 15-11-02 09:11:13
 *
 *   根据 reuseIdentifier 刷新对应的cell
 *
 *   @param data            要刷新的数据
 *   @param reuseIdentifier cell标示
 */
- (void)configData:(id)data reuseIdentifier:(NSString *)reuseIdentifier;


@end
