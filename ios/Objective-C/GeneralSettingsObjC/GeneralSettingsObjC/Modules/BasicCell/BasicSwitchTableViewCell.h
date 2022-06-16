//
//  BasicSwitchTableViewCell.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BasicSwitchTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *questionButton;

@property (nonatomic, strong) UISwitch *controlSwitch;

@property (nonatomic, strong) UIView *separationLine;

/// Question block.
@property (nonatomic, copy) void(^questionBlock)(void);

/// ControlSwitch value changed block.
@property (nonatomic, copy) void(^switchChangedBlock)(BOOL isOn);

/// Update UI.
- (void)updateUIWithTitle:(NSString *)titleString withSwitchState:(BOOL)isOpen;

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
