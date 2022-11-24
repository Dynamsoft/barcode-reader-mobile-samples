#import "CameraZoomFloatingButton.h"

@interface CameraZoomFloatingButton ()

@property (nonatomic, strong) UILabel *zoomLabel;

@end

@implementation CameraZoomFloatingButton


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = self.height / 2.0;
    
    self.zoomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.zoomLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.42];
    self.zoomLabel.textColor = [UIColor whiteColor];
    self.zoomLabel.layer.cornerRadius = self.height / 2.0;
    self.zoomLabel.layer.masksToBounds = YES;
    self.zoomLabel.font = kFont_SystemDefault(kCameraZoomFloatingLabelTextSize);
    self.zoomLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.zoomLabel];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction)];
    [self addGestureRecognizer:tapGes];
    
}

// MARK: - Setter
- (void)setCurrentCameraZoom:(CGFloat)currentCameraZoom {
    _currentCameraZoom = currentCameraZoom;
    self.zoomLabel.text = [NSString stringWithFormat:@"%.1fx", currentCameraZoom];
}

- (void)tapGesAction {
    if (self.tapPressActionBlock) {
        self.tapPressActionBlock();
    }
}


@end
