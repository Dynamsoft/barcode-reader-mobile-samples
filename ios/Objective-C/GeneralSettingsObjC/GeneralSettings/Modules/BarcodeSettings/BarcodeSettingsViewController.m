//
//  BarcodeSettingsViewController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/19.
//

#import "BarcodeSettingsViewController.h"
#import "BasicSwitchTableViewCell.h"
#import "BarcodeFormatDetailViewController.h"

static NSString *barcodeFormatsTag      = @"100";
static NSString *expectedCountTag      = @"101";
static NSString *continuousSCanTag      = @"102";


@interface BarcodeSettingsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *barcodeSettingDataArray;
}
@property (nonatomic, strong) UITableView *barcodeSettingTableView;

@end

@implementation BarcodeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Barcode Settings";
    
    barcodeSettingDataArray = @[@{@"name":@"Barcode Formats", @"tag":barcodeFormatsTag},
                                @{@"name":@"Expected Count", @"tag":expectedCountTag},
                                @{@"name":@"Continuous Scan", @"tag":continuousSCanTag}
    ];
    
    [self setupUI];
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


//MARK: UITableViewDelegate
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
    NSDictionary *itemDic = barcodeSettingDataArray[indexPath.row];
    NSString *title = [itemDic valueForKey:@"name"];
    NSInteger selectTag = [[itemDic valueForKey:@"tag"] integerValue];
    
    weakSelfs(self)
    if (selectTag == [barcodeFormatsTag integerValue]) {
        static NSString *identifier = @"basicCellIdentifier";
        BasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell updateUIWithTitle:title];
        return cell;
        
    } else if (selectTag == [expectedCountTag integerValue]) {
        static NSString *identifier = @"basicTextCellIdentifier";
        BasicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.questionBlock = ^{
            [[ToolsHandle toolManger] addAlertViewWithTitle:@"Expected Count" Content:expectedCountExplain actionTitle:nil ToView:weakSelf completion:nil];
          
        };
        
        cell.inputTFValueChangedBlock = ^(NSInteger numValue) {
            [GeneralSettingsHandle setting].ipublicRuntimeSettings.expectedBarcodesCount = numValue;
            [[GeneralSettingsHandle setting] updateIpublicRuntimeSettings];
        };
        
        [cell setInputCountTFMaxValueWithNum:kExpectedCountMaxValue];
        [cell updateUIWithTitle:title];
        return cell;
        
    } else if (selectTag == [continuousSCanTag integerValue]) {
        static NSString *identifier = @"basicSwitchCellIdentifier";
        BasicSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BasicSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.questionButton.hidden = YES;
        
        cell.switchChangedBlock = ^(BOOL isOn) {
            if (isOn == YES) {
                
                [GeneralSettingsHandle setting].continuousScan = YES;
            } else {
                [GeneralSettingsHandle setting].continuousScan = NO;
            }

        };
 
        [cell updateUIWithTitle:title withSwitchState:[GeneralSettingsHandle setting].continuousScan];
        return cell;
    }
    
    
    

    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *itemDic = barcodeSettingDataArray[indexPath.row];
    NSInteger selectTag = [[itemDic valueForKey:@"tag"] integerValue];
    
    if (selectTag == [barcodeFormatsTag integerValue]) {
       
        BarcodeFormatDetailViewController *barcodeFormatDetailVC = [[BarcodeFormatDetailViewController alloc] init];
        [self.navigationController pushViewController:barcodeFormatDetailVC animated:YES];
    }
    
    
  
}

@end
