//
//  ChatInputBar.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/19.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "ChatInputBar.h"
#import "UIViewExt.h"
#import "StringUitil.h"

#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define kTextInsetX 5
#define kTextInsetBottom 0

#define kTextChangeHeight 9

@interface ChatInputBar ()

@property (nonatomic, strong) NSTextContainer *textContainer;
/**
 *  背景图片
 */
@property (nonatomic,strong) UIImageView *inputBackgroundImageView;

@property (nonatomic, assign) CGFloat orginHeight;

@end

@implementation ChatInputBar
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self initSubViewsWithFrame:frame];
    }
    return self;
}

- (void)initSubViewsWithFrame:(CGRect)frame
{
    self.isCanSendMessage = YES;
    _inputTextStateHeight = self.height;
    self.inputBackgroundImageView.frame = self.inputTextView.frame;
    [self setInputTextBackgroundImage:[UIImage imageNamed:@"inputframe"]];
    [self addSubview:self.inputBackgroundImageView];
    
    [self addSubview:self.inputTextView];
    
    self.inputPlaceholder.frame = self.inputTextView.frame;
    [self addSubview:self.inputPlaceholder];
    
    self.sendButton.frame = CGRectMake(self.inputBackgroundImageView.right, 5, self.width-self.inputBackgroundImageView.right, self.height-10);
    [self addSubview:self.sendButton];
    
    self.maxAutoExpandHeight = 100.f;
    self.minAutoExpandHeight = 40.f;
    
    self.orginHeight = self.height;
}

- (void)textViewBecomeFirstResponder
{
    [self.inputTextView becomeFirstResponder];
}

- (void)textViewResignFirstResponder
{
    [self.inputTextView resignFirstResponder];
}

- (void)layoutInputTextView
{
    [self.inputTextView scrollRectToVisible:CGRectMake(0, self.inputTextView.contentSize.height - self.inputTextView.frame.size.height, self.inputTextView.frame.size.width,self.inputTextView.frame.size.height) animated:NO];
}
#pragma mark - system delegate
#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (self.isCanSendMessage == NO) {
        return;
    }
    /* 保留1000字 */
    if (self.inputTextView.text.length > 1000 ) {
        
        self.inputTextView.text = [self.inputTextView.text substringToIndex:999];
        
    }
    // frame 改变
    [self performSelector:@selector(updateDisplayByInputContentTextChange) withObject:nil afterDelay:0.1];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.isCanSendMessage == NO) {
        return NO;
    }
    
    if(![textView hasText] && [text isEqualToString:@""])
    {
        return NO;
    }
    /* 输入内容不能超过500字 */
    if (textView.text.length >= 1000 && ![text isEqualToString:@""]) {
        
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
    
        BOOL isAllWhiteSpace = [StringUitil stringIsAllWhiteSpace:textView.text];
        if (isAllWhiteSpace) {
            return NO;
        }
        for (int i = 0; i < textView.text.length; i++) {
            if ([textView.text characterAtIndex:i] == 0xfffc) {
                return NO;
            }
        }
        [self sendButtonAction];
        
    }
    return YES;
}

#pragma mark - event responses
/**
 *   @author xiaerfei, 15-10-19 14:10:27
 *
 *   发送信息
 */
- (void)sendButtonAction
{
    if (self.isCanSendMessage == NO) {
        return;
    }
    BOOL isAllWhiteSpace = [StringUitil stringIsAllWhiteSpace:self.inputTextView.text];
    if (isAllWhiteSpace) {
        return;
    }
    [self expandTextViewToHeight:self.orginHeight-10];
    self.top = SCREENHEIGHT - self.height - 64;
    if ([_delegate respondsToSelector:@selector(chatInputBar:sendMessage:)]) {
        [_delegate chatInputBar:self sendMessage:self.inputTextView.text];
    }
    self.inputTextView.text = @"";
    self.inputPlaceholder.hidden = NO;
    
    /*设置键盘*/
    //[self textViewResignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillChangeFrameNotification object:nil];
}


#pragma mark - private methods
-(void)setIsCanSendMessage:(BOOL)isCanSendMessage
{
    if (isCanSendMessage == NO) {
        self.inputTextView.editable = NO;
    }
    _isCanSendMessage = isCanSendMessage;
}

