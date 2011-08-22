//
//  Light_ViewController.m
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 Lars Anderson, drink&apple. All rights reserved.
//

#import "Light_ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FlurryAPI.h"

#define kTransitionDuration 1.5
#define kBatteryAlert 0.95
#define kBatteryCritical 0.10
#define kBatteryAlertTransparency 0.50f
#define kFastAnimationDuration 0.15f
#define kHintDisplayTime 3.0f

@implementation Light_ViewController

@synthesize imageView                   = _imageView;
@synthesize transitionView              = _transitionView;
@synthesize lowBatteryIndicatorView     = _lowBatteryIndicatorView;
@synthesize lowBatteryText              = _lowBatteryText;
@synthesize tapHintLabel                = _tapHintLabel;

@synthesize darkImagesArray             = _darkImagesArray;
@synthesize lightImagesArray            = _lightImagesArray;
@synthesize batteryIndicatorTapped      = _batteryIndicatorTapped;
@synthesize swapped                     = _swapped;
@synthesize canSwap                     = _canSwap;
@synthesize tapCount                    = _tapCount;


- (void)dealloc
{
    [_lightImagesArray release];
    
    //dark images are optionally created depending on availability of flash
    if ([self darkImagesArray]) {
        [_darkImagesArray release];
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[[UIScreen mainScreen] setBrightness:0.1f]; //sets screen brightness to 10% (iOS 5.0+ only)
    
    [[[self lowBatteryIndicatorView] layer] setCornerRadius:10.0f];
    [[self lowBatteryText] setText:NSLocalizedString(@"lowBatteryAlert", @"Low battery indicator text")];
    
    [[self tapHintLabel] setText:NSLocalizedString(@"tapHintLabel",@"Hints to users to double-tap to swap light functions")];
    
    [[self tapHintLabel] setTextColor:[UIColor blackColor]];
    [[self tapHintLabel] setShadowColor:[UIColor whiteColor]];
    [[self tapHintLabel] setShadowOffset:CGSizeMake(0.0f,-1.0f)];
    
    [self setCanSwap:NO];
    [self setSwapped:NO];
    
    if ([[self delegate] hasFlash]){
        //device has flash
        //dark images only used on devices without flash
        _darkImagesArray = [[NSArray alloc] initWithObjects:
                        @"carbon_fibre.png",
                        @"tactile_noise.png",
                        @"black_denim.png",
                        @"dark_stripes.png",
                        @"wood_1.png",
                        @"black_paper.png",
                        @"blackmamba.png",
                        @"padded.png",
                        @"black_linen.png",
                        nil];
        
        [[self tapHintLabel] setTextColor: [UIColor whiteColor]];
        [[self tapHintLabel] setShadowColor:[UIColor blackColor]];
        
        [self setCanSwap:YES];
    }
    
    //light images always created regardless of flash availability
    _lightImagesArray = [[NSArray alloc] initWithObjects:
                         @"45degree_fabric.png",
                         @"fabric_1.png",
                         @"white_carbon.png",
                         @"leather_1.png",
                         @"paper_1.png",
                         @"white_sand.png",
                         @"exclusive_paper.png",
                         @"60degree_gray.png",
                         @"smooth_wall.png",
                         @"pinstripe.png",
                         @"handmadepaper.png",
                         @"rockywall.png",
                         @"double_lined.png",
                         @"light_honeycomb.png",
                         nil];
    
    [self randomizeBackgroundAnimated:NO withDuration:kTransitionDuration];
    
    //setup tap gesture recognizer for low battery alert
    if (NSClassFromString(@"UIGestureRecognizer")) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLowBatteryAlertTap)];
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];

        [[self lowBatteryIndicatorView] setGestureRecognizers:[NSArray arrayWithObject:tapGesture]];
        
        [tapGesture release];
        
        if([self canSwap]){
            UITapGestureRecognizer *hintGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
            [hintGesture setNumberOfTapsRequired:1];
            [hintGesture setNumberOfTouchesRequired:1];
            [hintGesture setDelegate:self];
            [hintGesture setDelaysTouchesEnded:YES];
            
            UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapLightType)];
            [doubleTapGesture setNumberOfTapsRequired:2];
            [doubleTapGesture setNumberOfTouchesRequired:1];
            [doubleTapGesture setDelegate:self];
            
            //want mutually exclusive tap events (e.g. only want either single-tap or double-tap to fire, but not both)
            [hintGesture requireGestureRecognizerToFail:doubleTapGesture];
            
            [[self transitionView] setGestureRecognizers:[NSArray arrayWithObjects:doubleTapGesture, hintGesture, nil]];
            [[self imageView] setGestureRecognizers:[NSArray arrayWithObjects: doubleTapGesture, hintGesture, nil]];
            [[self transitionView] setUserInteractionEnabled:YES];
            [[self imageView] setUserInteractionEnabled:YES];
            
            [hintGesture release];
            [doubleTapGesture release];
        }
    }
    
    [self setBatteryIndicatorTapped:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (Light_AppDelegate *)delegate{
    return (Light_AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)randomizeBackgroundAnimated:(BOOL)animated withDuration:(float)duration{
//    NSLog(@"Randomizing background");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int rand;
    NSString *imageName;
    
    if ([self canSwap] && ![self isSwapped]) {
        //use dark images
        rand = arc4random() % [[self darkImagesArray] count];
        imageName = [[self darkImagesArray] objectAtIndex:rand];
    }
    else{
        //use light images
        rand = arc4random() % [[self lightImagesArray] count];
        imageName = [[self lightImagesArray] objectAtIndex:rand];
    }
    
//    NSLog(@"Image Name: %@", imageName);
    
    if (animated && NSClassFromString(@"NSBlockOperation")) {
        //change transition image
        [[self transitionView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:imageName]]];
        
        //fade in transition image
        [UIView animateWithDuration:duration
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseIn | 
                                    UIViewAnimationOptionBeginFromCurrentState | 
                                    UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             //fade in transition image to opaque
                             [[self transitionView] setAlpha:1.0f];
                         }
                         completion:^(BOOL finished){
                             //set main image to transition image
                             if (finished) {
                                 NSLog(@"Animation finished!");
                                 [[self imageView] setBackgroundColor:[[self transitionView] backgroundColor]];
                                 
                                 //set transition image opacity to 0% to prep for new image
                                 [[self transitionView] setAlpha:0.0f];
                                 [[self transitionView] setBackgroundColor:nil];
                             }
                             else{
//                                 NSLog(@"Animation did not finish!");
                             }
                             
                         }
         ];
    }
    else{
        [[self imageView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:imageName]]];
    }
    
    [pool drain];
}

