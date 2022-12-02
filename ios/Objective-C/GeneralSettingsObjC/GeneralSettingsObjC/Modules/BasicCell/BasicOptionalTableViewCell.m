//
//  BasicOptionalTableViewCell.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import "BasicOptionalTableViewCell.h"

@implementation BasicOptionalTableViewCell

+ (CGFloat)cellHeight
{
    return kCellHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel.frame = CGRectMake(kCellLeftMargin, 0, 0, kCellHeight);
    self.titleLabel.font = kFont_Regular(kCellTitleFontSize);
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.titleLabel];
    
    self.optionalStateImageV.frame = CGRectMake(kScreenWidth - kCellRightmarin - 16 * kScreenAdaptationRadio, (kCellHeight - 16 * kScreenAdaptationRadio) / 2.0, 16 * kScreenAdaptationRadio, 16 * kScreenAdaptationRadio);
    self.optionalStateImageV.image = [UIImage imageNamed:@"checked"];
    [self.contentView addSubview:self.optionalStateImageV];
    
    self.separationLine.frame = CGRectMake(0, kCellHeight - KCellSeparationLineHeight, kScreenWidth, KCellSeparationLineHeight);
    self.separationLine.backgroundColor = kCellSeparationLineBackgroundColor;
    [self.contentView addSubview:self.separationLine];
}

/// Update UI.
- (void)updateUIWithTitle:(NSString *)titleString andOptionalState:(NSString *)optionalState
{
    self.titleLabel.text = titleString;
    self.titleLabel.width = [[ToolsHandle toolManger] calculateWidthWithText:titleString font:self.titleLabel.font AndComponentheight:self.titleLabel.height];
    
    if ([optionalState isEqualToString:@"1"]) {
        self.optionalStateImageV.hidden = NO;
    } else {
        self.optionalStateImageV.hidden = YES;
    }
}

// MARK: - Lazy loading

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UIImageView *)optionalStateImageV
{
    if (!_optionalStateImageV) {
        _optionalStateImageV = [[UIImageView alloc] init];
    }
    return _optionalStateImageV;
}

- (UIView *)separationLine
{
    if (!_separationLine) {
        _separationLine = [[UIView alloc] init];
    }
    return _separationLine;
}


@end
