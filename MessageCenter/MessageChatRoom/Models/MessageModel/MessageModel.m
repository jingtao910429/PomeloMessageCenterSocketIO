//
//  MessageModel.m
//  QQ聊天布局
//
//  Created by xiaerfei on 15-10-19.
//  Copyright (c) 2015年 xiaerfei. All rights reserved.
//

#import "MessageModel.h"
#import "PomeloMessageCenterDBManager.h"
#import "MessageCenterMetadataModel.h"
#import "MessageCenterMessageModel.h"
#import "NSString+Extension.h"
#import "MessageTool.h"
#import "MessageCenterUserModel.h"
#import "AttLinkData.h"


@implementation MessageModel


#pragma mark - public methods
/**
 *   @author xiaerfei, 15-11-03 14:11:25
 *
 *   解析推送过来的信息
 *
 *   @param data Data
 *
 *   @return Model
 */
+ (MessageModel *)parseNotifyData:(id)data modelType:(MessageModelType)modelType
{
    NSDictionary *dict  = data;
    MessageModel *model = [[MessageModel alloc] init];
    model.messageId     = dict[@"_id"];
    model.text          = [dict[@"content"] unescape];
    model.fromId        = dict[@"from"];
    model.groupId       = dict[@"toGroupId"];
    model.userMessageId = dict[@"userMessageId"];
    model.personName    = dict[@"personName"];
    model.messageTime   = dict[@"time"];
    model.clientMsgId   = dict[@"clientMsgId"];
    NSArray *time       = [MessageModel parseTime:dict[@"time"]];
    model.yearAndMoth   = [time firstObject];
    model.time          = [time lastObject];
    model.modelType     = modelType;
    
    NSString *status = dict[@"status"];
    if (!isEmptyString(status)) {
        model.isSendFail = !status.boolValue;
    }
    
    // 判断是否是系统消息
    NSInteger typeValue = [dict[@"type"] integerValue];
    if (typeValue == 101 || typeValue == 106) {
        model.messageType   = MessageTypeSystem;
        if (isEmptyString(model.text) || [model.text isEqualToString:@"(null)"] || [model.text isEqualToString:@"<null>"]) {
            return nil;
        }
    } else {
        model.messageType   = MessageTypeChat;
    }
    
    [MessageModel calculateMessageModel:model];
    return model;
}
/**
 *   @author xiaerfei, 15-11-03 14:11:05
 *
 *   发送消息 转为对应的Model
 *
 *   @param content
 *
 *   @return 
 */
+ (MessageModel *)sendMessageWithContent:(NSString *)content
{
    NSDate *senddate = [NSDate date];
    NSDateFormatter *dateformatter = [MessageTool shareDateForMatter];
//    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//    [dateformatter setTimeZone:timeZone];
    
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *time = [dateformatter stringFromDate:senddate];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *yearAndMoth = [dateformatter stringFromDate:senddate];
    
    MessageModel *model = [[MessageModel alloc] init];
    model.text = content;
    model.time = time;
    model.yearAndMoth = yearAndMoth;
    model.modelType = MessageModelTypeMe;
    model.messageType = MessageTypeChat;
    model.animateStatus = YES;
    [MessageModel calculateMessageModel:model];
    return model;
}
#pragma mark 操作db
+ (NSDictionary *)messageCenterStatusWithGroupId:(NSString *)groupId
{
    PomeloMessageCenterDBManager *messageCenterDBManager = [PomeloMessageCenterDBManager shareInstance];
    NSArray *array = [messageCenterDBManager fetchDataInfosWithType:MessageCenterDBManagerTypeMETADATA conditionName:@"GroupId" SQLvalue:groupId];
    
    MessageCenterMetadataModel *messageCenterMetadataModel = [array lastObject];
    
    NSDictionary *dict = @{@"approveStatus":messageCenterMetadataModel.approveStatus== nil?@"":messageCenterMetadataModel.approveStatus,
                           @"unReadMsgCount":messageCenterMetadataModel.unReadMsgCount== nil?@"":messageCenterMetadataModel.unReadMsgCount,
                           @"isTop":messageCenterMetadataModel.isTop== nil?@"":messageCenterMetadataModel.isTop,
                           @"groupName":messageCenterMetadataModel.groupName== nil?@"":messageCenterMetadataModel.groupName,
                           @"companyName":messageCenterMetadataModel.companyName== nil?@"":messageCenterMetadataModel.companyName};
    return dict;
}

