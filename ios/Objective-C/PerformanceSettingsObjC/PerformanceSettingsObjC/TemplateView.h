//
//  TemplateView.h
//  PerformanceSettingsObjC
//
//  Created by dynamsoft on 5/20/22.
//

#import <UIKit/UIKit.h>
@class TemplateView;

typedef NS_ENUM(NSInteger, EnumTemplateType){
    EnumTemplateTypeSingleBarcode,
    EnumTemplateTypeSpeedFirst,
    EnumTemplateTypeReadRateFirst,
    EnumTemplateTypeAccuracyFirst
};

NS_ASSUME_NONNULL_BEGIN

@protocol TemplateViewDelegate <NSObject>

- (void)transformModeAction:(TemplateView *)templateView templateType:(EnumTemplateType)templateType;

- (void)explainAction:(TemplateView *)templateView templateType:(EnumTemplateType)templateType;

@end

@interface TemplateView : UIView

+ (CGFloat)getHeight;

@property (nonatomic, weak) id<TemplateViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
