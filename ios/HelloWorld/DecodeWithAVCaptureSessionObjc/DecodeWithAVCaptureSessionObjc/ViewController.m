/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

#import "ViewController.h"
#import "DSCaptureEnhancer.h"
#import <DynamsoftCore/DynamsoftCore.h>
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
#import <DynamsoftCaptureVisionRouter/DynamsoftCaptureVisionRouter.h>
#import <DynamsoftLicense/DynamsoftLicense.h>

@interface ViewController () <DSCapturedResultReceiver, DSLicenseVerificationListener>

@property (nonatomic, strong) DSCaptureEnhancer *capture;

@property (nonatomic, strong) DSCaptureVisionRouter *cvr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setLicense];
    [self setUpDCV];
}

- (void)setLicense {
    // Initialize the license.
    // The license string here is a trial license. Note that network connection is required for this license to work.
    // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
    [DSLicenseManager initLicense:@"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" verificationDelegate:self];
}

- (void)displayLicenseMessage:(NSString *)message {
    UILabel *label = [[UILabel alloc] init];
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor redColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [label.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:20],
        [label.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

- (void)setUpDCV {
    self.capture = [[DSCaptureEnhancer alloc] init];
    [self.capture setUpCameraView:self.view];
    self.cvr = [[DSCaptureVisionRouter alloc] init];
    NSError *error;
    // Set the image source adapter you created as the input.
    [self.cvr setInput:self.capture error:&error];
    if (error != nil) {
        NSLog(@"error: %@", error.description);
    }
    // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
    [self.cvr addResultReceiver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.capture startRunning];
    // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
    [self.cvr startCapturing:DSPresetTemplateReadSingleBarcode completionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        if (!isSuccess && error != nil) {
            [self showResult:@"Error" message:error.localizedDescription completion:nil];
        }
    }];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.capture stopRunning];
    [self.cvr stopCapturing];
    [self.capture clearBuffer];
    [super viewWillDisappear:animated];
}
// Implement the callback method to receive DecodedBarcodesResult.
// The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
// BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
- (void)onDecodedBarcodesReceived:(DSDecodedBarcodesResult *)result {
    if (result.items.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cvr stopCapturing];
            [self.capture clearBuffer];
        });
        NSString *message;
        for (DSBarcodeResultItem *item in result.items) {
            // Extract the barcode format and the barcode text from the BarcodeResultItem.
            message = [NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", item.formatString, item.text];
        }
        [self showResult:@"Results" message:message completion:^{
            [self.cvr startCapturing:DSPresetTemplateReadSingleBarcode completionHandler:nil];
        }];
    }
}

// MARK: LicenseVerificationListener
- (void)onLicenseVerified:(BOOL)isSuccess error:(nullable NSError *)error {
    if (!isSuccess && error != nil) {
        NSLog(@"error: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayLicenseMessage:[NSString stringWithFormat:@"License initialization failed: %@", error.localizedDescription]];
        });
    }
}

- (void)showResult:(NSString *)title message:(nullable NSString *)message completion:(void (^ __nullable)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion();
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end
