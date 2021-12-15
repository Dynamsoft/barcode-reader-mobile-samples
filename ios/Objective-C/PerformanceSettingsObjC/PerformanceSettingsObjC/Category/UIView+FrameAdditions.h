//
//  UIView+FrameAdditions.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (FrameAdditions)

///  hegiht
@property (nonatomic,assign) CGFloat height;
///  width
@property (nonatomic,assign) CGFloat width;

///  Y
@property (nonatomic,assign) CGFloat top;
///  X
@property (nonatomic,assign) CGFloat left;

///  Y + Height
@property (nonatomic,assign) CGFloat bottom;
///  X + width
@property (nonatomic,assign) CGFloat right;

@end

NS_ASSUME_NONNULL_END
