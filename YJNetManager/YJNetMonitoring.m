//
//  YJNetMonitoring.m
//  YJNetManagerDemo
//
//  Created by 刘亚军 on 2019/3/18.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJNetMonitoring.h"
#import <AFNetworking/AFNetworking.h>

#import <netdb.h>
#import <arpa/inet.h>

@implementation YJNetMonitoring
+ (YJNetMonitoring *)shareMonitoring{
    static YJNetMonitoring * macro = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        macro = [[YJNetMonitoring alloc]init];
    });
    return macro;
}
- (void)netMonitoring{
    [self checkNetCanUseWithComplete:nil];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                self.netStatus = YJNetMonitoringStatusReachableViaWWAN;
                NSLog(@"使用手机网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                self.netStatus = YJNetMonitoringStatusReachableViaWiFi;
                NSLog(@"使用WIFI");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                self.netStatus = YJNetMonitoringStatusNotReachable;
                NSLog(@"没有网络");
                break;
            default:
                self.netStatus = YJNetMonitoringStatusUnknown;
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)checkNetCanUseWithComplete:(void (^)(void))complete{
    if ((self.apiUrl && self.apiUrl.length > 0) && ![self.apiUrl containsString:@"com"] && ![self.apiUrl containsString:@"cn"]) {
        NSString *apiUrl = [self.apiUrl componentsSeparatedByString:@"//"].lastObject;
        apiUrl = [apiUrl stringByReplacingOccurrencesOfString:@"/" withString:@""];
        apiUrl = [apiUrl componentsSeparatedByString:@":"].firstObject;
        const char * a = [apiUrl UTF8String];
        unsigned int ipNum = str2intIP(a);

        unsigned int aBegin = str2intIP("10.0.0.0");
        unsigned int aEnd = str2intIP("10.255.255.255");
        unsigned int bBegin = str2intIP("172.16.0.0");
        unsigned int bEnd = str2intIP("172.31.255.255");
        unsigned int cBegin = str2intIP("192.168.0.0");
        unsigned int cEnd = str2intIP("192.168.255.255");

        bool isInnerIp = IsInner(ipNum, aBegin, aEnd) || IsInner(ipNum, bBegin, bEnd) || IsInner(ipNum, cBegin, cEnd);
        //( (a_ip>>24 == 0xa) || (a_ip>>16 == 0xc0a8) || (a_ip>>22 == 0x2b0) )
        if(isInnerIp){
            //内网
            self.networkCanUseState = 2;
        }else{
            //外网
            self.networkCanUseState = 1;
        }
        if (complete) {
            complete();
        }
        return;
    }
    NSString *urlString = @"http://captive.apple.com/";
    NSURL *requestUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.timeoutInterval = 8;
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            weakSelf.networkCanUseState = 0;
            if (complete) {
                complete();
            }
            NSLog(@"手机无法访问互联网");
        }else{
            NSString* result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //解析html页面
            NSString *htmlString = [weakSelf filterHTML:result];
            //除掉换行符
            NSString *resultString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if ([resultString isEqualToString:@"SuccessSuccess"]) {
                weakSelf.networkCanUseState = 1;
                NSLog(@"手机所连接的网络是可以访问互联网的");
            }else {
                weakSelf.networkCanUseState = 2;
                NSLog(@"手机无法访问互联网");
            }
            if (complete) {
                complete();
            }
        }
    }] resume];
}

- (NSString *)filterHTML:(NSString *)html {
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    }
    return html;
}


unsigned int str2intIP(char* strip) {
    unsigned int intIP;
    if(!(intIP = inet_addr(strip)))
    {
        perror("inet_addr failed./n");
        return -1;
    }
    return ntohl(intIP);
}

bool IsInner(unsigned int userIp, unsigned int begin, unsigned int end){
    return (userIp >= begin) && (userIp <= end);
}
@end
