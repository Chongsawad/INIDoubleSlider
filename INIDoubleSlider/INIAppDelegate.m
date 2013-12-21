//
//  INIAppDelegate.m
//  INIDoubleSlider
//
//  Created by InICe on 12/21/13.
//  Copyright (c) 2013 Chongsawad. All rights reserved.
//

#import "INIAppDelegate.h"
#import "INIViewController.h"

@implementation INIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

	/*
	 * Demo
	 */
	INIViewController *viewController = [[INIViewController alloc]
										 initWithNibName:NSStringFromClass([INIViewController class])
										 bundle:nil];
	self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
