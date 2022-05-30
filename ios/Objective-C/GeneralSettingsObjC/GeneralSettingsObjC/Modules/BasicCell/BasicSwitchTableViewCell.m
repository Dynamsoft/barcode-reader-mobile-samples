//
//  BasicSwitchTableViewCell.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import "BasicSwitchTableViewCell.h"

@implementation BasicSwitchTableViewCell

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
    
    self.questionButton.frame = CGRectMake(100, (kCellHeight - 16 * kScreenAdaptationRadio) / 2.0, 16 * kScreenAdaptationRadio, 16 * kScreenAdaptationRadio);
    [self.questionButton setImage:[UIImage imageNamed:@"icon_question"] forState:UIControlStateNormal];
    [self.questionButton addTarget:self action:@selector(clickQuestionButton) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.questionButton];
    
    self.controlSwitch.left = kScreenWidth - kCellRightmarin - self.controlSwitch.width;
    self.controlSwitch.top = (kCellHeight - self.controlSwitch.height) / 2.0;
    [self.controlSwitch addTarget:self action:@selector(controlSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.controlSwitch];
    
    self.separationLine.frame = CGRectMake(0, kCellHeight - KCellSeparationLineHeight, kScreenWidth, KCellSeparationLineHeight);
    self.separationLine.backgroundColor = kCellSeparationLineBackgroundColor;
    [self.contentView addSubview:self.separationLine];
}

- (void)clickQuestionButton
{
    if (self.questionBlock) {
        self.questionBlock();
    }
}

- (void)controlSwitchChanged:(UISwitch *)controlSwitch
{
    
    if (self.switchChangedBlock) {
        self.switchChangedBlock(controlSwitch.on);
    }
}

/// Update UI.
- (void)updateUIWithTitle:(NSString *)titleString withSwitchState:(BOOL)isOpen
{
    self.titleLabel.text = titleString;
    self.titleLabel.width = [[ToolsHandle toolManger] calculateWidthWithText:titleString font:self.titleLabel.font AndComponentheight:self.titleLabel.height];
    self.questionButton.left = self.titleLabel.right + kCellMarginBetweenTextAndQuestion * kScreenAdaptationRadio;
    
    self.controlSwitch.on = isOpen;
}

#pragma mark - Lazy loading
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}


- (UISwitch *)controlSwitch
{
    if (!_controlSwitch) {
        _controlSwitch = [[UISwitch alloc] init];
    }
    return _controlSwitch;
}

- (UIButton *)questionButton
{
    if (!_questionButton) {
        _questionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _questionButton;
}

- (UIView *)separationLine
{
    if (!_separationLine) {
        _separationLine = [[UIView alloc] init];
    }
    return _separationLine;
}


@end
