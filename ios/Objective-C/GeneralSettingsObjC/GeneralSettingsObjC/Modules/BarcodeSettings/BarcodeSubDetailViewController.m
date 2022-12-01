//
//  BarcodeSubDetailViewController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import "BarcodeSubDetailViewController.h"

typedef NS_ENUM(NSInteger, EnumSubBarcodeOptionalEntireState){
    /**
     means  choice all optional  barcode format
     */
    EnumSubBarcodeOptionalStateALL            =   0,
    /**
     means cancel choice all  optional barcode format
     */
    EnumSubBarcodeOptionalStateCANCELALL      =   1,
    /**
     means choice  imcompletion optional barcode format
     */
    EnumSubBarcodeOptionalStateIMCOMPLETION   =   2
};


@interface BarcodeSubDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *subDetailBarcodeFormatDataArray;
    /**
     save every barcode format optional state
     element:{@"barcode_format":@"1"} | {@"barcode_format":@"0"}
     1means selected ,0 means unselected
     */
    NSMutableDictionary *saveBarcodeFormatOptionalStateDic;
    
    UIView *topHeaderView;
    UILabel *subBarcodeTypeLabel;
    UIButton *selectAllBarcodeTypeButton;
}

@property (nonatomic, strong) UITableView *subDetailBarcodeFormatTableView;

@end

@implementation BarcodeSubDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self handleData];
    [self setupUI];

}

