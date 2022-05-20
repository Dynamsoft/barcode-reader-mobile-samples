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
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.frame = CGRectMake(kCellLeftMargin, 0, 0, kCellHeight);
    self.titleLabel.font = kFont_Regular(kCellTitleFontSize);
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.titleLabel];
    
    // questionButton
    self.questionButton.frame = CGRectMake(100, (kCellHeight - 16 * kScreenAdaptationRadio) / 2.0, 16 * kScreenAdaptationRadio, 16 * kScreenAdaptationRadio);
    [self.questionButton setImage:[UIImage imageNamed:@"icon_question"] forState:UIControlStateNormal];
    [self.questionButton addTarget:self action:@selector(clickQuestionButton) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.questionButton];
    
    self.separationLine.frame = CGRectMake(0, kCellHeight - KCellSeparationLineHeight, kScreenWidth, KCellSeparationLineHeight);
//    self.separationLine.backgroundColor = kCellSeparationLineBackgroundColor;
    self.separationLine.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.contentView addSubview:self.separationLine];
}

- (void)clickQuestionButton
{
    if (self.questionBlock) {
        self.questionBlock();
    }
}

//MARK: UpdateUI
- (void)updateUIWithTitle:(NSString *)titleString andOptionalState:(NSInteger)optionalState
{
    self.titleLabel.text = titleString;
    self.titleLabel.width = [[ToolsHandle toolManger] calculateWidthWithText:titleString font:self.titleLabel.font AndComponentheight:self.titleLabel.height];
    self.questionButton.left = self.titleLabel.right + kCellMarginBetweenTextAndQuestion * kScreenAdaptationRadio;
    
    if (optionalState == 1) {
        self.contentView.backgroundColor = [UIColor colorWithRed:250 / 255.0 green:250 / 255.0 blue:250 / 255.0 alpha:0.5];
    } else {
        self.contentView.backgroundColor = [UIColor colorWithRed:100 / 255.0 green:100 / 255.0 blue:100 / 255.0 alpha:0.5];
    }
}

#pragma mark - Lazy loading

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UIButton *)questionButton
{
    if (!_questionButton) {
        _questionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _questionButton;
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
