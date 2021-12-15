//
//  DecodeResultsCentreTableViewCell.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/25.
//

#import "DecodeResultsCentreTableViewCell.h"

@interface DecodeResultsCentreTableViewCell ()

@property (nonatomic, copy) NSString *recordBarcodeText;

@end

@implementation DecodeResultsCentreTableViewCell

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
    
    self.resultFormatLabel.frame = CGRectMake(10 * kScreenAdaptationRadio, 14 * kScreenAdaptationRadio, kDecodeResultContentCellWidth + 30 * kScreenAdaptationRadio, 15 * kScreenAdaptationRadio);
    self.resultFormatLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
    self.resultFormatLabel.font = kDecodeResultContentCellTextFont;
    self.resultFormatLabel.text = @"";
    [self.contentView addSubview:self.resultFormatLabel];
    
    self.resultTextLabel.frame = CGRectMake(10 * kScreenAdaptationRadio, 35 * kScreenAdaptationRadio, kDecodeResultContentCellWidth, 15 * kScreenAdaptationRadio);
    self.resultTextLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
    self.resultTextLabel.font = kDecodeResultContentCellTextFont;
    self.resultTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.resultTextLabel];
    
    self.countNumberLabel.frame = CGRectMake(kDecodeResultsBackgroundWidth - 50 * kScreenAdaptationRadio, 17 * kScreenAdaptationRadio, 40 * kScreenAdaptationRadio, 10 * kScreenAdaptationRadio);
    self.countNumberLabel.textAlignment = NSTextAlignmentRight;
    self.countNumberLabel.font = kFont_Regular(10 * kScreenAdaptationRadio);
    self.countNumberLabel.textColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
    [self.contentView addSubview:self.countNumberLabel];
    
    self.copyButton.frame = CGRectMake(self.countNumberLabel.left, 30 * kScreenAdaptationRadio, 45 * kScreenAdaptationRadio, 30 * kScreenAdaptationRadio);
    self.copyButton.titleLabel.font = kFont_Regular(14 * kScreenAdaptationRadio);
    [self.copyButton setTitle:@"copy" forState:UIControlStateNormal];
    [self.copyButton setTitleColor:[UIColor colorWithRed:62/255.0 green:130/255.0 blue:249/255.0 alpha:1] forState:UIControlStateNormal];
    self.copyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.copyButton addTarget:self action:@selector(resultCopy) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.copyButton];
    
}

- (void)resultCopy
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.recordBarcodeText;
    
    if (self.copyBlock) {
        self.copyBlock();
    }
}

/// Update copy State
- (void)updateCopyState:(NSString *)copyState
{
    if ([copyState isEqualToString:@"1"]) {
        [self.copyButton setTitle:@"copy" forState:UIControlStateNormal];
        [self.copyButton setTitleColor:[UIColor colorWithRed:62/255.0 green:130/255.0 blue:249/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        [self.copyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.copyButton setTitle:@"copied" forState:UIControlStateNormal];
    }
}

/// Update UI
- (void)updateUIWithResult:(iTextResult *)textResult
{
    if (textResult.barcodeFormat_2 != 0) {
        self.resultFormatLabel.text = [NSString stringWithFormat:@"%@%@", decodeResultFormatPrefix, textResult.barcodeFormatString_2];
    } else {
        self.resultFormatLabel.text = [NSString stringWithFormat:@"%@%@", decodeResultFormatPrefix, textResult.barcodeFormatString];
    }
    
    self.resultTextLabel.text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
    
    self.recordBarcodeText = textResult.barcodeText;
    
    CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:self.resultTextLabel.text font:kDecodeResultContentCellTextFont AndComponentWidth:kDecodeResultContentCellWidth];
    if (textHeight > 15 * kScreenAdaptationRadio) {
        self.resultTextLabel.height = textHeight;
    }
    
}

#pragma mark - LazyLoading
- (UILabel *)resultFormatLabel
{
    if (!_resultFormatLabel) {
        _resultFormatLabel = [[UILabel alloc] init];
    }
    return _resultFormatLabel;
}

- (UILabel *)resultTextLabel
{
    if (!_resultTextLabel) {
        _resultTextLabel = [[UILabel alloc] init];
    }
    return _resultTextLabel;
}

- (UIButton *)copyButton
{
    if (!_copyButton) {
        _copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _copyButton;
}

- (UILabel *)countNumberLabel
{
    if (!_countNumberLabel) {
        _countNumberLabel = [[UILabel alloc] init];
    }
    return _countNumberLabel;
}

@end
