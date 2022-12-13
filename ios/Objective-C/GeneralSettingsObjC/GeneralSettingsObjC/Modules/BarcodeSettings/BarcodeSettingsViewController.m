//
//  BarcodeSettingsViewController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/19.
//

#import "BarcodeSettingsViewController.h"
#import "BasicSwitchTableViewCell.h"
#import "BarcodeFormatDetailViewController.h"

// The barcode formats and barcode count settings are common for barcode reader.
// Specifying the barcode formats will help you improve the performance of the barcode reader.
// The less barcode count, the higher processing speed.
// For unknown usage scenarios, set the barcode count to 0. The barcode reader will try to decode at least one barcode.

@interface BarcodeSettingsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *barcodeSettingDataArray;
    
    /**
     Record DBR switch state dic.
     */
    NSMutableDictionary *recordDBRSwitchStateDic;
    
    NSInteger expectedCount;
    NSInteger minimumResultConfidence;
    NSInteger duplicateForgetTime;
    NSInteger minimumDecodeInterval;
    
    
}
@property (nonatomic, strong) UITableView *barcodeSettingTableView;

@end

@implementation BarcodeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Barcode Settings";
    
    [self handleData];
    [self setupUI];
}

- (void)handleData {
   
    recordDBRSwitchStateDic = [NSMutableDictionary dictionary];
    
    // Array.
    if ([GeneralSettingsHandle setting].barcodeSettings.duplicateFliterIsOpen) {
        barcodeSettingDataArray = @[[GeneralSettingsHandle setting].barcodeSettings.barcodeFormatStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.expectedCountStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.continuousScanStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.minimumResultConfidenceStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.resultVerificationStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.duplicateFliterStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.duplicateForgetTimeStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.minimumDecodeIntervalStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.decodeInvertedBarcodesStr
        ];
    } else {
        barcodeSettingDataArray = @[[GeneralSettingsHandle setting].barcodeSettings.barcodeFormatStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.expectedCountStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.continuousScanStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.minimumResultConfidenceStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.resultVerificationStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.duplicateFliterStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.minimumDecodeIntervalStr,
                                    [GeneralSettingsHandle setting].barcodeSettings.decodeInvertedBarcodesStr
        ];
    }
    
    // Switch state dic.
    if ([GeneralSettingsHandle setting].barcodeSettings.continuousScanIsOpen == YES) {
        [recordDBRSwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].barcodeSettings.continuousScanStr];
    } else {
        [recordDBRSwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].barcodeSettings.continuousScanStr];
    }
    
    if ([GeneralSettingsHandle setting].barcodeSettings.resultVerificationIsOpen == YES) {
        [recordDBRSwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].barcodeSettings.resultVerificationStr];
    } else {
        [recordDBRSwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].barcodeSettings.resultVerificationStr];
    }
    
    if ([GeneralSettingsHandle setting].barcodeSettings.duplicateFliterIsOpen == YES) {
        [recordDBRSwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].barcodeSettings.duplicateFliterStr];
    } else {
        [recordDBRSwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].barcodeSettings.duplicateFliterStr];
    }
    
    if ([GeneralSettingsHandle setting].barcodeSettings.decodeInvertedBarcodesIsOpen == YES) {
        [recordDBRSwitchStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].barcodeSettings.decodeInvertedBarcodesStr];
    } else {
        [recordDBRSwitchStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].barcodeSettings.decodeInvertedBarcodesStr];
    }
    
    expectedCount = [GeneralSettingsHandle setting].barcodeSettings.expectedCount;
    minimumResultConfidence = [GeneralSettingsHandle setting].barcodeSettings.minimumResultConfidence;
    duplicateForgetTime = [GeneralSettingsHandle setting].barcodeSettings.duplicateForgetTime;
    minimumDecodeInterval = [GeneralSettingsHandle setting].barcodeSettings.minimumDecodeInterval;
}

- (void)setupUI
{
    self.barcodeSettingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.barcodeSettingTableView.backgroundColor = [UIColor whiteColor];
    self.barcodeSettingTableView.delegate = self;
    self.barcodeSettingTableView.dataSource = self;
    self.barcodeSettingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.barcodeSettingTableView];
}


