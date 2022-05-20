//
//  DecodeResultsView.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/24.
//

#import <UIKit/UIKit.h>
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
#import <DynamsoftCameraEnhancer/DynamsoftCameraEnhancer.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EnumDecodeResultsLocation) {
    EnumDecodeResultsLocationCentre,
    EnumDecodeResultsLocationBottom
};

@interface DecodeResultsView : UIView

- (instancetype)initWithFrame:(CGRect)frame location:(EnumDecodeResultsLocation)location withTargetVC:(UIViewController *)targetVC;


/// ShowDecodeResults-Instance Method.
/// @param results TextResultCallback's result.
/// @param location Alert location.
/// @param completion Completion finish block.
- (void)showDecodeResultWith:(NSArray<iTextResult *> *)results location:(EnumDecodeResultsLocation)location completion:(void (^)(void))completion;

/// UpdateLocation,you should invoke this method when you want to change  show results location.
- (void)updateLocation:(EnumDecodeResultsLocation)location;

@end

NS_ASSUME_NONNULL_END
