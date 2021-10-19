
#import "ViewController.h"
#import <Photos/Photos.h>
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>

@interface ViewController ()<DMDLSLicenseVerificationDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;

@end

@implementation ViewController{
    NSInteger sourceType;
    UIActivityIndicatorView *loadingView;
    
    AVCaptureSession *session;
    AVCaptureDevice* inputDevice;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureStillImageOutput *photoOutput;
    dispatch_queue_t sessionQueue;
    UIButton *photoButton;
    UIButton *picButton;
    UIView *captureView;
    int orientationNum;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //This is a sample that shows how to reach the ReadRateFirstSettings when using Dynamsoft Barcode Reader.
    [self configurationDBR];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self stopSession];
}

- (void)configurationDBR{
    iDMDLSConnectionParameters* lts = [[iDMDLSConnectionParameters alloc] init];

    // Initialize license for Dynamsoft Barcode Reader.
    // The organization id 200001 here will grant you a public trial license good for 7 days. Note that network connection is required for this license to work.
    // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
    // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
    lts.organizationID = @"200001";
    _barcodeReader = [[DynamsoftBarcodeReader alloc] initLicenseFromDLS:lts verificationDelegate:self];
    
    NSError *error = [[NSError alloc] init];
    // LocalizationModes       : LocalizationModes are all enabled as default. Barcode reader will automatically switch between the modes and try decoding continuously until timeout or the expected barcode count is reached. Please manually update the enabled modes list or change the expected barcode count to promote the barcode scanning speed.
    // Read more about localization mode members: https://www.dynamsoft.com/barcode-reader/parameters/enum/parameter-mode-enums.html?ver=latest#localizationmode
    // BarcodeFormatIds        : The simpler barcode format, the faster decoding speed.
    // ExpectedBarcodesCount   : The barcode scanner will try to find 512 barcodes. If the result count does not reach the expected amount, the barcode scanner will try other algorithms in the setting list to find enough barcodes.
    // DeblurModes             : DeblurModes are all enabled as default. Barcode reader will automatically switch between the modes and try decoding continuously until timeout or the expected barcode count is reached. Please manually update the enabled modes list or change the expected barcode count to promote the barcode scanning speed.
    // Read more about deblur mode members: https://www.dynamsoft.com/barcode-reader/parameters/enum/parameter-mode-enums.html#deblurmode
    // ScaleUpModes            : It is a parameter to control the process for scaling up an image used for detecting barcodes with small module size.
    // GrayscaleTransformationModes : The image will be transformed into inverted grayscale with GTM_INVERTED mode.
    // DPMCodeReadingModes     : It is a parameter to control how to read direct part mark (DPM) barcodes.
    NSString* json = @"{\"ImageParameter\": {\"BarcodeFormatIds\": [\"BF_ALL\"],\"ExpectedBarcodesCount\": 64,\"RegionPredetectionModes\": [{\"Mode\": \"RPM_GENERAL\"}],\"DPMCodeReadingModes\":[{\"Mode\":\"DPMCRM_GENERAL\"}],\"LocalizationModes\": [{\"Mode\": \"LM_CONNECTED_BLOCKS\"},{\"Mode\": \"LM_SCAN_DIRECTLY\",\"ScanDirection\": 0},{\"Mode\": \"LM_STATISTICS\"},{\"Mode\": \"LM_LINES\"},{\"Mode\": \"LM_STATISTICS_MARKS\"},{\"Mode\": \"LM_STATISTICS_POSTAL_CODE\"}],\"BinarizationModes\": [{\"BlockSizeX\": 0,\"BlockSizeY\": 0,\"EnableFillBinaryVacancy\": 1,\"Mode\": \"BM_LOCAL_BLOCK\",\"ThresholdCompensation\": 10},{\"EnableFillBinaryVacancy\": 0,\"Mode\": \"BM_LOCAL_BLOCK\",\"ThresholdCompensation\": 15}],\"DeblurModes\": [{\"Mode\": \"DM_DIRECT_BINARIZATION\"},{\"Mode\": \"DM_THRESHOLD_BINARIZATION\"},{\"Mode\": \"DM_GRAY_EQUALIZATION\"},{\"Mode\": \"DM_SMOOTHING\"},{\"Mode\": \"DM_MORPHING\"},{\"Mode\": \"DM_DEEP_ANALYSIS\"},{\"Mode\": \"DM_SHARPENING\"}],\"GrayscaleTransformationModes\": [{\"Mode\": \"GTM_ORIGINAL\"},{\"Mode\": \"GTM_INVERTED\"}],\"ScaleUpModes\": [{\"Mode\": \"SUM_AUTO\"}],\"Name\":\"ReadRateFirstSettings\",\"Timeout\":30000}}";
    [_barcodeReader initRuntimeSettingsWithString:json conflictMode:EnumConflictModeOverwrite error:&error];
}

