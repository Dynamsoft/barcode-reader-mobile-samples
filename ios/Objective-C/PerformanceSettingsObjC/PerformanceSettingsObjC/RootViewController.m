//
//  RootViewController.m
//  PerformanceSettings
//
//  Created by dynamsoft on 2021/12/1.
//

#import "RootViewController.h"
#import <Photos/Photos.h>
#import "TemplateView.h"

typedef NS_ENUM(NSInteger, DecodeStyle){
    DecodeStyleVideo,
    DecodeStyleImage
};

@interface RootViewController ()<UINavigationControllerDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, DBRTextResultListener,TemplateViewDelegate>

@property(nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;
@property(nonatomic, strong) DynamsoftCameraEnhancer *dce;
@property(nonatomic, strong) DCECameraView *dceView;

/// Continuous timer.
@property (nonatomic, strong) NSTimer *continuousScanTimer;

/// Decode results view.
@property (nonatomic, strong) DecodeResultsView *decodeResultsView;

/// Template setitngs view.
@property (nonatomic, strong) TemplateView *templateView;

/// Scan bar.
@property (nonatomic, strong) UIImageView *scanLineImageV;

/// PhotoLibrary.
@property (nonatomic, strong) UIButton *photoLibraryButton;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

/// Save current decodeStyle.
@property (nonatomic, assign) DecodeStyle currentDecodeStyle;

/// Save current templateStyle.
@property (nonatomic, assign) EnumTemplateType currentTemplateType;

@end

@implementation RootViewController

/**
 You can freely switch Settings in the templates we give；
 We're going to use DBR continuous decoding when DCE is working;
 We use DBR single decoding when reading albums
 */

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.continuousScanTimer invalidate];
    self.continuousScanTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:kNavigationBackgroundColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Performace Settings";
    
    [self handleData];
    [self configureDBR];
    [self configureDCE];
    [self setupUI];
    
    // Register Notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

- (void)handleData
{
    self.currentDecodeStyle = DecodeStyleVideo;// Default
    self.currentTemplateType = EnumTemplateTypeSingleBarcode;// Default
}

- (void)setupUI
{
    [self.view addSubview:self.scanLineImageV];
    [self.view addSubview:self.decodeResultsView];
    [self.view addSubview:self.templateView];
    [self.view addSubview:self.photoLibraryButton];
    [self.view addSubview:self.loadingView];
    
    [self scanLineTurnOn];
    [self switchScanStyle];
}

//MARK: Configure DBR and DCE
- (void)configureDBR
{
    self.barcodeReader = [[DynamsoftBarcodeReader alloc] init];
    [self.barcodeReader setDBRTextResultListener:self];
    
    // Set template.
    [self dbrSwitchcTemplate];
}

- (void)configureDCE
{
    self.dceView = [[DCECameraView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight - kStatusBarHeight)];
    self.dceView.overlayVisible = true;
    [self.view addSubview:self.dceView];
    
    self.dce = [[DynamsoftCameraEnhancer alloc] initWithView:self.dceView];
    [self.dce open];

    // DBR link DCE.
    [self.barcodeReader setCameraEnhancer:self.dce];

    // DBR start decode.
    [self.barcodeReader startScanning];
}

