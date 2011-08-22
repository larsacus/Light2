//
//  Light_AppDelegate.m
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 Lars Anderson, drink&apple. All rights reserved.
//

#import "Light_AppDelegate.h"
#import "Light_ViewController.h"
#import "FlurryAPI.h"

@implementation Light_AppDelegate


@synthesize window=_window;

@synthesize viewController          =_viewController;
@synthesize torch                   = _torch;
@synthesize hasFlash                = _hasFlash;
@synthesize isBackgrounded          = _isBackgrounded;
@synthesize willBackground          = _willBackground;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //FIXME: [FlurryAPI startSession:@"ZQLF8RG2A9S4KI67JIDG"];//production (Light² Free)
    [FlurryAPI startSession:@"E4WRQESDZD4UQFCBBZL5"];//dev
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    if ([AVCaptureSession class] && 
        [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] hasFlash]
        ) {
        [self createNewTorchSession];
        [self setHasFlash:YES];
        [FlurryAPI logEvent:@"User Configuration" withParameters:[NSDictionary dictionaryWithObject:@"Yes" forKey:@"Has Flash?"]];
    }
    else{
        [self setHasFlash:NO];
        [FlurryAPI logEvent:@"User Configuration" withParameters:[NSDictionary dictionaryWithObject:@"No" forKey:@"Has Flash?"]];
    }
    
    if ([self.window respondsToSelector:@selector(setRootViewController)]) {
        self.window.rootViewController = self.viewController;
    }
    else{
        [self.window addSubview:self.viewController.view];
    }
    
    [self setIsBackgrounded:NO];
    [self setWillBackground:NO];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [self setWillBackground:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [self setIsBackgrounded:YES];
    [[[self viewController] lowBatteryIndicatorView] setAlpha:0.0f];
    [(Light_ViewController *)[self viewController] setBatteryIndicatorTapped:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
//    NSLog(@":: Application Will Enter Foreground");
//    NSLog(@"isSwapped? %@", [[self viewController] isSwapped] ? @"YES" : @"NO");
//    NSLog(@"isBackgrounded? %@", [self isBackgrounded]  ? @"YES" : @"NO");
    
    //fully backgrounded
    if ([self isBackgrounded]) {
        #if !TARGET_IPHONE_SIMULATOR
            if ([self hasFlash] && ![[self viewController] isSwapped]) {
                if (![self torch]) {
                    [self createNewTorchSession];
                }
                else{
                    [[self torch] setTorchOn:YES];
                }
            }
        #endif
        [[self viewController] setLowBatteryAnimation:YES];
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    //in a transition state, but not fully backgrounded yet
    if ([self willBackground] && ![self isBackgrounded]) {
#if !TARGET_IPHONE_SIMULATOR
        if ([self hasFlash] && ![[self viewController] isSwapped]) {
            if (![self torch]) {
                [self createNewTorchSession];
            }
            else{
                [[self torch] setTorchOn:YES];
            }
        }
#endif
    }
    else if(![self isBackgrounded]){
        //setup battery observers when app is launched for the first time only
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:[self viewController] selector:@selector(batteryStateChanged) name:@"UIDeviceBatteryLevelDidChangeNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:[self viewController] selector:@selector(batteryStateChanged) name:@"UIDeviceBatteryStateDidChangeNotification" object:nil];
    }
    
    if ([self isBackgrounded] || [self willBackground]) {
        [[self viewController] randomizeBackgroundAnimated:YES withDuration:1.5f];
    }
    
    [[self viewController] batteryStateChanged];
    [self setWillBackground:NO];
    [self setIsBackgrounded:NO];
}

- (void)createNewTorchSession{
    _torch = [[LARSTorch alloc] initWithTorchOn:YES];
    [[self torch] setDelegate:self];
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
    [[NSNotificationCenter defaultCenter] removeObserver:[self viewController] name:@"UIDeviceBatteryLevelDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:[self viewController] name:@"UIDeviceBatteryStateDidChangeNotification" object:nil];
    
    [_window release];
    [_viewController release];
    [_torch release];
    
    [super dealloc];
}

@end
