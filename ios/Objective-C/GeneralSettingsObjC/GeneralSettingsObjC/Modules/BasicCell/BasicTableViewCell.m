//
//  BasicTableViewCell.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/19.
//

#import "BasicTableViewCell.h"

@implementation BasicTableViewCell

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
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.titleLabel.frame = CGRectMake(kCellLeftMargin, 0, 0, kCellHeight);
    self.titleLabel.font = kFont_Regular(kCellTitleFontSize);
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.titleLabel];
    
    self.separationLine.frame = CGRectMake(0, kCellHeight - KCellSeparationLineHeight, kScreenWidth, KCellSeparationLineHeight);
    self.separationLine.backgroundColor = kCellSeparationLineBackgroundColor;
    [self.contentView addSubview:self.separationLine];
}

/// Update UI.
- (void)updateUIWithTitle:(NSString *)titleString
{
    self.titleLabel.text = titleString;
    self.titleLabel.width = [[ToolsHandle toolManger] calculateWidthWithText:titleString font:self.titleLabel.font AndComponentheight:self.titleLabel.height];
    
}

#pragma mark - Lazy loading
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UIView *)separationLine
{
    if (!_separationLine) {
        _separationLine = [[UIView alloc] init];
    }
    return _separationLine;
}


@end