- (void)DLSLicenseVerificationCallback:(bool)isSuccess error:(NSError *)error{
    NSString* msg = @"";
    if(error != nil)
    {
        __weak ViewController *weakSelf = self;
        if (error.code == -1009) {
            msg = @"Unable to connect to the public Internet to acquire a license. Please connect your device to the Internet or contact support@dynamsoft.com to acquire an offline license.";
            [self showResult:@"No Internet"
                         msg:msg
                     acTitle:@"Try Again"
                  completion:^{
                [weakSelf configurationDBR];
                  }];
        }else{
            msg = error.userInfo[NSUnderlyingErrorKey];
            if(msg == nil)
            {
                msg = [error localizedDescription];
            }
            [self showResult:@"Server license verify failed"
                         msg:msg
                     acTitle:@"OK"
                  completion:^{
                
                  }];
        }
    }
}

- (void)handResults:(NSArray<iTextResult *> *)results err:(NSError*)error{
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
        [self showResult:title
                     msg:msgText
                 acTitle:@"OK"
              completion:^{
            
              }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->loadingView stopAnimating];
        });
    }else{
        NSString *msg = error.code == 0 ? @"" : error.userInfo[NSUnderlyingErrorKey];
        [self showResult:@"No result" msg:msg  acTitle:@"OK" completion:^{
            [self->loadingView stopAnimating];
        }];
    }
}

- (void)showResult:(NSString *)title msg:(NSString *)msg acTitle:(NSString *)acTitle completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:acTitle style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    completion();
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
        [self->photoButton setEnabled:true];
    });
}

#pragma mark - image pick

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->loadingView startAnimating];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError* error = [[NSError alloc] init];
        NSArray<iTextResult*>* results = [self->_barcodeReader decodeImage:image withTemplate:@"" error:&error];
        [self handResults:results err:error];
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden{
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    if (w > h) {
        return YES;
    }
    return NO;
}

- (void)setupUI {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    sessionQueue = dispatch_queue_create("dbrQueue", NULL);
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    loadingView.center = self.view.center;
    [loadingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:loadingView];
    [self addCamera];
}

- (void)getAlertActionType:(NSInteger)type {
    NSInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (type == 1) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else if (type == 2) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self creatUIImagePickerControllerWithAlertActionType:sourceType];
}

- (void)creatUIImagePickerControllerWithAlertActionType:(NSInteger)type {
    sourceType = type;
    NSInteger cameragranted = [self AVAuthorizationStatusIsGranted];
    if (cameragranted == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                                                                                 message:@"Settings-Privacy-Camera/Album-Authorization"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertController addAction:comfirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (cameragranted == 1) {
        [self presentPickerViewController];
    }
}

- (BOOL)imagePickerControlerIsAvailabelToCamera {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (NSInteger)AVAuthorizationStatusIsGranted{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatusVideo = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    PHAuthorizationStatus authStatusAlbm  = [PHPhotoLibrary authorizationStatus];
    NSInteger authStatus = sourceType == UIImagePickerControllerSourceTypePhotoLibrary ? authStatusAlbm : authStatusVideo;
    switch (authStatus) {
        case 0: {
            if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        [self presentPickerViewController];
                    }
                }];
            }else{
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        [self presentPickerViewController];
                    }
                }];
            }
        }
            return 2;
        case 1: return 0;
        case 2: return 0;
        case 3: return 1;
        default:return 0;
    }
}

