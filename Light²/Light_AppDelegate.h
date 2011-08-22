//
//  Light_AppDelegate.h
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 Lars Anderson, drink&apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LARSTorch.h"

@class Light_ViewController;

@interface Light_AppDelegate : NSObject <UIApplicationDelegate> {
    LARSTorch *_torch;
    BOOL _hasFlash;
    BOOL _isBackgrounded;
    BOOL _willBackground;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Light_ViewController *viewController;
@property (nonatomic, retain) LARSTorch *torch;
@property (nonatomic, assign) BOOL hasFlash;
@property (nonatomic, assign) BOOL isBackgrounded;
@property (nonatomic, assign) BOOL willBackground;

- (void)createNewTorchSession;

@end
