//
//  CameraSettingsViewController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/19.
//

#import "CameraSettingsViewController.h"

/**
 You can custom you region you like when DCE is first setScanRegion.This sample is set to (0,100,0,100).
 */
static BOOL dceIsFirstOpenScanRegion = YES;

@interface CameraSettingsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *cameraSettingsDataArray;
    /**
     Record DCE switch state dic.
     */
    NSMutableDictionary *recordDCESwitchStateDic;
    
    /**
     Record scanRegion dic.
     */
    NSMutableDictionary *recordScanRegionValueDic;
    
    /**
    Save DCE resolution available value.
     */
    NSArray *resolutionOptionalArray;
    
    /**
     Save DCE resolution selected dic.
     */
    NSDictionary *saveResolutionSelectedDic;
    
}

@property (nonatomic, strong) UITableView *cameraSettingsTableView;

@end

@implementation CameraSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Camera Settings";
    
    [self handleData];
    
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    resolutionOptionalArray = @[
      @{@"showName":@"480p", @"valueTag":@(EnumRESOLUTION_480P)},
      @{@"showName":@"720p", @"valueTag":@(EnumRESOLUTION_720P)},
      @{@"showName":@"1080p", @"valueTag":@(EnumRESOLUTION_1080P)},
      @{@"showName":@"4k", @"valueTag":@(EnumRESOLUTION_4K)}
    ];
    
    NSInteger resolutionValue = [GeneralSettingsHandle setting].dceResolution.selectedResolutionValue;
    
    for (NSDictionary *resolutionDic in resolutionOptionalArray) {
        NSInteger valueTag = [[resolutionDic valueForKey:@"valueTag"] integerValue];
        if (resolutionValue == valueTag) {
            saveResolutionSelectedDic = resolutionDic;
            break;
        }
        
    }

    
}

- (void)keyboardWillShow:(NSNotification*)noti
{
    self.view.transform = CGAffineTransformMakeTranslation(0, -100);
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    self.view.transform = CGAffineTransformIdentity;
}

- (void)handleData
{
    cameraSettingsDataArray = [NSMutableArray array];
    recordDCESwitchStateDic = [NSMutableDictionary dictionary];
    recordScanRegionValueDic = [NSMutableDictionary dictionary];
    
    // Array
    NSArray *basicDataArray = @[[GeneralSettingsHandle setting].cameraSettings.dceResolution,
                                [GeneralSettingsHandle setting].cameraSettings.dceVibrate,
                                [GeneralSettingsHandle setting].cameraSettings.dceBeep,
                                [GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocus,
                                [GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilter,
                                [GeneralSettingsHandle setting].cameraSettings.dceSensorFilter,
                                [GeneralSettingsHandle setting].cameraSettings.dceAutoZoom,
                                [GeneralSettingsHandle setting].cameraSettings.dceFastMode,
                                [GeneralSettingsHandle setting].cameraSettings.smartTorch,
                                [GeneralSettingsHandle setting].cameraSettings.dceScanRegion
    ];
    [cameraSettingsDataArray addObjectsFromArray:basicDataArray];
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceScanRegionIsOpen == YES) {
        NSArray *scanRegionArray = @[[GeneralSettingsHandle setting].scanRegion.scanRegionTop,
                                     [GeneralSettingsHandle setting].scanRegion.scanRegionBottom,
                                     [GeneralSettingsHandle setting].scanRegion.scanRegionLeft,
                                     [GeneralSettingsHandle setting].scanRegion.scanRegionRight
        ];
        [cameraSettingsDataArray addObjectsFromArray:scanRegionArray];
        
        // scanRegionDic
        [recordScanRegionValueDic setValue:@([GeneralSettingsHandle setting].scanRegion.scanRegionTopValue) forKey:[GeneralSettingsHandle setting].scanRegion.scanRegionTop];
        [recordScanRegionValueDic setValue:@([GeneralSettingsHandle setting].scanRegion.scanRegionBottomValue) forKey:[GeneralSettingsHandle setting].scanRegion.scanRegionBottom];
        [recordScanRegionValueDic setValue:@([GeneralSettingsHandle setting].scanRegion.scanRegionLeftValue) forKey:[GeneralSettingsHandle setting].scanRegion.scanRegionLeft];
        [recordScanRegionValueDic setValue:@([GeneralSettingsHandle setting].scanRegion.scanRegionRightValue) forKey:[GeneralSettingsHandle setting].scanRegion.scanRegionRight];
    }
    
    // Switch state dic
    if ([GeneralSettingsHandle setting].cameraSettings.dceVibrateIsOpen == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].cameraSettings.dceVibrate];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].cameraSettings.dceVibrate];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceBeepIsOpen == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].cameraSettings.dceBeep];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].cameraSettings.dceBeep];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocusIsOpen == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocus];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocus];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilterIsOpen == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilter];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilter];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceSensorFilterIsOpen == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].cameraSettings.dceSensorFilter];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].cameraSettings.dceSensorFilter];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceAutoZoomIsOpen == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].cameraSettings.dceAutoZoom];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].cameraSettings.dceAutoZoom];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceFastModeIsOpen == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].cameraSettings.dceFastMode];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].cameraSettings.dceFastMode];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceSmartTorchIsOpen == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].cameraSettings.smartTorch];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].cameraSettings.smartTorch];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceScanRegionIsOpen == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].cameraSettings.dceScanRegion];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].cameraSettings.dceScanRegion];
    }
}

