//
//  LATorch.m
//  Light²
//
//  Created by Lars Anderson on 6/4/11.
//  Copyright 2011 Lars Anderson. All rights reserved.
//

#import "LATorch.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation LATorch

@synthesize torchSession = _torchSession;
@synthesize torchDevice = _torchDevice;
@synthesize torchDeviceInput = _torchDeviceInput;
@synthesize torchOutput = _torchOutput;

- (id)init{
    return [self initWithTorchOn:NO];
}

- (id)initWithTorchOn:(BOOL)torchOn{
    self = [super init];
    if(self){
        [self createNewTorchSessionWithTorchOn:torchOn];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(flashlightSessionResumeFromInturrupt) 
                                                 name:AVCaptureSessionInterruptionEndedNotification
                                               object:nil
     ];
    
    return self;
}

- (BOOL)isTorchOn{
    return  [[self torchSession] isRunning] && 
            ([[self torchDevice] torchMode] == AVCaptureTorchModeOn) &&
            ([[self torchDevice] flashMode] == AVCaptureFlashModeOn);
}

- (BOOL)isInturrupted{
    return [[self torchSession] isInterrupted];
}

- (void)setTorchOn:(BOOL)torchOn{
    NSError *lockError = nil;
    if(![[self torchDevice] lockForConfiguration:&lockError]){
        
        /*//Fetches exact model code of device for logging
        //http://stackoverflow.com/questions/1108859/detect-the-specific-iphone-ipod-touch-model
        //
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        //REPORT MACHINE MODEL TO ANALYTICS
        free(machine);*/
        NSLog(@"Lock error: %@", [lockError localizedDescription]);
    }
    
    [[self torchSession] beginConfiguration];
    
    if (![[[self torchSession] inputs] containsObject:[self torchDeviceInput]]) {
        [[self torchSession] addInput:[self torchDeviceInput]];
    }
    
    if (![[[self torchSession] outputs] containsObject:[self torchOutput]]) {
        [[self torchSession] addOutput:[self torchOutput]];
    }
    
    if (torchOn) {
        [[self torchDevice] setTorchMode:AVCaptureTorchModeOn];
        [[self torchDevice] setFlashMode:AVCaptureFlashModeOn];
    }
    else {
        [[self torchDevice] setTorchMode:AVCaptureTorchModeOff];
        [[self torchDevice] setFlashMode:AVCaptureFlashModeOff];
    }
    
    [[self torchDevice] unlockForConfiguration];
    
    [[self torchSession] commitConfiguration];
}

- (void)createNewTorchSessionWithTorchOn:(BOOL)torchOn{
    if (![self torchSession]) {
        _torchDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([[self torchDevice] hasTorch] && [[self torchDevice] hasFlash]){
            NSError *deviceError = nil;
            
            _torchDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[self torchDevice] error: &deviceError];
            
            //light does not function without capture output
            _torchOutput = [[AVCaptureVideoDataOutput alloc] init];
        
            _torchSession = [[AVCaptureSession alloc] init];
            
            [[self torchSession] setSessionPreset:AVCaptureSessionPresetLow];
            [self setTorchOn:YES];
            
            [[self torchSession] startRunning];
        }
    }
}

- (void)verifyTorchSubsystemsWithTorchOn:(BOOL)torchOn{
    //session
    if (![self torchDevice]) {
        _torchDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    if ([[self torchDevice] hasTorch] && [[self torchDevice] hasFlash]){
        if (![self torchDeviceInput]) {
            NSError *deviceError = nil;
            
            _torchDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[self torchDevice] error: &deviceError];
        }
        
        //light does not function without capture output
        if (![self torchOutput]) {
            _torchOutput = [[AVCaptureVideoDataOutput alloc] init];
        }
        
        //check if torch session is functioning properly
        if (![self torchSession]) {
            _torchSession = [[AVCaptureSession alloc] init];
            
            //verify session preset
            [[self torchSession] setSessionPreset:AVCaptureSessionPresetLow];
            [self setTorchOn:torchOn];
            
            [[self torchSession] startRunning];
        }
        else{//torch session is running, verify session subsystems
            [[self torchSession] setSessionPreset:AVCaptureSessionPresetLow];
            if ([self isTorchOn] != torchOn) {
                [self setTorchOn:torchOn];
            }
            if (![[self torchSession] isRunning]) {
                [[self torchSession] startRunning];
            }
        }
    }
}

-(void)flashlightSessionResumeFromInturrupt{
	//NSLog(@"Flashlight is resuming from inturruption");
    [self verifyTorchSubsystemsWithTorchOn:YES];
}

- (void)dealloc{
    [_torchDevice release];
    [_torchDeviceInput release];
    [_torchOutput release];
    
    if ([[self torchSession] isRunning]) {
        [[self torchSession] stopRunning];
    }
    [_torchSession release];
    
    [super dealloc];
}

@end
