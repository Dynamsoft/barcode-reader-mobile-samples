
#import "ViewController.h"
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
#import <DynamsoftCameraEnhancer/DynamsoftCameraEnhancer.h>

@interface ViewController ()<DMDLSLicenseVerificationDelegate, DBRTextResultDelegate, DCELicenseVerificationListener>

@property(nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;
@property(nonatomic, strong) DynamsoftCameraEnhancer *dce;
@property(nonatomic, strong) DCECameraView *dceView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //This is a sample that shows how to make settings to reach the SpeedFirstSettings when using Dynamsoft Barcode Reader.
    [self configurationDBR];
    
    //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
    [self configurationDCE];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    // LocalizationModes       : LM_ONED_FAST_SCAN is the fastest localization mode for ONED barcodes. For more barcode formats please use LM_SCAN_DIRECTLY Localizes barcodes quickly.
    // ScanDirection           : default value is 0, which means the barcode scanner will scan both vertical and horizontal directions. Read more about localization mode members: https://www.dynamsoft.com/barcode-reader/parameters/enum/parameter-mode-enums.html?ver=latest#localizationmode
    // BarcodeFormatIds        : The simpler barcode format, the faster decoding speed.
    // ExpectedBarcodesCount   : The less barcode count, the faster decoding speed.
    // EnableFillBinaryVacancy : Binarization process might cause vacant area in barcode. The barcode reader will fill the vacant black by default (default value 1). Set the value 0 to disable this process.
    // DeblurModes             : DeblurModes will improve the readability and accuracy but decrease the reading speed. DeblurMode is skipped by default. Please update your settings here is you want to enable Deblur mode.
    NSString* json = @"{\"ImageParameter\":{\"BarcodeFormatIds\":[\"BF_ALL\"],\"BinarizationModes\":[{\"BlockSizeX\":0,\"BlockSizeY\":0,\"EnableFillBinaryVacancy\":0,\"Mode\":\"BM_LOCAL_BLOCK\"}],\"DeblurModes\":[{\"LibraryFileName\":\"\",\"LibraryParameters\":\"\",\"Mode\":\"DM_BASED_ON_LOC_BIN\"},{\"LibraryFileName\":\"\",\"LibraryParameters\":\"\",\"Mode\":\"DM_THRESHOLD_BINARIZATION\"}],\"ExpectedBarcodesCount\":1,\"LocalizationModes\":[{\"Mode\":\"LM_ONED_FAST_SCAN\",\"ScanDirection\":0}],\"Name\":\"SpeedFirstSettings\",\"ScaleDownThreshold\":1200,\"Timeout\":500},\"Version\":\"3.0\"}";
    [_barcodeReader initRuntimeSettingsWithString:json conflictMode:EnumConflictModeOverwrite error:&error];
}

- (void)configurationDCE{
    // Initialize a camera view for previewing video.
    _dceView = [DCECameraView cameraWithFrame:self.view.bounds];

    // Enable overlay visibility to highlight the recognized barcode results.
    _dceView.overlayVisible = true;
    [self.view addSubview:_dceView];
    
    // Initialize license for Dynamsoft Camera Enhancer.
    // The string "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" here is a 7-day free license. Note that network connection is required for this license to work.
    // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dce&utm_source=installer&package=ios
    [DynamsoftCameraEnhancer initLicense:@"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" verificationDelegate:self];
    _dce = [[DynamsoftCameraEnhancer alloc] initWithView:_dceView];
    [_dce open];
    
	NSError *error = [[NSError alloc]init];
    // Fast mode is the feature of Dynamsoft Camera Enhancer. It will improve the barcode scanning efficiency of Dynamsoft barcode reader. Read more about Dynamsoft Camera Enhancer.
    [_dce enableFeatures:EnumFAST_MODE error:&error];

    // Create settings of video barcode reading.
    iDCESettingParameters* para = [[iDCESettingParameters alloc] init];

    // This cameraInstance is the instance of the Camera Enhancer.
    // The Barcode Reader will use this instance to take control of the camera and acquire frames from the camera to start the barcode decoding process.
    para.cameraInstance = _dce;

    // Make this setting to get the result. The result will be an object that contains text result and other barcode information.
    para.textResultDelegate = self;

    // Bind the Camera Enhancer instance to the Barcode Reader instance.
    [_barcodeReader setCameraEnhancerPara:para];
}

- (void)DLSLicenseVerificationCallback:(bool)isSuccess error:(NSError *)error{
    [self verificationCallback:error];
}

- (void)DCELicenseVerificationCallback:(bool)isSuccess error:(NSError *)error{
    [self verificationCallback:error];
}

- (void)verificationCallback:(NSError*)error{
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
                [weakSelf configurationDCE];
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
//                      weakSelf.dce.isEnable = YES;
                  }];
        }
    }
}

// Get the TestResult object from the callback 
- (void)textResultCallback:(NSInteger)frameId results:(NSArray<iTextResult *> *)results userData:(NSObject *)userData{
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
    }else{
        return;
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

@end
