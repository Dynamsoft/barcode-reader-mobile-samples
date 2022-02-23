//
//  MainViewController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/18.
//

#import "MainViewController.h"
#import "SettingsViewController.h"


@interface MainViewController ()<DMDLSLicenseVerificationDelegate, DBRTextResultDelegate>
{
    BOOL isNotFirstLaunch;
    /// default is NO
    BOOL cameraTorchIsOpen;
    
    /// scanLine is working, default is YES
    BOOL scanLineIsWorking;
    
    UIActivityIndicatorView *loadingView;
}

@property(nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;
@property(nonatomic, strong) DynamsoftCameraEnhancer *dce;
@property(nonatomic, strong) DCECameraView *dceView;

/// continuous timer
@property (nonatomic, strong) NSTimer *continuousScanTimer;

/// decode results view
@property (nonatomic, strong) DecodeResultsView *decodeResultsView;

/// scan bar
@property (nonatomic, strong) UIImageView *scanLineImageV;


@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:kNavigationBackgroundColor];
    
    [self changeDecodeResultViewLocation];
    
    if (isNotFirstLaunch == YES) {
        

        [self scanLineTurnOn];
        
        if ([GeneralSettingsHandle setting].continuousScan == YES) {
            [[GeneralSettingsHandle setting].cameraEnhancer open];
            [[GeneralSettingsHandle setting].barcodeReader startScanning];
            [self continuousScanTimerFire];
        } else {
            [[GeneralSettingsHandle setting].cameraEnhancer open];
            [[GeneralSettingsHandle setting].barcodeReader startScanning];
        }

        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[GeneralSettingsHandle setting].cameraEnhancer close];
    [[GeneralSettingsHandle setting].barcodeReader stopScanning];
    
    [self continuousScanTimerInvalidate];
    
    [self scanlineTurnOff];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"General Settings";

    scanLineIsWorking = YES;
    
    [self setupNavigation];
    
   
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->isNotFirstLaunch = YES;
    });
    
    
    [self configureDefaultDBR];
    [self configureDefaultDCE];

    [[GeneralSettingsHandle setting] setDefaultData];


    [self setupUI];
    
    // register Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:appDidEnterToBackground_Notication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:appWillEnterToForeground_Notication object:nil];
   
}


/// invoke this method when viewwillappear
- (void)changeDecodeResultViewLocation
{

    if ([GeneralSettingsHandle setting].continuousScan == YES) {
        [self.decodeResultsView updateLocation:EnumDecodeResultsLocationBottom];
    } else {
        [self.decodeResultsView updateLocation:EnumDecodeResultsLocationCentre];
    }
    
}

/// open continuous scan
- (void)continuousScanTimerFire
{
    if (self.continuousScanTimer.valid) {
        [self continuousScanTimerInvalidate];
    }
    self.continuousScanTimer = [NSTimer timerWithTimeInterval:kContinueScanInterval target:self selector:@selector(continuousScan:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.continuousScanTimer forMode:NSRunLoopCommonModes];
    
}

/// close continuous scan
- (void)continuousScanTimerInvalidate
{
    [self.continuousScanTimer invalidate];
    self.continuousScanTimer = nil;
}

- (void)continuousScan:(NSTimer *)timer
{
    [[GeneralSettingsHandle setting].barcodeReader startScanning];
}

- (void)setupNavigation
{
    
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_setting"] style:UIBarButtonItemStylePlain target:self action:@selector(jumpToSetting)];
    self.navigationItem.rightBarButtonItem = settingItem;
    
}

/// jump to setting page
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
    
    [self scanLineTurnOn];

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


//MARK: configureDBR and DCE

- (void)configureDefaultDBR
{
    iDMDLSConnectionParameters *dls = [[iDMDLSConnectionParameters alloc] init];
    // Initialize license for Dynamsoft Barcode Reader.
    // The organization id 200001 here will grant you a time-limited public trial license. Note that network connection is required for this license to work.
    // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
    // You can also request an extention for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
    dls.organizationID = @"200001";
 
    [GeneralSettingsHandle setting].barcodeReader = [[DynamsoftBarcodeReader alloc] initLicenseFromDLS:dls verificationDelegate:self];
    
    [[GeneralSettingsHandle setting].barcodeReader setDBRTextResultDelegate:self userData:nil];
  
    // public runtime
    NSError *runtimeError = [[NSError alloc] init];
    [GeneralSettingsHandle setting].ipublicRuntimeSettings = [[GeneralSettingsHandle setting].barcodeReader getRuntimeSettings:&runtimeError];

}

- (void)configureDefaultDCE
{
    
    [GeneralSettingsHandle setting].cameraView = [DCECameraView cameraWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight - kStatusBarHeight)];
    [GeneralSettingsHandle setting].cameraView.overlayVisible = true;
    [self.view addSubview:[GeneralSettingsHandle setting].cameraView];


    [GeneralSettingsHandle setting].cameraEnhancer = [[DynamsoftCameraEnhancer alloc] initWithView:[GeneralSettingsHandle setting].cameraView];
    [[GeneralSettingsHandle setting].cameraEnhancer open];
    
    
    // DBR link DCE
    [[GeneralSettingsHandle setting].barcodeReader setCameraEnhancer:[GeneralSettingsHandle setting].cameraEnhancer];
    // DBR start decode
    [[GeneralSettingsHandle setting].barcodeReader startScanning];

}

//MARK:DMDLSLicenseVerificationDelegate
- (void)DLSLicenseVerificationCallback:(bool)isSuccess error:(NSError *)error{

    [self verificationCallback:error];
}

- (void)verificationCallback:(NSError *)error{
    
    NSString* msg = @"";
    if(error != nil)
    {
       
        msg = error.userInfo[NSUnderlyingErrorKey];
        if(msg == nil)
        {
            msg = [error localizedDescription];
        }
        [self showResult:@"Server license verify failed"
                     msg:msg
                 acTitle:@"OK"
              completion:^{
              }];
    }
}

//MARK: DBRTextResultDelegate
// Obtain the barcode results from the callback and display the results.
- (void)textResultCallback:(NSInteger)frameId results:(NSArray<iTextResult *> *)results userData:(NSObject *)userData{

    if (results.count > 0) {

        // use dbr stopScanning
        if ([GeneralSettingsHandle setting].continuousScan == YES) {

            /**
             You can comment out this line of code to experience faster continuous decoding.
             Or open this line to experience decoding at intervals
             */
        //    [[GeneralSettingsHandle setting].barcodeReader stopScanning];
        } else {
            [[GeneralSettingsHandle setting].barcodeReader stopScanning];
  
        }
        
        // use dbr startScanning
        
        if ([GeneralSettingsHandle setting].continuousScan == YES) {

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
    }else{
        return;
    }
}

- (void)showResult:(NSString *)title msg:(NSString *)msg acTitle:(NSString *)acTitle completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:acTitle style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    completion();
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];

    });
}


//MARK: NOtificaiton
- (void)appEnterBackground:(NSNotification *)noti
{
    [self scanlineTurnOff];
}

- (void)appEnterForeground:(NSNotification *)noti
{
    [self scanLineTurnOn];
}

@end
