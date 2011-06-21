//
//  Light_ViewController.h
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Light_AppDelegate.h"

@interface Light_ViewController : UIViewController <UIGestureRecognizerDelegate> {
    IBOutlet UIImageView *_imageView;
    IBOutlet UIImageView *_transitionView;
    IBOutlet UIView *_lowBatteryIndicatorView;
    IBOutlet UILabel *_lowBatteryText;
    IBOutlet UILabel *_tapHintLabel;
    
@private
    NSArray *_darkImagesArray;
    NSArray *_lightImagesArray;
    BOOL _batteryIndicatorTapped;
    BOOL _swapped;
    BOOL _canSwap;
    int _tapCount;
}

@property (nonatomic,assign) UIImageView *imageView;
@property (nonatomic,assign) UIImageView *transitionView;
@property (nonatomic,assign) UIView *lowBatteryIndicatorView;
@property (nonatomic,assign) UILabel *lowBatteryText;
@property (nonatomic,assign) UILabel *tapHintLabel;

//privates
@property (nonatomic,retain) NSArray *darkImagesArray;
@property (nonatomic,retain) NSArray *lightImagesArray;
@property (nonatomic) BOOL batteryIndicatorTapped;
@property (nonatomic, getter = isSwapped) BOOL swapped;
@property (nonatomic) BOOL canSwap;
@property (nonatomic) int tapCount;

- (Light_AppDelegate *)delegate;
- (void)randomizeBackgroundAnimated:(BOOL)animated withDuration:(float)duration;
- (void)setLowBatteryAnimation:(BOOL)shouldAnimate;
- (void)batteryStateChanged;
- (void)handleLowBatteryAlertTap;
- (void)swapLightType;
- (void)showDoubleTapHintAnimated:(BOOL)animated;

@end
