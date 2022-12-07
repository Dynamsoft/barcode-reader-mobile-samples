//
//  BasicPullTableViewCell.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/26.
//

#import "BasicPullTableViewCell.h"

@implementation BasicPullTableViewCell

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
    
    self.pullImageV.frame = CGRectMake(kScreenWidth - kCellRightMargin - 16 * kScreenAdaptationRadio, (kCellHeight - 16 * kScreenAdaptationRadio) / 2.0, 16 * kScreenAdaptationRadio, 16 * kScreenAdaptationRadio);
    self.pullImageV.image = [UIImage imageNamed:@"select_down"];
    [self.contentView addSubview:self.pullImageV];
    
    self.pullTextLabel.frame = CGRectMake(self.pullImageV.left - 150 * kScreenAdaptationRadio, (kCellHeight - 20 * kScreenAdaptationRadio) / 2.0, 150 * kScreenAdaptationRadio, 20 * kScreenAdaptationRadio);
    self.pullTextLabel.font = kFont_Regular(kCellPullTextFontSize);
    self.pullTextLabel.textAlignment = NSTextAlignmentRight;
    self.pullTextLabel.text = @"";
    [self.contentView addSubview:self.pullTextLabel];
    
    self.separationLine.frame = CGRectMake(0, kCellHeight - KCellSeparationLineHeight, kScreenWidth, KCellSeparationLineHeight);
    self.separationLine.backgroundColor = kCellSeparationLineBackgroundColor;
    [self.contentView addSubview:self.separationLine];
}

/// Update UI.
- (void)updateUIWithTitle:(NSString *)titleString andContentString:(NSString *)contentString
{
    self.titleLabel.text = titleString;
    self.titleLabel.width = [[ToolsHandle toolManger] calculateWidthWithText:titleString font:self.titleLabel.font AndComponentheight:self.titleLabel.height];
    
    self.pullTextLabel.text = contentString;
    
}

// MARK: - Lazy loading

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UIImageView *)pullImageV
{
    if (!_pullImageV) {
        _pullImageV = [[UIImageView alloc] init];
    }
    return _pullImageV;
}

- (UILabel *)pullTextLabel
{
    if (!_pullTextLabel) {
        _pullTextLabel = [[UILabel alloc] init];
    }
    return _pullTextLabel;
}

- (UIView *)separationLine
{
    if (!_separationLine) {
        _separationLine = [[UIView alloc] init];
    }
    return _separationLine;
}

@end