#pragma mark -
#pragma mark Battery Monitors

- (void)setLowBatteryAnimation:(BOOL)shouldAnimate{
    
    if (shouldAnimate && ![self batteryIndicatorTapped]) {
        [FlurryAPI logEvent:@"Low Battery Alert Displayed"];
        if (NSClassFromString(@"NSBlockOperation")) {
            //animate with blocks
            [UIView animateWithDuration:kTransitionDuration 
                                  delay:1.0f 
                                options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 [[self lowBatteryIndicatorView] setAlpha:kBatteryAlertTransparency];
                             }
                             completion:nil
             ];
        }
        else{
            //animate without blocks
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:kTransitionDuration];
            [UIView setAnimationRepeatAutoreverses:YES];
            [UIView setAnimationRepeatCount:INFINITY];
            [UIView setAnimationDelay:1.0f];
            
            [[self lowBatteryIndicatorView] setAlpha:kBatteryAlertTransparency];
            
            [UIView commitAnimations];
        }
    }
    else{
        if (NSClassFromString(@"NSBlockOperation")) {
            [UIView animateWithDuration:kTransitionDuration/2 
                                  delay:0.0f 
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 [[self lowBatteryIndicatorView] setAlpha:0.0f];
                             }
                             completion:^(BOOL finished){
                                 [[self lowBatteryIndicatorView] setAlpha:0.0f];
                             }
             ];
        }
        else{
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:kTransitionDuration/2];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            [[self lowBatteryIndicatorView] setAlpha:0.0f];
            
            [UIView commitAnimations];
        }
    }
}

- (void)handleLowBatteryAlertTap{
    [FlurryAPI logEvent:@"Low Battery Alert Tapped"];
    [self setLowBatteryAnimation:NO];
    [self setBatteryIndicatorTapped:YES];
}

- (void)batteryStateChanged{
    //set battery warning animation when battery is 10% or less and unplugged
    if ([[UIDevice currentDevice] batteryLevel] <= kBatteryAlert &&
        [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        [self setLowBatteryAnimation:YES];
    }
    else{
        [self setLowBatteryAnimation:NO];
    }
    
    //turn off idle timer if battery is 5% or less and device is unplugged
    if ([[UIDevice currentDevice] batteryLevel] <= kBatteryCritical &&
        [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    else{
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

#pragma mark -
#pragma mark Gesture Handlers

- (void)swapLightType{
    if ([self canSwap]){
        [FlurryAPI logEvent:@"Toggling Light Mode"];
        [[[self delegate] torch] setTorchOn:[self isSwapped]];
        [[[[[self delegate] torch] delegate] torch] setTorchStateOnResume:![[[[[self delegate] torch] delegate] torch] torchStateOnResume]];
        [self setSwapped:![self isSwapped]];
        
        //swap shadow color and text color
        UIColor *tempColor = [[self tapHintLabel] textColor];
        [[self tapHintLabel] setTextColor:[[self tapHintLabel] shadowColor]];
        [[self tapHintLabel] setShadowColor:tempColor];
        
        [self randomizeBackgroundAnimated:YES withDuration:kFastAnimationDuration];
    }
}

- (void)singleTap{
    if ([self tapCount] >= 1) {
        //display double-tap hint
        [self showDoubleTapHintAnimated:YES];
        self.tapCount = 0;
        return;
    }
    self.tapCount++;
}

- (void)showDoubleTapHintAnimated:(BOOL)animated{
    [FlurryAPI logEvent:@"Double-Tap Hint Displayed"];
    if (animated) {
        if (NSClassFromString(@"NSBlockOperation")) {
            //animate with blocks
            [UIView animateWithDuration:kFastAnimationDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 [[self tapHintLabel] setAlpha:1.0f];
                             }
                             completion:^(BOOL completed){
//                                 NSLog(@"Calling timer");
                                 [UIView animateWithDuration:kHintDisplayTime
                                                       delay:0.0f
                                                     options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                                                  animations:^{
                                                      [[self tapHintLabel] setAlpha:0.0f];
                                                  }
                                                  completion:nil
                                  ];
                             }
             ];
        }
    }
    else{
        [[self tapHintLabel] setAlpha:1.0f];
        [NSTimer scheduledTimerWithTimeInterval:kHintDisplayTime
                                         target:self
                                       selector:@selector(hideDoubleTapHintAnimated)
                                       userInfo:nil
                                        repeats:NO
         ];
    }
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

@end