- (void)setupUI
{
    self.cameraSettingsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.cameraSettingsTableView.backgroundColor = [UIColor whiteColor];
    self.cameraSettingsTableView.delegate = self;
    self.cameraSettingsTableView.dataSource = self;
    self.cameraSettingsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.cameraSettingsTableView];
}

// MARK: - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cameraSettingsDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BasicTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dceSettingString = cameraSettingsDataArray[indexPath.row];
    
    weakSelfs(self)
    
    if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceResolution]) {
        static NSString *identifier = @"basicPullCellIdentifier";
        BasicPullTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicPullTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }

        [cell updateUIWithTitle:dceSettingString andContentString:[saveResolutionSelectedDic valueForKey:@"showName"]];
        return cell;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceVibrate] ||
               [dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceBeep] ||
               [dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocus] ||
               [dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilter] ||
               [dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceSensorFilter] ||
               [dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceAutoZoom] ||
               [dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceFastMode] ||
               [dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.smartTorch] ||
               [dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceScanRegion]
               ) {
        NSInteger switchSelectState = [[recordDCESwitchStateDic valueForKey:dceSettingString] integerValue];
        static NSString *identifier = @"basicSwitchCellIdentifier";
        BasicSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceVibrate] || [dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceBeep]) {
            cell.questionButton.hidden = YES;
        } else {
            cell.questionButton.hidden = NO;
        }
    
        cell.questionBlock = ^{
            [weakSelf handleDCEExplainWithIndexPath:indexPath settingString:dceSettingString];
        };
        
        cell.switchChangedBlock = ^(BOOL isOn) {
            [weakSelf handleDCESettingSwitchWithIndexPath:indexPath settingString:dceSettingString andSwitchState:isOn];
        };
 
        [cell updateUIWithTitle:dceSettingString withSwitchState:switchSelectState];
        return cell;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].scanRegion.scanRegionTop] || [dceSettingString isEqualToString:[GeneralSettingsHandle setting].scanRegion.scanRegionBottom] || [dceSettingString isEqualToString:[GeneralSettingsHandle setting].scanRegion.scanRegionLeft] || [dceSettingString isEqualToString:[GeneralSettingsHandle setting].scanRegion.scanRegionRight]) {
        
        NSInteger scanRegionValue = [[recordScanRegionValueDic valueForKey:dceSettingString] integerValue];
        static NSString *identifier = @"basicTextCellIdentifier";
        BasicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.inputTFValueChangedBlock = ^(NSInteger numValue) {
            [weakSelf handleScanRegionWithIndexPath:indexPath settingString:dceSettingString scanRegionInputValue:numValue];
        };
        
        [cell setDefaultValue:scanRegionValue];
        [cell setInputCountTFMaxValueWithNum:100];
        [cell setTitleOffset:20.0];
        [cell updateUIWithTitle:dceSettingString value:scanRegionValue];
        cell.questionButton.hidden = YES;
        return cell;
        
        
    }
    static NSString *identifier = @"basicCellIdentifier";
    BasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BasicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    [cell updateUIWithTitle:dceSettingString];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dceSettingString = cameraSettingsDataArray[indexPath.row];
    
    if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceResolution]) {
        
        [PullListView showPullListViewWithArray:resolutionOptionalArray titleName:@"Resolution" selectedDicInfo:saveResolutionSelectedDic completion:^(NSDictionary * _Nonnull selectedDic) {
            [self handleSelectedResolutionWithDic:selectedDic];

        }];
    }
}