//MARK: Switch template
- (void)dbrSwitchcTemplate
{
    switch (self.currentTemplateType) {
        case EnumTemplateTypeSingleBarcode:
        {
            // Set the barcode scanning mode to single barcode scanning.
            NSLog(@"single barcode!");
            self.photoLibraryButton.hidden = YES;

            // Select video single barcode template.
            [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoSingleBarcode];
            
            NSError *scanRegionError = nil;

            // Reset the scanRegion settings.
            // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
            [self.dce setScanRegion:nil error:&scanRegionError];
            break;
        }
        case EnumTemplateTypeSpeedFirst:
        {
            // Set the barcode decoding mode to video speed first.
            self.photoLibraryButton.hidden = NO;
            if (self.currentDecodeStyle == DecodeStyleVideo) {
                NSLog(@"video speed first!");
                // Select the video speed first template.
                // The template includes settings that benefits the processing speed for general video barcode scanning scenarios.
                [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoSpeedFirst];
                
                NSError *settingsError = nil;
                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];
                
                // Specifiy the barcode formats to match your usage scenarios will help you further improve the barcode processing speed.
                runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
                runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                runtimeSettings.expectedBarcodesCount = 0;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                runtimeSettings.scaleDownThreshold = 2300;

                // The unit of timeout is millisecond, it will force the Barcode Reader to stop processing the current image.
                // Set a smaller timeout value will help the Barcode Reader to quickly quit the video frames without a barcode when decoding on video streaming.
                runtimeSettings.timeout = 500;

                // Add or update the above settings.
                [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];
                
                NSError *scanRegionError = nil;

                // Specify the scanRegion via Camera Enhancer will help you improve the barcode processing speed.
                // The video frames will be cropped based on the scanRegion so that the Barcode Reader will focus on the scanRegion only.
                // Configure a RegionDefinition value for the scanRegion.
                iRegionDefinition *scanRegion = [[iRegionDefinition alloc] init];

                // The int value 30 means the top border of the scanRegion is 30% margin from the top border of the video frame.
                scanRegion.regionTop = 30;

                // The int value 70 means the bottom border of the scanRegion is 70% margin from the top border of the video frame.
                scanRegion.regionBottom = 70;

                // The int value 15 means the left border of the scanRegion is 15% margin from the left border of the video frame.
                scanRegion.regionLeft = 15;

                // The int value 85 means the right border of the scanRegion is 85% margin from the left border of the video frame.
                scanRegion.regionRight = 85;

                // Set the regionMeasuredByPercentage to 1, so that the above values will stands for percentage. Otherwise, they will stands for pixel length.
                scanRegion.regionMeasuredByPercentage = 1;

                // Trigger the scanRegion setting, the scanRegion will be displayed on the UI at the same time.
                // Trigger setScanRegionVisible = false will hide the scanRegion on the UI but the scanRegion still exist.
                // Set the scanRegion to a null value can disable the scanRegion setting.
                [self.dce setScanRegion:scanRegion error:&scanRegionError];
                
            } else if (self.currentDecodeStyle == DecodeStyleImage) {

                // Set the barcode decoding mode to image speed first.
                NSLog(@"image speed first!");

                // Select Image speed first template.
                // The template includes settings that benefits the processing speed for general image barcode decoding scenarios.
                [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateImageSpeedFirst];                
             
                NSError *settingsError = nil;

                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];

                // Specifiy the barcode formats to match your usage scenarios will help you further improve the barcode processing speed.
                runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
                runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                runtimeSettings.expectedBarcodesCount = 0;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                runtimeSettings.scaleDownThreshold = 2300;

                // Add or update the above settings.
                [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];
                
                // Reset the scanRegion settings.
                // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
                NSError *scanRegionError = nil;
                [self.dce setScanRegion:nil error:&scanRegionError];
                
            }
            break;
        }
            
        case EnumTemplateTypeReadRateFirst:
        {
            self.photoLibraryButton.hidden = NO;
            if (self.currentDecodeStyle == DecodeStyleVideo) {
                // Select the video read rate first template.
                // A higher Read Rate means the Barcode Reader has higher possibility to decode the target barcode.
                // The template includes settings that benefits the read rate for general video barcode scanning scenarios.
                NSLog(@"video read rate first!");
                [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoReadRateFirst];
                
              
                NSError *settingsError = nil;

                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];

                // Specifiy more barcode formats will help you to improve the read rate of the Barcode Reader
                runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
                runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                runtimeSettings.expectedBarcodesCount = 512;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                runtimeSettings.scaleDownThreshold = 2300;

                // The unit of timeout is millisecond, it will force the Barcode Reader to stop processing the current image.
                // Set a smaller timeout value will help the Barcode Reader to quickly quit the video frames without a barcode when decoding on video streaming.
                runtimeSettings.timeout = 5000;
                
                // Add support for inverted barcodes
                runtimeSettings.furtherModes.grayscaleTransformationModes = @[@(EnumGrayscaleTransformationModeOriginal), @(EnumGrayscaleTransformationModeInverted)];

                // Add or update the above settings.
                [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];
                
                NSError *scanRegionError = nil;

                // Reset the scanRegion settings.
                // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
                [self.dce setScanRegion:nil error:&scanRegionError];
                
            } else if (self.currentDecodeStyle == DecodeStyleImage) {

                NSLog(@"image read rate first!");

                // Select the image read rate first template.
                // A higher Read Rate means the Barcode Reader has higher possibility to decode the target barcode.
                // The template includes settings that benefits the read rate for general image barcode decoding scenarios.
                [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateImageReadRateFirst];
                
                NSError *settingsError = nil;

                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];

                // Specifiy more barcode formats will help you to improve the read rate of the Barcode Reader.
                runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
                runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                runtimeSettings.expectedBarcodesCount = 512;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                runtimeSettings.scaleDownThreshold = 10000;
                
                // Add support for inverted barcodes
                runtimeSettings.furtherModes.grayscaleTransformationModes = @[@(EnumGrayscaleTransformationModeOriginal), @(EnumGrayscaleTransformationModeInverted)];

                // Add or update the above settings.
                [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];
                
                NSError *scanRegionError = nil;

                // Reset the scanRegion settings.
                // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
                [self.dce setScanRegion:nil error:&scanRegionError];
                
            }
            break;
        }

        case EnumTemplateTypeAccuracyFirst:
        {
            // There is no template for accuracy settings. You can use other methods to make the settings.
            NSLog(@"accuracy first!");
            self.photoLibraryButton.hidden = YES;
         
            NSError *resetError = nil;
            // Reset all of the runtime settings first.
            [self.barcodeReader resetRuntimeSettings:&resetError];
            
            NSError *settingsError = nil;
            iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];

            // Specifiy the barcode formats to match your usage scenarios will help you further improve the barcode processing accuracy.
            runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
            runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

            // Simplify the DeblurModes so that the severely blurred images will be skipped.
            runtimeSettings.deblurModes = @[@(EnumDeblurModeBasedOnLocBin), @(EnumDeblurModeThresholdBinarization)];
            
            // Add support for inverted barcodes.
            runtimeSettings.furtherModes.grayscaleTransformationModes = @[@(EnumGrayscaleTransformationModeOriginal), @(EnumGrayscaleTransformationModeInverted)];

            // Add confidence filter for the barcode results.
            // A higher confidence for the barcode result means the higher possibility to be correct.
            // The default value of the confidence is 30, which can filter the majority of misreading barcode results.
            runtimeSettings.minResultConfidence = 30;

            // The Barcode Reader will try to decode as many barcodes as the expected count.
            // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
            runtimeSettings.expectedBarcodesCount = 512;

            // Add filter condition for the barcode results.
            runtimeSettings.minBarcodeTextLength = 6;

            // Add or update the above settings.
            [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];

            // The correctness of barcode results will be double checked before output.
            [self.barcodeReader setEnableResultVerification:true];
            
            NSError *dceError = nil;
            // The frame filter feature of Camera Enhancer will help you to skip blurry frame when decoding on video streaming.
            // This feature requires a valid license of Dynamsoft Camera Enhancer
            [self.dce enableFeatures:EnumFRAME_FILTER error:&dceError];
            
            // Reset the scanRegion settings.
            // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
            NSError *scanRegionError = nil;
            [self.dce setScanRegion:nil error:&scanRegionError];
            
            break;
        }

        default:
            break;
    }
}

