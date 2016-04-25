//
//  MoreMessageView.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/11/3.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "MoreMessageView.h"
#import "MessageModel.h"

@interface MoreMessageView ()
{
    SEL _action;
}
@property (nonatomic,weak) id target;
@property (nonatomic, strong) UIImageView *moreInfoImageView;
@property (nonatomic, strong) UILabel *moreInfoLabel;
@property (nonatomic, strong) UIControl *control;

@property (nonatomic, assign, readwrite) NSInteger unReadMessageNumber;

@end

@implementation MoreMessageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 15;
    
    _moreInfoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,10, 10, 10)];
    _moreInfoImageView.image = [UIImage imageNamed:@"moreInfo"];
    _moreInfoImageView.userInteractionEnabled = YES;
    [self addSubview:_moreInfoImageView];
    
    _moreInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 5, 115, 20)];
    _moreInfoLabel.userInteractionEnabled = YES;
    _moreInfoLabel.textColor = [UIColor colorWithRed:66.0f/255.0f green:157.0f/255.0f blue:19.0f/255.0f alpha:1];
    _moreInfoLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:_moreInfoLabel];
    
    _control = [[UIControl alloc] initWithFrame:self.bounds];
    [_control addTarget:self action:@selector(moreMessageControlAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_control];
}

- (void)moreMessageControlAction
{
    if ([_target respondsToSelector:_action]) {
        [_target performSelector:_action withObject:nil afterDelay:0];
    }
}


- (void)addTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}


- (void)unReadMessageNumber:(NSString *)number
{
    NSInteger unReadNumber = [number integerValue] - kFetchMessageNumber;
    if (unReadNumber < 0) {
        self.hidden = YES;
        return;
    }
    self.unReadMessageNumber = unReadNumber;
    if (unReadNumber < 5) {
        self.hidden = YES;
    }
    NSString *messageStr = nil;
    if (unReadNumber >= 100) {
        messageStr = @"您有更多未读消息";
    } else {
        messageStr = [NSString stringWithFormat:@"您有%@条未读消息",@(unReadNumber)];
    }
    self.moreInfoLabel.text = messageStr;
}

@end
