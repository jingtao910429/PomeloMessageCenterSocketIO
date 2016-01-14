//
//  ChatInputBar.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/19.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatInputBar;


@protocol ChatInputBarDelegate <NSObject>

- (void)chatInputBar:(ChatInputBar *)chatInputBar changeHeigh:(CGFloat)changeHeigh;
- (void)chatInputBar:(ChatInputBar *)chatInputBar sendMessage:(NSString *)message;

@end


@interface ChatInputBar : UIView <UITextViewDelegate>


/**
 *  当前文本内容
 */
@property (nonatomic,strong)NSString *content;
/**
 *  最大自动伸展高度
 */
@property (nonatomic,assign)CGFloat maxAutoExpandHeight;

/**
 *  最小高度
 */
@property (nonatomic,assign)CGFloat minAutoExpandHeight;
/**
 *  textView
 */
@property (nonatomic, strong) UITextView *inputTextView;
/**
 *  placeholder
 */
@property (nonatomic, strong) UILabel *inputPlaceholder;
/**
 *  发送按钮
 */
@property (nonatomic, strong) UIButton *sendButton;
/**
 *  textView 的高度
 */
@property (nonatomic, readonly)CGFloat inputTextStateHeight;
/**
 *  是否可以发送信息
 */
@property (nonatomic, assign) BOOL isCanSendMessage;


@property (nonatomic, weak) id<ChatInputBarDelegate> delegate;

- (void)textViewBecomeFirstResponder;

- (void)textViewResignFirstResponder;

@end
