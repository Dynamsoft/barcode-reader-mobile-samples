#import "ViewController.h"
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
#import <DynamsoftCameraEnhancer/DynamsoftCameraEnhancer.h>

@interface ViewController ()<DBRTextResultListener>
{
    CGFloat currentCameraZoom;
    BOOL autoZoomIsOpen;
}

@property (nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;
@property (nonatomic, strong) DynamsoftCameraEnhancer *dce;
@property (nonatomic, strong) DCECameraView *dceView;

@property (nonatomic, strong) CameraZoomFloatingButton *cameraZoomFloatingButton;
@property (nonatomic, strong) CameraZoomSlider *cameraZoomSlider;
@property (nonatomic, strong) CameraSettingView *cameraSettingView;
@property (nonatomic, strong) UILabel *interestLeadingView;

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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Tiny Barcode";
    
    currentCameraZoom = kDCEDefaultZoom;
    autoZoomIsOpen = kAutoZoomIsOpen;
    
    //This is a sample that illustrates how to quickly set up a video barcode scanner with Dynamsoft Barcode Reader.
    [self configurationDBR];
    
    //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
    [self configurationDCE];
    
    [self addZoomFloatingButton];
    [self addZoomSlider];
    [self addCameraSettingView];
    [self addInterestLeadingView];
}

- (void)configurationDBR{
    _barcodeReader = [[DynamsoftBarcodeReader alloc] init];
    
    [_barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoSingleBarcode];
    
//    iPublicRuntimeSettings *runtimeSetting = [_barcodeReader getRuntimeSettings:nil];
//    runtimeSetting.barcodeFormatIds = EnumBarcodeFormatONED | EnumBarcodeFormatQRCODE | EnumBarcodeFormatMAXICODE | EnumBarcodeFormatPDF417;
//    [_barcodeReader updateRuntimeSettings:runtimeSetting error:nil];
    
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
    
    // Set the zoom factor of the camera.
    [self.dce setZoom:currentCameraZoom];
    
    // Restrict the zoom range. Both zoom and auto-zoom will not exceed this range.
    [_dce setAutoZoomRange:UIFloatRangeMake(1.5, 5.0)];
    
    // Trigger a focus at the middel of the screen and keep continuous auto-focus enabled after the focus finished.
    [_dce setFocus:CGPointMake(0.5, 0.5) focusMode:EnumFocusModeFM_CONTINUOUS_AUTO];

    // Bind Camera Enhancer to the Barcode Reader.
    // Barcode Reader will acquire video frame from Camera Enhancer.
    [_barcodeReader setCameraEnhancer:_dce];

    // Start the barcode decoding thread.
    [_barcodeReader startScanning];
}

// MARK: - DBRTextResultListener

// Obtain the recognized barcode results from the textResultCallback and display the results.
- (void)textResultCallback:(NSInteger)frameId imageData:(iImageData *)imageData results:(NSArray<iTextResult *> *)results{
    if (results) {
        NSString *title = @"Results";
        NSString *msgText = @"";
        for (NSInteger i = 0; i< [results count]; i++) {
            msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString, results[i].barcodeText]];
        }
        
        [self showResult:title msg:msgText acString:@"OK" completion:^{
            [self->_barcodeReader startScanning];
        }];
    }
}

- (void)showResult:(NSString *)title msg:(NSString *)msg acString:(NSString *)acString completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:acString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completion();
        }]];

        [self presentViewController:alert animated:YES completion:^{
            [self->_barcodeReader stopScanning];
            [DCEFeedback vibrate];
            [DCEFeedback beep];
        }];
        
    });
}

// MARK: - DCE zoom

- (void)addZoomFloatingButton {
    
    CGFloat bottomHeight = 0;
    if (kIs_iPhoneXAndLater) {
        bottomHeight = kZoomComponentBottomMargin + 34;
    } else {
        bottomHeight = kZoomComponentBottomMargin;
    }
    
    weakSelfs(self)
    
    self.cameraZoomFloatingButton = [[CameraZoomFloatingButton alloc] initWithFrame:CGRectMake((kScreenWidth - kCameraZoomFloatingButtonWidth) / 2.0, kScreenHeight - bottomHeight - kCameraZoomFloatingButtonWidth, kCameraZoomFloatingButtonWidth, kCameraZoomFloatingButtonWidth)];
    [self.view addSubview:self.cameraZoomFloatingButton];
    self.cameraZoomFloatingButton.currentCameraZoom = currentCameraZoom;
    [self.view addSubview:self.cameraZoomFloatingButton];
    
    self.cameraZoomFloatingButton.tapPressActionBlock = ^{
        weakSelf.cameraZoomSlider.hidden = NO;
        weakSelf.cameraZoomFloatingButton.hidden = YES;
        weakSelf.cameraSettingView.hidden = YES;
    };
}

