//
//  DecodeResultsView.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EnumDecodeResultsLocation) {
    EnumDecodeResultsLocationCentre,
    EnumDecodeResultsLocationBottom
};

@interface DecodeResultsView : UIView

- (instancetype)initWithFrame:(CGRect)frame location:(EnumDecodeResultsLocation)location withTargetVC:(UIViewController *)targetVC;

/// ShowDecodeResults-Instance Method
/// @param results textResultCallback's result
/// @param location alert location
/// @param completion completion finish block
- (void)showDecodeResultWith:(NSArray<iTextResult *> *)results location:(EnumDecodeResultsLocation)location completion:(void (^)(void))completion;

/// updateLocation,you should invoke this method when you want to change  show results location
- (void)updateLocation:(EnumDecodeResultsLocation)location;

@end

NS_ASSUME_NONNULL_END
