/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

#import "DSCaptureEnhancer.h"
#import <AVFoundation/AVFoundation.h>

@interface DSCaptureEnhancer () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation DSCaptureEnhancer

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpCamera];
    }
    return self;
}

- (void)setUpCameraView:(nonnull UIView *)view {
    self.previewLayer.frame = view.bounds;
    [view.layer addSublayer:self.previewLayer];
}

- (void)startRunning {
    if (![self.session isRunning]) {
        dispatch_async(self.queue, ^{
            [self.session startRunning];
        });
        [self setImageFetchState:true];
    }
}

- (void)stopRunning {
    if ([self.session isRunning]) {
        dispatch_async(self.queue, ^{
            [self.session stopRunning];
        });
        [self setImageFetchState:false];
        [self clearBuffer];
    }
}

- (void)setUpCamera {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        NSError *error;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (input && !error) {
            if ([self.session canAddInput:input]) {
                [self.session addInput:input];
            }
        } else {
            NSLog(@"error: %@", error.description);
        }
    } else {
        NSLog(@"defaultDeviceWithMediaType wrong");
    }
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    [output setSampleBufferDelegate:self queue:self.queue];
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    NSData *buffer = [NSData dataWithBytes:baseAddress length:bufferSize];
    
    DSImageData *imageData = [[DSImageData alloc] initWithBytes:buffer width:width height:height stride:bytesPerRow format:DSImagePixelFormatARGB8888 orientation:0 tag:nil];
    [self addImageToBuffer:imageData];
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    return _session;
}

- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("queue", nil);
    }
    return _queue;
}

@end
