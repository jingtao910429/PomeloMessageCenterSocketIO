//
//  MessageModel.h
//  QQ聊天布局
//
//  Created by TianGe-ios on 14-8-19.
//  Copyright (c) 2014年 TianGe-ios. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>
#import "AttFrameParser.h"

#define kToolBarH 50
#define kTextFieldH 30

#define kTextViewH 30
#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
// 获取消息的起始Pos
#define kFetchMessageNumber 20


#define isEmptyString(string) ((string == nil || string.length == 0) ? YES : NO)


typedef NS_ENUM(NSInteger, MessageModelType) {
    MessageModelTypeMe      = 0,
    MessageModelTypeOther   = 1,
};

typedef NS_ENUM(NSInteger, MessageType) {
    /// 聊天消息
    MessageTypeChat    = 3,
    /// 时间分割线
    MessageTypeTime    = 4,
    /// 系统消息
    MessageTypeSystem  = 5,
};

typedef NS_ENUM(NSInteger, MessageUserType) {
    /// 融誉客服
    MessageUserTypeService    = 6,
    /// 金融机构
    MessageUserTypeFinancial  = 7,
    /// 代理商
    MessageUserTypeAgent      = 8,
    /// 客户
    MessageUserTypeCustomer   = 9,
};



@interface MessageModel : NSObject

@property (nonatomic, copy) NSString *personName;
@property (nonatomic, copy) NSString *iconURL;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *yearAndMoth;
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *fromId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *messageTime;
/// sessionId
@property (nonatomic, copy) NSString *clientMsgId;

@property (nonatomic, copy) NSString *userMessageId; //主键
/// 菊花是否旋转
@property (nonatomic, assign) BOOL animateStatus;
/// 是否发送失败
@property (nonatomic, assign) BOOL isSendFail;
/// 发送消息内容的类别  我  还是 其他人
@property (nonatomic, assign) MessageModelType modelType;
/// 消息的类型：聊天消息、时间分割线、系统消息
@property (nonatomic, assign) MessageType      messageType;
/// 消息发送者的类型
@property (nonatomic, assign) MessageUserType  messageUserType;
/// 头像 frame
@property (nonatomic, assign) CGRect iconFrame;
/// 名称frame
@property (nonatomic, assign) CGRect chatFrame;
/// 消息背景frame
@property (nonatomic, assign) CGRect bgFrame;
/// 消息高度
@property (nonatomic, assign) CGFloat textHeigh;
/// 消息 size
@property (nonatomic, assign) CGSize textSize;
/// 对应的cell  高度
@property (nonatomic, assign) CGFloat cellHeght;

@property (nonatomic, strong) AttTextData *attTextData;


+ (MessageModel *)sendMessageWithContent:(NSString *)content;
/**
 *   @author xiaerfei, 15-12-14 09:12:50
 *
 *   解析推送过来的消息
 *
 *   @param data
 *   @param modelType
 *
 *   @return
 */
+ (MessageModel *)parseNotifyData:(id)data modelType:(MessageModelType)modelType;
/**
 *   @author xiaerfei, 15-12-14 09:12:25
 *
 *   获取群组信息
 *
 *   @param groupId
 *
 *   @return
 */
+ (NSDictionary *)messageCenterStatusWithGroupId:(NSString *)groupId;
/**
 *   @author xiaerfei, 15-11-04 14:11:38
 *
 *   载入历史消息
 *
 *   @param groupId
 *   @param userId
 *   @param startPos
 *
 *   @return 
 */
+ (NSMutableArray *)fectchHistoryMessageWithGroupId:(NSString *)groupId userId:(NSString *)userId number:(NSInteger)number userMessageTime:(NSString *)userMessageTime;
/**
 *   @author xiaerfei, 15-11-05 10:11:05
 *
 *   插入时间分割线
 *
 *   @param currentModel     现在的消息
 *   @param lastModel        上一条消息
 *   @param destinationArray 要加入的数组
 *   @param index            插入的地方
 */
+ (void)getTimeIntervalCurrentModel:(MessageModel *)currentModel lastModel:(MessageModel *)lastModel destinationArray:(NSMutableArray *)destinationArray atIndex:(NSInteger)index;
/**
 *   @author xiaerfei, 15-11-20 15:11:41
 *
 *   将发送的消息add到DB
 *
 *   @param model
 */
+ (void)sendMessageAddToDBWithModel:(MessageModel *)model;
/**
 *   @author xiaerfei, 15-11-09 17:11:33
 *
 *   创建 clientMsgId
 *
 *   @return
 */
+ (NSString *)createClientMsgId;
/**
 *   @author xiaerfei, 15-12-18 16:12:02
 *
 *   解析服务器时间
 *
 *   @param time
 *
 *   @return
 */
+ (NSArray *)parseTime:(NSString *)time;
@end