- (void)presentPickerViewController{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        if (@available(iOS 11.0, *)){
            [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
        }
        picker.delegate = self;
        picker.sourceType = self->sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    });
}

- (void)handleOrientationDidChange{
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect mainBounds = CGRectZero;
        AVCaptureVideoOrientation avOri = AVCaptureVideoOrientationPortrait;
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationPortrait:
                mainBounds.size.width = MIN(h, w);
                mainBounds.size.height = MAX(h, w);
                avOri = AVCaptureVideoOrientationPortrait;
                self->orientationNum = 0;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                mainBounds.size.width = MIN(h, w);
                mainBounds.size.height = MAX(h, w);
                avOri = AVCaptureVideoOrientationPortraitUpsideDown;
                self->orientationNum = 3;
                break;
            case UIInterfaceOrientationLandscapeRight:
                mainBounds.size.width = MAX(h, w);
                mainBounds.size.height = MIN(h, w);
                avOri = AVCaptureVideoOrientationLandscapeRight;
                self->orientationNum = 2;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                mainBounds.size.width = MAX(h, w);
                mainBounds.size.height = MIN(h, w);
                avOri = AVCaptureVideoOrientationLandscapeLeft;
                self->orientationNum = 1;
                break;
            default:
                mainBounds.size.width = MIN(h, w);
                mainBounds.size.height = MAX(h, w);
                avOri = AVCaptureVideoOrientationPortrait;
                self->orientationNum = 0;
                break;
        }
        self->previewLayer.connection.videoOrientation = avOri;
        self->previewLayer.frame = mainBounds;
        self->captureView.frame = mainBounds;
        CGFloat SafeAreaBottomHeight = [[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 34 : 0;
        if (mainBounds.size.width > mainBounds.size.height) {
            self->photoButton.frame = CGRectMake(mainBounds.size.width - 170, mainBounds.size.height / 2 - 60, 120, 120);
            self->picButton.frame = CGRectMake(mainBounds.size.width - 142, mainBounds.size.height / 2 - 153, 65, 65);
        }else{
            self->photoButton.frame = CGRectMake(mainBounds.size.width / 2 - 60, mainBounds.size.height - 170 - SafeAreaBottomHeight, 120, 120);
            self->picButton.frame = CGRectMake(mainBounds.size.width / 2 + 88, mainBounds.size.height - 142 - SafeAreaBottomHeight, 65, 65);
        }
        self->loadingView.frame = CGRectMake(mainBounds.size.width / 2 - 25, mainBounds.size.height / 2 - 25, 50, 50);
    });
}

- (void)addCamera{
    [self setVideoSession];
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat tabH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat SafeAreaBottomHeight = [[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 34 : 0;
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    previewLayer.frame = CGRectMake(0, tabH, w, h - tabH);
    photoButton = [[UIButton alloc] initWithFrame:CGRectMake(w / 2 - 60, h - 170 - SafeAreaBottomHeight, 120, 120)];
    photoButton.adjustsImageWhenDisabled = NO;
    [photoButton setImage:[UIImage imageNamed:@"icon_capture"] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(takePictures) forControlEvents:UIControlEventTouchUpInside];

    picButton = [[UIButton alloc] initWithFrame:CGRectMake(w / 2 + 88, h - 142 - SafeAreaBottomHeight, 65, 65)];
    [picButton setImage:[UIImage imageNamed:@"icon_picture"] forState:UIControlStateNormal];
    [picButton addTarget:self action:@selector(selectPic) forControlEvents:UIControlEventTouchUpInside];
    
    captureView = [[UIView alloc] initWithFrame:CGRectMake(0, tabH, w, h - tabH)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->captureView.layer addSublayer:self->previewLayer];
        [self.view insertSubview:self->captureView belowSubview:self->loadingView];
        [self.view addSubview:self->photoButton];
        [self.view addSubview:self->picButton];
    });
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [self startSession];
        }
    }];
}

- (void)selectPic{
    [self getAlertActionType:1];
}