//MARK: Switch scanStyle
- (void)switchScanStyle
{
    if (self.currentDecodeStyle == DecodeStyleVideo) {
        // Open continuous decode timer.
        [self continuousScanTimerFire];
    } else if (self.currentDecodeStyle == DecodeStyleImage) {
        // Close continuous decode timer.
        [self continuousScanTimerInvalidate];
        [self.barcodeReader stopScanning];
    }
}

/// Open continuous scan
- (void)continuousScanTimerFire
{
    if (self.continuousScanTimer.valid) {
        [self continuousScanTimerInvalidate];
    }
    MyTargetProxy *target = [MyTargetProxy weakProxyTarget:self];
    self.continuousScanTimer = [NSTimer timerWithTimeInterval:kContinueScanInterval target:target selector:@selector(continuousScan:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.continuousScanTimer forMode:NSRunLoopCommonModes];
    [self.continuousScanTimer fire];
}

/// Close continuous scan
- (void)continuousScanTimerInvalidate
{
    [self.continuousScanTimer invalidate];
    self.continuousScanTimer = nil;
}

- (void)continuousScan:(NSTimer *)timer
{
    [self.barcodeReader startScanning];
}

//MARK: Select picture
- (void)selectPic
{
    [self openPhotoLibrary];
}

//MARK: About scanline
- (void)scanLineTurnOn
{
    CATransform3D scanLineTransform3D = CATransform3DMakeTranslation(0,  kScreenHeight - kNaviBarAndStatusBarHeight - kTabBarHeight - 100, 0);
    CABasicAnimation *scanLineAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scanLineAnimation.toValue = [NSValue valueWithCATransform3D:scanLineTransform3D];
    scanLineAnimation.duration = 2;
    scanLineAnimation.repeatCount = 999;
    [self.scanLineImageV.layer addAnimation:scanLineAnimation forKey:@"scanLine"];
}

- (void)scanlineTurnOff
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scanLineImageV.layer removeAllAnimations];
    });

}

