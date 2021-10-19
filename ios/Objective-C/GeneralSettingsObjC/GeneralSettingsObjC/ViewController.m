
#import "ViewController.h"
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
#import <DynamsoftCameraEnhancer/DynamsoftCameraEnhancer.h>

@interface ViewController ()<DMDLSLicenseVerificationDelegate, DBRTextResultDelegate>

@property(nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;
@property(nonatomic, strong) DynamsoftCameraEnhancer *dce;
@property(nonatomic, strong) DCECameraView *dceView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //This is a sample that shows how to make GeneralSettings when using Dynamsoft Barcode Reader.
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

    // General settings (including barcode format, barcode count and scan region) for the instance.
    // Obtain current runtime settings of instance.
    iPublicRuntimeSettings *settings = [_barcodeReader getRuntimeSettings:&error];

    // Set the expected barcode format you want to read.
    // The barcode format our library will search for is composed of BarcodeFormat group 1 and BarcodeFormat group 2.
    // So you need to specify the barcode format in group 1 and group 2 individually.
    settings.barcodeFormatIds = EnumBarcodeFormatONED | EnumBarcodeFormatPDF417 | EnumBarcodeFormatQRCODE | EnumBarcodeFormatDATAMATRIX | EnumBarcodeFormatAZTEC;

    // Set the expected barcode count you want to read.
    settings.expectedBarcodesCount = 5;

    // Set the ROI(region of insterest) to speed up the barcode reading process.
    // Note: DBR supports setting coordinates by pixels or percentages. The origin of the coordinate system is the upper left corner point.
    settings.region.regionTop      = 15;
    settings.region.regionBottom   = 85;
    settings.region.regionLeft     = 30;
    settings.region.regionRight    = 70;
    settings.region.regionMeasuredByPercentage = 1;

    // Apply the new settings to the instance
    [_barcodeReader updateRuntimeSettings:settings error:&error];
}

- (void)configurationDCE{
    // Initialize a camera view for previewing video.
    _dceView = [DCECameraView cameraWithFrame:self.view.bounds];
    // Enable overlay visibility to highlight the recognized barcode results.
    _dceView.overlayVisible = true;
    [self.view addSubview:_dceView];
    
    _dce = [[DynamsoftCameraEnhancer alloc] initWithView:_dceView];
    [_dce open];
    
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

// Obtain the barcode results from the callback and display the results.
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
