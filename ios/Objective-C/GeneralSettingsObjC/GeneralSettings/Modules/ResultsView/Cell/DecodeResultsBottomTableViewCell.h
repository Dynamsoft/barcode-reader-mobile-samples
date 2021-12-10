//
//  DecodeResultsBottomTableViewCell.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DecodeResultsBottomTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *resultFormatLabel;

@property (nonatomic, strong) UILabel *resultTextLabel;

/// Update UI
- (void)updateUIWithResult:(iTextResult *)textResult;

@end

NS_ASSUME_NONNULL_END
