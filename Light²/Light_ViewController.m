//
//  Light_ViewController.m
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Light_ViewController.h"
#import "Light_AppDelegate.h"

#define kTransitionDuration 1.5

@implementation Light_ViewController

@synthesize imageView = _imageView;
@synthesize transitionView = _transitionView;
@synthesize imagesArray = _imagesArray;


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
    
    if ([(Light_AppDelegate *)[[UIApplication sharedApplication] delegate] hasFlash]){
        //device has flash
        //init array with dark images
        _imagesArray = [[NSMutableArray alloc] initWithObjects:
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
        _imagesArray = [[NSMutableArray alloc] initWithObjects:
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
        //NSLog(@"image name: %@", [[self imagesArray] objectAtIndex:rand]);
        [[self transitionView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[[self imagesArray] objectAtIndex:rand]]]];
        //[[self imageView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[[self imagesArray] objectAtIndex:rand]]]];
        
        //[[self imageView] setBackgroundColor:[UIColor redColor]];
        //[[self transitionView] setBackgroundColor:[UIColor blueColor]];
        
        
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
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(imageFadeOutAnimationDidStop:)];
            
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

- (void)imageFadeOutAnimationDidStop:(id)sender{
    //set main image to transition image
    [[self imageView] setBackgroundColor:[[self transitionView] backgroundColor]];
    
    //set transition image opacity to 0% to prep for new image
    [[self transitionView] setAlpha:0.0f];
    [[self transitionView] setBackgroundColor:nil];
}

@end
