//
//  DecodeResultsBottomTableViewCell.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/26.
//

#import "DecodeResultsBottomTableViewCell.h"

@implementation DecodeResultsBottomTableViewCell

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
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.resultFormatLabel.frame = CGRectMake((kScreenWidth - kDecodeResultBottomTypeContentCellWidth) / 2.0, 10 * kScreenAdaptationRadio, kDecodeResultBottomTypeContentCellWidth, 15 * kScreenAdaptationRadio);
    self.resultFormatLabel.textColor = [UIColor whiteColor];
    self.resultFormatLabel.font = kDecodeResultBottomTypeContentCellTextFont;
    self.resultFormatLabel.textAlignment = NSTextAlignmentCenter;
    self.resultFormatLabel.text = @"";
    [self.contentView addSubview:self.resultFormatLabel];
    
    self.resultTextLabel.frame = CGRectMake((kScreenWidth - kDecodeResultBottomTypeContentCellWidth) / 2.0, self.resultFormatLabel.bottom, kDecodeResultBottomTypeContentCellWidth, 15 * kScreenAdaptationRadio);
    self.resultTextLabel.textColor = [UIColor whiteColor];
    self.resultTextLabel.font = kDecodeResultBottomTypeContentCellTextFont;
    self.resultTextLabel.textAlignment = NSTextAlignmentCenter;
    self.resultTextLabel.text = @"";
    self.resultTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.resultTextLabel];
}

/// Update UI.
- (void)updateUIWithResult:(iTextResult *)textResult
{
    if (textResult.barcodeFormat_2 != 0) {
        self.resultFormatLabel.text = [NSString stringWithFormat:@"%@%@", decodeResultFormatPrefix, textResult.barcodeFormatString_2];
    } else {
        self.resultFormatLabel.text = [NSString stringWithFormat:@"%@%@", decodeResultFormatPrefix, textResult.barcodeFormatString];
    }
    
    self.resultTextLabel.text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
    
    CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:self.resultTextLabel.text font:kDecodeResultBottomTypeContentCellTextFont AndComponentWidth:kDecodeResultBottomTypeContentCellWidth];
    if (textHeight > 15 * kScreenAdaptationRadio) {
        self.resultTextLabel.height = textHeight;
    }
}

#pragma mark - Lazy loading
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

@end
