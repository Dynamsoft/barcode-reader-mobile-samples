
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
    
    // This is a sample that shows how to reach the AccuracyFirstSettings when using Dynamsoft Barcode Reader.
    [self configurationDBR];
    
    // Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
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
    // Mostly, misreading only occurs on reading oneD barcode.
    iPublicRuntimeSettings *settings = [_barcodeReader getRuntimeSettings:&error];

    // Here we set expected barcode count to 1.
    settings.expectedBarcodesCount = 1;

    // Parameter 1. Set expected barcode format
    // The more precise the barcode format is set, the higher the accuracy.
    // Mostly, misreading only occurs on reading oneD barcode. So here we use OneD barcode format to demonstrate.
    settings.barcodeFormatIds = EnumBarcodeFormatONED;

    // Parameter 2. Set the minimal result confidence.
    // The greater the confidence, the higher the accuracy.
    // Filter by minimal confidence of the decoded barcode. We recommend using 30 as the default minimal confidence value
    settings.minResultConfidence = 30;

    // Parameter 3. Sets the minimum length of barcode text for filtering.
    // The more precise the barcode text length is set, the higher the accuracy.
    settings.minBarcodeTextLength = 6;

    // Apply the new settings to the instance
    [_barcodeReader updateRuntimeSettings:settings error:&error];

    // Enable result verification for video barcode reading.
    // After the result verification is turned on, the SDK will verify the result among multiple video frames.
    [_barcodeReader setEnableResultVerification:true];
}

- (void)configurationDCE{
    // Initialize a camera view for previewing video.
    _dceView = [DCECameraView cameraWithFrame:self.view.bounds];

    // Enable overlay visibility to highlight the recognized barcode results.
    _dceView.overlayVisible = true;
    [self.view addSubview:_dceView];
    
    // The string "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" here will grant you a public trial license good for 7 days. After that, please visit: https://www.dynamsoft.com/customer/license/trialLicense?product=dce&utm_source=installer&package=ios to request for 30 days extension.
    [DynamsoftCameraEnhancer initLicense:@"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" verificationDelegate:self];
    _dce = [[DynamsoftCameraEnhancer alloc] initWithView:_dceView];
    [_dce open];
	
    NSError *error = [[NSError alloc]init];
    
    //Frame filter is the feature of Dynamsoft Camera Enhancer. It will improve the barcode scanning accuracy of Dynamsoft barcode reader. Read more about Dynamsoft Camera Enhancer.
    [_dce enableFeatures:EnumFRAME_FILTER error:&error];

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

- (void)verificationCallback:(NSError *)error{
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