- (void)handleSelectedResolutionWithDic:(NSDictionary *)selectedDic
{
    saveResolutionSelectedDic = selectedDic;
    
    DCEResolution dceResolution = [GeneralSettingsHandle setting].dceResolution;
    NSInteger resolution = [[selectedDic valueForKey:@"valueTag"] integerValue];
    dceResolution.selectedResolutionValue = resolution;
    [GeneralSettingsHandle setting].dceResolution = dceResolution;
    
    // Set DCE resolution
    [[GeneralSettingsHandle setting].cameraEnhancer setResolution:resolution];
    
    [self.cameraSettingsTableView reloadData];
}

// MARK: - HandleOperation

/**
 DCE parameter switch changed
 */
// Enhanced focus feature of Dynamsoft Camera Enhancer will enhance the focus ability of low-end device.
// Frame filter feature of Dynamsoft Camera Enhancer will filter out the blurry video frame.
// Sensor filter feature of Dynamsoft Camera Enhancer will filter out the frames captured when the device is shaking.
// Auto zoom feature of Dynamsoft Camera Enhancer will enable the camera to zoom in to apporach the barcodes.
// Fast mode feature of Dynamsoft Camera Enhancer will crop the frames to reduce the processing size.
- (void)handleDCESettingSwitchWithIndexPath:(NSIndexPath *)indexPath settingString:(NSString *)dceSettingString andSwitchState:(BOOL)isOn
{
    
    CameraSettings setting = [GeneralSettingsHandle setting].cameraSettings;
    ScanRegion scanRegion = [GeneralSettingsHandle setting].scanRegion;
    NSError *error = nil;
    
    if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceVibrate]) {
        setting.dceVibrateIsOpen = isOn;
        [GeneralSettingsHandle setting].cameraSettings = setting;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceBeep]) {
        setting.dceBeepIsOpen = isOn;
        [GeneralSettingsHandle setting].cameraSettings = setting;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocus]) {
       
        if (isOn) {
            [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumENHANCED_FOCUS error:&error];
        } else {
            [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumENHANCED_FOCUS];
        }
        
        if (error != nil) {
            [self enableFeatureSettingFailure:error];
            return;
        }
        
        setting.dceEnhancedFocusIsOpen = isOn;
        [GeneralSettingsHandle setting].cameraSettings = setting;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilter]) {
        
        if (isOn) {
            [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumFRAME_FILTER error:&error];
        } else {
            [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumFRAME_FILTER];
        }
        
        if (error != nil) {
            [self enableFeatureSettingFailure:error];
            return;
        }
        
        setting.dceFrameSharpnessFilterIsOpen = isOn;
        [GeneralSettingsHandle setting].cameraSettings = setting;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceSensorFilter]) {
        
        if (isOn) {
            [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumSENSOR_CONTROL error:&error];
        } else {
            [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumSENSOR_CONTROL];
        }
        
        if (error != nil) {
            [self enableFeatureSettingFailure:error];
            return;
        }
        
        setting.dceSensorFilterIsOpen = isOn;
        [GeneralSettingsHandle setting].cameraSettings = setting;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceAutoZoom]) {
        
        if (isOn) {
            [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumAUTO_ZOOM error:&error];
        } else {
            [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumAUTO_ZOOM];
        }
        
        if (error != nil) {
            [self enableFeatureSettingFailure:error];
            return;
        }
        
        setting.dceAutoZoomIsOpen = isOn;
        [GeneralSettingsHandle setting].cameraSettings = setting;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceFastMode]) {
        
        if (isOn) {
            [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumFAST_MODE error:&error];
        } else {
            [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumFAST_MODE];
        }
        
        if (error != nil) {
            [self enableFeatureSettingFailure:error];
            return;
        }
        
        setting.dceFastModeIsOpen = isOn;
        [GeneralSettingsHandle setting].cameraSettings = setting;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.smartTorch]) {
        
        if (isOn) {
            [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumSMART_TORCH error:&error];
        } else {
            [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumSMART_TORCH];
        }
        
        if (error != nil) {
            [self enableFeatureSettingFailure:error];
            return;
        }
        
        setting.dceSmartTorchIsOpen = isOn;
        [GeneralSettingsHandle setting].cameraSettings = setting;
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceScanRegion]) {
     
        if (isOn) {
            
            if (dceIsFirstOpenScanRegion) {
                dceIsFirstOpenScanRegion = NO;
                scanRegion.scanRegionTopValue = 0;
                scanRegion.scanRegionBottomValue = 100;
                scanRegion.scanRegionLeftValue = 0;
                scanRegion.scanRegionRightValue = 100;
                [GeneralSettingsHandle setting].scanRegion = scanRegion;

                NSError *scanRegionError = nil;
                iRegionDefinition *dceScanRegion = [[iRegionDefinition alloc] init];
                dceScanRegion.regionTop = scanRegion.scanRegionTopValue;
                dceScanRegion.regionBottom = scanRegion.scanRegionBottomValue;
                dceScanRegion.regionLeft = scanRegion.scanRegionLeftValue;
                dceScanRegion.regionRight = scanRegion.scanRegionRightValue;
                dceScanRegion.regionMeasuredByPercentage = 1;

                [[GeneralSettingsHandle setting].cameraEnhancer setScanRegion:dceScanRegion error:&scanRegionError];
                if (scanRegionError != nil) {
                    [self dceScanRegionSettingFailure:scanRegionError];
                    return;
                }
            } else {// You should only set scanRegionVisble to true.
                [[GeneralSettingsHandle setting].cameraEnhancer setScanRegionVisible:true];
            }

        } else {
            // Should set scanRegionVisble to false.
            [[GeneralSettingsHandle setting].cameraEnhancer setScanRegionVisible:false];
        }
        
        setting.dceScanRegionIsOpen = isOn;
        [GeneralSettingsHandle setting].cameraSettings = setting;
    }
    
    if (isOn == YES) {
        [recordDCESwitchStateDic setValue:@(1) forKey:dceSettingString];
    } else {
        [recordDCESwitchStateDic setValue:@(0) forKey:dceSettingString];
    }
    
    [self handleData];
    [self.cameraSettingsTableView reloadData];
}

