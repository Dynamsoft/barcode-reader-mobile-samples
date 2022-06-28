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
    [[GeneralSettingsHandle setting] resetToDefault];
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
