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
    
@private
    NSMutableArray *_lightImagesArray;
    NSMutableArray *_darkImagesArray;
}

@property (nonatomic,assign) UIImageView *imageView;
@property (nonatomic,assign) UIImageView *transitionView;

//privates
@property (nonatomic,retain) NSMutableArray *lightImagesArray;
@property (nonatomic,retain) NSMutableArray *darkImagesArray;

- (void)randomizeBackgroundAnimated:(BOOL)animated;

@end
