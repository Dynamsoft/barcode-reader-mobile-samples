//
//  ViewController.m
//  DecodeWithAVCaptureSession
//
//  Created by dynamsoft on 2022/3/21.
//

#import "ViewController.h"
#import <Photos/Photos.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    BOOL resultIsShowing;
}

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) dispatch_queue_t captureQueue;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *captureView;

@property (nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.003/255.0 green:61.9991/255.0 blue:69.0028/255.0 alpha:1]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    [self configurationDBR];
    [self setupUI];
}

- (void)configurationDBR {
    
    self.barcodeReader = [[DynamsoftBarcodeReader alloc] init];
    [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoSpeedFirst];
}

- (void)setupUI {
    [self configureSession];

    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight);
    
    self.captureView = [[UIView alloc] initWithFrame:CGRectMake(0, kNaviBarAndStatusBarHeight, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight)];
    [self.captureView.layer addSublayer:self.previewLayer];
    [self.view addSubview:self.captureView];
}

- (void)configureSession {
    [self.session beginConfiguration];
    self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    // Input
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    if([_session canAddInput:deviceInput]) {
        [_session addInput:deviceInput];
    }
    
    // Output
    if ([_session canAddOutput:self.videoOutput]) {
        [_session addOutput:self.videoOutput];
    }
    [self.session commitConfiguration];
    
    dispatch_async(self.sessionQueue, ^{
        [self.session startRunning];
    });
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (imageBuffer == nil) {
        return;
    }
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    NSData *buffer = [NSData dataWithBytes:baseAddress length:bufferSize];
    
    NSArray<iTextResult*> *result = [self.barcodeReader decodeBuffer:buffer withWidth:width height:height stride:bytesPerRow format:EnumImagePixelFormatARGB_8888 error:nil];
    [self handResults:result];
}

- (void)handResults:(NSArray<iTextResult *> *)results
{
    if (resultIsShowing) {
        return;
    }
    if (results.count > 0) {
        resultIsShowing = YES;
        NSString *title = @"Results";
        NSString *msgText = @"";
        for (NSInteger i = 0; i< [results count]; i++) {
            
            if (results[i].barcodeFormat_2 != 0) {
                msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString_2, results[i].barcodeText]];
            }else{
                msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString, results[i].barcodeText]];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msgText preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self->resultIsShowing = NO;
            }]];
            [self presentViewController:alert animated:YES completion:nil];
          
        });
    }
}

// MARK: - Lazy

- (AVCaptureSession *)session {
    if (_session == nil) {
        _session = [AVCaptureSession new];
    }
    return _session;
}

- (AVCaptureVideoDataOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoOutput.alwaysDiscardsLateVideoFrames = NO;
        _videoOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [_videoOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _videoOutput;
}

- (dispatch_queue_t)sessionQueue {
    if (_sessionQueue == NULL) {
        _sessionQueue = dispatch_queue_create("com.dynamsoft.sessionQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _sessionQueue;
}

- (dispatch_queue_t)captureQueue {
    if (_captureQueue == NULL) {
        _captureQueue = dispatch_queue_create("com.dynamsoft.captureQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}

@end
