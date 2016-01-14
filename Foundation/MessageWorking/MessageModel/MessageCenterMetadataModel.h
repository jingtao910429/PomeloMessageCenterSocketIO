//
//  MessageCenterMetadataModel.h
//  Client
//
//  Created by wwt on 15/10/21.
//  Copyright (c) 2015年 xiaochuan. All rights reserved.
//

#import "CommonModel.h"

@interface MessageCenterMetadataModel : CommonModel

@property (nonatomic, copy) NSString *msgMetadataId;       //主键
@property (nonatomic, copy) NSString *accountId;           //区分账号
@property (nonatomic, copy) NSString *groupId;             //组ID
@property (nonatomic, copy) NSString *groupName;           //组名字
@property (nonatomic, copy) NSString *avatar;              //组头像
@property (nonatomic, copy) NSString *avatarCache;         //组头像本地缓存
@property (nonatomic, copy) NSString *groupType;         //组类型/*1:信贷申请组,2:用户一对一对话组,3:用户创建组*/
@property (nonatomic, copy) NSString *companyName;         //申请人公司(1-7,-1,-5,-6)
@property (nonatomic, copy) NSString *approveStatus;       //信贷申请审核状态
@property (nonatomic, copy) NSString *lastedReadMsgId;     //最后读取消息Id
@property (nonatomic, copy) NSString *lastedReadTime;      //最后读取时间
@property (nonatomic, copy) NSString *lastedMsgId;         //最新消息id
@property (nonatomic, copy) NSString *lastedMsgSenderName; //最新消息发送者
@property (nonatomic, copy) NSString *lastedMsgTime;       //最新消息的发送时间
@property (nonatomic, copy) NSString *lastedMsgContent;    //最新消息内容
@property (nonatomic, copy) NSString *unReadMsgCount;      //未读消息数量
@property (nonatomic, copy) NSString *createTime;          //创建时间

@property (nonatomic, copy) NSString *isTop;               //本地设置置顶信息


//查询行数用到
@property (nonatomic, copy) NSString *TNumbers;

@end
