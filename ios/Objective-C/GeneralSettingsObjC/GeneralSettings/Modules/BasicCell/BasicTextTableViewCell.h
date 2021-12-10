//
//  BasicTextTableViewCell.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BasicTextTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *questionButton;

@property (nonatomic, strong) UITextField *inputCountTF;

@property (nonatomic, strong) UIView *separationLine;

/// question block
@property (nonatomic, copy) void(^questionBlock)(void);

/// inputTF value changed block
@property (nonatomic, copy) void(^inputTFValueChangedBlock)(NSInteger numValue);

/// setting the maxvalue of the inputCountTF
- (void)setInputCountTFMaxValueWithNum:(NSInteger)maxValue;

/// update UI
- (void)updateUIWithTitle:(NSString *)titleString;

/// update UI with title and value
- (void)updateUIWithTitle:(NSString *)titleString value:(NSInteger)valueNum;

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
