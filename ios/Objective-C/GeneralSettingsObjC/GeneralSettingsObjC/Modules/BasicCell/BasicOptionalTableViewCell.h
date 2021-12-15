//
//  BasicOptionalTableViewCell.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BasicOptionalTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *optionalStateImageV;

@property (nonatomic, strong) UIView *separationLine;

/// update UI
- (void)updateUIWithTitle:(NSString *)titleString andOptionalState:(NSString *)optionalState;


+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
