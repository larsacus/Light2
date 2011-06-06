//
//  Light_AppDelegate.h
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LATorch.h"

@class Light_ViewController;

@interface Light_AppDelegate : NSObject <UIApplicationDelegate> {
    LATorch *_torch;
    BOOL _hasFlash;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Light_ViewController *viewController;
@property (nonatomic, retain) LATorch *torch;
@property (nonatomic, assign) BOOL hasFlash;

@end
