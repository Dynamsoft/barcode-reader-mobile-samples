//
//  ViewController.m
//  DecodeWithAVCaptureSession
//
//  Created by dynamsoft on 2022/3/21.
//

#import "ViewController.h"
#import <Photos/Photos.h>


@interface ViewController ()<AVCapturePhotoCaptureDelegate>

@property (strong, nonatomic) dispatch_queue_t videoQueue;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieOutput;
@property (strong, nonatomic) AVCapturePhotoOutput *imageOutput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) UIView *captureView;

@property (strong, nonatomic) DynamsoftBarcodeReader *barcodeReader;

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

- (void)configurationDBR
{
    
    self.barcodeReader = [[DynamsoftBarcodeReader alloc] init];
    [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoSpeedFirst];
}

- (void)setupUI
{
    [self setupSession];

    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight);
    
    self.captureView = [[UIView alloc] initWithFrame:CGRectMake(0, kNaviBarAndStatusBarHeight, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight)];
    [self.captureView.layer addSublayer:self.previewLayer];
    [self.view addSubview:self.captureView];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self captureFrameFromCamera];
            });
        }
    }];

}

- (void)setupSession
{
    self.captureSession = [[AVCaptureSession alloc]init];
    
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // Vedio
    AVCaptureDevice *vedioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:vedioDevice error:nil];
    if (deviceInput){
        if([self.captureSession canAddInput:deviceInput]) {
            [self.captureSession addInput:deviceInput];
        }
    }
    self.movieOutput = [[AVCaptureMovieFileOutput alloc]init];
    if([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    if (@available(iOS 10.0, *)) {
        self.imageOutput = [[AVCapturePhotoOutput alloc]init];

        if ([self.captureSession canAddOutput:self.imageOutput]){
            [self.captureSession addOutput:self.imageOutput];
        }
    }else {
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];

        self.stillImageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
        if ([self.captureSession canAddOutput:self.stillImageOutput]){
            [self.captureSession addOutput:self.stillImageOutput];
        }
    }
    
    self.videoQueue = dispatch_queue_create("cc.VideoQueue", NULL);

    dispatch_async(self.videoQueue, ^{
        [self.captureSession startRunning];
    });
    
}

- (void)captureFrameFromCamera
{
    if (@available(iOS 10.0, *)) {
        AVCapturePhotoOutput * output = (AVCapturePhotoOutput *)self.imageOutput;
        AVCapturePhotoSettings * settings = [AVCapturePhotoSettings photoSettings];
        
        [output capturePhotoWithSettings:settings delegate:self];
    }else{
        AVCaptureStillImageOutput * stillImageOutput = (AVCaptureStillImageOutput *)self.stillImageOutput;

        AVCaptureConnection *connection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
            if (imageDataSampleBuffer != nil) {
                NSData * data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc]initWithData:data];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self dbrDecodeBufferWithImage:image];

                });
            }
        }];
    }
}

- (void)dbrDecodeBufferWithImage:(UIImage *)image
{
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    size_t stride = CGImageGetBytesPerRow(image.CGImage);
    size_t bpp = CGImageGetBitsPerPixel(image.CGImage);
    
    CGDataProviderRef provider = CGImageGetDataProvider(image.CGImage);
    NSData *buffer = (__bridge_transfer NSData *)CGDataProviderCopyData(provider);
    
    EnumImagePixelFormat type;
    
    switch (bpp) {
        case 1:
            type = EnumImagePixelFormatBinary;
            break;
        case 8:
            type = EnumImagePixelFormatGrayScaled;
            break;
        case 32:
            type = EnumImagePixelFormatARGB_8888;
            break;
        case 48:
            type = EnumImagePixelFormatRGB_161616;
            break;
        case 64:
            type = EnumImagePixelFormatARGB_16161616;
            break;
        default:
            type = EnumImagePixelFormatRGB_888;
            break;
    }
    
    NSError *error = nil;
    NSArray<iTextResult*>* results = [self.barcodeReader decodeBuffer:buffer withWidth:width height:height stride:stride format:type error:&error];
    [self handResults:results err:error];

}

- (void)handResults:(NSArray<iTextResult *> *)results err:(NSError*)error
{
    if (results.count > 0) {
        NSString *title = @"Results";
        NSString *msgText = @"";
        NSString *msg = @"Please visit: https://www.dynamsoft.com/customer/license/trialLicense?";
        for (NSInteger i = 0; i< [results count]; i++) {
            if (results[i].exception != nil && [results[i].exception containsString:msg]) {
                msgText = [msg stringByAppendingString:@"product=dbr&utm_source=installer&package=ios to request for 30 days extension."];
                title = @"Exception";
                break;
            }
            if (results[i].barcodeFormat_2 != 0) {
                msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString_2, results[i].barcodeText]];
            }else{
                msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString, results[i].barcodeText]];
            }
        }
        
        [[DynamsoftManager manager] showResult:title msg:msgText acTitle:@"OK" completion:^{
            [self captureFrameFromCamera];
        }];
       
       
    }else{
        [self captureFrameFromCamera];

    }
}

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error
{
    if (!error) {

        if (@available(iOS 11.0, *)) {
            NSData *data = [photo fileDataRepresentation];
            UIImage *image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self dbrDecodeBufferWithImage:image];

            });
        } else {
            // Fallback on earlier versions
        }
            
           
    }
   
}

- (void)captureOutput:(AVCapturePhotoOutput *)output willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
    AudioServicesDisposeSystemSoundID(1108);
}


@end