//MARK: LoadingView
- (void)loadingStart {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startAnimating];
    });
}

- (void)loadingFinished {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopAnimating];
    });
}

//MARK: TemplateViewDelegate
- (void)transformModeAction:(TemplateView *)templateView templateType:(EnumTemplateType)templateType {
    self.currentTemplateType = templateType;
    [self dbrSwitchcTemplate];
}

- (void)explainAction:(TemplateView *)templateView templateType:(EnumTemplateType)templateType {
    switch (templateType) {
        case EnumTemplateTypeSingleBarcode:
        {
            [[ToolsHandle toolManger] addAlertViewWithTitle:@"Single Barcode Scanning" Content:singleBarcodeExplain actionTitle:nil ToView:self completion:^{
                        
            }];
            break;
        }
        case EnumTemplateTypeSpeedFirst:
        {
            [[ToolsHandle toolManger] addAlertViewWithTitle:@"Speed First Settings" Content:speedFirstExplain actionTitle:nil ToView:self completion:^{
                        
            }];
            break;
        }
        case EnumTemplateTypeReadRateFirst:
        {
            [[ToolsHandle toolManger] addAlertViewWithTitle:@"Read Rate First Template" Content:readRateFirstExplain actionTitle:nil ToView:self completion:^{
                        
            }];
            break;
        }
        case EnumTemplateTypeAccuracyFirst:
        {
            [[ToolsHandle toolManger] addAlertViewWithTitle:@"Accuracy First Template" Content:accuracyFirstExplain actionTitle:nil ToView:self completion:^{
                        
            }];
            break;
        }
        default:
            break;
    }
}

//MARK: DBRTextResultDelegate
/// Obtain the barcode results from the callback and display the results.
- (void)textResultCallback:(NSInteger)frameId imageData:(iImageData *)imageData results:(NSArray<iTextResult *> *)results{

    if (results.count > 0) {
        weakSelfs(self)
        // Use dbr stopScanning.
        if (self.currentDecodeStyle == DecodeStyleVideo) {

            /**
             You can comment out this line of code to experience faster continuous decoding.
             Or open this line to experience decoding at intervals
             */
          //  [self.barcodeReader stopScanning];
        } else if (self.currentDecodeStyle == DecodeStyleImage) {
            [self.barcodeReader stopScanning];
            return;
        }
        
        // Use dbr startScanning.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.decodeResultsView showDecodeResultWith:results location:EnumDecodeResultsLocationBottom completion:^{
                [weakSelf.barcodeReader startScanning];
          
            }];
        });
    }
}