// MARK: - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return barcodeSettingDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BasicTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleString = barcodeSettingDataArray[indexPath.row];
    
    weakSelfs(self)
    if ([titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.barcodeFormatStr]) {
        static NSString *identifier = @"basicCellIdentifier";
        BasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell updateUIWithTitle:titleString];
        return cell;
        
    } else if ([titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.expectedCountStr]) {
        static NSString *identifier = @"basicTextCellIdentifier";
        BasicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.questionBlock = ^{
            [weakSelf handleDBRExplainWithIndexPath:indexPath settingString:titleString];
        };
        
        cell.inputTFValueChangedBlock = ^(NSInteger numValue) {
            [weakSelf handleExpectedCount:numValue];
        };
        
        [cell setInputCountTFMaxValueWithNum:kExpectedCountMaxValue];
        [cell setDefaultValue:expectedCount];
        [cell updateUIWithTitle:titleString value:expectedCount];
        return cell;
        
    } else if ([titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.minimumResultConfidenceStr]) {
        static NSString *identifier = @"basicTextCellIdentifier";
        BasicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.inputTFValueChangedBlock = ^(NSInteger numValue) {
            [weakSelf handleMinimumResultConfidence:numValue];
        };
        
        [cell setInputCountTFMaxValueWithNum:kMinimumResultConfidenceMaxValue];
        [cell setQuestionButtonIsHidden:YES];
        [cell setDefaultValue:minimumResultConfidence];
        [cell updateUIWithTitle:titleString value:minimumResultConfidence];
        return cell;
        
    } else if ([titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.duplicateForgetTimeStr]) {
        static NSString *identifier = @"basicTextCellIdentifier";
        BasicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.questionBlock = ^{
            [weakSelf handleDBRExplainWithIndexPath:indexPath settingString:titleString];
        };
        
        cell.inputTFValueChangedBlock = ^(NSInteger numValue) {
            [weakSelf handleDuplicateForgetTime:numValue];
        };
        
        [cell setInputCountTFMaxValueWithNum:kDuplicateForgetTimeMaxValue];
        [cell setTitleOffset:20.0];
        [cell setDefaultValue:duplicateForgetTime];
        [cell updateUIWithTitle:titleString value:duplicateForgetTime];
        return cell;
        
    } else if ([titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.minimumDecodeIntervalStr]) {
        static NSString *identifier = @"basicTextCellIdentifier";
        BasicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.questionBlock = ^{
            [weakSelf handleDBRExplainWithIndexPath:indexPath settingString:titleString];
        };
        
        cell.inputTFValueChangedBlock = ^(NSInteger numValue) {
            [weakSelf handleMinimumDecodeInterval:numValue];
        };
        
        [cell setInputCountTFMaxValueWithNum:kMinimumDecodeIntervalMaxValue];
        [cell setDefaultValue:minimumDecodeInterval];
        [cell updateUIWithTitle:titleString value:minimumDecodeInterval];
        return cell;
        
    } else if ([titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.continuousScanStr] ||
               [titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.resultVerificationStr] ||
               [titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.duplicateFliterStr] ||
               [titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.decodeInvertedBarcodesStr]) {
        NSInteger switchSelectState = [[recordDBRSwitchStateDic valueForKey:titleString] integerValue];
        static NSString *identifier = @"basicSwitchCellIdentifier";
        BasicSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.resultVerificationStr] ||
            [titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.duplicateFliterStr]) {
            cell.questionButton.hidden = NO;
        } else {
            cell.questionButton.hidden = YES;
        }
        cell.questionBlock = ^{
            [weakSelf handleDBRExplainWithIndexPath:indexPath settingString:titleString];
        };
       
        cell.switchChangedBlock = ^(BOOL isOn) {
            [weakSelf handleDBRSettingSwitchWithIndexPath:indexPath settingString:titleString andSwitchState:isOn];
        };
 
        [cell updateUIWithTitle:titleString withSwitchState:switchSelectState];
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *titleString = barcodeSettingDataArray[indexPath.row];
    if ([titleString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.barcodeFormatStr]) {
       
        BarcodeFormatDetailViewController *barcodeFormatDetailVC = [[BarcodeFormatDetailViewController alloc] init];
        [self.navigationController pushViewController:barcodeFormatDetailVC animated:YES];
    }
  
}

// MARK: - Handle value changed
- (void)handleExpectedCount:(NSInteger)numValue {
    BarcodeSettings barcodeSettings = [GeneralSettingsHandle setting].barcodeSettings;
    barcodeSettings.expectedCount = numValue;
    [GeneralSettingsHandle setting].barcodeSettings = barcodeSettings;
    
    [GeneralSettingsHandle setting].ipublicRuntimeSettings.expectedBarcodesCount = numValue;
    [[GeneralSettingsHandle setting] updateIpublicRuntimeSettings];
    
    [self handleData];
    [self.barcodeSettingTableView reloadData];
}

- (void)handleMinimumResultConfidence:(NSInteger)numValue {
    BarcodeSettings barcodeSettings = [GeneralSettingsHandle setting].barcodeSettings;
    barcodeSettings.minimumResultConfidence = numValue;
    [GeneralSettingsHandle setting].barcodeSettings = barcodeSettings;
    
    [GeneralSettingsHandle setting].ipublicRuntimeSettings.minResultConfidence = numValue;
    [[GeneralSettingsHandle setting] updateIpublicRuntimeSettings];
    
    [self handleData];
    [self.barcodeSettingTableView reloadData];
}

