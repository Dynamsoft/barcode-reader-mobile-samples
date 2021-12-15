//
//  BasicTableViewCell.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BasicTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *questionButton;

@property (nonatomic, strong) UIImageView *optionalStateImageV;

@property (nonatomic, strong) UIView *separationLine;


/// question block
@property (nonatomic, copy) void(^questionBlock)(void);

/// update UI
/// update UI
- (void)updateUIWithTitle:(NSString *)titleString andOptionalState:(NSInteger)optionalState;

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