- (void)handleImageDecodeResults:(NSArray<iTextResult *> *)results err:(NSError*__nullable)error{
    weakSelfs(self)
    if (results.count > 0) {
        NSString *title = @"Results";
        NSString *msgText = @"";
        NSString *msg = @"Please visit: https://www.dynamsoft.com/customer/license/trialLicense?";
        for (NSInteger i = 0; i< [results count]; i++) {
            if (results[i].exception != nil && [results[i].exception containsString:msg]) {
                msgText = [msg stringByAppendingString:@"product=dbr&utm_source=installer&package=ios to request for an extension."];
                title = @"Exception";
                break;
            }
            msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString, results[i].barcodeText]];

        }
        [self showResult:title msg:msgText acTitle:@"OK" completion:^{
            // Change currentDecodeStyle to video.
            weakSelf.currentDecodeStyle = DecodeStyleVideo;
            [weakSelf dbrSwitchcTemplate];
            [weakSelf switchScanStyle];
        }];
        [self loadingFinished];
    }else{
        
        NSString *msg = error.code == 0 ? @"" : error.userInfo[NSUnderlyingErrorKey];
        [self showResult:@"No result" msg:msg  acTitle:@"OK" completion:^{
            // Change currentDecodeStyle to video.
            weakSelf.currentDecodeStyle = DecodeStyleVideo;
            [weakSelf dbrSwitchcTemplate];
            [weakSelf switchScanStyle];
        }];
        [self loadingFinished];
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

    });
}

//MARK: PhotoLibrary authorization
- (void)openPhotoLibrary {
    [self.loadingView startAnimating];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        [self loadingFinished];
        if (status != PHAuthorizationStatusAuthorized) {
            [self requestAuthorization];
            return;
        }
        
        [self transformTemplateSettings];
        [self presentPickerViewController];
    }];
}

- (void)transformTemplateSettings {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentDecodeStyle = DecodeStyleImage;
        [self dbrSwitchcTemplate];
        [self switchScanStyle];
    });
}

- (void)requestAuthorization {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                                                                                 message:@"Settings-Privacy-Camera/Album-Authorization"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:comfirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
   
}

- (void)presentPickerViewController{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        if (@available(iOS 11.0, *)){
            [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
        }
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    });
}

//MARK: UIImagePicker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.currentDecodeStyle = DecodeStyleVideo;
    [self dbrSwitchcTemplate];
    [self switchScanStyle];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    [self loadingStart];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSError* error = nil;
        NSArray<iTextResult*>* results = [self->_barcodeReader decodeImage:image error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Image decode.
            [self handleImageDecodeResults:results err:error];
        });
        
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//MARK: Notification
- (void)appEnterBackground:(NSNotification *)noti
{
    [self scanlineTurnOff];
}

- (void)appEnterForeground:(NSNotification *)noti
{
    [self scanLineTurnOn];
}

//MARK: Lazy loading
- (UIImageView *)scanLineImageV {
    if (!_scanLineImageV) {
        _scanLineImageV = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - kScanLineWidth) / 2.0, kNaviBarAndStatusBarHeight + 50, kScanLineWidth, 10)];
        _scanLineImageV.image = [UIImage imageNamed:@"scan_line"];
    }
    return  _scanLineImageV;
}

- (DecodeResultsView *)decodeResultsView {
    if (!_decodeResultsView) {
        _decodeResultsView = [[DecodeResultsView alloc] initWithFrame:CGRectMake(0, kNaviBarAndStatusBarHeight, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight) location:EnumDecodeResultsLocationBottom withTargetVC:self];
    }
    return _decodeResultsView;
}

- (TemplateView *)templateView {
    if (!_templateView) {
        _templateView = [[TemplateView alloc] initWithFrame:CGRectMake(0, kNaviBarAndStatusBarHeight, kTableViewCellWidth, [TemplateView getHeight])];
        _templateView.delegate = self;
    }
    return _templateView;
}

- (UIButton *)photoLibraryButton {
    if (!_photoLibraryButton) {
        _photoLibraryButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 50 - 20, 20 + kNaviBarAndStatusBarHeight, 50, 50)];
        [_photoLibraryButton setImage:[UIImage imageNamed:@"icon_select"] forState:UIControlStateNormal];
        [_photoLibraryButton addTarget:self action:@selector(selectPic) forControlEvents:UIControlEventTouchUpInside];
        _photoLibraryButton.hidden = YES;
    }
    return _photoLibraryButton;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _loadingView.center = self.view.center;
        [_loadingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _loadingView;
}

@end
