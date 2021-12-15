//
//  RootViewController.m
//  PerformanceSettings
//
//  Created by dynamsoft on 2021/12/1.
//

#import "RootViewController.h"
#import <Photos/Photos.h>
#import "BasicTableViewCell.h"

static NSString *singleBarcodeTag              = @"100";
static NSString *speedFirstTag                 = @"101";
static NSString *readRateFirstTag              = @"102";
static NSString *accuracyFirstTag              = @"103";

typedef NS_ENUM(NSInteger, DecodeStyle){
    DecodeStyle_Video,
    DecodeStyle_Image
};

typedef NS_ENUM(NSInteger, EnumTemplateType){
    EnumTemplateTypeSingleBarcode,
    EnumTemplateTypeSpeedFirst,
    EnumTemplateTypeReadRateFirst,
    EnumTemplateTypeAccuracyFirst
};

@interface RootViewController ()<UITableViewDelegate, UITableViewDataSource, DMDLSLicenseVerificationDelegate, DBRTextResultDelegate,UINavigationControllerDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate>
{
    NSArray *templateDataArray;
    NSMutableDictionary *recordTemplateSelectedStateDic;
    
    NSInteger sourceType;
    UIActivityIndicatorView *loadingView;
}

@property (nonatomic, strong) UITableView *performanceTableView;

