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

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, strong) DSCaptureVisionRouter *cvr;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUp];
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
        DSCapturedResult *result = [self.cvr captureFromImage:image templateName:DSPresetTemplateReadBarcodesReadRateFirst];
        [self handleCapturedResult:result];
        [self.loadingView stopAnimating];
    } else {
        [self showResult:@"Image is nil!" message:@"" completion:nil];
    }
}

- (void)handleCapturedResult:(DSCapturedResult *)result {
    if (result.items.count > 0) {
        NSString *message = [NSString stringWithFormat:@"Decoded Barcode Count: %lu\n", (unsigned long)result.items.count];
        for (DSBarcodeResultItem *item in result.items) {
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