- (void)handleDuplicateForgetTime:(NSInteger)numValue {
    BarcodeSettings barcodeSettings = [GeneralSettingsHandle setting].barcodeSettings;
    barcodeSettings.duplicateForgetTime = numValue;
    [GeneralSettingsHandle setting].barcodeSettings = barcodeSettings;
    
    [[GeneralSettingsHandle setting].barcodeReader setDuplicateForgetTime:numValue];
    
    [self handleData];
    [self.barcodeSettingTableView reloadData];
}

- (void)handleMinimumDecodeInterval:(NSInteger)numValue {
    BarcodeSettings barcodeSettings = [GeneralSettingsHandle setting].barcodeSettings;
    barcodeSettings.minimumDecodeInterval = numValue;
    [GeneralSettingsHandle setting].barcodeSettings = barcodeSettings;
    
    [[GeneralSettingsHandle setting].barcodeReader setMinImageReadingInterval:numValue];
    
    [self handleData];
    [self.barcodeSettingTableView reloadData];
}

// MARK: - Handle switch changed
- (void)handleDBRSettingSwitchWithIndexPath:(NSIndexPath *)indexPath settingString:(NSString *)dbrSettingString andSwitchState:(BOOL)isOn {
    
    BarcodeSettings barcodeSettings = [GeneralSettingsHandle setting].barcodeSettings;
    
    if ([dbrSettingString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.continuousScanStr]) {
        barcodeSettings.continuousScanIsOpen = isOn;
        [GeneralSettingsHandle setting].barcodeSettings = barcodeSettings;
    } else if ([dbrSettingString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.resultVerificationStr]) {
        barcodeSettings.resultVerificationIsOpen = isOn;
        [GeneralSettingsHandle setting].barcodeSettings = barcodeSettings;
        
        [GeneralSettingsHandle setting].barcodeReader.enableResultVerification = isOn;
    } else if ([dbrSettingString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.duplicateFliterStr]) {
        barcodeSettings.duplicateFliterIsOpen = isOn;
        [GeneralSettingsHandle setting].barcodeSettings = barcodeSettings;
        
        [GeneralSettingsHandle setting].barcodeReader.enableDuplicateFilter = isOn;
    } else if ([dbrSettingString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.decodeInvertedBarcodesStr]) {
        barcodeSettings.decodeInvertedBarcodesIsOpen = isOn;
        [GeneralSettingsHandle setting].barcodeSettings = barcodeSettings;
        
        NSArray *grayscaleTransformationModes = @[];
        if (isOn) {
            grayscaleTransformationModes = @[@(EnumGrayscaleTransformationModeOriginal),
                                             @(EnumGrayscaleTransformationModeInverted),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip)
            ];
        } else {
            grayscaleTransformationModes = @[@(EnumGrayscaleTransformationModeOriginal),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip),
                                             @(EnumGrayscaleTransformationModeSkip)
            ];
        }
        [GeneralSettingsHandle setting].ipublicRuntimeSettings.furtherModes.grayscaleTransformationModes = grayscaleTransformationModes;
        [[GeneralSettingsHandle setting] updateIpublicRuntimeSettings];
    }
    
    if (isOn == YES) {
        [recordDBRSwitchStateDic setValue:@(1) forKey:dbrSettingString];
    } else {
        [recordDBRSwitchStateDic setValue:@(0) forKey:dbrSettingString];
    }
    
    [self handleData];
    [self.barcodeSettingTableView reloadData];
}

- (void)handleDBRExplainWithIndexPath:(NSIndexPath *)indexPath settingString:(NSString *)dbrSettingString {
    if ([dbrSettingString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.expectedCountStr]) {
        [[ToolsHandle toolManger] addAlertViewWithTitle:dbrSettingString Content:expectedCountExplain actionTitle:nil ToView:self completion:nil];
    } else if ([dbrSettingString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.duplicateForgetTimeStr]) {
        [[ToolsHandle toolManger] addAlertViewWithTitle:dbrSettingString Content:duplicateForgetTimeExplain actionTitle:nil ToView:self completion:nil];
    } else if ([dbrSettingString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.minimumDecodeIntervalStr]) {
        [[ToolsHandle toolManger] addAlertViewWithTitle:dbrSettingString Content:minimumDecodeIntervalExplain actionTitle:nil ToView:self completion:nil];
    } else if ([dbrSettingString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.resultVerificationStr]) {
        [[ToolsHandle toolManger] addAlertViewWithTitle:dbrSettingString Content:resultVerificationExplain actionTitle:nil ToView:self completion:nil];
    } else if ([dbrSettingString isEqualToString:[GeneralSettingsHandle setting].barcodeSettings.duplicateFliterStr]) {
        [[ToolsHandle toolManger] addAlertViewWithTitle:dbrSettingString Content:duplicateFilterExplain actionTitle:nil ToView:self completion:nil];
    }
}

@end
