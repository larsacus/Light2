//
//  Light_AppDelegate.m
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Light_AppDelegate.h"

#import "Light_ViewController.h"

@implementation Light_AppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;
@synthesize torch = _torch;
@synthesize hasFlash = _hasFlash;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     
    if ([self.window respondsToSelector:@selector(setRootViewController)]) {
        self.window.rootViewController = self.viewController;
    }
    else{
        [self.window addSubview:self.viewController.view];
    }
    
    if ([AVCaptureSession class] && 
        [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] hasFlash]
        ) {
        _torch = [[LATorch alloc] initWithTorchOn:YES];
        [self setHasFlash:YES];
    }
    else{
        [self setHasFlash:NO];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [(Light_ViewController *)[self viewController] randomizeBackgroundAnimated:YES];
    
#if !TARGET_IPHONE_SIMULATOR
	if (![self torch]) {
		NSLog(@"Starting flashlight session");
		_torch = [[LATorch alloc] initWithTorchOn:YES];
	}
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [_torch release];
    
    [super dealloc];
}

@end