- (void)updateDisplayByInputContentTextChange
{
    if (self.inputTextView.text.length > 0) {
        self.inputPlaceholder.hidden = YES;
    }else{
        self.inputPlaceholder.hidden = NO;
    }
    CGSize contentSize = CGSizeZero;
    
    NSInteger newSizeH; //UITextView的实际高度
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {//7.0以上我们需要自己计算高度
        float fPadding = 16.0; // 8.0px x 2
        
        CGSize constraint = CGSizeMake(self.inputTextView.contentSize.width - fPadding, CGFLOAT_MAX);
        
//        CGSize size = [self.inputTextView.text sizeWithFont: self.inputTextView.font
//                                    constrainedToSize:constraint
//                                        lineBreakMode:UILineBreakModeWordWrap];
        
        NSDictionary *attribute = @{NSFontAttributeName:self.inputTextView.font};
        
        CGSize size = [self.inputTextView.text boundingRectWithSize:constraint
                                            options:
                          NSStringDrawingTruncatesLastVisibleLine |
                          NSStringDrawingUsesLineFragmentOrigin |
                          NSStringDrawingUsesFontLeading
                                         attributes:attribute
                                            context:nil].size;
        
        
        newSizeH = size.height + 16.0 - 6;
        if (newSizeH < 34) {
            newSizeH = 34;
        }
        contentSize = CGSizeMake(size.width, newSizeH);
        
    }
    else {
        newSizeH = self.inputTextView.contentSize.height - 6;
        if (newSizeH < 34) {
            newSizeH = 34;
        }
        contentSize = CGSizeMake(0, newSizeH);
    }
    
    
    
    if (contentSize.height - kTextChangeHeight > self.inputTextView.height && self.height <= self.maxAutoExpandHeight) {
        
        CGFloat changeDelta = contentSize.height - kTextChangeHeight - self.inputTextView.height;
        if (changeDelta > self.maxAutoExpandHeight) {
            changeDelta = self.maxAutoExpandHeight - self.height+10;
        }
        [self expandTextViewToHeight:contentSize.height - kTextChangeHeight];
        self.top -= changeDelta;
        if ([_delegate respondsToSelector:@selector(chatInputBar:changeHeigh:)]) {
            [_delegate chatInputBar:self changeHeigh:changeDelta];
        }
    } else if (contentSize.height - kTextChangeHeight  < self.inputTextView.height && contentSize.height > self.minAutoExpandHeight){
        
        CGFloat minHeight = MAX(self.minAutoExpandHeight, contentSize.height);
        if (contentSize.height - self.minAutoExpandHeight < 5) {
            minHeight = self.minAutoExpandHeight;
        }
        
        CGFloat changeDelta = minHeight - self.inputTextView.height;
        if (changeDelta > self.maxAutoExpandHeight) {
            changeDelta = self.maxAutoExpandHeight;
        }
        [self expandTextViewToHeight:minHeight];
        self.top -= changeDelta;
        
        if ([_delegate respondsToSelector:@selector(chatInputBar:changeHeigh:)]) {
            [_delegate chatInputBar:self changeHeigh:changeDelta];
        }
    } else if (contentSize.height < self.minAutoExpandHeight) {
        CGFloat changeDelta = contentSize.height - self.inputTextView.height;
        [self expandTextViewToHeight:contentSize.height];
        self.top -= changeDelta;
        
        if ([_delegate respondsToSelector:@selector(chatInputBar:changeHeigh:)]) {
            [_delegate chatInputBar:self changeHeigh:changeDelta];
        }
    }
}

- (void)expandTextViewToHeight:(CGFloat)height
{
    if (height > self.maxAutoExpandHeight) {
        height = self.maxAutoExpandHeight;
    }
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.height = height+10;
    [UIView commitAnimations];

    _inputTextStateHeight = self.height;
    /* 文本视图 */
//    self.inputTextView.frame = CGRectMake(5, 5, self.width - 75, self.height-10);
    self.inputTextView.height = self.height - 10;
    self.inputBackgroundImageView.frame = self.inputTextView.frame;
    self.sendButton.bottom = self.inputTextView.bottom;
}

- (void)setInputTextBackgroundImage:(UIImage *)inputTextBackgroundImage
{
    self.inputBackgroundImageView.image = [inputTextBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake( 2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
}


#pragma mark - getters 

- (UITextView *)inputTextView
{
    if (_inputTextView == nil) {
        CGRect backgroundFrame = self.frame;
        backgroundFrame.origin.y = 0;
        backgroundFrame.origin.x = 0;
        CGRect textViewFrame = CGRectInset(backgroundFrame, kTextInsetX, kTextInsetX);
        textViewFrame.size.height = self.height - 2*kTextInsetX;
        textViewFrame.size.width -= 65;
//ps:这个方法会造成文本只显示第一行
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//            NSTextStorage* textStorage = [[NSTextStorage alloc] initWithString:@""];
//            NSLayoutManager* layoutManager = [NSLayoutManager new];
//            [textStorage addLayoutManager:layoutManager];
//            self.textContainer = [[NSTextContainer alloc] initWithSize:textViewFrame.size];
//            [layoutManager addTextContainer:self.textContainer];
//            
//            _inputTextView = [[UITextView alloc] initWithFrame:textViewFrame textContainer:self.textContainer];
//        } else {
//        }
        _inputTextView = [[UITextView alloc] initWithFrame:textViewFrame];
        _inputTextView.delegate         = self;
        _inputTextView.font             = [UIFont systemFontOfSize:15.0f];
        _inputTextView.contentInset     = UIEdgeInsetsMake(-4,0,-4,0);
        _inputTextView.opaque           = NO;
        _inputTextView.backgroundColor  = [UIColor clearColor];
        _inputTextView.showsHorizontalScrollIndicator = YES;
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.enablesReturnKeyAutomatically = YES;
        _inputTextView.scrollEnabled = YES;
    }
    return _inputTextView;
}

- (UILabel *)inputPlaceholder
{
    if (_inputPlaceholder == nil) {
        _inputPlaceholder = [[UILabel alloc] init];
        _inputPlaceholder.backgroundColor = [UIColor clearColor];
        _inputPlaceholder.font            = [UIFont systemFontOfSize:15.0];
        _inputPlaceholder.hidden          = NO;
        _inputPlaceholder.textColor       = [UIColor colorWithRed:201.0f/255.0f green:201.0f/255.0f blue:201.0f/255.0f alpha:1];
        _inputPlaceholder.text            = @"  添加回复";
    }
    return _inputPlaceholder;
}

- (UIButton *)sendButton
{
    if (_sendButton == nil) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor colorWithRed:0 green:95.0f/255.0f blue:196.0f/255.0f alpha:1] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (UIImageView *)inputBackgroundImageView
{
    if (_inputBackgroundImageView == nil) {
        _inputBackgroundImageView = [[UIImageView alloc]init];
        _inputBackgroundImageView.userInteractionEnabled = YES;
    }
    return _inputBackgroundImageView;
}

@end
