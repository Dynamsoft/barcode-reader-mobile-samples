//
//  ViewSettingsViewController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/19.
//

#import "ViewSettingsViewController.h"

static NSString *displayOverlayTag      = @"100";
static NSString *displayTorchButtonTag      = @"101";

@interface ViewSettingsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *viewSettingDataArray;
    NSMutableDictionary *recordViewSettingStateDic;
}
@property (nonatomic, strong) UITableView *viewSettingsTableView;

@end

@implementation ViewSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"View Settings";
    
    viewSettingDataArray = @[[GeneralSettingsHandle setting].dceViewSettings.displayOverlay,
                             [GeneralSettingsHandle setting].dceViewSettings.displayTorchButton
    ];
    
    recordViewSettingStateDic = [NSMutableDictionary dictionary];
    if ([GeneralSettingsHandle setting].dceViewSettings.displayOverlayIsOpen) {
        [recordViewSettingStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].dceViewSettings.displayOverlay];
    } else {
        [recordViewSettingStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].dceViewSettings.displayOverlay];
    }
    
    if ([GeneralSettingsHandle setting].dceViewSettings.displayTorchButtonIsOpen) {
        [recordViewSettingStateDic setValue:@(1) forKey:[GeneralSettingsHandle setting].dceViewSettings.displayTorchButton];
    } else {
        [recordViewSettingStateDic setValue:@(0) forKey:[GeneralSettingsHandle setting].dceViewSettings.displayTorchButton];
    }
    
    [self setupUI];
}

- (void)setupUI
{
    self.viewSettingsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.viewSettingsTableView.backgroundColor = [UIColor whiteColor];
    self.viewSettingsTableView.delegate = self;
    self.viewSettingsTableView.dataSource = self;
    self.viewSettingsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.viewSettingsTableView];
}


//MARK: UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return viewSettingDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BasicTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dceViewSettingString = viewSettingDataArray[indexPath.row];
    NSInteger switchState = [[recordViewSettingStateDic valueForKey:dceViewSettingString] integerValue];
    
    weakSelfs(self)
    static NSString *identifier = @"basicSwitchCellIdentifier";
    BasicSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BasicSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if ([dceViewSettingString isEqualToString:[GeneralSettingsHandle setting].dceViewSettings.displayOverlay]) {
        cell.questionButton.hidden = NO;
        cell.questionBlock = ^{
            [[ToolsHandle toolManger] addAlertViewWithTitle:@"Display Overlay" Content:displayOverlayExplain actionTitle:nil ToView:weakSelf completion:^{
                            
            }];
        };
    } else {
        cell.questionButton.hidden = YES;
    }
    
    cell.switchChangedBlock = ^(BOOL isOn) {
        [weakSelf handleSwitchWithDCESettingString:dceViewSettingString andState:isOn];
    };

    [cell updateUIWithTitle:dceViewSettingString withSwitchState:switchState];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
}

///Make configurations on the camera view.
- (void)handleSwitchWithDCESettingString:(NSString *)dceViewSettingString andState:(BOOL)isOn
{
    DCEViewSettings dceViewSettings = [GeneralSettingsHandle setting].dceViewSettings;
    
    if ([dceViewSettingString isEqualToString:[GeneralSettingsHandle setting].dceViewSettings.displayOverlay]) {

        // Make configurations for overlays.
        // Highlighted overlays will be displayed on the successfully decoded barcodes when overlayVisible is set to true.
        if (isOn) {
            dceViewSettings.displayOverlayIsOpen = YES;
            [GeneralSettingsHandle setting].dceViewSettings = dceViewSettings;
            
            [GeneralSettingsHandle setting].cameraView.overlayVisible = true;
        } else {
            dceViewSettings.displayOverlayIsOpen = NO;
            [GeneralSettingsHandle setting].dceViewSettings = dceViewSettings;
            
            [GeneralSettingsHandle setting].cameraView.overlayVisible = false;
        }
        
    } else if ([dceViewSettingString isEqualToString:[GeneralSettingsHandle setting].dceViewSettings.displayTorchButton]) {

        // Make configurations for overlays.
        // Setting the torchButtonVisible to true will display a torch button on the UI.
        // The torch button can control the status of the mobile torch.
        if (isOn) {
            dceViewSettings.displayTorchButtonIsOpen = YES;
            [GeneralSettingsHandle setting].dceViewSettings = dceViewSettings;
            
            [GeneralSettingsHandle setting].cameraView.torchButtonVisible = true;
        } else {
            dceViewSettings.displayTorchButtonIsOpen = NO;
            [GeneralSettingsHandle setting].dceViewSettings = dceViewSettings;
            
            [GeneralSettingsHandle setting].cameraView.torchButtonVisible = false;
        }
        
        
    }
}




@end
