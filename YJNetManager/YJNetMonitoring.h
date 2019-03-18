//
//  YJNetMonitoring.h
//  YJNetManagerDemo
//
//  Created by 刘亚军 on 2019/3/18.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, YJNetMonitoringStatus) {
    YJNetMonitoringStatusUnknown          = -1,
    YJNetMonitoringStatusNotReachable     = 0,
    YJNetMonitoringStatusReachableViaWWAN = 1,
    YJNetMonitoringStatusReachableViaWiFi = 2,
};
@interface YJNetMonitoring : NSObject
/** 是否外网 0-连接失败,1-外网，2-内网*/
@property (nonatomic,assign) NSInteger networkCanUseState;
/** 网络状态 */
@property (nonatomic,assign) YJNetMonitoringStatus netStatus;
/** 基础地址 */
@property (nonatomic,copy) NSString *apiUrl;

+ (YJNetMonitoring *)shareMonitoring;

/** 网络监控 */
- (void)netMonitoring;

/** 检测是否为外网 */
- (void)checkNetCanUseWithComplete:(nullable void (^) (void))complete;
@end

NS_ASSUME_NONNULL_END
