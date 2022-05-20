//
//  BasicPullTableViewCell.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BasicPullTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *pullImageV;

@property (nonatomic, strong) UILabel *pullTextLabel;

@property (nonatomic, strong) UIView *separationLine;

/// Update UI.
- (void)updateUIWithTitle:(NSString *)titleString andContentString:(NSString *)contentString;

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
