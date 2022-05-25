//
//  BasicTextTableViewCell.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import "BasicTextTableViewCell.h"

@interface BasicTextTableViewCell ()<UITextFieldDelegate>

/// The accessoryVIew of the inputCountTF.
@property (nonatomic, strong) UIView *inputCountTFAccessoryView;

/// Save maxvalue of the inputCountTF.
@property (nonatomic, assign) NSInteger saveMaxNum;

@end

@implementation BasicTextTableViewCell

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

    self.inputCountTF.frame = CGRectMake(kScreenWidth - kCellRightmarin - 150 * kScreenAdaptationRadio, (kCellHeight - 20 * kScreenAdaptationRadio) / 2.0, 150 * kScreenAdaptationRadio, 20 * kScreenAdaptationRadio);
    self.inputCountTF.tintColor = kCellInputTFTextColor;
    self.inputCountTF.textColor = kCellInputTFTextColor;
    self.inputCountTF.font = kFont_Regular(kCellInputCountFontSize);
    self.inputCountTF.textAlignment = NSTextAlignmentRight;
    self.inputCountTF.keyboardType = UIKeyboardTypeNumberPad;
    self.inputCountTF.returnKeyType = UIReturnKeyDone;
    self.inputCountTF.clearsOnBeginEditing = YES;
    self.inputCountTF.inputAccessoryView = self.inputCountTFAccessoryView;
    self.inputCountTF.delegate = self;
    [self.inputCountTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:self.inputCountTF];
    
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

- (void)doneButtonClicked
{
    [self.inputCountTF resignFirstResponder];
    if ([[ToolsHandle toolManger] stringIsEmptyOrNull:self.inputCountTF.text]) {
        self.inputCountTF.text = @"0";
    }
    if (self.inputTFValueChangedBlock) {
        self.inputTFValueChangedBlock([self.inputCountTF.text integerValue]);
    }
}

/// Setting the maxvalue of the inputCountTF.
- (void)setInputCountTFMaxValueWithNum:(NSInteger)maxValue
{
    self.saveMaxNum = maxValue;
}

/// Update UI.
- (void)updateUIWithTitle:(NSString *)titleString
{
    
    self.titleLabel.text = titleString;
    self.titleLabel.width = [[ToolsHandle toolManger] calculateWidthWithText:titleString font:self.titleLabel.font AndComponentheight:self.titleLabel.height];
    self.questionButton.left = self.titleLabel.right + kCellMarginBetweenTextAndQuestion * kScreenAdaptationRadio;
    
    NSInteger expectedBarcodesCount = [GeneralSettingsHandle setting].ipublicRuntimeSettings.expectedBarcodesCount;
    self.inputCountTF.text = [NSString stringWithFormat:@"%ld", (long)expectedBarcodesCount];
    
}

/// Update UI with title and value.
- (void)updateUIWithTitle:(NSString *)titleString value:(NSInteger)valueNum
{
    self.titleLabel.text = titleString;
    self.titleLabel.width = [[ToolsHandle toolManger] calculateWidthWithText:titleString font:self.titleLabel.font AndComponentheight:self.titleLabel.height];
    self.questionButton.left = self.titleLabel.right + kCellMarginBetweenTextAndQuestion * kScreenAdaptationRadio;
    self.inputCountTF.text = [NSString stringWithFormat:@"%ld", (long)valueNum];
}

//MARK: UITextFieldDeleagte
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([[ToolsHandle toolManger] stringIsEmptyOrNull:self.inputCountTF.text]) {
        self.inputCountTF.text = [NSString stringWithFormat:@"%ld", [GeneralSettingsHandle setting].ipublicRuntimeSettings.expectedBarcodesCount];
    }
    if (self.inputTFValueChangedBlock) {
        self.inputTFValueChangedBlock([self.inputCountTF.text integerValue]);
    }
}
- (void)textFieldDidChange:(UITextField *)textField
{
    NSInteger numValue = [textField.text integerValue];
    if (numValue > self.saveMaxNum) {
        textField.text = [textField.text substringToIndex:[textField.text length]-1];

    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return YES;
}

#pragma mark - Lazy loading
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UITextField *)inputCountTF
{
    if (!_inputCountTF) {
        _inputCountTF = [[UITextField alloc] init];
    }
    return _inputCountTF;
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

- (UIView *)inputCountTFAccessoryView
{
    if (!_inputCountTFAccessoryView) {
        _inputCountTFAccessoryView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        _inputCountTFAccessoryView.backgroundColor = [UIColor colorWithRed:216 / 255.0 green:216 / 255.0 blue:216 / 255.0 alpha:1];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 55, 5, 40, 28)];
        [btn setTitle:@"Done" forState:UIControlStateNormal];
        
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        btn.titleLabel.font = kFont_Regular(16);
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(doneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_inputCountTFAccessoryView addSubview:btn];
    }
    return _inputCountTFAccessoryView;
}

@end