@property(nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;
@property(nonatomic, strong) DynamsoftCameraEnhancer *dce;
@property(nonatomic, strong) DCECameraView *dceView;

/// continuous timer
@property (nonatomic, strong) NSTimer *continuousScanTimer;

/// decode results view
@property (nonatomic, strong) DecodeResultsView *decodeResultsView;

/// scan bar
@property (nonatomic, strong) UIImageView *scanLineImageV;

/// selectPictureButton
@property (nonatomic, strong) UIButton *selectPictureButton;

/// save current decodeStyle
@property (nonatomic, assign) DecodeStyle currentDecodeStyle;

/// save current templateStyle
@property (nonatomic, assign) EnumTemplateType currentTemplateType;

@end

@implementation RootViewController

/**
 You can freely switch Settings in the templates we give；
 We're going to use DBR continuous decoding when DCE is working;
 We use DBR single decoding when reading albums
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:kNavigationBackgroundColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Performace Settings";
    
    [self handleData];
    
    [self configureDBR];
    [self configureDCE];
    
    [self setupUI];
    
    // register Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:appDidEnterToBackground_Notication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:appWillEnterToForeground_Notication object:nil];
}

- (void)handleData
{
    templateDataArray = @[@{@"cellName":@"Single Barcode", @"tag":singleBarcodeTag},
                  @{@"cellName":@"Speed First", @"tag":speedFirstTag},
                  @{@"cellName":@"Read Rate First", @"tag":readRateFirstTag},
                  @{@"cellName":@"Accuracy First", @"tag":accuracyFirstTag}
    ];
    
    recordTemplateSelectedStateDic = [NSMutableDictionary dictionary];
    for (NSDictionary *templateDic in templateDataArray) {
        NSString *cellName = [templateDic valueForKey:@"cellName"];
        NSInteger tag = [[templateDic valueForKey:@"tag"] integerValue];
        if (tag == [singleBarcodeTag integerValue]) {
            [recordTemplateSelectedStateDic setValue:@(1) forKey:cellName];
        } else {
            [recordTemplateSelectedStateDic setValue:@(0) forKey:cellName];
        }
    }
    
    self.currentDecodeStyle = DecodeStyle_Video;// default
    self.currentTemplateType = EnumTemplateTypeSingleBarcode;// default
}

//MARK: switchTemplate
- (void)dbrSwitchcTemplate
{
    switch (self.currentTemplateType) {
        case EnumTemplateTypeSingleBarcode:
        {
            // Set the barcode scanning mode to single barcode scanning.
            NSLog(@"single barcode!");
            self.selectPictureButton.hidden = YES;

            // Select video single barcode template.
            [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoSingleBarcode];
            
            NSError *scanRegionError = nil;

            // Reset the scanRegion settings.
            // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
            [self.dce setScanRegion:nil error:&scanRegionError];
            break;
        }
        case EnumTemplateTypeSpeedFirst:
        {
            // Set the barcode decoding mode to video speed first.
            self.selectPictureButton.hidden = NO;
            if (self.currentDecodeStyle == DecodeStyle_Video) {
                NSLog(@"video speed first!");
                // Select the video speed first template.
                // The template includes settings that benefits the processing speed for general video barcode scanning scenarios.
                [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoSpeedFirst];
                
                NSError *settingsError = nil;
                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];
                
                // Specifiy the barcode formats to match your usage scenarios will help you further improve the barcode processing speed.
                runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
                runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                runtimeSettings.expectedBarcodesCount = 0;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                runtimeSettings.scaleDownThreshold = 2300;

                // The unit of timeout is millisecond, it will force the Barcode Reader to stop processing the current image.
                // Set a smaller timeout value will help the Barcode Reader to quickly quit the video frames without a barcode when decoding on video streaming.
                runtimeSettings.timeout = 500;

                // Add or update the above settings.
                [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];
                
                NSError *scanRegionError = nil;

                // Specify the scanRegion via Camera Enhancer will help you improve the barcode processing speed.
                // The video frames will be cropped based on the scanRegion so that the Barcode Reader will focus on the scanRegion only.
                // Configure a RegionDefinition value for the scanRegion.
                iRegionDefinition *scanRegion = [[iRegionDefinition alloc] init];

                // The int value 30 means the top border of the scanRegion is 30% margin from the top border of the video frame.
                scanRegion.regionTop = 30;

                // The int value 70 means the bottom border of the scanRegion is 70% margin from the top border of the video frame.
                scanRegion.regionBottom = 70;

                // The int value 15 means the left border of the scanRegion is 15% margin from the left border of the video frame.
                scanRegion.regionLeft = 15;

                // The int value 85 means the right border of the scanRegion is 85% margin from the left border of the video frame.
                scanRegion.regionRight = 85;

                // Set the regionMeasuredByPercentage to 1, so that the above values will stands for percentage. Otherwise, they will stands for pixel length.
                scanRegion.regionMeasuredByPercentage = 1;

                // Trigger the scanRegion setting, the scanRegion will be displayed on the UI at the same time.
                // Trigger setScanRegionVisible = false will hide the scanRegion on the UI but the scanRegion still exist.
                // Set the scanRegion to a null value can disable the scanRegion setting.
                [self.dce setScanRegion:scanRegion error:&scanRegionError];
                
            } else if (self.currentDecodeStyle == DecodeStyle_Image) {

                // Set the barcode decoding mode to image speed first.
                NSLog(@"image speed first!");

                // Select Image speed first template.
                // The template includes settings that benefits the processing speed for general image barcode decoding scenarios.
                [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateImageSpeedFirst];                
             
                NSError *settingsError = nil;

                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];

                // Specifiy the barcode formats to match your usage scenarios will help you further improve the barcode processing speed.
                runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
                runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                runtimeSettings.expectedBarcodesCount = 0;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                runtimeSettings.scaleDownThreshold = 2300;

                // Add or update the above settings.
                [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];
                
                // Reset the scanRegion settings.
                // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
                NSError *scanRegionError = nil;
                [self.dce setScanRegion:nil error:&scanRegionError];
                
            }
            break;
        }
            
        case EnumTemplateTypeReadRateFirst:
        {
            self.selectPictureButton.hidden = NO;
            if (self.currentDecodeStyle == DecodeStyle_Video) {
                // Select the video read rate first template.
                // A higher Read Rate means the Barcode Reader has higher possibility to decode the target barcode.
                // The template includes settings that benefits the read rate for general video barcode scanning scenarios.
                NSLog(@"video read rate first!");
                [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateVideoReadRateFirst];
                
              
                NSError *settingsError = nil;

                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];

                // Specifiy more barcode formats will help you to improve the read rate of the Barcode Reader
                runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
                runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                runtimeSettings.expectedBarcodesCount = 512;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                runtimeSettings.scaleDownThreshold = 2300;

                // The unit of timeout is millisecond, it will force the Barcode Reader to stop processing the current image.
                // Set a smaller timeout value will help the Barcode Reader to quickly quit the video frames without a barcode when decoding on video streaming.
                runtimeSettings.timeout = 5000;

                // Add or update the above settings.
                [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];
                
                NSError *scanRegionError = nil;

                // Reset the scanRegion settings.
                // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
                [self.dce setScanRegion:nil error:&scanRegionError];
                
            } else if (self.currentDecodeStyle == DecodeStyle_Image) {

                NSLog(@"image read rate first!");

                // Select the image read rate first template.
                // A higher Read Rate means the Barcode Reader has higher possibility to decode the target barcode.
                // The template includes settings that benefits the read rate for general image barcode decoding scenarios.
                [self.barcodeReader updateRuntimeSettings:EnumPresetTemplateImageReadRateFirst];
                
                NSError *settingsError = nil;

                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];

                // Specifiy more barcode formats will help you to improve the read rate of the Barcode Reader.
                runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
                runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                runtimeSettings.expectedBarcodesCount = 512;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                runtimeSettings.scaleDownThreshold = 10000;

                // Add or update the above settings.
                [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];
                
                NSError *scanRegionError = nil;

                // Reset the scanRegion settings.
                // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
                [self.dce setScanRegion:nil error:&scanRegionError];
                
            }
            break;
        }

        case EnumTemplateTypeAccuracyFirst:
        {
            /**
            There is no template for accuracy settings. You can use other methods to make the settings.
             */
            NSLog(@"accuracy first!");
            self.selectPictureButton.hidden = YES;
         
            NSError *resetError = nil;
            // Reset all of the runtime settings first.
            [self.barcodeReader resetRuntimeSettings:&resetError];
            
            NSError *settingsError = nil;
            iPublicRuntimeSettings *runtimeSettings = [self.barcodeReader getRuntimeSettings:&settingsError];

            // Specifiy the barcode formats to match your usage scenarios will help you further improve the barcode processing accuracy.
            runtimeSettings.barcodeFormatIds = EnumBarcodeFormatALL;
            runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;

            // Simplify the DeblurModes so that the severely blurred images will be skipped.
            runtimeSettings.deblurModes = @[@(EnumDeblurModeBasedOnLocBin), @(EnumDeblurModeThresholdBinarization)];

            // Add confidence filter for the barcode results.
            // A higher confidence for the barcode result means the higher possibility to be correct.
            // The default value of the confidence is 30, which can filter the majority of misreading barcode results.
            runtimeSettings.minResultConfidence = 30;

            // Add filter condition for the barcode results.
            runtimeSettings.minBarcodeTextLength = 6;

            // Add or update the above settings.
            [self.barcodeReader updateRuntimeSettings:runtimeSettings error:&settingsError];

            // The correctness of barcode results will be double checked before output.
            [self.barcodeReader setEnableResultVerification:true];
            
            NSError *dceError = nil;
            // The frame filter feature of Camera Enhancer will help you to skip blurry frame when decoding on video streaming.
            // This feature requires a valid license of Dynamsoft Camera Enhancer
            [self.dce enableFeatures:EnumFRAME_FILTER error:&dceError];
            
            // Reset the scanRegion settings.
            // The scanRegion will be reset to the whole video when you trigger the setScanRegion with a null value.
            NSError *scanRegionError = nil;
            [self.dce setScanRegion:nil error:&scanRegionError];
            
            break;
        }

        default:
            break;
    }
}

