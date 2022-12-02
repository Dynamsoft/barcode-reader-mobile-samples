#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraSettingView : UIView

@property (nonatomic, copy) void(^switchChangedBlock)(BOOL isOn);

- (void)updateSwitchState:(BOOL)switchState;

@end

NS_ASSUME_NONNULL_END
