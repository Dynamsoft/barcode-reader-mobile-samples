//
//  BarcodeFormatDetailViewController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import "BarcodeFormatDetailViewController.h"
#import "BarcodeSubDetailViewController.h"


@interface BarcodeFormatDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *allBarcodeFormatDataArray;
    
    /**
     save every barcode format optional state
     element:{@"barcode_format":@"1"} | {@"barcode_format":@"0"}
     1means selected ,0 means unselected
     */
    NSMutableDictionary *saveBarcodeFormatOptionalStateDic;
}

@property (nonatomic, strong) UITableView *allBarcodeFormatTableView;

@end

@implementation BarcodeFormatDetailViewController

- (void)dealloc
{
   // NSLog(@"barcode format dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    self.title = @"Barcode Formats";

    [self handleData];
    
    [self setupUI];
}

//

- (void)handleData
{
    allBarcodeFormatDataArray = @[[GeneralSettingsHandle setting].allBarcodeFormat.format_OneD,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_GS1DataBar,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_PostalCode,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_PatchCode,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_PDF417,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_QRCode,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_DataMatrix,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_AZTEC,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_MaxiCode,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_MicroQR,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_MicroPDF417,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_GS1Composite,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_DotCode,
                                  [GeneralSettingsHandle setting].allBarcodeFormat.format_PHARMACODE


    ];
    
    saveBarcodeFormatOptionalStateDic = [NSMutableDictionary dictionary];
    
    iPublicRuntimeSettings *settings = [GeneralSettingsHandle setting].ipublicRuntimeSettings;
    for (NSString *barcodeFormatString in allBarcodeFormatDataArray) {
        
        if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_PatchCode]) {
            
            if (settings.barcodeFormatIds & EnumBarcodeFormatPATCHCODE) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
            
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_PDF417]) {
        
            if (settings.barcodeFormatIds & EnumBarcodeFormatPDF417) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_QRCode]) {
            
            if (settings.barcodeFormatIds & EnumBarcodeFormatQRCODE) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_DataMatrix]) {
            
            if (settings.barcodeFormatIds & EnumBarcodeFormatDATAMATRIX) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_AZTEC]) {
            
            if (settings.barcodeFormatIds & EnumBarcodeFormatAZTEC) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_MaxiCode]) {
            
            if (settings.barcodeFormatIds & EnumBarcodeFormatMAXICODE) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_MicroQR]) {
            
            if (settings.barcodeFormatIds & EnumBarcodeFormatMICROQR) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_MicroPDF417]) {
            
            if (settings.barcodeFormatIds & EnumBarcodeFormatMICROPDF417) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_GS1Composite]) {
            
            if (settings.barcodeFormatIds & EnumBarcodeFormatGS1COMPOSITE) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_DotCode]) {
            
            if (settings.barcodeFormatIds_2 & EnumBarcodeFormat2DOTCODE) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_PHARMACODE]) {
            
            if (settings.barcodeFormatIds_2 & EnumBarcodeFormat2PHARMACODE) {
                [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            } else {
                [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            }
        }
        
    }
    
    
    
}

- (void)setupUI
{
    self.allBarcodeFormatTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.allBarcodeFormatTableView.backgroundColor = [UIColor whiteColor];
    self.allBarcodeFormatTableView.delegate = self;
    self.allBarcodeFormatTableView.dataSource = self;
    self.allBarcodeFormatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.allBarcodeFormatTableView];
}