//MARK: switchScanStyle
- (void)switchScanStyle
{
    if (self.currentDecodeStyle == DecodeStyle_Video) {
        // open continuous decode timer
        [self continuousScanTimerFire];
    } else if (self.currentDecodeStyle == DecodeStyle_Image) {
        // close continuous decode timer
        [self continuousScanTimerInvalidate];
        [self.barcodeReader stopScanning];
    }
}

/// open continuous scan
- (void)continuousScanTimerFire
{
    if (self.continuousScanTimer.valid) {
        [self continuousScanTimerInvalidate];
    }
    MyTargetProxy *target = [MyTargetProxy weakProxyTarget:self];
    self.continuousScanTimer = [NSTimer timerWithTimeInterval:kContinueScanInterval target:target selector:@selector(continuousScan:) userInfo:nil repeats:YES];
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
    [self.barcodeReader startScanning];
}

- (void)setupUI
{
    
    self.scanLineImageV = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - kScanLineWidth) / 2.0, kNaviBarAndStatusBarHeight + 50, kScanLineWidth, 10)];
    self.scanLineImageV.image = [UIImage imageNamed:@"scan_line"];
    [self.view addSubview:self.scanLineImageV];
    
    [self scanLineTurnOn];
    
    self.decodeResultsView = [[DecodeResultsView alloc] initWithFrame:CGRectMake(0, kNaviBarAndStatusBarHeight, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight) location:EnumDecodeResultsLocationBottom withTargetVC:self];
    
    
    self.performanceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNaviBarAndStatusBarHeight, kTableViewCellWidth, templateDataArray.count * kCellHeight) style:UITableViewStylePlain];
    self.performanceTableView.backgroundColor = [UIColor clearColor];
    self.performanceTableView.delegate = self;
    self.performanceTableView.dataSource = self;
    self.performanceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.performanceTableView];
    
    
    self.selectPictureButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 50 - 20, 20 + kNaviBarAndStatusBarHeight, 50, 50)];
    [self.selectPictureButton setImage:[UIImage imageNamed:@"icon_select"] forState:UIControlStateNormal];
    [self.selectPictureButton addTarget:self action:@selector(selectPic) forControlEvents:UIControlEventTouchUpInside];
    self.selectPictureButton.hidden = YES;
    [self.view addSubview:self.selectPictureButton];
    
    // activityIndicatorView
    loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    loadingView.center = self.view.center;
    [loadingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:loadingView];
    
    // continuous decode start
    [self switchScanStyle];
}

