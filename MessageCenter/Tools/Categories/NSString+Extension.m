//
//  NSString+Extension.m
//  QQ聊天布局
//
//  Created by TianGe-ios on 14-8-20.
//  Copyright (c) 2014年 TianGe-ios. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "NSString+Extension.h"
#import <CoreText/CoreText.h>
//引入IOS自带密码库
#import <CommonCrypto/CommonCryptor.h>

//空字符串
#define     LocalStr_None           @""

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


/*修改编码方式base64*/

@implementation NSString (Extension)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font,NSForegroundColorAttributeName:[UIColor blackColor]};
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    return [self boundingRectWithSize:maxSize options:options attributes:attrs context:nil].size;
    
    //    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] initWithString:self];
    //    // 创建 CTFramesetterRef 实例
    //
    //    //对齐模式
    //    CTParagraphStyleSetting ctTextAlignment;
    //    CTTextAlignment textAlignment = kCTLeftTextAlignment; //对齐模式
    //    ctTextAlignment.spec = kCTParagraphStyleSpecifierAlignment;
    //    ctTextAlignment.value = &textAlignment;
    //    ctTextAlignment.valueSize = sizeof(CTTextAlignment);
    //
    //    //换行
    //    CTParagraphStyleSetting lineBreakMode;
    //    CTLineBreakMode lineBreak = kCTLineBreakByWordWrapping; //换行模式
    //    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    //    lineBreakMode.value = &lineBreak;
    //    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    //    //行间距
    //    CTParagraphStyleSetting LineSpacing;
    //    CGFloat spacing = 3.0f;  //指定间距
    //    LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    //    LineSpacing.value = &spacing;
    //    LineSpacing.valueSize = sizeof(CGFloat);
    //
    //    CTParagraphStyleSetting settings[] = {lineBreakMode};
    //    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);   //第二个参数为settings的长度
    //    [resultString addAttribute:(NSString *)kCTParagraphStyleAttributeName
    //                             value:(__bridge id)paragraphStyle
    //                             range:NSMakeRange(0, resultString.length)];
    //
    //    CFRelease(paragraphStyle);
    //    [resultString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, resultString.length)];
    //    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)resultString);
    //    //CFRelease(framesetter);
    //    // 获得要缓制的区域的高度 lineSpacing
    //    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, maxSize, nil);
    //    CFRelease(framesetter);
    //    return coreTextSize;
    
    
}



- (NSString *)escape
{
    /*
     NSArray *hex = [NSArray arrayWithObjects:
     @"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"0A",@"0B",@"0C",@"0D",@"0E",@"0F",
     @"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"1A",@"1B",@"1C",@"1D",@"1E",@"1F",
     @"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"2A",@"2B",@"2C",@"2D",@"2E",@"2F",
     @"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"3A",@"3B",@"3C",@"3D",@"3E",@"3F",
     @"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"4A",@"4B",@"4C",@"4D",@"4E",@"4F",
     @"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59",@"5A",@"5B",@"5C",@"5D",@"5E",@"5F",
     @"60",@"61",@"62",@"63",@"64",@"65",@"66",@"67",@"68",@"69",@"6A",@"6B",@"6C",@"6D",@"6E",@"6F",
     @"70",@"71",@"72",@"73",@"74",@"75",@"76",@"77",@"78",@"79",@"7A",@"7B",@"7C",@"7D",@"7E",@"7F",
     @"80",@"81",@"82",@"83",@"84",@"85",@"86",@"87",@"88",@"89",@"8A",@"8B",@"8C",@"8D",@"8E",@"8F",
     @"90",@"91",@"92",@"93",@"94",@"95",@"96",@"97",@"98",@"99",@"9A",@"9B",@"9C",@"9D",@"9E",@"9F",
     @"A0",@"A1",@"A2",@"A3",@"A4",@"A5",@"A6",@"A7",@"A8",@"A9",@"AA",@"AB",@"AC",@"AD",@"AE",@"AF",
     @"B0",@"B1",@"B2",@"B3",@"B4",@"B5",@"B6",@"B7",@"B8",@"B9",@"BA",@"BB",@"BC",@"BD",@"BE",@"BF",
     @"C0",@"C1",@"C2",@"C3",@"C4",@"C5",@"C6",@"C7",@"C8",@"C9",@"CA",@"CB",@"CC",@"CD",@"CE",@"CF",
     @"D0",@"D1",@"D2",@"D3",@"D4",@"D5",@"D6",@"D7",@"D8",@"D9",@"DA",@"DB",@"DC",@"DD",@"DE",@"DF",
     @"E0",@"E1",@"E2",@"E3",@"E4",@"E5",@"E6",@"E7",@"E8",@"E9",@"EA",@"EB",@"EC",@"ED",@"EE",@"EF",
     @"F0",@"F1",@"F2",@"F3",@"F4",@"F5",@"F6",@"F7",@"F8",@"F9",@"FA",@"FB",@"FC",@"FD",@"FE",@"FF", nil];
     
     NSMutableString *result = [NSMutableString stringWithString:@""];
     int strLength = (int)self.length;
     for (int i=0; i<strLength; i++) {
     int ch = [self characterAtIndex:i];
     
     if (ch == ' ')
     {
     [result appendFormat:@"%c",'+'];
     }
     else if ('A' <= ch && ch <= 'Z')
     {
     [result appendFormat:@"%c",(char)ch];
     
     }
     else if ('a' <= ch && ch <= 'z')
     {
     [result appendFormat:@"%c",(char)ch];
     }
     else if ('0' <= ch && ch<='9')
     {
     [result appendFormat:@"%c",(char)ch];
     }
     else if (ch == '-' || ch == '_' || ch == '+'
     || ch == '.' || ch == '*'
     || ch == '@' || ch == '/')
     {
     [result appendFormat:@"%c",(char)ch];
     }
     else if (ch <= 0x007F)
     {
     [result appendFormat:@"%%",'%'];
     [result appendString:[hex objectAtIndex:ch]];
     }
     else
     {
     [result appendFormat:@"%%",'%'];
     [result appendFormat:@"%c",'u'];
     [result appendString:[hex objectAtIndex:ch>>8]];
     [result appendString:[hex objectAtIndex:0x00FF & ch]];
     }
     }
     return result;
     */
    
    
    //base64
    //return [self base64EncodedStringFrom:[self dataUsingEncoding:NSUTF8StringEncoding]];
    return self;
}