- (void)enableFeatureSettingFailure:(NSError *)error
{
    NSString *msg = error.userInfo[NSUnderlyingErrorKey];
    [[ToolsHandle toolManger] addAlertViewWithTitle:@"" Content:msg actionTitle:nil ToView:self completion:^{
        [self handleData];
        [self.cameraSettingsTableView reloadData];
    }];
}

/// Configure DCE scanRegion.
/// The scanRegion will helps the barcode reader to reduce the processing time.
/// Set the scanRegion with a nil value will reset the scanRegion to the default status.
- (void)handleScanRegionWithIndexPath:(NSIndexPath *)indexPath settingString:(NSString *)dceSettingString scanRegionInputValue:(NSInteger)numValue
{
    NSError *scanRegionError = nil;
    
    iRegionDefinition *dceScanRegion = [[iRegionDefinition alloc] init];
    ScanRegion scanRegion = [GeneralSettingsHandle setting].scanRegion;
  
    if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].scanRegion.scanRegionTop]) {// SettingScanRegionTop.
        
        dceScanRegion.regionTop = numValue;
        dceScanRegion.regionBottom = scanRegion.scanRegionBottomValue;
        dceScanRegion.regionLeft = scanRegion.scanRegionLeftValue;
        dceScanRegion.regionRight = scanRegion.scanRegionRightValue;
        dceScanRegion.regionMeasuredByPercentage = 1;
        
        [[GeneralSettingsHandle setting].cameraEnhancer setScanRegion:dceScanRegion error:&scanRegionError];
        
        if (scanRegionError != nil) {
            [self dceScanRegionSettingFailure:scanRegionError];
            return;
        }
        
        scanRegion.scanRegionTopValue = numValue;
        [GeneralSettingsHandle setting].scanRegion = scanRegion;
        
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].scanRegion.scanRegionBottom]) {// SettingScanRegionBottom.
        
        dceScanRegion.regionTop = scanRegion.scanRegionTopValue;
        dceScanRegion.regionBottom = numValue;
        dceScanRegion.regionLeft = scanRegion.scanRegionLeftValue;
        dceScanRegion.regionRight = scanRegion.scanRegionRightValue;
        dceScanRegion.regionMeasuredByPercentage = 1;
        
        [[GeneralSettingsHandle setting].cameraEnhancer setScanRegion:dceScanRegion error:&scanRegionError];
        
        if (scanRegionError != nil) {
            [self dceScanRegionSettingFailure:scanRegionError];
            return;
        }
        
        scanRegion.scanRegionBottomValue = numValue;
        [GeneralSettingsHandle setting].scanRegion = scanRegion;

    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].scanRegion.scanRegionLeft]) {// SettingScanRegionLeft.
        
        dceScanRegion.regionTop = scanRegion.scanRegionTopValue;
        dceScanRegion.regionBottom = scanRegion.scanRegionBottomValue;
        dceScanRegion.regionLeft = numValue;
        dceScanRegion.regionRight = scanRegion.scanRegionRightValue;
        dceScanRegion.regionMeasuredByPercentage = 1;
        
        [[GeneralSettingsHandle setting].cameraEnhancer setScanRegion:dceScanRegion error:&scanRegionError];
        
        if (scanRegionError != nil) {
            [self dceScanRegionSettingFailure:scanRegionError];
            return;
        }
        
        scanRegion.scanRegionLeftValue = numValue;
        [GeneralSettingsHandle setting].scanRegion = scanRegion;
        
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].scanRegion.scanRegionRight]) {// SettingScanRegionRight.
        
        dceScanRegion.regionTop = scanRegion.scanRegionTopValue;
        dceScanRegion.regionBottom = scanRegion.scanRegionBottomValue;
        dceScanRegion.regionLeft = scanRegion.scanRegionLeftValue;
        dceScanRegion.regionRight = numValue;
        dceScanRegion.regionMeasuredByPercentage = 1;
        
        [[GeneralSettingsHandle setting].cameraEnhancer setScanRegion:dceScanRegion error:&scanRegionError];
        
        if (scanRegionError != nil) {
            [self dceScanRegionSettingFailure:scanRegionError];
            return;
        }
        
        scanRegion.scanRegionRightValue = numValue;
        [GeneralSettingsHandle setting].scanRegion = scanRegion;
    }
    
    [self handleData];
    [self.cameraSettingsTableView reloadData];
        
}