//MARK: selectPicture
- (void)selectPic
{
    [self.selectPictureButton setEnabled:NO];
    [self getAlertActionType:1];
}

//MARK: about scanline
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

//MARK: UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return templateDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BasicTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *itemDic = templateDataArray[indexPath.row];
    NSString *title = [itemDic valueForKey:@"cellName"];
    NSInteger templateSelectedState = [[recordTemplateSelectedStateDic valueForKey:title] integerValue];
    static NSString *identifier = @"basicCellIdentifier";
    BasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BasicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    weakSelfs(self)
    cell.questionBlock = ^{
        [weakSelf handleQuestionWithIndexPath:indexPath];
    };
    
    [cell updateUIWithTitle:title andOptionalState:templateSelectedState];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *itemDic = templateDataArray[indexPath.row];
    NSInteger selectTag = [[itemDic valueForKey:@"tag"] integerValue];

    [recordTemplateSelectedStateDic removeAllObjects];
    for (NSDictionary *templateDic in templateDataArray) {
        NSString *cellName = [templateDic valueForKey:@"cellName"];
        NSInteger tag = [[templateDic valueForKey:@"tag"] integerValue];
        if (tag == selectTag) {
            [recordTemplateSelectedStateDic setValue:@(1) forKey:cellName];
        } else {
            [recordTemplateSelectedStateDic setValue:@(0) forKey:cellName];
        }
    }
    
    [self.performanceTableView reloadData];
    
    if (selectTag == [singleBarcodeTag integerValue]) {
        
        self.currentTemplateType = EnumTemplateTypeSingleBarcode;
    } else if (selectTag == [speedFirstTag integerValue]) {
       
        self.currentTemplateType = EnumTemplateTypeSpeedFirst;
    } else if (selectTag == [readRateFirstTag integerValue]) {
       
        self.currentTemplateType = EnumTemplateTypeReadRateFirst;
    } else if (selectTag == [accuracyFirstTag integerValue]) {
        
        self.currentTemplateType = EnumTemplateTypeAccuracyFirst;
    }
    [self dbrSwitchcTemplate];
}