// MARK: - handleData
- (void)handleData
{
    saveBarcodeFormatOptionalStateDic = [NSMutableDictionary dictionary];
    
    if (self.subBarcodeFormatName == EnumSubBarcodeONED) {
        self.title = @"OneDType";

        subDetailBarcodeFormatDataArray = @[@{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_Code39, @"EnumValue":@(EnumBarcodeFormatCODE39)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_Code128, @"EnumValue":@(EnumBarcodeFormatCODE128)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_Code39Extended, @"EnumValue":@(EnumBarcodeFormatCODE39EXTENDED)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_Code93, @"EnumValue":@(EnumBarcodeFormatCODE93)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_Code_11, @"EnumValue":@(EnumBarcodeFormatCODE_11)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_Codabar, @"EnumValue":@(EnumBarcodeFormatCODABAR)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_ITF, @"EnumValue":@(EnumBarcodeFormatITF)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_EAN13, @"EnumValue":@(EnumBarcodeFormatEAN13)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_EAN8, @"EnumValue":@(EnumBarcodeFormatEAN8)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_UPCA, @"EnumValue":@(EnumBarcodeFormatUPCA)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_UPCE, @"EnumValue":@(EnumBarcodeFormatUPCE)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_Industrial25, @"EnumValue":@(EnumBarcodeFormatINDUSTRIAL)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatONED.format_MSICode, @"EnumValue":@(EnumBarcodeFormatMSICODE)}
        ];
        
        iPublicRuntimeSettings *settings = [GeneralSettingsHandle setting].ipublicRuntimeSettings;
        for (NSDictionary *subBarcodeFormatDic in subDetailBarcodeFormatDataArray) {
            NSString *subBarcodeFormatString = [subBarcodeFormatDic valueForKey:@"title"];
            NSInteger subBarcodeEnumValue = [[subBarcodeFormatDic valueForKey:@"EnumValue"] integerValue];
            
            if (settings.barcodeFormatIds & subBarcodeEnumValue) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:subBarcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:subBarcodeFormatString];
            }
        }

        [self judgeOptionalEntireState];

    } else if (self.subBarcodeFormatName == EnumSubBarcodeGS1DataBar) {
        self.title = @"GS1DataBarType";
        
        subDetailBarcodeFormatDataArray = @[@{@"title":[GeneralSettingsHandle setting].barcodeFormatGS1DATABAR.format_GS1DatabarOmnidirectional, @"EnumValue":@(EnumBarcodeFormatGS1DATABAROMNIDIRECTIONAL)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatGS1DATABAR.format_GS1DatabarTrunncated, @"EnumValue":@(EnumBarcodeFormatGS1DATABARTRUNCATED)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatGS1DATABAR.format_GS1DatabarStacked, @"EnumValue":@(EnumBarcodeFormatGS1DATABARSTACKED)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatGS1DATABAR.format_GS1DatabarStackedOmnidirectional, @"EnumValue":@(EnumBarcodeFormatGS1DATABARSTACKEDOMNIDIRECTIONAL)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatGS1DATABAR.format_GS1DatabarExpanded, @"EnumValue":@(EnumBarcodeFormatGS1DATABAREXPANDED)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatGS1DATABAR.format_GS1DatabarExpanedStacked, @"EnumValue":@(EnumBarcodeFormatGS1DATABAREXPANDEDSTACKED)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormatGS1DATABAR.format_GS1DatabarLimited, @"EnumValue":@(EnumBarcodeFormatGS1DATABARLIMITED)}
        ];
        
        iPublicRuntimeSettings *settings = [GeneralSettingsHandle setting].ipublicRuntimeSettings;
        for (NSDictionary *subBarcodeFormatDic in subDetailBarcodeFormatDataArray) {
            NSString *subBarcodeFormatString = [subBarcodeFormatDic valueForKey:@"title"];
            NSInteger subBarcodeEnumValue = [[subBarcodeFormatDic valueForKey:@"EnumValue"] integerValue];
            
            if (settings.barcodeFormatIds & subBarcodeEnumValue) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:subBarcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:subBarcodeFormatString];
            }
        }

        
    } else if (self.subBarcodeFormatName == EnumSubBarcodePostalCode) {
        self.title = @"PostalCodeType";
        
        subDetailBarcodeFormatDataArray = @[@{@"title":[GeneralSettingsHandle setting].barcodeFormat2POSTALCODE.format2_USPSIntelligentMail, @"EnumValue":@(EnumBarcodeFormat2USPSINTELLIGENTMAIL)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormat2POSTALCODE.format2_Postnet, @"EnumValue":@(EnumBarcodeFormat2POSTNET)},
                                            @{@"title":[GeneralSettingsHandle setting].barcodeFormat2POSTALCODE.format2_Planet, @"EnumValue":@(EnumBarcodeFormat2PLANET)},
                                            @{@"title": [GeneralSettingsHandle setting].barcodeFormat2POSTALCODE.format2_AustralianPost, @"EnumValue":@(EnumBarcodeFormat2AUSTRALIANPOST)},
                                            @{@"title": [GeneralSettingsHandle setting].barcodeFormat2POSTALCODE.format2_RM4SCC, @"EnumValue":@(EnumBarcodeFormat2RM4SCC)}
        ];
        
        iPublicRuntimeSettings *settings = [GeneralSettingsHandle setting].ipublicRuntimeSettings;
        for (NSDictionary *subBarcodeFormatDic in subDetailBarcodeFormatDataArray) {
            NSString *subBarcodeFormatString = [subBarcodeFormatDic valueForKey:@"title"];
            NSInteger subBarcodeEnumValue = [[subBarcodeFormatDic valueForKey:@"EnumValue"] integerValue];
            
            if (settings.barcodeFormatIds_2 & subBarcodeEnumValue) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:subBarcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:subBarcodeFormatString];
            }
        }

    }
    
    
}