- (NSString *)unescape
{
    //javascript escape函数
    /*
     Byte val[] = {
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
     0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F};
     NSMutableString *outStr = [NSMutableString string];
     if(self && ![self isEqualToString:@""]){
     int i = 0;
     int len = [self length];
     while (i < len) {
     unichar ch = [self characterAtIndex:i];
     
     if (ch == '+') {
     [outStr appendString:@"' '"];
     } else if ('A' <= ch && ch <= 'Z') {
     [outStr appendString:[NSString stringWithFormat:@"%C",ch]];
     } else if ('a' <= ch && ch <= 'z') {
     [outStr appendString:[NSString stringWithFormat:@"%C",ch]];
     } else if ('0' <= ch && ch <= '9') {
     [outStr appendString:[NSString stringWithFormat:@"%C",ch]];
     } else if (ch == '-' || ch == '_' || ch == '+'
     || ch == '.' || ch == '*'
     || ch == '@' || ch == '/' || ch == '!'
     || ch == '~' || ch == '\'' || ch == '('
     || ch == ')') {
     [outStr appendString:[NSString stringWithFormat:@"%C",ch]];
     } else if (ch == '%') {
     unichar cint = 0;
     if ('u' != [self characterAtIndex:i+1]) {
     cint = (cint << 4) | val[[self characterAtIndex:i+1]];
     cint = (cint << 4) | val[[self characterAtIndex:i+2]];
     i+=2;
     } else {
     cint = (cint << 4) | val[[self characterAtIndex:i+2]];
     cint = (cint << 4) | val[[self characterAtIndex:i+3]];
     cint = (cint << 4) | val[[self characterAtIndex:i+4]];
     cint = (cint << 4) | val[[self characterAtIndex:i+5]];
     i+=5;
     }
     [outStr appendString:[NSString stringWithFormat:@"%C",cint]];
     }else {
     [outStr appendString:[NSString stringWithFormat:@"%C",ch]];
     }
     i++;
     }
     }
     
     if (0 == outStr.length) {
     return self;
     }
     
     return [NSString stringWithString:outStr];
     */
    
    //base64
    //return [[NSString alloc] initWithData:[self dataWithBase64Encoded] encoding:NSUTF8StringEncoding];
    return self;
}

/******************************************************************************
 函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
 函数描述 : base64格式字符串转换为文本数据
 输入参数 : (NSString *)string
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 :
 ******************************************************************************/
- (NSData *)dataWithBase64Encoded
{
    if (self == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([self length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [self cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([self length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

/******************************************************************************
 函数名称 : + (NSString *)base64EncodedStringFrom:(NSData *)data
 函数描述 : 文本数据转换为base64格式字符串
 输入参数 : (NSData *)data
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 ******************************************************************************/
- (NSString *)base64EncodedStringFrom:(NSData *)data
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

@end
