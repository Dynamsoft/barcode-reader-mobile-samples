//
//  MainViewController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/18.
//

#import "MainViewController.h"
#import "SettingsViewController.h"


@interface MainViewController ()<DBRTextResultListener>
{
    BOOL isFirstLaunch;
}
@property(nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;
@property(nonatomic, strong) DynamsoftCameraEnhancer *dce;
@property(nonatomic, strong) DCECameraView *dceView;

/// Decode results view.
@property (nonatomic, strong) DecodeResultsView *decodeResultsView;

/// Scan bar.
@property (nonatomic, strong) UIImageView *scanLineImageV;

@end

@implementation MainViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:kNavigationBackgroundColor];
    
    [self changeDecodeResultViewLocation];
    
    if (isFirstLaunch) {
        isFirstLaunch = NO;
        [[GeneralSettingsHandle setting].cameraEnhancer open];
        [[GeneralSettingsHandle setting].barcodeReader startScanning];
    } else {
        [[GeneralSettingsHandle setting].cameraEnhancer resume];
        [[GeneralSettingsHandle setting].barcodeReader startScanning];
    }
    
    [self scanLineTurnOn];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[GeneralSettingsHandle setting].cameraEnhancer pause];
    [[GeneralSettingsHandle setting].barcodeReader stopScanning];
    [[GeneralSettingsHandle setting].cameraEnhancer turnOffTorch];
    
    [self scanlineTurnOff];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"General Settings";
    
    isFirstLaunch = YES;
    
    [self setupNavigation];
    [self configureDefaultDBR];
    [self configureDefaultDCE];
    [self setupUI];
    [[GeneralSettingsHandle setting] setDefaultData];

    // Register notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

///// Should invoke this method when viewWillAppear.
//- (void)refreshDCEState {
//    if ([GeneralSettingsHandle setting].dceViewSettings.displayTorchButtonIsOpen == YES) {
//
//    }
//}

/// Should invoke this method when viewWillAppear.
- (void)changeDecodeResultViewLocation
{
    if ([GeneralSettingsHandle setting].barcodeSettings.continuousScanIsOpen == YES) {
        [self.decodeResultsView updateLocation:EnumDecodeResultsLocationBottom];
    } else {
        [self.decodeResultsView updateLocation:EnumDecodeResultsLocationCentre];
    }
}

- (void)setupNavigation
{
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_setting"] style:UIBarButtonItemStylePlain target:self action:@selector(jumpToSetting)];
    self.navigationItem.rightBarButtonItem = settingItem;
    
}

/// Jump to setting page.
- (void)jumpToSetting
{
    SettingsViewController *settingVC = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)setupUI
{
    self.scanLineImageV = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - kScanLineWidth) / 2.0, kNaviBarAndStatusBarHeight + 50, kScanLineWidth, 10)];
    self.scanLineImageV.image = [UIImage imageNamed:@"scan_line"];
    [self.view addSubview:self.scanLineImageV];

    self.decodeResultsView = [[DecodeResultsView alloc] initWithFrame:CGRectMake(0, kNaviBarAndStatusBarHeight + 150, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight - 150) location:EnumDecodeResultsLocationCentre withTargetVC:self];
}

- (void)scanLineTurnOn
{
    CATransform3D scanLineTransform3D = CATransform3DMakeTranslation(0,  kScreenHeight - kNaviBarAndStatusBarHeight - kTabBarHeight - 100, 0);
    CABasicAnimation *scanLineAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scanLineAnimation.toValue = [NSValue valueWithCATransform3D:scanLineTransform3D];
    scanLineAnimation.duration = 2;
    scanLineAnimation.repeatCount = 999;
    [self.scanLineImageV.layer addAnimation:scanLineAnimation forKey:@"scanLine"];
}

- (void)scanlineTurnOff
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scanLineImageV.layer removeAllAnimations];
    });

}

//MARK: Configure DBR and DCE

- (void)configureDefaultDBR
{ 
    [GeneralSettingsHandle setting].barcodeReader = [[DynamsoftBarcodeReader alloc] init];
    
    [[GeneralSettingsHandle setting].barcodeReader setDBRTextResultListener:self];
  
    // Public runtime.
    NSError *runtimeError = nil;
    [GeneralSettingsHandle setting].ipublicRuntimeSettings = [[GeneralSettingsHandle setting].barcodeReader getRuntimeSettings:&runtimeError];

}

- (void)configureDefaultDCE
{
    
    [GeneralSettingsHandle setting].cameraView = [DCECameraView cameraWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight - kStatusBarHeight)];
    [GeneralSettingsHandle setting].cameraView.overlayVisible = true;
    [self.view addSubview:[GeneralSettingsHandle setting].cameraView];


    [GeneralSettingsHandle setting].cameraEnhancer = [[DynamsoftCameraEnhancer alloc] initWithView:[GeneralSettingsHandle setting].cameraView];

    // DBR link DCE
    [[GeneralSettingsHandle setting].barcodeReader setCameraEnhancer:[GeneralSettingsHandle setting].cameraEnhancer];
}

// MARK: - DBRTextResultDelegate
// Obtain the barcode results from the callback and display the results.
- (void)textResultCallback:(NSInteger)frameId imageData:(iImageData *)imageData results:(NSArray<iTextResult *> *)results{

    if (results) {

        // Vibrate.
        if ([GeneralSettingsHandle setting].cameraSettings.dceVibrateIsOpen == YES) {
            [DCEFeedback vibrate];
        }
        
        // Beep.
        if ([GeneralSettingsHandle setting].cameraSettings.dceBeepIsOpen == YES) {
            [DCEFeedback beep];
        }
        
        // Use dbr stopScanning.
        if ([GeneralSettingsHandle setting].barcodeSettings.continuousScanIsOpen == YES) {
            // Nothing should to do.
        } else {
            [[GeneralSettingsHandle setting].barcodeReader stopScanning];
        }
        
        // Use dbr startScanning.
        if ([GeneralSettingsHandle setting].barcodeSettings.continuousScanIsOpen == YES) {

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.decodeResultsView showDecodeResultWith:results location:EnumDecodeResultsLocationBottom completion:^{
                    [[GeneralSettingsHandle setting].barcodeReader startScanning];
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.decodeResultsView showDecodeResultWith:results location:EnumDecodeResultsLocationCentre completion:^{
                    [[GeneralSettingsHandle setting].barcodeReader startScanning];
              
                }];
            });
        }
    }
}

// MARK: - Notification
- (void)appEnterBackground:(NSNotification *)noti
{
    [self scanlineTurnOff];
}

- (void)appEnterForeground:(NSNotification *)noti
{
    [self scanLineTurnOn];
}

@end
