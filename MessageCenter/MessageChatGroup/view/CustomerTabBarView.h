//
//  GXTabBarView.h
//
//  RongYu100
//
//  Created by gqq on 15/11/13.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomerTabBarView;

@protocol CustomerTabBarDelegate <NSObject>

/**
 *  工具栏按钮被选中, 记录从哪里跳转到哪里. (方便以后做相应特效)
 */
- (void)tabBar:(CustomerTabBarView *)tabBar selectedFrom:(NSInteger) from to:(NSInteger)to;

@end
@interface CustomerTabBarView : UIView

@property(nonatomic,assign)id<CustomerTabBarDelegate>delegate;
@property(nonatomic,strong)UILabel *dotLabel;
@end
