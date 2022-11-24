#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraZoomFloatingButton : UIView

@property (nonatomic, copy) void(^tapPressActionBlock)(void);

@property (nonatomic, assign) CGFloat currentCameraZoom;

@end

NS_ASSUME_NONNULL_END
