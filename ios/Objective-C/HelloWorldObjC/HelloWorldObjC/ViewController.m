
#import "ViewController.h"
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
#import <DynamsoftCameraEnhancer/DynamsoftCameraEnhancer.h>
#import "AppDelegate.h"

@interface ViewController ()<DBRTextResultListener>

@property(nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;
@property(nonatomic, strong) DynamsoftCameraEnhancer *dce;
@property(nonatomic, strong) DCECameraView *dceView;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.003/255.0 green:61.9991/255.0 blue:69.0028/255.0 alpha:1]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //This is a sample that illustrates how to quickly set up a video barcode scanner with Dynamsoft Barcode Reader.
    [self configurationDBR];
    
    //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
    [self configurationDCE];
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)configurationDBR{
    _barcodeReader = [[DynamsoftBarcodeReader alloc] init];
    
    [_barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoSingleBarcode];
    
    // Set text result call back to get barcode results.
    [_barcodeReader setDBRTextResultListener:self];
}

- (void)configurationDCE{
    // Initialize a camera view for previewing video.
    _dceView = [DCECameraView cameraWithFrame:self.view.bounds];
    [self.view addSubview:_dceView];
    
    // Initialize the Camera Enhancer with the camera view.
    _dce = [[DynamsoftCameraEnhancer alloc] initWithView:_dceView];
    [_dce open];

    // Bind Camera Enhancer to the Barcode Reader.
    // Barcode Reader will acquire video frame from Camera Enhancer.
    [_barcodeReader setCameraEnhancer:_dce];

    // Start the barcode decoding thread.
    [_barcodeReader startScanning];
    
}

// Obtain the recognized barcode results from the textResultCallback and display the results.
- (void)textResultCallback:(NSInteger)frameId imageData:(iImageData *)imageData results:(NSArray<iTextResult *> *)results{
    if (results.count > 0) {
       
        NSString *title = @"Results";
        NSString *msgText = @"";
        for (NSInteger i = 0; i< [results count]; i++) {
            
            msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString, results[i].barcodeText]];
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
        
        if (self.presentedViewController) {
            [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];

        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:acTitle style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        completion();
                                                    }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        
    });
}


@end
