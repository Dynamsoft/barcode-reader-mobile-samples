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

@interface ViewController () <DSCapturedResultReceiver>

@property (nonatomic, strong) DSCaptureEnhancer *capture;

@property (nonatomic, strong) DSCaptureVisionRouter *cvr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpDCV];
}

- (void)setUpDCV {
    self.capture = [[DSCaptureEnhancer alloc] init];
    [self.capture setUpCameraView:self.view];
    self.cvr = [[DSCaptureVisionRouter alloc] init];
    NSError *error;
    [self.cvr setInput:self.capture error:&error];
    if (error != nil) {
        NSLog(@"error: %@", error.description);
    }
    [self.cvr addResultReceiver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.capture startRunning];
    [self.cvr startCapturing:DSPresetTemplateReadBarcodes completionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        if (!isSuccess && error != nil) {
            [self showResult:@"Error" message:error.localizedDescription completion:nil];
        }
    }];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.capture stopRunning];
    [self.cvr stopCapturing];
    [super viewWillDisappear:animated];
}

- (void)onDecodedBarcodesReceived:(DSDecodedBarcodesResult *)result {
    if (result.items.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cvr stopCapturing];
        });
        NSString *message;
        for (DSBarcodeResultItem *item in result.items) {
            message = [NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", item.formatString, item.text];
        }
        [self showResult:@"Results" message:message completion:^{
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
