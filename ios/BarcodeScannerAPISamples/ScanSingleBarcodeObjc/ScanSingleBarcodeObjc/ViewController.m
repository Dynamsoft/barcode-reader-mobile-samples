/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

#import "ViewController.h"
#import <DynamsoftBarcodeReaderBundle/DynamsoftBarcodeReaderBundle.h>
#import <DynamsoftBarcodeReaderBundle/DynamsoftBarcodeReaderBundle-Swift.h>

@interface ViewController ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self setup];
}

- (void)buttonTapped {
    DSBarcodeScannerViewController *vc = [[DSBarcodeScannerViewController alloc] init];
    DSBarcodeScannerConfig *config = [[DSBarcodeScannerConfig alloc] init];
    // Initialize the license.
    // The license string here is a trial license. Note that network connection is required for this license to work.
    // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
    config.license = @"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9";
    // You can use the following code to specify the barcode format. If you are using a template file, the "BarcodeFormat" can also be specified via the template file.
    /* config.barcodeFormats = DSBarcodeFormatOneD | DSBarcodeFormatQRCode; */
    // If you have a customized template file, please put it under "DynamsoftResources.bundle\Templates\" and call the following code.
    /* config.templateFile = @"ReadSingleBarcode.json"; */
    // The following settings will display a scan region on the view. Only the barcode in the scan region can be decoded.
    /*
     DSRect *region = [[DSRect alloc] init];
     region.left = 0.15;
     region.top = 0.3;
     region.right = 0.85;
     region.bottom = 0.7;
     config.scanRegion = region;
     */
    // Uncomment the following line to enable the beep sound when a barcode is scanned.
    /* config.isBeepEnabled = true; */
    // Uncomment the following line if you don't want to display the torch button.
     /* config.isTorchButtonVisible = false; */
    // Uncomment the following line if you don't want to display the close button.
     /* config.isCloseButtonVisible = false; */
    // Uncomment the following line if you want to hide the scan laser.
     /* config.isScanLaserVisible = false; */
    // Uncomment the following line if you want the camera to auto-zoom when the barcode is far away.
     /* config.isAutoZoomEnabled = true; */
    vc.config = config;

    __weak typeof(self) weakSelf = self;
    vc.onScannedResult = ^(DSBarcodeScanResult *result) {
        switch (result.resultStatus) {
            case DSResultStatusFinished: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *format = result.barcodes.firstObject.formatString ?: @"";
                    NSString *text = result.barcodes.firstObject.text ?: @"";
                    weakSelf.label.text = [NSString stringWithFormat:@"Result:\nFormat: %@\nText: %@", format, text];
                });
                break;
            }
            case DSResultStatusCanceled: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.label.text = @"Scan canceled";
                });
                break;
            }
            case DSResultStatusException: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.label.text = result.errorString;
                });
                break;
            }
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    };

    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.navigationController.navigationBar.hidden = YES;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    });
}

- (void)setup {
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.backgroundColor = [UIColor blackColor];
    [self.button setTitle:@"Scan a Barcode" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.layer.cornerRadius = 8;
    self.button.clipsToBounds = YES;
    [self.button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.button];
    
    self.label = [[UILabel alloc] init];
    self.label.numberOfLines = 0;
    self.label.textColor = [UIColor blackColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:20];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.label];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.button.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor constant:-32],
        [self.button.heightAnchor constraintEqualToConstant:48],
        [self.button.widthAnchor constraintEqualToConstant:160],

        [self.label.centerXAnchor constraintEqualToAnchor:safeArea.centerXAnchor],
        [self.label.centerYAnchor constraintEqualToAnchor:safeArea.centerYAnchor],
        [self.label.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor constant:32],
        [self.label.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor constant:-32],
        [self.label.bottomAnchor constraintLessThanOrEqualToAnchor:self.button.topAnchor constant:-8]
    ]];
}

@end