- (void)takePictures{
    [photoButton setEnabled:false];
    AVCaptureConnection *videoConnect = [photoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnect == nil) {
        [photoButton setEnabled:true];
        return;
    }
    [photoOutput captureStillImageAsynchronouslyFromConnection:videoConnect completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer == nil) {
            [self->photoButton setEnabled:true];
            return;
        }
        NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = nil;
        if (self->orientationNum == 2) {
            image = [UIImage imageWithData:imgData];
        }else{
            image = [self imageWithRightOrientation:[UIImage imageWithData:imgData]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->loadingView startAnimating];
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError* error = [[NSError alloc] init];
            NSArray<iTextResult*>* results = [self->_barcodeReader decodeImage:image withTemplate:@"" error:&error];
            [self handResults:results err:error];
        });
    }];
}

#pragma mark - take photo
- (void)setVideoSession{
    inputDevice = [self getAvailableCamera];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
                                          deviceInputWithDevice:inputDevice
                                          error:nil];
    if ([inputDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error = nil;
        if ([inputDevice lockForConfiguration:&error]) {
            inputDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            [inputDevice unlockForConfiguration];
        }
    }
    if([inputDevice respondsToSelector:@selector(isAutoFocusRangeRestrictionSupported)] &&
       inputDevice.autoFocusRangeRestrictionSupported) {
        if([inputDevice lockForConfiguration:nil]) {
            inputDevice.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
            [inputDevice unlockForConfiguration];
        }
    }
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    [captureOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    if(captureInput == nil || captureOutput == nil) return;
    
    session = [[AVCaptureSession alloc] init];
    photoOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([session canAddInput:captureInput]) [session addInput:captureInput];
    if ([session canAddOutput:captureOutput]) [session addOutput:captureOutput];
    if ([session canAddOutput:photoOutput]) [session addOutput:photoOutput];
    else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]){
        [session setSessionPreset :AVCaptureSessionPreset1280x720];
    }
}

- (void)startSession{
#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    dispatch_async(sessionQueue, ^{
        if (!self->session.isRunning) [self->session startRunning];
    });
}

- (void)stopSession{
#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    dispatch_async(sessionQueue, ^{
        if (self->session.isRunning) [self->session stopRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->previewLayer) [self->previewLayer removeFromSuperlayer];
            [self->photoButton removeFromSuperview];
            [self->captureView removeFromSuperview];
        });
        for (AVCaptureInput *input in self->session.inputs) {
            [self->session removeInput:input];
        }
        for (AVCaptureOutput *output in self->session.outputs) {
            [self->session removeOutput:output];
        }
        self->inputDevice = nil;
    });
}

- (AVCaptureDevice *)getAvailableCamera{
#if TARGET_IPHONE_SIMULATOR
    return nil;
#endif
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionBack) {
            captureDevice = device;
            break;
        }
    }
    if (!captureDevice) captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return captureDevice;
}

- (UIImage *)imageWithRightOrientation:(UIImage *)aImage {
    if (aImage.imageOrientation == UIImageOrientationUp) return aImage;
     
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (aImage.imageOrientation) {
       case UIImageOrientationLeft:
       case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
       case UIImageOrientationRight:
       case UIImageOrientationRightMirrored:
            if(orientationNum == 1){
                transform = CGAffineTransformTranslate(transform, aImage.size.height, aImage.size.width);
                transform = CGAffineTransformRotate(transform, -M_PI);
            } else{
                transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
                transform = CGAffineTransformRotate(transform, -M_PI_2);
            }
            break;
       default:
            break;
    }
    switch (aImage.imageOrientation) {
       case UIImageOrientationUpMirrored:
       case UIImageOrientationDownMirrored:
           transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
           transform = CGAffineTransformScale(transform, -1, 1);
           break;
             
       case UIImageOrientationLeftMirrored:
       case UIImageOrientationRightMirrored:
           transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
           transform = CGAffineTransformScale(transform, -1, 1);
           break;
       default:
           break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = nil;
    if (orientationNum == 1) {
        ctx = CGBitmapContextCreate(NULL, aImage.size.height, aImage.size.width,
                                    CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                    CGImageGetColorSpace(aImage.CGImage),
                                    CGImageGetBitmapInfo(aImage.CGImage));
    }else{
        ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                         CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                         CGImageGetColorSpace(aImage.CGImage),
                                         CGImageGetBitmapInfo(aImage.CGImage));
    }
    
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