// MARK: - SetUI
- (void)setupUI
{
    self.subDetailBarcodeFormatTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.subDetailBarcodeFormatTableView.backgroundColor = [UIColor whiteColor];
    self.subDetailBarcodeFormatTableView.delegate = self;
    self.subDetailBarcodeFormatTableView.dataSource = self;
    self.subDetailBarcodeFormatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.subDetailBarcodeFormatTableView];
    
    // Layout headerView
    topHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30 * kScreenAdaptationRadio)];
    topHeaderView.backgroundColor = kTableViewHeaderBackgroundColor;
    self.subDetailBarcodeFormatTableView.tableHeaderView = topHeaderView;
    
  
    subBarcodeTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftMargin, 0, 100, topHeaderView.height)];
    subBarcodeTypeLabel.textColor = kTableViewHeaderTitleColor;
    subBarcodeTypeLabel.font = kTableViewHeaderTitleFont;
    if (self.subBarcodeFormatName == EnumSubBarcodeONED) {
        subBarcodeTypeLabel.text = @"OneD";
    } else if (self.subBarcodeFormatName == EnumSubBarcodeGS1DataBar) {
        subBarcodeTypeLabel.text = @"GS1DataBar";
    } else if (self.subBarcodeFormatName == EnumSubBarcodePostalCode) {
        subBarcodeTypeLabel.text = @"PostalCode";
    }
    [topHeaderView addSubview:subBarcodeTypeLabel];
    
    selectAllBarcodeTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectAllBarcodeTypeButton.frame = CGRectMake(kScreenWidth - kCellRightmarin - 100, 0, 100, topHeaderView.height);
    [selectAllBarcodeTypeButton setTitleColor:kTableViewHeaderButtonColor forState:UIControlStateNormal];
    selectAllBarcodeTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    selectAllBarcodeTypeButton.titleLabel.font = kTableViewHeaderButtonFont;
    [selectAllBarcodeTypeButton addTarget:self action:@selector(switchChoiceState) forControlEvents:UIControlEventTouchUpInside];
    [topHeaderView addSubview:selectAllBarcodeTypeButton];
    [self updateChoiceButtonState];
    
}

//MARK: UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return subDetailBarcodeFormatDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BasicTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *subBarcodeFormatDic = subDetailBarcodeFormatDataArray[indexPath.row];
    NSString *subBarcodeFormatString = [subBarcodeFormatDic valueForKey:@"title"];
    
    NSString *barcodeOptionalState = [saveBarcodeFormatOptionalStateDic valueForKey:subBarcodeFormatString];

    static NSString *identifier = @"basicOptionalCellIdentifier";
    BasicOptionalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BasicOptionalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [cell updateUIWithTitle:subBarcodeFormatString andOptionalState:barcodeOptionalState];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self handleSelectBarcodeWithIndexPath:indexPath];
}

/// Handle select barcode.
- (void)handleSelectBarcodeWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *subBarcodeFormatDic = subDetailBarcodeFormatDataArray[indexPath.row];
    NSString *subBarcodeFormatString = [subBarcodeFormatDic valueForKey:@"title"];
    NSInteger subBarcodeEnumValue = [[subBarcodeFormatDic valueForKey:@"EnumValue"] integerValue];
    NSString *barcodeOptionalState = [saveBarcodeFormatOptionalStateDic valueForKey:subBarcodeFormatString];
    
    iPublicRuntimeSettings *setting = [GeneralSettingsHandle setting].ipublicRuntimeSettings;
    
    switch (self.subBarcodeFormatName) {
        case EnumSubBarcodeONED:
            if ([barcodeOptionalState isEqualToString:@"1"]) {// Remove
                
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~subBarcodeEnumValue);
            } else {// Add
                
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | subBarcodeEnumValue;
            }
            break;
        case EnumSubBarcodeGS1DataBar:
            if ([barcodeOptionalState isEqualToString:@"1"]) {// Remove
                
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~subBarcodeEnumValue);
            } else {// Add
                
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | subBarcodeEnumValue;
            }
            break;
        case EnumSubBarcodePostalCode:
            if ([barcodeOptionalState isEqualToString:@"1"]) {// Remove
                
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds_2 = setting.barcodeFormatIds_2 & (~subBarcodeEnumValue);
            } else {// Add
                
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds_2 = setting.barcodeFormatIds_2 | subBarcodeEnumValue;
            }
            break;;
        default:
            break;
    }
    
    [self.subDetailBarcodeFormatTableView reloadData];
    
    [[GeneralSettingsHandle setting] updateIpublicRuntimeSettings];
    
    [self updateChoiceButtonState];
}

