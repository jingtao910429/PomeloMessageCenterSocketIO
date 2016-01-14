//
//  ApplicationStatusView.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/11/5.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "ApplicationStatusView.h"
#import "UIViewExt.h"
#import "NSString+Extension.h"

@interface ApplicationStatusView ()

@property (nonatomic, strong) UILabel *aplicationLabel;
@property (nonatomic, strong) UIImageView *progressImageView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGes;

@end

@implementation ApplicationStatusView
#pragma mark - Lift Cycel
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
    [self addGestureRecognizer:self.tapGes];
    [self addSubview:self.aplicationLabel];
//    [self addSubview:self.progressImageView];
}
#pragma mark - public methods
- (void)updateAplicationStatusText:(NSString *)text
{
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(MAXFLOAT, 20)];
    size.width += 10;
    self.aplicationLabel.text = text;
    self.aplicationLabel.frame = CGRectMake((self.width-size.width)/2.0f, 5, size.width, 20);
//    self.progressImageView.frame = CGRectMake(self.aplicationLabel.left-1, 4, self.aplicationLabel.width+2, self.aplicationLabel.height+2);
}

- (void)applicationProgress {
    
    if (self.ApplicationStatusViewBlock) {
        self.ApplicationStatusViewBlock();
    }
    
}


#pragma mark - getter and setter

- (UILabel *)aplicationLabel
{
    if (_aplicationLabel == nil) {
        _aplicationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 0, 20)];
        _aplicationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _aplicationLabel.textAlignment = NSTextAlignmentCenter;
        _aplicationLabel.font = [UIFont systemFontOfSize:13];
        _aplicationLabel.text = @"借款申请编辑中";
        _aplicationLabel.textColor = [UIColor colorWithRed:16.0f/255.0f green:120.0f/255.0f blue:193.0f/255.0f alpha:1];
        _aplicationLabel.layer.borderWidth = 1.0f;
        _aplicationLabel.layer.borderColor = COLOR(209, 209, 209, 1).CGColor;
        _aplicationLabel.layer.masksToBounds = YES;
        _aplicationLabel.layer.cornerRadius = 10;
        _aplicationLabel.userInteractionEnabled = YES;
    }
    return _aplicationLabel;
}

- (UIImageView *)progressImageView
{
    if (_progressImageView == nil) {
        _progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.aplicationLabel.left-1, 4, self.aplicationLabel.width+2, self.aplicationLabel.height+2)];
        _progressImageView.image = [[UIImage imageNamed:@"progressframe"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    return _progressImageView;
}

- (UITapGestureRecognizer *)tapGes {
    if (!_tapGes) {
        _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applicationProgress)];
    }
    return _tapGes;
}

@end
