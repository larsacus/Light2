//
//  Light_ViewController.h
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Light_ViewController : UIViewController {
    IBOutlet UIImageView *_imageView;
    IBOutlet UIImageView *_transitionView;
    IBOutlet UIView *_lowBatteryIndicatorView;
    IBOutlet UILabel *_lowBatteryText;
    
@private
    NSArray *_imagesArray;
    BOOL _batteryIndicatorTapped;
}

@property (nonatomic,assign) UIImageView *imageView;
@property (nonatomic,assign) UIImageView *transitionView;
@property (nonatomic,assign) UIView *lowBatteryIndicatorView;
@property (nonatomic,assign) UILabel *lowBatteryText;

//privates
@property (nonatomic,retain) NSArray *imagesArray;
@property (nonatomic) BOOL batteryIndicatorTapped;

- (void)randomizeBackgroundAnimated:(BOOL)animated;
- (void)setLowBatteryAnimation:(BOOL)shouldAnimate;
- (void)batteryStateChanged;
- (void)handleLowBatteryAlertTap;

@end