- (void)dceScanRegionSettingFailure:(NSError *)error
{
    NSString *msg = error.userInfo[NSUnderlyingErrorKey];
    [[ToolsHandle toolManger] addAlertViewWithTitle:@"" Content:msg actionTitle:nil ToView:self completion:^{
        [self handleData];
        [self.cameraSettingsTableView reloadData];
    }];
}

/// Parameter explain.
- (void)handleDCEExplainWithIndexPath:(NSIndexPath *)indexPath settingString:(NSString *)dceSettingString
{
    if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocus]) {
       
        [[ToolsHandle toolManger] addAlertViewWithTitle:[GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocus Content:enhancedFocusExplain actionTitle:nil ToView:self completion:^{
                    
        }];
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilter]) {
        
        [[ToolsHandle toolManger] addAlertViewWithTitle:[GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilter Content:frameSharpnessFilterExplain actionTitle:nil ToView:self completion:^{
                    
        }];
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceSensorFilter]) {
        
        [[ToolsHandle toolManger] addAlertViewWithTitle:[GeneralSettingsHandle setting].cameraSettings.dceSensorFilter Content:sensorFilterExplain actionTitle:nil ToView:self completion:^{
                    
        }];
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceAutoZoom]) {
        
        [[ToolsHandle toolManger] addAlertViewWithTitle:[GeneralSettingsHandle setting].cameraSettings.dceAutoZoom Content:autoZoomExplain actionTitle:nil ToView:self completion:^{
                    
        }];
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceFastMode]) {
        
        [[ToolsHandle toolManger] addAlertViewWithTitle:[GeneralSettingsHandle setting].cameraSettings.dceFastMode Content:fastModeExplain actionTitle:nil ToView:self completion:^{
                    
        }];
    }  else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.smartTorch]) {
        
        [[ToolsHandle toolManger] addAlertViewWithTitle:[GeneralSettingsHandle setting].cameraSettings.smartTorch Content:smartTorchExplain actionTitle:nil ToView:self completion:^{
                    
        }];
    } else if ([dceSettingString isEqualToString:[GeneralSettingsHandle setting].cameraSettings.dceScanRegion]) {
        
        [[ToolsHandle toolManger] addAlertViewWithTitle:[GeneralSettingsHandle setting].cameraSettings.dceScanRegion Content:dceScanRegionExplain actionTitle:nil ToView:self completion:^{
                    
        }];
    }
}


@end
