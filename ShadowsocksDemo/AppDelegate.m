//
//  AppDelegate.m
//  ShadowsocksDemo
//
//  Created by Jason Hsu on 15/7/2.
//  Copyright (c) 2015年 Jason Hsu. All rights reserved.
//

#import "AppDelegate.h"
#import "SSProxyProtocol.h"
#import "ShadowsocksClient.h"

static ShadowsocksClient *proxy;

@interface AppDelegate ()

@end

@implementation AppDelegate

/*
 ⚠️我觉得要看懂，需要掌握的知识有：unix socket编程、加密技术、tcp/ip详解
 1、流量代理在这个例子里面的思路是将所有流量导入到规定的端口发出去；
 2、再监听这个给定的端口，监听之后经过这个端口的流量可以拿到；
 3、一开始向给定的端口发送自己构造的数据，告诉应该该端口发送的数据应该以什么协议版本和方法发送；
 4、紧接着，app的请求发出，请求数据被拦截，加密，然后连接代理服务器的socket，在连接成功之后会将之前拦截并加密的数据发出去；
 5、因为这个地方将本地发送的数据拦截了，所以需要自己构造一个数据，形成一个fake reply回复一下客户端（至于为什么要回复，请参考sock5的RFC 说得挺清楚的）。
 6、接下来就是等待代理服务器那边的回复了，回复过来的数据解密然后发给10800端口。
 */


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //实例化一个shadowsocks client类，并赋予类的一些属性
    proxy = [[ShadowsocksClient alloc] initWithHost:<your ip>
                                               port:443
                                           password:@"ByzSbH880f"
                                             method:@"aes-256-cfb"];
    //proxy类是NSURLProtocol的子类，,处理socket的accept和bind()等事件及其回调
    //proxy可以将流量导到代理服务器上去
    [proxy startWithLocalPort:10800];
    //ssproxyProtocal是NSURLProtocol的子类，里面规定了所有请求应该走的端口，并在这个类里面调用代理的回调通知上一级
    [SSProxyProtocol setLocalPort:10800];
    [NSURLProtocol registerClass:[SSProxyProtocol class]];
    
    //一旦有请求，会先走SSProxyProtocol，SSProxyProtocol会将流量导向自己规定的10800端口，在10800端口上会有一个socket代理，会将流量加密然后发出去。
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
