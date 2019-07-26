//
//  YJSubtitleParser.m
//  YJNetManagerDemo
//
//  Created by 刘亚军 on 2019/3/18.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJSubtitleParser.h"
#import <YJExtensions/YJExtensions.h>

@implementation YJSubtitleParser
+ (YJSubtitleParser *)parser{
    static YJSubtitleParser * macro = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        macro = [[YJSubtitleParser alloc]init];
    });
    return macro;
}
- (NSDictionary *)parseLrc:(NSString *)lrc{
    if ((![lrc containsString:@"]"] && ![lrc containsString:@"["])) {
        return @{};
    }
    lrc = [lrc stringByReplacingOccurrencesOfString:@"]" withString:@"\n"];
    lrc = [lrc stringByReplacingOccurrencesOfString:@"[" withString:[[NSString yj_Char1] stringByAppendingString:@"\n"]];
    NSArray *singlearray = [lrc componentsSeparatedByString:@"\n"];
    NSMutableArray *begintimearray = [NSMutableArray array];
    NSMutableArray *subtitlesarray = [NSMutableArray array];
    NSString *subStr = @"";
    int j = 0;
    for (NSString *s in singlearray) {
        NSString *str = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];;
        if ([str isEqualToString:[NSString yj_Char1]]) {
            j = 0;
        }
        
        switch (j) {
            case 1:
            {
                //时间
                NSString *timeStr = str;
                NSArray *arr = [timeStr componentsSeparatedByString:@":"];
                if ([self isContainLimitText:arr.lastObject]) {
                    j = 0;
                    continue;
                }
                NSArray *arr1 = [arr.lastObject componentsSeparatedByString:@"."];
                //将开始时间数组中的时间换化成秒为单位的
                float teim= [arr[arr.count-2] floatValue]*60 + [arr1.firstObject floatValue] + [arr1.lastObject floatValue]/1000;
                //将float类型转化成NSNumber类型才能存入数组
                NSNumber *beginnum = [NSNumber numberWithFloat:teim];
                [begintimearray addObject:beginnum];
            }
                break;
            case 2:
            {
                NSString *nextS = [singlearray objectAtIndex:j+1];
                NSString *nextStr = [nextS stringByReplacingOccurrencesOfString:@"\r" withString:@""];;
                if ([nextStr isEqualToString:[NSString yj_Char1]]) {
                    [subtitlesarray addObject:str];
                    subStr = @"";
                }else{
                    subStr = str;
                    if ([s isEqualToString:singlearray.lastObject]) {
                        [subtitlesarray addObject:subStr];
                    }
                }
            }
                break;
            case 3:
            {
                if (str && str.length > 0) {
                    subStr = [subStr stringByAppendingFormat:@"\n%@",str];
                }
                if (subtitlesarray.count < begintimearray.count) {
                    [subtitlesarray addObject:subStr];
                }
                subStr = @"";
            }
                break;
            default:
                break;
        }
        j++;
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < begintimearray.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[begintimearray yj_objectAtIndex:i] forKey:@"beginTime"];
        [dic setObject:[subtitlesarray yj_objectAtIndex:i] forKey:@"subtitles"];
        [arr addObject:dic];
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:arr forKey:@"srtList"];
    [info setObject:@(0) forKey:@"subTitleType"];
    return info;
}
- (NSDictionary *)parseSrt:(NSString *) srt{
    if (![srt containsString:@" --> "]) {
        return @{};
    }
    NSArray *singlearray = [srt componentsSeparatedByString:@"\n"];
    NSMutableArray *begintimearray = [NSMutableArray array];
    NSMutableArray *endtimearray = [NSMutableArray array];
    NSMutableArray *subtitlesarray = [NSMutableArray array];
    NSString *subStr = @"";
    int j = 0;
    for (NSString *s in singlearray) {
        NSString *str = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        if ([str containsString:@" --> "]) {
            j = 0;
        }
        switch (j) {
            case 0:
            {
                //时间
                NSString *timeStr = str;
                NSRange range = [timeStr rangeOfString:@" --> "];
                if (range.location != NSNotFound) {
                    NSString *beginstr = [timeStr substringToIndex:range.location];
                    NSString *endstr = [timeStr substringFromIndex:range.location+range.length];
                    NSArray *arr = [beginstr componentsSeparatedByString:@":"];
                    NSArray *arr1 = [arr[2] componentsSeparatedByString:@","];
                    //将开始时间数组中的时间换化成秒为单位的
                    float teim=[arr[0] floatValue] * 60*60 + [arr[1] floatValue]*60 + [arr1[0] floatValue] + [arr1[1] floatValue]/1000;
                    //将float类型转化成NSNumber类型才能存入数组
                    NSNumber *beginnum = [NSNumber numberWithFloat:teim];
                    [begintimearray addObject:beginnum];
                    NSArray * array = [endstr componentsSeparatedByString:@":"];
                    NSArray * arr2 = [array[2] componentsSeparatedByString:@","];
                    //将结束时间数组中的时间换化成秒为单位的
                    float fl=[array[0] floatValue] * 60*60 + [array[1] floatValue]*60 + [arr2[0] floatValue] + [arr2[1] floatValue]/1000;
                    NSNumber *endnum = [NSNumber numberWithFloat:fl];
                    [endtimearray addObject:endnum];
                }
            }
                break;
            case 1:
                subStr = str;
                if ([s isEqualToString:singlearray.lastObject]) {
                    [subtitlesarray addObject:subStr];
                }
                break;
            case 2:
                if (str && str.length > 0) {
                    subStr = [subStr stringByAppendingFormat:@"\n%@",str];
                }
                [subtitlesarray addObject:subStr];
                subStr = @"";
                break;
            default:
                break;
        }
        j++;
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < begintimearray.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[begintimearray yj_objectAtIndex:i] forKey:@"beginTime"];
        [dic setObject:[endtimearray yj_objectAtIndex:i] forKey:@"endTime"];
        [dic setObject:[subtitlesarray yj_objectAtIndex:i] forKey:@"subtitles"];
        [arr addObject:dic];
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:arr forKey:@"srtList"];
    [info setObject:@(1) forKey:@"subTitleType"];
    return info;
}

- (BOOL)isContainLimitText:(NSString *)text{
    if (text && text.length > 0) {
        BOOL isContain = NO;
        
        for (int i=0; i < text.length; i++) {
            NSRange range = NSMakeRange(i, 1);
            NSString *strFromSubStr = [text substringWithRange:range];
            if (![self predicateMatchWithText:strFromSubStr matchFormat:@"^[0-9.]$"]) {
                isContain = YES;
                
                break;
            }
        }
        return isContain;
        
    }
    return YES;
}

- (BOOL)predicateMatchWithText:(NSString *) text matchFormat:(NSString *) matchFormat{
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", matchFormat];
    return [predicate evaluateWithObject:text];
}
@end
