//
//  MessageChatBarSetTool.m
//  RongYu100
//
//  Created by wwt on 16/4/15.
//  Copyright © 2016年 ___RongYu100___. All rights reserved.
//

#import "MessageChatBarSetTool.h"

@implementation MessageChatBarSetTool

+ (void)setChatBarFrameSet:(NSString *)chatBarFrameSet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:chatBarFrameSet forKey:[NSString stringWithFormat:@"%@chatBarFrameSet",[Tool getOwerUserID]]];
    [defaults synchronize];
    
}

+ (NSString *)chatBarFrameSet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"%@chatBarFrameSet",[Tool getOwerUserID]]];
}

@end