/// handle question
- (void)handleQuestionWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *itemDic = templateDataArray[indexPath.row];
    NSInteger selectTag = [[itemDic valueForKey:@"tag"] integerValue];
    if (selectTag == [singleBarcodeTag integerValue]) {
        [[ToolsHandle toolManger] addAlertViewWithTitle:@"Single Barcode Scanning" Content:singleBarcodeExplain actionTitle:nil ToView:self completion:^{
                    
        }];
        
    } else if (selectTag == [speedFirstTag integerValue]) {
        [[ToolsHandle toolManger] addAlertViewWithTitle:@"Speed First Settings" Content:speedFirstExplain actionTitle:nil ToView:self completion:^{
                    
        }];
        
    } else if (selectTag == [readRateFirstTag integerValue]) {
        [[ToolsHandle toolManger] addAlertViewWithTitle:@"Read Rate First Template" Content:readRateFirstExplain actionTitle:nil ToView:self completion:^{
                    
        }];
        
    } else if (selectTag == [accuracyFirstTag integerValue]) {
        [[ToolsHandle toolManger] addAlertViewWithTitle:@"Accuracy First Template" Content:accuracyFirstExplain actionTitle:nil ToView:self completion:^{
                    
        }];
        
    }
}

//MARK: configureDBR and DCE
- (void)configureDBR
{
    iDMDLSConnectionParameters *dls = [[iDMDLSConnectionParameters alloc] init];
    // Initialize license for Dynamsoft Barcode Reader.
    // The organization id 200001 here will grant you a public trial license good for 7 days. Note that network connection is required for this license to work.
    // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
    // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
    dls.organizationID = @"200001";
    
    self.barcodeReader = [[DynamsoftBarcodeReader alloc] initLicenseFromDLS:dls verificationDelegate:self];
  
    [self.barcodeReader setDBRTextResultDelegate:self userData:nil];
    
    // set template
    [self dbrSwitchcTemplate];
}

- (void)configureDCE
{
    self.dceView = [[DCECameraView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight - kStatusBarHeight)];
    [self.view addSubview:self.dceView];
    
    [DynamsoftCameraEnhancer initLicense:@"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" verificationDelegate:self];
    self.dce = [[DynamsoftCameraEnhancer alloc] initWithView:self.dceView];
    [self.dce open];

    // DBR link DCE
    [self.barcodeReader setCameraEnhancer:self.dce];

    // DBR start decode
    [self.barcodeReader startScanning];
}

//MARK: DMDLSLicenseVerificationDelegate
- (void)DLSLicenseVerificationCallback:(bool)isSuccess error:(NSError *)error{

    NSLog(@"%@", isSuccess ? @"DLS_vertify_success!":@"DLS_vertify_failure!");
    [self verificationCallback:error];
}

- (void)verificationCallback:(NSError *)error{

    NSString* msg = @"";
    if(error != nil)
    {
        __weak RootViewController *weakSelf = self;
        if (error.code == -1009) {
            msg = @"Unable to connect to the public Internet to acquire a license. Please connect your device to the Internet or contact support@dynamsoft.com to acquire an offline license.";
            [self showResult:@"No Internet"
                         msg:msg
                     acTitle:@"Try Again"
                  completion:^{
                [weakSelf configureDBR];
                [weakSelf configureDCE];
                  }];
        }else{
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

//MARK: DBRTextResultDelegate
// Obtain the barcode results from the callback and display the results.
- (void)textResultCallback:(NSInteger)frameId results:(NSArray<iTextResult *> *)results userData:(NSObject *)userData{

    if (results.count > 0) {

        weakSelfs(self)
        // use dbr stopScanning
        if (self.currentDecodeStyle == DecodeStyle_Video) {

            /**
             You can comment out this line of code to experience faster continuous decoding.
             Or open this line to experience decoding at intervals
             */
          //  [self.barcodeReader stopScanning];
        } else {
            [self.barcodeReader stopScanning];
  
        }
        
        // use dbr startScanning
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.decodeResultsView showDecodeResultWith:results location:EnumDecodeResultsLocationBottom completion:^{
                [weakSelf.barcodeReader startScanning];
          
            }];
        });
    }else{
        return;
    }
}

