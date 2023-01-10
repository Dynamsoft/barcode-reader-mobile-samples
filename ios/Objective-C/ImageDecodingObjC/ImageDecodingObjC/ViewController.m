//
//  ViewController.m
//  ImageDecodingObjC
//
//  Created by dynamsoft's mac on 2022/12/27.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>

@interface ViewController ()<UINavigationControllerDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;

@property (nonatomic, strong) UIButton *photoLibraryButton;

@property (nonatomic, strong) UIButton *imageDecodingButton;

@property (nonatomic, strong) UIImageView *selectedImageV;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.003/255.0 green:61.9991/255.0 blue:69.0028/255.0 alpha:1]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Image Decoding";
    
    [self configureDBR];
    [self setupUI];
}

- (void)configureDBR {
    self.barcodeReader = [[DynamsoftBarcodeReader alloc] init];
    // Set preset template to ImageReadRateFirst to improve the readability of the library when processing a still image.
    [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateImageReadRateFirst];
    // You can add the following code to update the barcode format settings based on the ImageReadRateFirst template.
    iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:nil];
    runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
    runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2DOTCODE;
    [self.barcodeReader updateRuntimeSettings:runtimeSettings error:nil];
}

- (void)setupUI {
    [self.view addSubview:self.photoLibraryButton];
    [self.view addSubview:self.imageDecodingButton];
    [self.view addSubview:self.selectedImageV];
    [self.view addSubview:self.loadingView];
    
    [self updateSelectedImage:[UIImage imageNamed:@"image-decoding"]];
}

- (void)updateSelectedImage:(UIImage *)image {
    self.selectedImageV.image = image;
}

// MARK: - Photo selection.
- (void)selectPic {
    [self openPhotoLibrary];
}

- (void)openPhotoLibrary {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            [self requestAuthorization];
            return;
        }
        [self presentPickerViewController];
    }];
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
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
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

//MARK: UIImagePicker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// The following method is triggered when an image is picked from the album.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self updateSelectedImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
    // In this sample, the barcode decoding process is triggered after you click the "Decode" button.
    // Uncomment the following line to let the image be processed immediately after picked.
    // [self startDecoding];
}

// MARK: - Start Decoding
- (void)startDecoding {
    [self loadingStart];
    UIImage *image = self.selectedImageV.image;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError* error = nil;
        // Decode the UIImage with method decodeImage. The return value is an array of barcode result.
        NSArray<iTextResult*>* results = [self->_barcodeReader decodeImage:image error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Image decode.
            [self loadingFinished];
            [self handleImageResults:results err:error];
        });
    });
}

- (void)handleImageResults:(NSArray<iTextResult *> *)results err:(NSError*__nullable)error {
    if (results) {
        NSString *title = @"Results";
        NSString *msgText = @"";
        for (NSInteger i = 0; i< [results count]; i++) {
            msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString, results[i].barcodeText]];
        }
        [self showResult:title msg:msgText acTitle:@"OK" completion:^{
            
        }];
    }else{
        
        NSString *msg = error.code == 0 ? @"" : error.userInfo[NSUnderlyingErrorKey];
        [self showResult:@"No result" msg:msg  acTitle:@"OK" completion:^{
            
        }];
    }
}

- (void)showResult:(NSString *)title msg:(NSString *)msg acTitle:(NSString *)acTitle completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:acTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completion();
        }]];
        [self presentViewController:alert animated:YES completion:nil];

    });
}

// MARK: - Lazy
- (UIButton *)photoLibraryButton {
    if (!_photoLibraryButton) {
        _photoLibraryButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 50 - 20, 20 + kNaviBarAndStatusBarHeight, 50, 50)];
        [_photoLibraryButton setImage:[UIImage imageNamed:@"icon_select"] forState:UIControlStateNormal];
        [_photoLibraryButton addTarget:self action:@selector(selectPic) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoLibraryButton;
}

- (UIButton *)imageDecodingButton {
    if (!_imageDecodingButton) {
        _imageDecodingButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 100) / 2.0, kScreenHeight - 100, 100, 50)];
        _imageDecodingButton.backgroundColor = [UIColor colorWithRed:59.003/255.0 green:61.9991/255.0 blue:69.0028/255.0 alpha:1];
        _imageDecodingButton.layer.cornerRadius = 5.0;
        [_imageDecodingButton setTitle:@"Decode" forState:UIControlStateNormal];
        [_imageDecodingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_imageDecodingButton addTarget:self action:@selector(startDecoding) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageDecodingButton;
}

- (UIImageView *)selectedImageV {
    if (!_selectedImageV) {
        CGFloat topX = self.photoLibraryButton.frame.origin.y + self.photoLibraryButton.frame.size.height + 10;
        _selectedImageV = [[UIImageView alloc] init];
        _selectedImageV.frame = CGRectMake(0, topX, kScreenWidth, kScreenHeight -  2 * topX);
        _selectedImageV.layer.contentsGravity = kCAGravityResizeAspect;
        _selectedImageV.layer.contentsScale = [UIScreen  mainScreen].scale;
    }
    return _selectedImageV;
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
