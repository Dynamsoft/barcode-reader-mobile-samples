//
//  DecodeResultsCentreTableViewCell.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DecodeResultsCentreTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *resultFormatLabel;

@property (nonatomic, strong) UILabel *resultTextLabel;

@property (nonatomic, strong) UIButton *copyButton;

@property (nonatomic, strong) UILabel *countNumberLabel;


/// copy block
@property (nonatomic, copy) void(^copyBlock)(void);

/// Update copy State
- (void)updateCopyState:(NSString *)copyState;

/// Update UI
- (void)updateUIWithResult:(iTextResult *)textResult;

@end

NS_ASSUME_NONNULL_END
