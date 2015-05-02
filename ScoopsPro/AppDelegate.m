//
//  AppDelegate.m
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/25/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

#import "AppDelegate.h"
#import "MXWScoopFeed.h"
#import "MXWViewController.h"
#import "MXWScoop.h"
#import "MXWScoopsTableViewController.h"
@import UIKit;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    MXWScoopFeed * sf = [[MXWScoopFeed alloc] init];
    
    MXWScoopsTableViewController* stVC = [[MXWScoopsTableViewController alloc] initWithModel:sf];
    
    MXWScoop * fScoop = [[MXWScoop alloc] init];
    
    MXWViewController * sVC = [[MXWViewController alloc] initWithScoopFeeder:sf andModel:fScoop];
    
    UINavigationController * sp1Nav = [UINavigationController new];
    [sp1Nav pushViewController:stVC animated:NO];
    
    UINavigationController * sp2Nav = [UINavigationController new];
    [sp2Nav pushViewController:sVC animated:NO];
    
    UISplitViewController * spVC = [UISplitViewController new];
    spVC.viewControllers = @[sp1Nav,sp2Nav];
    
    spVC.delegate = sVC;
    stVC.delegate = sVC;
    
    self.window = [[UIWindow alloc] initWithFrame:
                   [[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = spVC;
    
    [self.window makeKeyAndVisible];
    
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
