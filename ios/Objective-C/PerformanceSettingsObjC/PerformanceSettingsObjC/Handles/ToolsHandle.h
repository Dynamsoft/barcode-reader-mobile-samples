//
//  ToolsHandle.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToolsHandle : NSObject<NSCopying, NSMutableCopying>

+ (ToolsHandle *)toolManger;


/// Font adaptive width.
/// @param string The content of the string.
/// @param font The font of the string.
/// @param componentHeight The height of the compoent.
- (CGFloat)calculateWidthWithText:(NSString *)string font:(UIFont *)font AndComponentheight:(CGFloat)componentHeight;

/// Font adaptive height.
/// @param string The content of the string.
/// @param font The font of the string.
/// @param componentWidth The width of the compoent.
- (CGFloat)calculateHeightWithText:(NSString *)string font:(UIFont *)font AndComponentWidth:(CGFloat)componentWidth;

/// Checks if the string is empty.
- (BOOL)stringIsEmptyOrNull:(NSString*)string;

/// Alert view.
/// @param title The title of the reminder.
/// @param content The content of the reminder.
/// @param actionTitle The title fo the action.
/// @param targetController Target controller.
/// @param completion Click completion.
- (void)addAlertViewWithTitle:(NSString *)title Content:(NSString *)content actionTitle:(NSString *_Nullable)actionTitle ToView:(UIViewController *)targetController completion:(nullable void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