//MARK: UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allBarcodeFormatDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BasicTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *barcodeFormatString = allBarcodeFormatDataArray[indexPath.row];

    NSString *barcodeOptionalState = [saveBarcodeFormatOptionalStateDic valueForKey:barcodeFormatString];
    
    
    if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_OneD] || [barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_GS1DataBar] || [barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_PostalCode]) {
        static NSString *identifier = @"basicCellIdentifier";
        BasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }

        [cell updateUIWithTitle:barcodeFormatString];
        return cell;

    } else {
        static NSString *identifier = @"basicOptionalCellIdentifier";
        BasicOptionalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicOptionalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        [cell updateUIWithTitle:barcodeFormatString andOptionalState:barcodeOptionalState];
        
        return cell;
    }


    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *barcodeFormatString = allBarcodeFormatDataArray[indexPath.row];
    
    // handle select
    if (!([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_OneD] || [barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_GS1DataBar] || [barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_PostalCode]))
    {
        [self handleSelectBarcodeWithIndexPath:indexPath];
        return;
    }
    
    
    BarcodeSubDetailViewController *subDetailVC = [[BarcodeSubDetailViewController alloc] init];

    if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_OneD]) {

        subDetailVC.subBarcodeFormatName = EnumSubBarcodeONED;
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_GS1DataBar]) {

        subDetailVC.subBarcodeFormatName = EnumSubBarcodeGS1DataBar;
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_PostalCode]) {

        subDetailVC.subBarcodeFormatName = EnumSubBarcodePostalCode;
    }

    [self.navigationController pushViewController:subDetailVC animated:YES];
    
}

/// handle select barcode
- (void)handleSelectBarcodeWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *barcodeFormatString = allBarcodeFormatDataArray[indexPath.row];
    NSString *barcodeOptionalState = [saveBarcodeFormatOptionalStateDic valueForKey:barcodeFormatString];
    
    iPublicRuntimeSettings *setting = [GeneralSettingsHandle setting].ipublicRuntimeSettings;
    if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_PatchCode]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~EnumBarcodeFormatPATCHCODE);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | EnumBarcodeFormatPATCHCODE;
        }
        
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_PDF417]) {
    
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~EnumBarcodeFormatPDF417);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | EnumBarcodeFormatPDF417;
        }
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_QRCode]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~EnumBarcodeFormatQRCODE);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | EnumBarcodeFormatQRCODE;
        }
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_DataMatrix]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~EnumBarcodeFormatDATAMATRIX);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | EnumBarcodeFormatDATAMATRIX;
        }
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_AZTEC]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~EnumBarcodeFormatAZTEC);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | EnumBarcodeFormatAZTEC;
        }
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_MaxiCode]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~EnumBarcodeFormatMAXICODE);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | EnumBarcodeFormatMAXICODE;
        }
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_MicroQR]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~EnumBarcodeFormatMICROQR);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | EnumBarcodeFormatMICROQR;
        }
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_MicroPDF417]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~EnumBarcodeFormatMICROPDF417);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | EnumBarcodeFormatMICROPDF417;
        }
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_GS1Composite]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds & (~EnumBarcodeFormatGS1COMPOSITE);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds = setting.barcodeFormatIds | EnumBarcodeFormatGS1COMPOSITE;
        }
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_DotCode]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds_2 = setting.barcodeFormatIds_2 & (~EnumBarcodeFormat2DOTCODE);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds_2 = setting.barcodeFormatIds_2 | EnumBarcodeFormat2DOTCODE;
        }
    } else if ([barcodeFormatString isEqualToString:[GeneralSettingsHandle setting].allBarcodeFormat.format_PHARMACODE]) {
        
        if ([barcodeOptionalState isEqualToString:@"1"]) {// remove
            [saveBarcodeFormatOptionalStateDic setValue:@"0" forKey:barcodeFormatString];
            
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds_2 = setting.barcodeFormatIds_2 & (~EnumBarcodeFormat2PHARMACODE);
        } else {// add
            [saveBarcodeFormatOptionalStateDic setValue:@"1" forKey:barcodeFormatString];
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.barcodeFormatIds_2 = setting.barcodeFormatIds_2 | EnumBarcodeFormat2PHARMACODE;
        }
    }
    
    [self.allBarcodeFormatTableView reloadData];
    
    
    [[GeneralSettingsHandle setting] updateIpublicRuntimeSettings];
    

}

@end
