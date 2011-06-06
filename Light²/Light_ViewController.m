//
//  Light_ViewController.m
//  Light²
//
//  Created by Lars Anderson on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Light_ViewController.h"

#define kTransitionDuration 0.7

@implementation Light_ViewController

@synthesize imageView = _imageView;
@synthesize transitionView = _transitionView;
@synthesize lightImagesArray = _lightImagesArray;
@synthesize darkImagesArray = _darkImagesArray;

- (void)dealloc
{
    [_lightImagesArray release];
    
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
    
    _lightImagesArray = [[NSMutableArray alloc] initWithObjects:
                         @"45degree_fabric",
                         @"fabric_1",
                         @"white_carbon",
                         @"leather_1",
                         @"paper_1",
                         @"white_sand",
                         @"exclusive_paper",
                         @"60degree_gray",
                         @"smooth_wall",
                         @"pinstripe",
                         @"handmadepaper",
                         @"rockywall",
                         @"double_lined",
                         @"light_honeycomb",
                         nil];
    
    [self randomizeBackgroundAnimated:NO];
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
    
    int rand = arc4random() % [[self lightImagesArray] count];
    
    if (animated) {
        //change transition image
        [[self transitionView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[[self lightImagesArray] objectAtIndex:rand]]]];
        
        [UIView animateWithDuration:kTransitionDuration
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
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
        [[self imageView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[[self lightImagesArray] objectAtIndex:rand]]]];
    }
    
    [pool drain];
}

@end