- (void)handleImageDecodeResults:(NSArray<iTextResult *> *)results err:(NSError*__nullable)error{
    weakSelfs(self)
    if (results.count > 0) {
        NSString *title = @"Results";
        NSString *msgText = @"";
        NSString *msg = @"Please visit: https://www.dynamsoft.com/customer/license/trialLicense?";
        for (NSInteger i = 0; i< [results count]; i++) {
            if (results[i].exception != nil && [results[i].exception containsString:msg]) {
                msgText = [msg stringByAppendingString:@"product=dbr&utm_source=installer&package=ios to request for 30 days extension."];
                title = @"Exception";
                break;
            }
            if (results[i].barcodeFormat_2 != 0) {
                msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString_2, results[i].barcodeText]];
            }else{
                msgText = [msgText stringByAppendingString:[NSString stringWithFormat:@"\nFormat: %@\nText: %@\n", results[i].barcodeFormatString, results[i].barcodeText]];
            }
        }
        [self showResult:title
                     msg:msgText
                 acTitle:@"OK"
              completion:^{
            // change currentDecodeStyle to video
            weakSelf.currentDecodeStyle = DecodeStyle_Video;
            [weakSelf dbrSwitchcTemplate];
            [weakSelf switchScanStyle];
            
              }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->loadingView stopAnimating];
        });
    }else{
       
        NSString *msg = error.code == 0 ? @"" : error.userInfo[NSUnderlyingErrorKey];
        [self showResult:@"No result" msg:msg  acTitle:@"OK" completion:^{
            // change currentDecodeStyle to video
            weakSelf.currentDecodeStyle = DecodeStyle_Video;
            [weakSelf dbrSwitchcTemplate];
            [weakSelf switchScanStyle];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->loadingView stopAnimating];
        });
    }
}

#pragma mark - Photo album authorization
- (void)getAlertActionType:(NSInteger)type {
    NSInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (type == 1) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else if (type == 2) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self creatUIImagePickerControllerWithAlertActionType:sourceType];
}

- (void)creatUIImagePickerControllerWithAlertActionType:(NSInteger)type {
    sourceType = type;
    NSInteger cameragranted = [self AVAuthorizationStatusIsGranted];
    
    // change currentDecodeStyle to image
    self.currentDecodeStyle = DecodeStyle_Image;
    [self dbrSwitchcTemplate];
    [self switchScanStyle];
    
    [self.selectPictureButton setEnabled:YES];
    
   
    if (cameragranted == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                                                                                 message:@"Settings-Privacy-Camera/Album-Authorization"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertController addAction:comfirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (cameragranted == 1) {
        [self presentPickerViewController];
    }
}

- (NSInteger)AVAuthorizationStatusIsGranted{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatusVideo = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    PHAuthorizationStatus authStatusAlbm  = [PHPhotoLibrary authorizationStatus];
    NSInteger authStatus = sourceType == UIImagePickerControllerSourceTypePhotoLibrary ? authStatusAlbm : authStatusVideo;
    NSLog(@"----authStatus:%ld", authStatus);
    switch (authStatus) {
        case 0: {
            if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        [self presentPickerViewController];
                    }
                }];
            }else{
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        [self presentPickerViewController];
                    }
                }];
            }
        }
            return 2;
        case 1: return 0;
        case 2: return 0;
        case 3: return 1;
        default:return 0;
    }
}

- (void)presentPickerViewController{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        if (@available(iOS 11.0, *)){
            [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
        }
        picker.delegate = self;
        picker.sourceType = self->sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    });
}

#pragma mark - UIImagePicker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // should switch to decodeStyle_video
    self.currentDecodeStyle = DecodeStyle_Video;
    [self dbrSwitchcTemplate];
    [self switchScanStyle];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self->loadingView startAnimating];
        NSError* error = [[NSError alloc] init];
        // image decode
        NSArray<iTextResult*>* results = [self->_barcodeReader decodeImage:image withTemplate:@"" error:&error];
        [self handleImageDecodeResults:results err:error];
    });
    
    [picker dismissViewControllerAnimated:YES completion:nil];
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