- (void)addZoomSlider {
    CGFloat bottomHeight = 0;
    if (kIs_iPhoneXAndLater) {
        bottomHeight = kZoomComponentBottomMargin + 34;
    } else {
        bottomHeight = kZoomComponentBottomMargin;
    }
    
    weakSelfs(self)
    
    self.cameraZoomSlider = [[CameraZoomSlider alloc] initWithFrame:CGRectMake(0, kScreenHeight - bottomHeight - kCameraZoomSliderViewHeight, kScreenWidth, kCameraZoomSliderViewHeight)];
    [self.view addSubview:self.cameraZoomSlider];
    
    self.cameraZoomSlider.hidden = YES;
    self.cameraZoomSlider.cameraMinZoom = kDCEDefaultZoom;
    self.cameraZoomSlider.cameraMaxZoom = KDCEMaxZoom;
    self.cameraZoomSlider.currentCameraZoom = currentCameraZoom;
    
    self.cameraZoomSlider.closeActionBlock = ^{
        weakSelf.cameraZoomSlider.hidden = YES;
        weakSelf.cameraZoomFloatingButton.hidden = NO;
        weakSelf.cameraSettingView.hidden = NO;
    };
    
    self.cameraZoomSlider.zoomValueChangedBlock = ^(CGFloat zoomValue) {
        [weakSelf changeCameraZoom:zoomValue];
    };
}

- (void)changeCameraZoom:(CGFloat)cameraZoom {
    self.cameraZoomFloatingButton.currentCameraZoom = cameraZoom;
    self.cameraZoomSlider.currentCameraZoom = cameraZoom;
    currentCameraZoom = cameraZoom;
    
    if ([self.dce getCameraState] == EnumCAMERA_STATE_OPENED) {
        [self.dce setZoom:cameraZoom];
    }
}

- (void)addCameraSettingView {
    
    CGFloat height = 0;
    if (kIs_iPhoneXAndLater) {
        height = KCameraSettingAvailableHeight + 34;
    } else {
        height = KCameraSettingAvailableHeight;
    }
    
    weakSelfs(self)
    
    self.cameraSettingView = [[CameraSettingView alloc] initWithFrame:CGRectMake(0, kScreenHeight - height, kScreenWidth, height)];
    [self.view addSubview:self.cameraSettingView];
    
    [self.cameraSettingView updateSwitchState:autoZoomIsOpen];
    self.cameraSettingView.switchChangedBlock = ^(BOOL isOn) {
        [weakSelf refreshAutoZoomState:isOn];
    };
}

- (void)refreshAutoZoomState:(BOOL)isOn {
    autoZoomIsOpen = isOn;
    if (autoZoomIsOpen) {
        [self.dce enableFeatures:EnumAUTO_ZOOM error:nil];
        self.cameraZoomFloatingButton.hidden = YES;
        self.cameraZoomSlider.hidden = YES;
    } else {
        [self.dce disableFeatures:EnumAUTO_ZOOM];
        self.cameraZoomFloatingButton.hidden = NO;
        self.cameraZoomSlider.hidden = YES;
        currentCameraZoom = kDCEDefaultZoom;
        [self changeCameraZoom:currentCameraZoom];
    }
}

- (void)addInterestLeadingView {
    CGFloat leadingWidth = 21.0;
    self.interestLeadingView = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - leadingWidth) / 2.0, (kScreenHeight - leadingWidth) / 2.0, leadingWidth, leadingWidth)];
    self.interestLeadingView.text = @"+";
    self.interestLeadingView.textColor = [UIColor colorWithRed:254 / 255.0 green:142 / 255.0 blue:20 / 255.0 alpha:1];
    self.interestLeadingView.font = kFont_SystemDefault(30);
    self.interestLeadingView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.interestLeadingView];
}

@end
