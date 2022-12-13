#import "CameraSettingView.h"

@interface CameraSettingView ()

@property (nonatomic, strong) UILabel *autoZoomLabel;

@property (nonatomic, strong) UISwitch *controlSwitch;

@end

@implementation CameraSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1];
    
    CGFloat contentHeight = KCameraSettingAvailableHeight;
    
    self.autoZoomLabel = [[UILabel alloc] init];
    self.autoZoomLabel.frame = CGRectMake(kLeftMarginOfContainer, 0, 100, contentHeight);
    self.autoZoomLabel.text = @"Auto Zoom";
    self.autoZoomLabel.font = kFont_SystemDefault(KCameraSettingTitleTextSize);
    self.autoZoomLabel.textColor = [UIColor whiteColor];
    self.autoZoomLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.autoZoomLabel];
    
    self.controlSwitch = [[UISwitch alloc] init];
    self.controlSwitch.left = kScreenWidth - kRightMarginOfContainer - self.controlSwitch.width;
    self.controlSwitch.top = (contentHeight - self.controlSwitch.height) / 2.0;
    self.controlSwitch.onTintColor = kSwitchOnTintColor;
    self.controlSwitch.tintColor = kSwitchOffTintColor;
    self.controlSwitch.backgroundColor = kSwitchOffTintColor;
    self.controlSwitch.layer.cornerRadius = self.controlSwitch.height / 2.0;
    [self.controlSwitch addTarget:self action:@selector(controlSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.controlSwitch];
}

- (void)controlSwitchChanged:(UISwitch *)controlSwitch
{
    if (controlSwitch.on) {
        self.controlSwitch.thumbTintColor = kSwitchOnThumbColor;
    } else {
        self.controlSwitch.thumbTintColor = kSwitchOffThumbColor;
    }
    if (self.switchChangedBlock) {
        self.switchChangedBlock(controlSwitch.on);
    }
}

- (void)updateSwitchState:(BOOL)switchState {
    self.controlSwitch.on = switchState;
    
    if (self.controlSwitch.on) {
        self.controlSwitch.thumbTintColor = kSwitchOnThumbColor;
    } else {
        self.controlSwitch.thumbTintColor = kSwitchOffThumbColor;
    }
}

@end
