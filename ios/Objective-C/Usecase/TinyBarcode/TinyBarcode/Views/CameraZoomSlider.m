#import "CameraZoomSlider.h"

@interface CameraZoomSlider ()

@property (nonatomic, strong) UILabel *zoomLabel;

@property (nonatomic, strong) UIImageView *arrowIcon;

@property (nonatomic, strong) UISlider *zoomSlider;

@end

@implementation CameraZoomSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat viewHeight = kCameraZoomSliderViewHeight;
    
    self.zoomLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.width - kCameraZoomFloatingButtonWidth) / 2.0, 0, kCameraZoomFloatingButtonWidth, kCameraZoomFloatingButtonWidth)];
    self.zoomLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.42];
    self.zoomLabel.font = kFont_SystemDefault(kCameraZoomFloatingLabelTextSize);
    self.zoomLabel.textColor = [UIColor whiteColor];
    self.zoomLabel.textAlignment = NSTextAlignmentCenter;
    self.zoomLabel.layer.cornerRadius = self.zoomLabel.height / 2.0;
    self.zoomLabel.layer.masksToBounds = YES;
    [self addSubview:self.zoomLabel];
    
    UIView *sliderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 80, self.width, 80)];
    sliderBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self addSubview:sliderBackgroundView];
    
    self.arrowIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 17) / 2.0, 10, 17, 10)];
    self.arrowIcon.image = [UIImage imageNamed:@"icon_arrow_camera_zoom_close"];
    [sliderBackgroundView addSubview:self.arrowIcon];
    
    UIView *arrowActionView = [[UIView alloc] initWithFrame:CGRectMake(self.arrowIcon.left - 10, self.arrowIcon.top - 10, self.arrowIcon.width + 20, self.arrowIcon.height + 20)];
    arrowActionView.backgroundColor = [UIColor clearColor];
    [sliderBackgroundView addSubview:arrowActionView];
    
    UITapGestureRecognizer *closeTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomCloseAction)];
    [arrowActionView addGestureRecognizer:closeTapGes];
    
    self.zoomSlider = [[UISlider alloc] initWithFrame:CGRectMake(40, 40, self.width - 80, 34)];
    self.zoomSlider.thumbTintColor = [UIColor whiteColor];
    self.zoomSlider.minimumTrackTintColor = [UIColor colorWithRed:112 / 255.0 green:112 / 255.0 blue:112 / 255.0 alpha:1];
    self.zoomSlider.maximumTrackTintColor = [UIColor colorWithRed:112 / 255.0 green:112 / 255.0 blue:112 / 255.0 alpha:1];
    [self.zoomSlider addTarget:self action:@selector(zoomValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.zoomSlider.minimumValue = 1.0f;
    [sliderBackgroundView addSubview:self.zoomSlider];

}

// MARK: - Setter
- (void)setCameraMinZoom:(CGFloat)cameraMinZoom {
    _cameraMinZoom = cameraMinZoom;
    self.zoomSlider.minimumValue = cameraMinZoom;
}

- (void)setCameraMaxZoom:(CGFloat)cameraMaxZoom {
    _cameraMaxZoom = cameraMaxZoom;
    self.zoomSlider.maximumValue = cameraMaxZoom;
}

- (void)setCurrentCameraZoom:(CGFloat)currentCameraZoom {
    _currentCameraZoom = currentCameraZoom;
    self.zoomLabel.text = [NSString stringWithFormat:@"%.1fx", currentCameraZoom];
    self.zoomSlider.value = currentCameraZoom;
}

- (void)zoomCloseAction {
    if (self.closeActionBlock) {
        self.closeActionBlock();
    }
}

- (void)zoomValueChanged:(UISlider *)slider {
    if (self.zoomValueChangedBlock) {
        self.zoomLabel.text = [NSString stringWithFormat:@"%.1fx", slider.value];
        self.zoomValueChangedBlock(slider.value);
    }
}

@end
