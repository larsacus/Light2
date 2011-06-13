//
//  Light_ViewController.m
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Light_ViewController.h"
#import "Light_AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define kTransitionDuration 1.5

@implementation Light_ViewController

@synthesize imageView = _imageView;
@synthesize transitionView = _transitionView;
@synthesize imagesArray = _imagesArray;
@synthesize lowBatteryIndicatorView = _lowBatteryIndicatorView;
@synthesize lowBatteryText = _lowBatteryText;
@synthesize batteryIndicatorTapped = _batteryIndicatorTapped;


- (void)dealloc
{
    [_imagesArray release];
    
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
    //[[UIScreen mainScreen] setBrightness:0.1f]; //sets screen brightness to 10%
    
    //configure low battery indicator view
    if ([(Light_AppDelegate *)[[UIApplication sharedApplication] delegate] hasFlash]) {
        //no flash - make dark-colored scheme for alert
        [[[self lowBatteryIndicatorView] layer] setBackgroundColor:[[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.25f] CGColor]];
    }
    else{
        //has flash - make light-colored scheme for alert
        [[[self lowBatteryIndicatorView] layer] setBackgroundColor:[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f] CGColor]];
    }
    [[[self lowBatteryIndicatorView] layer] setCornerRadius:10.0f];
    [[self lowBatteryText] setText:NSLocalizedString(@"Low Battery", @"Low battery indicator text")];
    [[self lowBatteryText] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    
    if ([(Light_AppDelegate *)[[UIApplication sharedApplication] delegate] hasFlash]){
        //device has flash
        //init array with dark images
        _imagesArray = [[NSArray alloc] initWithObjects:
                        @"carbon_fibre.png",
                        @"tactile_noise.png",
                        @"black_denim.png",
                        @"dark_stripes.png",
                        @"wood_1.png",
                        @"black_paper.png",
                        @"blackmamba.png",
                        @"padded.png",
                        @"black_linen.png",
                        @"random_grey_variations.png",
                        nil];
    }
    else{
        //device has no flash
        //init with light images
        _imagesArray = [[NSArray alloc] initWithObjects:
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
    }
    [self randomizeBackgroundAnimated:NO];
    
    //setup tap gesture recognizer for low battery alert
    if (NSClassFromString(@"UIGestureRecognizer")) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLowBatteryAlertTap)];
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];

        [[self lowBatteryIndicatorView] setGestureRecognizers:[NSArray arrayWithObject:tapGesture]];
        
        [tapGesture release];
    }
    
    [self setBatteryIndicatorTapped:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)randomizeBackgroundAnimated:(BOOL)animated{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int rand = arc4random() % [[self imagesArray] count];
    
    if (animated) {
        //change transition image
        [[self transitionView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[[self imagesArray] objectAtIndex:rand]]]];
        
        
        if (NSClassFromString(@"NSBlockOperation")) {
            NSLog(@"Using block animations");
            [UIView animateWithDuration:kTransitionDuration
                                  delay:0.0 
                                options:UIViewAnimationOptionCurveEaseIn 
                             animations:^{
                                 //fade in transition image to opaque
                                 [[self transitionView] setAlpha:1.0f];
                             }
                             completion:^(BOOL finished){
                                 //set main image to transition image
                                 [[self imageView] setBackgroundColor:[[self transitionView] backgroundColor]];
                                 
                                 //set transition image opacity to 0% to prep for new image
                                 [[self transitionView] setAlpha:0.0f];
                                 [[self transitionView] setBackgroundColor:nil];
                             }
             ];
        }
        else{
            NSLog(@"Using UIView animations without blocks");
            //system cannot use block animations, use older non-block animations instead
            [UIView beginAnimations:@"image_transition" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:kTransitionDuration];
            
            [[self transitionView] setAlpha:1.0f];
            
            [UIView commitAnimations];
        }
    }
    else{
        //NSLog(@"image name: %@", [[self imagesArray] objectAtIndex:rand]);
        [[self imageView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[[self imagesArray] objectAtIndex:rand]]]];
    }
    
    [pool drain];
}

- (void)setLowBatteryAnimation:(BOOL)shouldAnimate{
    //[[self lowBatteryIndicatorView] setAlpha:1.0f];
    
    if (shouldAnimate && ![self batteryIndicatorTapped]) {
        if (NSClassFromString(@"NSBlockOperation")) {
            //animate with blocks
            [UIView animateWithDuration:kTransitionDuration 
                                  delay:1.0f 
                                options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 [[self lowBatteryIndicatorView] setAlpha:0.75f];
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
            
            [[self lowBatteryIndicatorView] setAlpha:0.75f];
            
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
    [self setLowBatteryAnimation:NO];
    [self setBatteryIndicatorTapped:YES];
    /*if ([[UIApplication sharedApplication] isIdleTimerDisabled]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }*/
}

- (void)batteryStateChanged{
    //set battery warning animation when battery is 10% or less and unplugged
    if ([[UIDevice currentDevice] batteryLevel] <= 0.15 &&
        [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        //set battery warning animation
        [self setLowBatteryAnimation:YES];
    }
    else{
        [self setLowBatteryAnimation:NO];
    }
    
    //turn off idle timer if battery is 5% or less and device is unplugged
    if ([[UIDevice currentDevice] batteryLevel] <= 0.10 &&
        [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    else{
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

@end
