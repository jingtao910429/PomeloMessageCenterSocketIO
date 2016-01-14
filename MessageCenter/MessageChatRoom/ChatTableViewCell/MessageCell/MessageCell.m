//
//  MessageCell.h
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/20.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "MessageCell.h"
#import "MessageModel.h"
#import "UIImage+ResizeImage.h"
#import "UIViewExt.h"
#import "NSString+Extension.h"
#import "UIImageView+WebCache.h"
#import "AttLinkData.h"
#import "AttLinkUtils.h"
#import "AttView.h"
#import "MessageUserInfo.h"
#import "NSString+Extension.h"
#import "UIView+Additions.h"

NSString * const kMessageCellChat   = @"MessageCellChat";
NSString * const kMessageCellThough = @"MessageCellThough";
NSString * const kMessageCellTime   = @"MessageCellTime";
NSString * const kMessageCellSystem = @"MessageCellSystem";
NSString * const kMessageCellDelete = @"MessageCellDelete";

@interface MessageCell()<AttViewDelegate>

@property (nonatomic,strong) UILabel *chatName;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UIButton *textView;
@property (nonatomic,strong) UIControl *iconAction;

@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic,strong) UITapGestureRecognizer       *tapGesture;
@property (nonatomic,strong) UIView *creditThough;

@property (nonatomic,strong) UILabel *systemLabel;
@property (nonatomic,strong) UIImageView *systemBg;

@property (nonatomic,strong) AttView *attView;

@property (nonatomic,strong) UIImageView *textBackground;

@property (nonatomic,strong) MessageModel *clickModel;

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic,strong) UIImageView *sendFailView;


@property (nonatomic,strong) UIView *lineLeft;
@property (nonatomic,strong) UIView *lineRight;

@property (nonatomic,strong) MessageUserInfo *messageUserInfo;


@property (nonatomic, strong) UIView  *errorView;
@property (nonatomic, strong) UILabel *titleErrorLable;
@property (nonatomic, strong) UIImageView *logImgView;

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor clearColor];
        [self configUIWithReuseIdentifier:reuseIdentifier];
    }
    return self;
}

- (void)configUIWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if ([reuseIdentifier isEqualToString:kMessageCellChat]) {
        [self.iconView addSubview:self.iconAction];
        [self.contentView addSubview:self.chatName];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.textBackground];
        [self.contentView addSubview:self.activityIndicator];
        [self.contentView addSubview:self.sendFailView];
        [self.textBackground addSubview:self.attView];
        [self.sendFailView addGestureRecognizer:self.tapGesture];
        [self.textBackground addGestureRecognizer:self.longPressGesture];
        
    } else if ([reuseIdentifier isEqualToString:kMessageCellTime]) {
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.lineLeft];
        [self.contentView addSubview:self.lineRight];
    } else if ([reuseIdentifier isEqualToString:kMessageCellSystem]) {
        [self.systemBg addSubview:self.systemLabel];
        [self.contentView addSubview:self.systemBg];
    } else if ([reuseIdentifier isEqualToString:kMessageCellDelete]) {
        [self.errorView addSubview:self.logImgView];
        self.titleErrorLable.top = self.logImgView.bottom+20;
        [self.errorView addSubview:self.titleErrorLable];
        [self.contentView addSubview:self.errorView];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)configData:(id)data reuseIdentifier:(NSString *)reuseIdentifier
{
    MessageModel *model = data;
    _clickModel = model;
    if ([reuseIdentifier isEqualToString:kMessageCellChat]) {
        self.iconView.frame = model.iconFrame;
        self.iconView.backgroundColor = RGB(224, 224, 224);
        self.chatName.frame = model.chatFrame;
        self.chatName.textAlignment = model.modelType==MessageModelTypeMe ? NSTextAlignmentRight : NSTextAlignmentLeft;
        self.chatName.text  = [NSString stringWithFormat:@"%@",model.time];
        self.iconView.image = nil;
        [self.messageUserInfo userInfoWithGroupId:_clickModel.groupId userId:_clickModel.fromId completionBlock:^(NSDictionary *userInfo) {
            if (_clickModel.modelType == MessageModelTypeMe) {
                self.chatName.text  = [NSString stringWithFormat:@"%@ %@",_clickModel.time,userInfo[@"PersonName"]];
            } else {
                self.chatName.text  = [NSString stringWithFormat:@"%@ %@",userInfo[@"PersonName"],_clickModel.time];
            }
            [self.iconView sd_setImageWithURL:[NSURL URLWithString:userInfo[@"Avatar"]]];
        }];
        
        
        CGFloat pad = (model.modelType == MessageModelTypeOther ? 3 : -5);
        self.textBackground.frame = model.bgFrame;
        self.attView.frame = CGRectMake((self.textBackground.width-model.textSize.width)/2.0f + pad,(self.textBackground.height - model.textSize.height)/2.0f, model.textSize.width, model.textSize.height);
        self.attView.attTextData = model.attTextData;
        [self.attView setNeedsDisplay];
        
        UIImage *strechImage = nil;
        self.sendFailView.hidden = YES;
        if (model.modelType == MessageModelTypeMe) {
            
            strechImage = [[UIImage imageNamed:@"send"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 8, 7, 15) resizingMode:UIImageResizingModeStretch];
            
            if (model.isSendFail == NO) {
                [self beginSendMessage];
                self.activityIndicator.frame = CGRectMake(self.textBackground.left-20, self.textBackground.bottom-20, 15, 15);
                self.sendFailView.hidden = YES;
            } else {
                [self.activityIndicator stopAnimating];
                self.sendFailView.hidden = NO;
                self.sendFailView.frame = CGRectMake(self.textBackground.left-20, self.textBackground.bottom-20, 15, 15);
            }
        } else {
            strechImage = [[UIImage imageNamed:@"recive"] resizableImageWithCapInsets:UIEdgeInsetsMake(28,15, 7, 8) resizingMode:UIImageResizingModeStretch];
        }
        self.textBackground.image = strechImage;
    } else if ([reuseIdentifier isEqualToString:kMessageCellTime]) {
        CGSize size = [model.yearAndMoth sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(MAXFLOAT, 26)];
        CGFloat x =([UIScreen mainScreen].bounds.size.width- size.width)/2.0f;
        self.timeLabel.frame = CGRectMake(x, 9, size.width, 26);
        
        CGFloat lineWith = x-39;
        
        self.lineLeft.width  = lineWith;
        self.lineRight.width = lineWith;
        self.lineLeft.right  = self.timeLabel.left-4;
        self.lineRight.left  = self.timeLabel.right + 4;
        
        self.timeLabel.text = model.yearAndMoth;
    } else if ([reuseIdentifier isEqualToString:kMessageCellSystem]) {
        self.systemBg.frame = model.bgFrame;
        
        self.systemLabel.frame = CGRectMake(5, 5, model.textSize.width, model.textSize.height);
        self.systemLabel.text  = model.text;
    }
}