+ (NSMutableArray *)fectchHistoryMessageWithGroupId:(NSString *)groupId userId:(NSString *)userId number:(NSInteger)number userMessageTime:(NSString *)userMessageTime
{
    MessageCenterMessageModel *messageCenterModelFetch = nil;
    if (userMessageTime != nil) {
        messageCenterModelFetch = [[MessageCenterMessageModel alloc] init];
        messageCenterModelFetch.createTime = userMessageTime;
    }
    PomeloMessageCenterDBManager *messageCenterDBManager = [PomeloMessageCenterDBManager shareInstance];
    NSArray *array = [messageCenterDBManager fetchDataInfosWithType:MessageCenterDBManagerTypeMESSAGE conditionName:@"GroupId" SQLvalue:groupId messageModel:messageCenterModelFetch number:number];
    NSMutableArray *historyData = [[NSMutableArray alloc] init];
    for (MessageCenterMessageModel *messageCenterModel in array) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"_id"]           = messageCenterModel.messageId     == nil?@"":messageCenterModel.messageId;
        dict[@"content"]       = messageCenterModel.msgContent    == nil?@"":messageCenterModel.msgContent;
        dict[@"from"]          = messageCenterModel.userId        == nil?@"":messageCenterModel.userId;
        dict[@"toGroupId"]     = messageCenterModel.groupId       == nil?@"":messageCenterModel.groupId;
        dict[@"time"]          = messageCenterModel.createTime    == nil?@"":messageCenterModel.createTime;
        dict[@"userMessageId"] = messageCenterModel.userMessageId == nil?@"":messageCenterModel.userMessageId;
        dict[@"status"]        = messageCenterModel.Status        == nil?@"":messageCenterModel.Status;
        dict[@"personName"]    = messageCenterModel.personName    == nil?@"":messageCenterModel.personName;
        dict[@"type"]          = messageCenterModel.type          == nil?@"":messageCenterModel.type;
        dict[@"clientMsgId"]   = messageCenterModel.clientMsgId   == nil?@"":messageCenterModel.clientMsgId;
        MessageModelType modelType;
        if ([messageCenterModel.userId isEqualToString:userId]) {
            modelType = MessageModelTypeMe;
        } else {
            modelType = MessageModelTypeOther;
        }
        MessageModel *messageModel = [MessageModel parseNotifyData:dict modelType:modelType];
        if (messageModel != nil) {
            messageModel.groupId = groupId;
            messageModel.iconURL = [MessageModel iconURLWithUserId:messageCenterModel.userId];
            [historyData addObject:messageModel];
        }
    }

    return historyData;
}
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
+ (void)getTimeIntervalCurrentModel:(MessageModel *)currentModel lastModel:(MessageModel *)lastModel destinationArray:(NSMutableArray *)destinationArray atIndex:(NSInteger)index
{
    if (lastModel.messageType == MessageTypeTime) {
        return;
    }
    NSDateFormatter *formatter = [MessageTool shareDateForMatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date1 = [formatter dateFromString:currentModel.yearAndMoth];
    NSDate *date2 = [formatter dateFromString:lastModel.yearAndMoth];
    NSTimeInterval aTimer = [date1 timeIntervalSinceDate:date2];
    if (aTimer >= 86400.0f) {
        MessageModel *message = [[MessageModel alloc] init];
        message.yearAndMoth = currentModel.yearAndMoth;
        message.messageType = MessageTypeTime;
        [destinationArray insertObject:message atIndex:index];
    }
}
/**
 *   @author xiaerfei, 15-11-20 15:11:41
 *
 *   将发送的消息add到DB
 *
 *   @param model
 */
+ (void)sendMessageAddToDBWithModel:(MessageModel *)model
{
    PomeloMessageCenterDBManager *messageCenterDBManager = [PomeloMessageCenterDBManager shareInstance];
    
    if (isEmptyString(model.clientMsgId)) {
        NSString *clientMsgId = [self createClientMsgId];
        model.clientMsgId = clientMsgId;
    }
    MessageCenterMessageModel *messageCenterMessageModel = [[MessageCenterMessageModel alloc] init];
    messageCenterMessageModel.accountId   = [MessageTool getUserID];
    messageCenterMessageModel.userId      = model.fromId;
    messageCenterMessageModel.Status      = @"0";
    messageCenterMessageModel.type        = model.type;
    messageCenterMessageModel.clientMsgId = model.clientMsgId;
    messageCenterMessageModel.msgContent  = [model.text escape];
    messageCenterMessageModel.groupId     = model.groupId;
    messageCenterMessageModel.createTime  = [MessageModel componentsTime];
    [messageCenterDBManager addNoSendMessageToTableWithType:MessageCenterDBManagerTypeMESSAGE data:@[messageCenterMessageModel]];
}


+ (NSString *)createClientMsgId
{
    NSDateFormatter *formatter = [MessageTool shareDateForMatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [NSDate date];

    return [NSString stringWithFormat:@"%.0f-%@",[date timeIntervalSince1970],[MessageTool sessionId]];
}


#pragma mark - private methods
/**
 *   @author xiaerfei, 15-11-03 14:11:01
 *
 *   解析成对应的Model 或计算每条消息对应的frame
 *
 *   @param model
 */
+ (void)calculateMessageModel:(MessageModel *)model
{
    CGFloat screenWith   = [UIScreen mainScreen].bounds.size.width;
    if (model.messageType == MessageTypeChat) {
        CGFloat maxWidth = screenWith - 60 - 80;
        AttFrameParserConfig *config = [[AttFrameParserConfig alloc] init];
        config.width = maxWidth;
        config.fontSize = 15.0f;
        if (model.modelType == MessageModelTypeMe) {
            config.textColor = [UIColor whiteColor];
        } else {
            config.textColor = [UIColor blackColor];
        }
        AttTextData *attTextData = nil;
        CGSize textSize;
        if (model.text.length != 0) {
            NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            model.text = [[NSString alloc]initWithString:[model.text stringByTrimmingCharactersInSet:whiteSpace]];
            attTextData = [AttFrameParser parseWithContentString:model.text config:config];
            model.attTextData = attTextData;
            textSize = attTextData.textSize;
        } else {
            textSize = CGSizeMake(0, 0);
        }
        
        if (textSize.width > maxWidth) {
            textSize.width = maxWidth;
        }
        
        model.textHeigh = textSize.height;
        model.textSize  = textSize;
        if (textSize.width < 26) {
            textSize.width = 26;
        }
        if (textSize.height < 22) {
            textSize.height = 22;
        }
        
        if (model.modelType == MessageModelTypeMe) {
            model.iconFrame = CGRectMake(screenWith-50, 0, 40, 40);
            model.chatFrame = CGRectMake(screenWith-65-200, 0, 200, 20);
            model.bgFrame   = CGRectMake(screenWith-60- (textSize.width+20), 21, textSize.width+20, textSize.height+10);
        } else if (model.modelType == MessageModelTypeOther) {
            model.iconFrame = CGRectMake(10, 0, 40, 40);
            model.chatFrame = CGRectMake(65, 0, 200, 20);
            model.bgFrame   = CGRectMake(60, 21, textSize.width+20, textSize.height+10);
        }
        
        CGFloat cellHeight = model.chatFrame.size.height + textSize.height;
        if (cellHeight < model.iconFrame.size.height) {
            cellHeight = model.iconFrame.size.height + 10;
        } else {
            cellHeight += 10;
        }
        model.cellHeght = cellHeight+10;
    }
    
    if (model.messageType == MessageTypeSystem) {
        CGFloat maxWidth = screenWith - 70-20;
        CGSize textSize;
        if (model.text.length != 0) {
            textSize = [model.text sizeWithFont:[UIFont systemFontOfSize:14.0] maxSize:CGSizeMake(maxWidth, MAXFLOAT)];
        } else {
            textSize = CGSizeMake(0, 0);
        }
        model.textSize  = textSize;
        model.textHeigh = textSize.height;
        model.cellHeght = textSize.height + 30;
        model.bgFrame = CGRectMake((SCREENWIDTH - model.textSize.width - 10)/2.0f, (model.cellHeght - model.textHeigh - 10)/2.0f,model.textSize.width+10, model.textHeigh+10);
    }
}
/**
 *   @author xiaerfei, 15-11-17 09:11:18
 *
 *   根据userId 获取对应的头像URL
 *
 *   @param userId
 *
 *   @return
 */
+ (NSString *)iconURLWithUserId:(NSString *)userId
{
    PomeloMessageCenterDBManager *messageCenterDBManager = [PomeloMessageCenterDBManager shareInstance];
    NSArray *array = [messageCenterDBManager fetchDataInfosWithType:MessageCenterDBManagerTypeUSER conditionName:@"UserId" SQLvalue:userId];
    MessageCenterUserModel *userModel = array.lastObject;
    return userModel.userId;
}
/**
 *   @author xiaerfei, 15-11-17 09:11:52
 *
 *   解析系统返回的时间 2015-11-19T07:46:57.525Z
 *                   2015-11-20T02:05:46.000Z
 *   @param time
 *
 *   @return
 */
+ (NSArray *)parseTime:(NSString *)time
{
    if (isEmptyString(time) || [time isEqualToString:@"(null)"]) {
        return nil;
    }
    NSArray *array = [time componentsSeparatedByString:@"T"];
    NSString *yearAndMoth = [array firstObject];
    NSString *timeText = [[[array lastObject] componentsSeparatedByString:@"."] firstObject];
    if (isEmptyString(timeText) || isEmptyString(yearAndMoth)) {
        return @[@"",@""];
    }
    
    NSString *utcTime = [NSString stringWithFormat:@"%@T%@+0000",yearAndMoth,timeText];

    NSArray *nowZone = [MessageModel getLocalDateFormateUTCDate:utcTime];
    return @[nowZone[0],nowZone[1]];
}
/**
 *   @author xiaerfei, 15-11-13 15:11:02
 *
 *   拼接时间字符串为： 2015-11-13T15:54:07.000Z 格式
 *
 *   @return
 */
+ (NSString *)componentsTime
{
    NSDateFormatter *formatter = [MessageTool shareDateForMatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
    NSDate *date = [NSDate date];
    NSString *timeStr = [formatter stringFromDate:date];
    return timeStr;
}

+ (NSArray *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [MessageTool shareDateForMatter];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    
    NSMutableArray *timeArray = [[NSMutableArray alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *yearAndMonth = [dateFormatter stringFromDate:dateFormatted];
    [timeArray addObject:yearAndMonth];
    
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *second = [dateFormatter stringFromDate:dateFormatted];
    [timeArray addObject:second];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *allTime = [dateFormatter stringFromDate:dateFormatted];
    [timeArray addObject:allTime];
    return timeArray;
}


@end

