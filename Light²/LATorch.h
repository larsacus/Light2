//
//  LATorch.h
//  Light²
//
//  Created by Lars Anderson on 6/4/11.
//  Copyright 2011 Lars Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LATorch : NSObject {
    
@private
#if !TARGET_IPHONE_SIMULATOR
    AVCaptureSession *_torchSession;
    AVCaptureDevice *_torchDevice;
    AVCaptureDeviceInput *_torchDeviceInput;
    AVCaptureOutput *_torchOutput;
#endif
    
}

#if !TARGET_IPHONE_SIMULATOR
@property (nonatomic, retain) AVCaptureSession *torchSession;
@property (nonatomic, retain) AVCaptureDevice *torchDevice;
@property (nonatomic, retain) AVCaptureDeviceInput *torchDeviceInput;
@property (nonatomic, retain) AVCaptureOutput *torchOutput;
#endif

- (id)initWithTorchOn:(BOOL)torchOn;
- (void)setTorchOn:(BOOL)torchOn;
- (BOOL)isTorchOn;
- (BOOL)isInturrupted;
- (void)createNewTorchSessionWithTorchOn:(BOOL)torchOn;
- (void)verifyTorchSubsystemsWithTorchOn:(BOOL)torchOn;

@end
