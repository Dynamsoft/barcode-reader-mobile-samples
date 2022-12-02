#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraZoomSlider : UIView

@property (nonatomic, copy) void(^closeActionBlock)(void);

@property (nonatomic, copy) void(^zoomValueChangedBlock)(CGFloat zoomValue);

@property (nonatomic, assign) CGFloat cameraMinZoom;

@property (nonatomic, assign) CGFloat cameraMaxZoom;

@property (nonatomic, assign) CGFloat currentCameraZoom;

@end

NS_ASSUME_NONNULL_END
