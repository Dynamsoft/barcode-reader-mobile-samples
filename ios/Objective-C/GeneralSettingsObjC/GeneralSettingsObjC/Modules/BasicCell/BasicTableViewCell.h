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

@property (nonatomic, strong) UIView *separationLine;

/// Update UI
- (void)updateUIWithTitle:(NSString *)titleString;

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