- (void)beginSendMessage
{
    if (_clickModel.animateStatus) {
        [self.activityIndicator startAnimating];
        _clickModel.animateStatus = YES;
        _clickModel.isSendFail = NO;
    } else {
        [self.activityIndicator stopAnimating];
    }
    self.sendFailView.hidden = YES;
}

- (void)endSendMessageStatus:(BOOL)status
{
    [self.activityIndicator stopAnimating];
    _clickModel.animateStatus = NO;
    if (status) {
        self.sendFailView.hidden = YES;
    } else {
        self.sendFailView.frame = CGRectMake(self.textBackground.left-20, self.textBackground.bottom-20, 15, 15);
        self.sendFailView.hidden = NO;
        _clickModel.isSendFail = YES;
    }
}

#pragma mark - AttViewDelegate
- (void)attViewTouch:(AttView *)attView attLinkData:(AttLinkData *)attLinkData
{
    if (attLinkData == nil || _clickModel.isSendFail == YES) {

    } else {
        if (attLinkData.attLinkDataType == AttLinkDataTypePhoneNumber) {
            NSURL *url = [NSURL URLWithString:attLinkData.text];
            UIWebView *remView = (UIWebView *)[self viewWithTag:1125];
            [remView removeFromSuperview];
            
            NSMutableString * str = [[NSMutableString alloc] initWithFormat:@"tel:%@",[url absoluteString]];
            UIWebView * callWebview = [[UIWebView alloc] init];
            callWebview.tag = 1125;
            [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            [self addSubview:callWebview];
        }
    }
}

#pragma mark - events response
- (void)iconTouchAction:(UIControl *)iconAction
{
    if ([_delegate respondsToSelector:@selector(messageCell:iconTouchData:)]) {
        [_delegate messageCell:self iconTouchData:_clickModel];
    }
}

- (void)tapGestureAction
{
    if (_clickModel.isSendFail == YES) {
        if ([_delegate respondsToSelector:@selector(messageCell:touchData:)]) {
            [_delegate messageCell:self touchData:_clickModel];
        }
    }
}
#pragma mark - 复制处理
/**
 *   @author xiaerfei, 15-10-20 09:10:59
 *
 *   长按手势
 *
 *   @param recognizer
 */
- (void)menuItemLongPress:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuItem *itCopy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(handleCopyCell:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:itCopy,nil]];
        [menu setTargetRect:_clickModel.bgFrame inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}
/**
 *   @author xiaerfei, 15-10-20 09:10:21
 *
 *   复制cell中的内容
 *
 *   @param sender
 */
- (void)handleCopyCell:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _clickModel.text;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(handleCopyCell:)) {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - getters
- (UIControl *)iconAction
{
    if (_iconAction == nil) {
        _iconAction = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_iconAction addTarget:self action:@selector(iconTouchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iconAction;
}

- (UILongPressGestureRecognizer *)longPressGesture
{
    if (_longPressGesture == nil) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(menuItemLongPress:)];
    }
    return _longPressGesture;
}

- (UITapGestureRecognizer *)tapGesture
{
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
    }
    return _tapGesture;
}


