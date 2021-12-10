//
//  SettingsViewController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/19.
//

#import "SettingsViewController.h"

static NSString *barcodeSettingTag      = @"100";
static NSString *cameraSettingTag       = @"101";
static NSString *viewSettingTag         = @"102";
static NSString *resetAllSettingTag        = @"103";

@interface SettingsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *settingDataArray;
}
@property (nonatomic, strong) UITableView *settingTableView;

@end

@implementation SettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
   
    self.title = @"Settings";

    
    settingDataArray = @[@{@"name":@"Barcode", @"tag":barcodeSettingTag},
                         @{@"name":@"Camera", @"tag":cameraSettingTag},
                         @{@"name":@"View", @"tag":viewSettingTag},
                         @{@"name":@"Reset All Settings", @"tag":resetAllSettingTag}
    ];
    
    [self setupUI];
}

- (void)setupUI
{
    self.settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.settingTableView.backgroundColor = [UIColor whiteColor];
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    self.settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.settingTableView];
}


//MARK: UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return settingDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BasicTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *itemDic = settingDataArray[indexPath.row];
    NSString *title = [itemDic valueForKey:@"name"];
    NSInteger selectTag = [[itemDic valueForKey:@"tag"] integerValue];
    static NSString *identifier = @"basicCellIdentifier";
    BasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BasicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (selectTag == [resetAllSettingTag integerValue]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell updateUIWithTitle:title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *itemDic = settingDataArray[indexPath.row];
    NSInteger selectTag = [[itemDic valueForKey:@"tag"] integerValue];
    UIViewController *pushVC = nil;
    if (selectTag == [barcodeSettingTag integerValue]) {
        pushVC = [[NSClassFromString(@"BarcodeSettingsViewController") alloc] init];
    } else if (selectTag == [cameraSettingTag integerValue]) {
        pushVC = [[NSClassFromString(@"CameraSettingsViewController") alloc] init];
    } else if (selectTag == [viewSettingTag integerValue]) {
        pushVC = [[NSClassFromString(@"ViewSettingsViewController") alloc] init];
    } else if (selectTag == [resetAllSettingTag integerValue]) {
        NSLog(@"reset all settings");
        [self resetToDefault];
    }
   
    if (!pushVC) {
        return;
    }
   

    [self.navigationController pushViewController:pushVC animated:YES];
  
}

- (void)resetToDefault
{
    // You can use dbr resetRuntimeSettings to set all runtime parameters to default
//    NSError *resetError = nil;
//    [[GeneralSettingsHandle setting].barcodeReader resetRuntimeSettings:&resetError];
    
    // Or like this set iPublicRuntimeSettings to default
    // barcode settings
    // barcodeFormat to default
    iPublicRuntimeSettings *setting = [GeneralSettingsHandle setting].ipublicRuntimeSettings;
    setting.barcodeFormatIds = EnumBarcodeFormatALL;
    setting.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;
   
    
    // expect count to default
    setting.expectedBarcodesCount = 0;
    [GeneralSettingsHandle setting].ipublicRuntimeSettings = setting;
    
    [[GeneralSettingsHandle setting] updateIpublicRuntimeSettings];
    
    // continuous scan to YES
    [GeneralSettingsHandle setting].continuousScan = YES;
    
    // camera settings
    // set resolution to default
    DCEResolution dceResolution = [GeneralSettingsHandle setting].dceResolution;
    dceResolution.selectedResolutionValue = EnumRESOLUTION_HIGH;
    [GeneralSettingsHandle setting].dceResolution = dceResolution;
    [[GeneralSettingsHandle setting].cameraEnhancer setResolution:EnumRESOLUTION_HIGH];
    
    // set feature mode to default
    CameraSettings cameraSettings = [GeneralSettingsHandle setting].cameraSettings;
    cameraSettings.dceEnhancedFocusIsOpen = NO;
    cameraSettings.dceFrameSharpnessFilterIsOpen = NO;
    cameraSettings.dceSensorFilterIsOpen = NO;
    cameraSettings.dceAutoZoomIsOpen = NO;
    cameraSettings.dceFastModeIsOpen = NO;
    cameraSettings.dceScanRegionIsOpen = NO;
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocusIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumENHANCED_FOCUS];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilterIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumFRAME_FILTER];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceSensorFilterIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumSENSOR_CONTROL];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceAutoZoomIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumAUTO_ZOOM];
    }
    
    if ([GeneralSettingsHandle setting].cameraSettings.dceFastModeIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumFAST_MODE];
    }
    [GeneralSettingsHandle setting].cameraSettings = cameraSettings;
    
    // set scan region to default
    ScanRegion scanRegion = [GeneralSettingsHandle setting].scanRegion;
    
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
   
    // set scanRegionVisible to false
    [[GeneralSettingsHandle setting].cameraEnhancer setScanRegionVisible:false];
    
    // view settings
    // DCE view set to default
    DCEViewSettings dceViewSettings = [GeneralSettingsHandle setting].dceViewSettings;
    dceViewSettings.displayOverlayIsOpen = YES;
    dceViewSettings.displayTorchButtonIsOpen = NO;
    [GeneralSettingsHandle setting].dceViewSettings = dceViewSettings;
    
    [GeneralSettingsHandle setting].cameraView.overlayVisible = true;
    [GeneralSettingsHandle setting].cameraView.torchButtonVisible = false;
    
    [[ToolsHandle toolManger] addAlertViewWithTitle:@"" Content:@"Reset Successfully" actionTitle:nil ToView:self completion:^{
            
    }];
}

- (void)dceScanRegionSettingFailure:(NSError *)error
{
    NSString *msg = error.userInfo[NSUnderlyingErrorKey];
    [[ToolsHandle toolManger] addAlertViewWithTitle:@"" Content:msg actionTitle:nil ToView:self completion:^{
     
    }];
}


@end
