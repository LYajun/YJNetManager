//
//  ViewController.m
//  YJNetManagerDemo
//
//  Created by 刘亚军 on 2019/3/16.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "ViewController.h"
#import <Reachability/Reachability.h>

@interface ViewController ()
@property (nonatomic) Reachability *hostReachability;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReachability = [Reachability reachabilityWithHostName:@"http://www.stkouyu.com/"];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
}

- (void) reachabilityChanged:(NSNotification *)note{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}
- (void)updateInterfaceWithReachability:(Reachability *)reachability{
    if (reachability == self.hostReachability){
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        switch (netStatus){
            case NotReachable: {
                
                NSLog(@"ViewController : 没有网络！");
                break;
            }
            case ReachableViaWWAN: {
                
                NSLog(@"ViewController : 4G/3G");
                break;
            }
            case ReachableViaWiFi: {
                
                NSLog(@"ViewController : WiFi");
                break;
            }
        }
    }
}
@end