// MARK: - SelectAll Or CancelAll
- (void)switchChoiceState
{
    EnumSubBarcodeOptionalEntireState optionalState = [self judgeOptionalEntireState];
    
    BOOL shouldChoiceAll = YES;
    
    switch (optionalState) {
        case EnumSubBarcodeOptionalStateALL:
        {// Should cancel all.
            shouldChoiceAll = NO;
            break;
        }
        case EnumSubBarcodeOptionalStateCANCELALL:
        {// Should choice all.
            shouldChoiceAll = YES;
            break;
        }
        case EnumSubBarcodeOptionalStateIMCOMPLETION:
        {// Should choice all.
            shouldChoiceAll = YES;
            break;
        }
        default:
            break;
    }
    
    
    
    if (self.subBarcodeFormatName == EnumSubBarcodeONED || self.subBarcodeFormatName == EnumSubBarcodeGS1DataBar) {
        
       
        for (NSDictionary *subBarcodeFormatDic in subDetailBarcodeFormatDataArray) {
            iPublicRuntimeSettings *settings = [GeneralSettingsHandle setting].ipublicRuntimeSettings;
            NSString *subBarcodeFormatString = [subBarcodeFormatDic valueForKey:@"title"];
            NSInteger subBarcodeEnumValue = [[subBarcodeFormatDic valueForKey:@"EnumValue"] integerValue];
            
            if (shouldChoiceAll == YES) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = settings.barcodeFormatIds | subBarcodeEnumValue;
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = settings.barcodeFormatIds & (~subBarcodeEnumValue);
            }
            
        }
        
    } else {
        
        for (NSDictionary *subBarcodeFormatDic in subDetailBarcodeFormatDataArray) {
            iPublicRuntimeSettings *settings = [GeneralSettingsHandle setting].ipublicRuntimeSettings;
            NSString *subBarcodeFormatString = [subBarcodeFormatDic valueForKey:@"title"];
            NSInteger subBarcodeEnumValue = [[subBarcodeFormatDic valueForKey:@"EnumValue"] integerValue];
            
            if (shouldChoiceAll == YES) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds_2 = settings.barcodeFormatIds_2 | subBarcodeEnumValue;
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:subBarcodeFormatString];
                [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds_2 = settings.barcodeFormatIds_2 & (~subBarcodeEnumValue);
            }
            
        }
    }
   
    [self.subDetailBarcodeFormatTableView reloadData];
    
    [[GeneralSettingsHandle setting] updateIpublicRuntimeSettings];
    
    [self updateChoiceButtonState];
}

/// Judge choice state.
- (EnumSubBarcodeOptionalEntireState)judgeOptionalEntireState
{
    EnumSubBarcodeOptionalEntireState optionalState = EnumSubBarcodeOptionalStateALL;
    
    NSArray *allOptionalStringValueArray = saveBarcodeFormatOptionalStateDic.allValues;
    
    if ([allOptionalStringValueArray containsObject:@"1"] && [allOptionalStringValueArray containsObject:@"0"]) {
      
        optionalState = EnumSubBarcodeOptionalStateIMCOMPLETION;
    } else if (![allOptionalStringValueArray containsObject:@"1"]) {
    
        optionalState = EnumSubBarcodeOptionalStateCANCELALL;
    } else if (![allOptionalStringValueArray containsObject:@"0"]) {
     
        optionalState = EnumSubBarcodeOptionalStateALL;
    }

    return optionalState;
}

/// UpdateChoiceButtonState.
- (void)updateChoiceButtonState
{
    EnumSubBarcodeOptionalEntireState optionalState = [self judgeOptionalEntireState];
    
    switch (optionalState) {
        case EnumSubBarcodeOptionalStateALL:
        {
            [selectAllBarcodeTypeButton setTitle:barcodeFormatDisableAllString forState:UIControlStateNormal];
            break;
        }
        case EnumSubBarcodeOptionalStateCANCELALL:
        {
            [selectAllBarcodeTypeButton setTitle:barcodeFormatEnableAllString forState:UIControlStateNormal];
            break;
        }
        case EnumSubBarcodeOptionalStateIMCOMPLETION:
        {
            [selectAllBarcodeTypeButton setTitle:barcodeFormatEnableAllString forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}


@end
