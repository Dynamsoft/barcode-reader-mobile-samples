/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

#import "ViewController.h"
#import <DynamsoftCameraEnhancer/DynamsoftCameraEnhancer.h>
#import <DynamsoftCore/DynamsoftCore.h>
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
#import <DynamsoftCaptureVisionRouter/DynamsoftCaptureVisionRouter.h>

@interface ViewController () <DSCapturedResultReceiver>

@property (nonatomic, strong) DSCameraView *cameraView;

@property (nonatomic, strong) DSCameraEnhancer *dce;

@property (nonatomic, strong) DSCaptureVisionRouter *cvr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpCamera];
    [self setUpDCV];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.dce open];
    // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
    [self.cvr startCapturing:DSPresetTemplateReadBarcodes completionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        if (!isSuccess && error != nil) {
            [self showResult:@"Error" message:error.localizedDescription completion:nil];
        }
    }];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.dce close];
    [self.cvr stopCapturing];
    [super viewWillDisappear:animated];
}

- (void)setUpCamera {
    self.cameraView = [[DSCameraView alloc] initWithFrame:self.view.bounds];
    self.cameraView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.cameraView atIndex:0];
    self.dce = [[DSCameraEnhancer alloc] init];
    self.dce.cameraView = self.cameraView;
}

- (void)setUpDCV {
    self.cvr = [[DSCaptureVisionRouter alloc] init];
    NSError *error;
    // Set the camera enhancer as the input.
    [self.cvr setInput:self.dce error:&error];
    if (error != nil) {
        NSLog(@"error: %@", error);
    }
    // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
    [self.cvr addResultReceiver:self];
}

// Implement the callback method to receive DecodedBarcodesResult.
// The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
// BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
- (void)onDecodedBarcodesReceived:(DSDecodedBarcodesResult *)result {
    if (result.items.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cvr stopCapturing];
        });
        NSString *message;
        for (DSBarcodeResultItem *item in result.items) {
            // Extract the barcode format and the barcode text from the BarcodeResultItem.
            message = [NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", item.formatString, item.text];
        }
        [self showResult:@"Results" message:message completion:^{
            // Restart the capture
            [self.cvr startCapturing:DSPresetTemplateReadBarcodes completionHandler:nil];
        }];
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
