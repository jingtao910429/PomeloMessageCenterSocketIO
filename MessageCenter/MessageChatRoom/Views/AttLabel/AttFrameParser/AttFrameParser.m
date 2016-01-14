//
//  AttFrameParser.m
//  RongYu100
//
//  Created by xiaerfei on 15/11/16.
//  Copyright (c) 2015年 ___RongYu100___. All rights reserved.
//

#import "AttFrameParser.h"
#import "RegexKitLite.h"

@implementation AttFrameParser


+ (AttTextData *)parseWithContentString:(NSString *)contentString config:(AttFrameParserConfig*)config
{
    NSMutableArray *linkArray = [NSMutableArray array];
    NSAttributedString *content = [self loadContentString:contentString linkArray:linkArray config:config];
    AttTextData *data = [self parseAttributedContent:content config:config];
    data.linkArray = linkArray;
    return data;
}

+ (AttTextData *)parseAttributedContent:(NSAttributedString *)content config:(AttFrameParserConfig*)config
{
    // 创建 CTFramesetterRef 实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    // 获得要缓制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    // 生成 CTFrameRef 实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    
    // 将生成好的 CTFrameRef 实例和计算好的缓制高度保存到 AttTextData 实例中，最后返回 AttTextData 实例
    AttTextData *data = [[AttTextData alloc] init];
    data.ctFrame = frame;
    data.textSize = coreTextSize;
    data.height = textHeight;
    data.content = content;
    // 释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    return data;
}


+ (NSMutableAttributedString *)loadContentString:(NSString *)contentString linkArray:(NSMutableArray *)linkArray config:(AttFrameParserConfig*)config
{
    NSMutableAttributedString *resultString = nil;
    if (contentString) {
        resultString = [[NSMutableAttributedString alloc] initWithString:contentString];
        NSDictionary *attriInfo = [AttFrameParser attributesWithConfig:config];
        [resultString addAttributes:attriInfo range:NSMakeRange(0, resultString.length)];
        
        NSError *error = NULL;
        NSRegularExpression *regexPhone = [NSRegularExpression regularExpressionWithPattern:@"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|(010\\d{8})|(0[2-9]\\d{9})|\\d{8}|\\d{7}" options:NSRegularExpressionAnchorsMatchLines error:&error];

        [regexPhone enumerateMatchesInString:contentString options:NSMatchingReportProgress range:NSMakeRange(0, [contentString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            for (int i = 0; i < result.numberOfRanges; i++) {
                NSRange rang = [result rangeAtIndex:i];
                if (rang.length == 0) {
                    continue;
                }
                [resultString addAttributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)} range:rang];
                AttLinkData *linkData = [[AttLinkData alloc] init];
                linkData.text  = [contentString substringWithRange:rang];
                linkData.range = rang;
                linkData.attLinkDataType = AttLinkDataTypePhoneNumber;
                [linkArray addObject:linkData];
            }
         }];
        
        NSRegularExpression *regexURL = [NSRegularExpression regularExpressionWithPattern:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" options:NSRegularExpressionAnchorsMatchLines error:&error];
        
        [regexURL enumerateMatchesInString:contentString options:NSMatchingReportProgress range:NSMakeRange(0, [contentString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            for (int i = 0; i < result.numberOfRanges; i++) {
                NSRange rang = [result rangeAtIndex:i];
                if (rang.length == 0) {
                    continue;
                }
                [resultString addAttributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)} range:rang];
                AttLinkData *linkData = [[AttLinkData alloc] init];
                linkData.text  = [contentString substringWithRange:rang];
                linkData.range = rang;
                linkData.attLinkDataType = AttLinkDataTypeURL;
                [linkArray addObject:linkData];
            }
        }];
        NSRegularExpression *regexEmail = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}" options:NSRegularExpressionAnchorsMatchLines error:&error];
        
        [regexEmail enumerateMatchesInString:contentString options:NSMatchingReportProgress range:NSMakeRange(0, [contentString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            for (int i = 0; i < result.numberOfRanges; i++) {
                NSRange rang = [result rangeAtIndex:i];
                if (rang.length == 0) {
                    continue;
                }
                [resultString addAttributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)} range:rang];
                AttLinkData *linkData = [[AttLinkData alloc] init];
                linkData.text  = [contentString substringWithRange:rang];
                linkData.range = rang;
                linkData.attLinkDataType = AttLinkDataTypeEmail;
                [linkArray addObject:linkData];
            }
        }];
        
    }
    

    //url @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
    //email @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
    //phone @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"  不能识别 021xxxxxx
    /*
     (010\d{8})|(0[2-9]\d{9})  识别 02158330660
     @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}" 手机021-58330660
     @"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)"
     */
    
    return resultString;
}

+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
                                  config:(AttFrameParserConfig *)config
                                  height:(CGFloat)height {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

+ (NSMutableDictionary *)attributesWithConfig:(AttFrameParserConfig *)config {
    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CGFloat lineSpacing = config.lineSpace;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor * textColor = config.textColor;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    return dict;
}
@end
