//
//  BarcodeSubDetailViewController.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// The sub detail of the appointed barcode format
@interface BarcodeSubDetailViewController : BaseViewController

/// The name of the subBarcodeFormat
@property (nonatomic, assign) EnumSubBarcodeFormatName subBarcodeFormatName;

@end

NS_ASSUME_NONNULL_END
