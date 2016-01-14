//
//  GXTabBarView.m
//  RongYu100
//
//  Created by gqq on 15/11/13.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//


#import "CustomerTabBarView.h"
#import "MessageTool.h"
@interface CustomerTabBarView (){
    NSArray *unSelectImage;    //未选中时的图片
    NSArray *selectImage; //选中时的图片
    NSArray *btnTitle;    //所有标题
    int btnnum;   //按钮的数量
}
//设置之前选中的按钮
@property (nonatomic,strong) UIButton *selectedBtn;

@end
@implementation CustomerTabBarView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //code
        btnnum = 3;
        unSelectImage = [[NSArray alloc] initWithObjects:@"messageTabBar",@" ",@" ", nil];
        selectImage = [[NSArray alloc] initWithObjects:@"messageTabBar",@" ",@" ", nil];
        btnTitle = [[NSArray alloc] initWithObjects:@"消息",@"同行",@"客户",nil];
        //添加自己的视图
        UIImageView *myView = [[UIImageView alloc] init];
        myView.userInteractionEnabled = YES;
        myView.frame = self.bounds;
        myView.image = [UIImage imageNamed:@"title_background"];
        [self addSubview:myView];
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_BOUND_WIDTH, 0.5)];
        lineLabel.backgroundColor = [UIColor grayColor];
        [self addSubview:lineLabel];
        for (int i = 0; i < btnnum; i++) {
            //添加按钮
            UIButton *btn = [[UIButton alloc] init];
            CGFloat x = i * myView.frame.size.width / btnnum;
            btn.frame = CGRectMake(x, 0, myView.frame.size.width / btnnum, myView.frame.size.height);
            [myView addSubview:btn];
            
            //添加图标
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((btn.bounds.size.width-25)/2, 8, 25, 25)];
            imageView.tag = 200+i;
            imageView.image = [UIImage imageNamed:unSelectImage[i]];
            [btn addSubview:imageView];
            
            //标题
            UILabel *labTitle = [[UILabel alloc] init];
            labTitle.tag = 100+i;
            labTitle.frame = CGRectMake(0, 33, btn.bounds.size.width, 12);
            labTitle.textColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1];
            labTitle.font = [UIFont systemFontOfSize:11];
            labTitle.textAlignment = NSTextAlignmentCenter;
            labTitle.text = btnTitle[i];
            [btn addSubview:labTitle];
            
            btn.tag = i;
            [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            if (i == 1) {
                //消息中心icon红点
                 self.dotLabel = [[UILabel alloc]initWithFrame:CGRectMake((btn.bounds.size.width-22)/2 + 18, 4, 10, 10)];
                self.dotLabel.layer.cornerRadius = 5;
                self.dotLabel.backgroundColor = [UIColor redColor];
                self.dotLabel.clipsToBounds = YES;
                self.dotLabel.hidden = YES;
                [myView addSubview:self.dotLabel];
            }
            
            //设置刚进入时,第一个按钮为选中状态
            if (0 == i) {
                imageView.image = [UIImage imageNamed:selectImage[i]];
                labTitle.textColor = [UIColor colorWithRed:23.0/255 green:143.0/255 blue:203.0/255 alpha:1];
                btn.selected = YES;
                self.selectedBtn = btn;
            }
        }
        
        
    }
    return self;
}
//自定义TabBar的按钮点击事件
- (void)clickBtn:(UIButton *)button {
    
    //设置所有按钮的状态
    for (int i=0; i<btnnum; i++) {
        UILabel *labTitle = (UILabel *)[self viewWithTag:100+i];
        UIImageView *imgView = (UIImageView *)[self viewWithTag:200+i];
        if(i == button.tag){
            imgView.image = [UIImage imageNamed:selectImage[i]];
            labTitle.textColor = [UIColor colorWithRed:23.0/255 green:143.0/255 blue:203.0/255 alpha:1];
        }else{
            imgView.image = [UIImage imageNamed:unSelectImage[i]];
            labTitle.textColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1];
        }
    }
    
    //1.先将之前选中的按钮设置为未选中
    self.selectedBtn.selected = NO;
    //2.再将当前按钮设置为选中
    button.selected = YES;
    //3.最后把当前按钮赋值为之前选中的按钮
    self.selectedBtn = button;
    //4.跳转到相应的视图控制器. (通过selectIndex参数来设置选中了那个控制器)
    if ([self.delegate respondsToSelector:@selector(tabBar:selectedFrom:to:)]) {
        [self.delegate tabBar:self selectedFrom:self.selectedBtn.tag to:button.tag];
    }
    
}



@end