- (UILabel *)chatName
{
    if (_chatName == nil) {
        _chatName = [[UILabel alloc] init];
        _chatName.textAlignment = NSTextAlignmentCenter;
        _chatName.textColor = [UIColor grayColor];
        _chatName.font = [UIFont systemFontOfSize:12];
    }
    return _chatName;
}
- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-140)/2.0f, 9, 140, 26)];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor colorWithRed:172.0f/255.0f green:173.0f/255.0f blue:178.0f/255.0f alpha:1];
        _timeLabel.font = [UIFont systemFontOfSize:13];
    }
    return _timeLabel;
}

- (UIView *)lineLeft
{
    if (_lineLeft == nil) {
        _lineLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 21.5f,0, 1)];
        _lineLeft.backgroundColor = [UIColor colorWithRed:172.0f/255.0f green:173.0f/255.0f blue:178.0f/255.0f alpha:1];
    }
    return _lineLeft;
}

- (UIView *)lineRight
{
    if (_lineRight == nil) {
        _lineRight = [[UIView alloc] initWithFrame:CGRectMake(0, 21.5f, 0, 1)];
        _lineRight.backgroundColor = [UIColor colorWithRed:172.0f/255.0f green:173.0f/255.0f blue:178.0f/255.0f alpha:1];
    }
    return _lineRight;
}

- (UIImageView *)iconView
{
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
        _iconView.userInteractionEnabled = YES;
    }
    return _iconView;
}

- (AttView *)attView
{
    if (_attView == nil) {
        _attView = [[AttView alloc] init];
        _attView.userInteractionEnabled = YES;
        _attView.delegate = self;
        _attView.backgroundColor = [UIColor clearColor];
    }
    return _attView;
}


- (UIImageView *)textBackground
{
    if (_textBackground == nil) {
        _textBackground = [[UIImageView alloc] init];
        _textBackground.userInteractionEnabled = YES;
    }
    return _textBackground;
}

- (UILabel *)systemLabel
{
    if (_systemLabel == nil) {
        _systemLabel = [[UILabel alloc] init];
        _systemLabel.textColor = [UIColor colorWithRed:253.0f/255.0f green:120.0f/255.0f blue:48.0f/255.0f alpha:1];
//        _systemBg.backgroundColor = [UIColor grayColor];
        _systemLabel.numberOfLines = 0;
        _systemLabel.font = [UIFont systemFontOfSize:14];
        _systemLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _systemLabel;
}

- (UIImageView *)systemBg
{
    if (_systemBg == nil) {
        _systemBg = [[UIImageView alloc] init];
        _systemBg.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:220.0f/255.0f blue:211.0f/255.0f alpha:1];
        _systemBg.layer.masksToBounds = YES;
        _systemBg.layer.cornerRadius  = 5;
    }
    return _systemBg;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (_activityIndicator == nil) {
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

- (UIImageView *)sendFailView
{
    if (_sendFailView == nil) {
        _sendFailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _sendFailView.image = [UIImage imageNamed:@"sendmsgfail"];
        _sendFailView.hidden = YES;
        _sendFailView.userInteractionEnabled = YES;
    }
    return _sendFailView;
}

- (MessageUserInfo *)messageUserInfo
{
    if (_messageUserInfo == nil) {
        _messageUserInfo = [[MessageUserInfo alloc] init];
    }
    return _messageUserInfo;
}

- (UILabel *)titleErrorLable
{
    if (_titleErrorLable == nil) {
        _titleErrorLable = [[UILabel alloc] initWithFrame:CGRectMake(0,0, SCREEN_BOUND_WIDTH, 30)];
        _titleErrorLable.textColor = [UIColor colorWithRed:193/255.0f green:192/255.0f blue:196/255.0f alpha:1.0f];
        _titleErrorLable.font = [UIFont systemFontOfSize:15];
        _titleErrorLable.textAlignment = NSTextAlignmentCenter;
        _titleErrorLable.text = @"抱歉！你已经被移出本组群聊";
    }
    return _titleErrorLable;
}

- (UIImageView *)logImgView
{
    if (_logImgView == nil) {
        UIImage *image = [UIImage imageNamed:@"rerror"];
        _logImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, image.size.width, image.size.height)];
        _logImgView.center = CGPointMake(SCREEN_BOUND_WIDTH/2.0f, (SCREEN_BOUND_HEIGHT-64)/2.0f-64);
        _logImgView.image = image;
    }
    return _logImgView;
}

- (UIView *)errorView
{
    if (_errorView == nil) {
        _errorView = [[UIView alloc] initWithFrame:CGRectMake(0,0, SCREEN_BOUND_WIDTH, SCREEN_BOUND_HEIGHT-40-64-40)];
        _errorView.tag = 2345;
        _errorView.backgroundColor = [UIColor clearColor];
    }
    return _errorView;
}

@end
