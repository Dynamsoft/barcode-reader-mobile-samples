/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

#import "ViewController.h"
#import <Photos/Photos.h>
#import <DynamsoftCore/DynamsoftCore.h>
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
#import <DynamsoftCaptureVisionRouter/DynamsoftCaptureVisionRouter.h>
#import <DynamsoftLicense/DynamsoftLicense.h>

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, DSLicenseVerificationListener>

@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, strong) DSCaptureVisionRouter *cvr;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setLicense];
    [self setUp];
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

- (void)setUp {
    self.cvr = [[DSCaptureVisionRouter alloc] init];
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    [self.view addSubview:self.loadingView];
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _loadingView.center = self.view.center;
    }
    return _loadingView;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    [self.picker dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)selectPhoto:(id)sender {
    [self presentViewController:self.picker animated:true completion:nil];
}

- (IBAction)capture:(id)sender {
    UIImage *image = self.imageView.image;
    if (image) {
        [self.loadingView startAnimating];
        // Decode barcodes from a UIImage.
        // The method returns a CapturedResult object that contains an array of CapturedResultItems.
        // CapturedResultItem is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
        DSCapturedResult *result = [self.cvr captureFromImage:image templateName:DSPresetTemplateReadBarcodesReadRateFirst];
        [self handleCapturedResult:result];
        [self.loadingView stopAnimating];
    } else {
        [self showResult:@"Image is nil!" message:@"" completion:nil];
    }
}
// This is the method that extract the barcodes info from the CapturedResult.
- (void)handleCapturedResult:(DSCapturedResult *)result {
    if (result.items.count > 0) {
        NSString *message = [NSString stringWithFormat:@"Decoded Barcode Count: %lu\n", (unsigned long)result.items.count];
        // Get each CapturedResultItem object from the array.
        for (DSBarcodeResultItem *item in result.items) {
            // Extract the barcode format and the barcode text from the CapturedResultItem.
            message = [message stringByAppendingFormat:@"\nFormat: %@\nText: %@\n", item.formatString, item.text];
        }
        [self showResult:@"Results" message:message completion:nil];
    } else {
        if (result.errorCode != 0) {
            [self showResult:@"Error" message:result.errorMessage completion:nil];
        } else {
            [self showResult:@"No Result" message:nil completion:nil];
        }
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
