//
//  GroupChatCell.m
//  ChatUIDemo
//
//  Created by xiaerfei on 15/10/20.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "GroupChatCell.h"
#import "UIViewExt.h"

NSString *const kGroupChatCellGroupName      = @"GroupChatCellGroupName";
NSString *const kGroupChatCellChatTop        = @"GroupChatCellChatTop";
NSString *const kGroupChatCellInfoNotDisturb = @"GroupChatCellInfoNotDisturb";

@interface GroupChatCell ()

@property (nonatomic, strong) UILabel  *leftValueLabel;
@property (nonatomic, strong) UISwitch *defSwitch;
@end

@implementation GroupChatCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configUIWithReuseIdentifier:reuseIdentifier];
    }
    return self;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configUIWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self.textLabel.font = [UIFont systemFontOfSize:15];
    if ([reuseIdentifier isEqualToString:kGroupChatCellGroupName]) {
        self.textLabel.text = @"群名称";
        [self.contentView addSubview:self.leftValueLabel];
    } else if ([reuseIdentifier isEqualToString:kGroupChatCellChatTop]) {
        self.textLabel.text = @"聊天置顶";
        self.defSwitch.tag = 1234;
        [self.contentView addSubview:self.defSwitch];
    } else if ([reuseIdentifier isEqualToString:kGroupChatCellInfoNotDisturb]) {
        self.textLabel.text = @"消息免打扰";
        self.defSwitch.tag = 1235;
        self.defSwitch.on = YES;
        [self.contentView addSubview:self.defSwitch];
    }
}
#pragma mark - public methods
- (void)updateData:(id)data reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([reuseIdentifier isEqualToString:kGroupChatCellGroupName]) {
        self.leftValueLabel.text = data;
    } else {
        self.defSwitch.on = [data boolValue];
    }
    
}

#pragma mark - events responses
- (void)switchAction:(UISwitch *)defSwitch
{
    NSString *reuseIdentifier = nil;
    if (defSwitch.tag == 1234) {
        //聊天置顶
        reuseIdentifier = kGroupChatCellChatTop;
    } else if (defSwitch.tag == 1235) {
        //消息免打扰
        reuseIdentifier = kGroupChatCellInfoNotDisturb;
    }
    if ([_delegate respondsToSelector:@selector(switchValueChange:reuseIdentifier:)]) {
        [_delegate switchValueChange:defSwitch.on reuseIdentifier:reuseIdentifier];
    }
    
}

#pragma mark - getters
- (UILabel *)leftValueLabel
{
    if (_leftValueLabel == nil) {
        _leftValueLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-215, 12, 200, 20)];
        _leftValueLabel.textAlignment = NSTextAlignmentRight;
        _leftValueLabel.font = [UIFont systemFontOfSize:16];
        _leftValueLabel.text = @"";
    }
    return _leftValueLabel;
}

- (UISwitch *)defSwitch
{
    if (_defSwitch == nil) {
        _defSwitch = [[UISwitch alloc] init];
        _defSwitch.right = [UIScreen mainScreen].bounds.size.width-15;
        _defSwitch.top   = (44 - _defSwitch.height)/2.0f;
        [_defSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _defSwitch;
}

@end
