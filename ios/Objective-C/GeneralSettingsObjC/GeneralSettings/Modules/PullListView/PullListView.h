//
//  PullListView.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PullListView : UIView

+ (void)showPullListViewWithArray:(NSArray *)pullListArray titleName:(NSString *)title selectedDicInfo:(NSDictionary *)selectedDicInfo completion:(void (^)(NSDictionary *selectedDic))completion;

@end

NS_ASSUME_NONNULL_END
