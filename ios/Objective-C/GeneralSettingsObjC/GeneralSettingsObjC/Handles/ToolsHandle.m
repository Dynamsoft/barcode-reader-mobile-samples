//
//  ToolsHandle.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import "ToolsHandle.h"

@implementation ToolsHandle

+ (ToolsHandle *)toolManger
{
    static ToolsHandle *_toolsHandle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _toolsHandle = [super allocWithZone:NULL];
    });
    return _toolsHandle;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [ToolsHandle toolManger];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [ToolsHandle toolManger];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [ToolsHandle toolManger];
}

/// Font adaptive width.
/// @param string The content of the string
/// @param font The font of the string
/// @param componentHeight The height of the compoent
- (CGFloat)calculateWidthWithText:(NSString *)string font:(UIFont *)font AndComponentheight:(CGFloat)componentHeight
{
    if ([self stringIsEmptyOrNull:string]) {
        return 0;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGRect frame = [string boundingRectWithSize:CGSizeMake(10000, componentHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    return frame.size.width;
}

/// Font adaptive height.
/// @param string The content of the string
/// @param font The font of the string
/// @param componentWidth The width of the compoent
- (CGFloat)calculateHeightWithText:(NSString *)string font:(UIFont *)font AndComponentWidth:(CGFloat)componentWidth
{
    if ([self stringIsEmptyOrNull:string]) {
        return 0;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGRect frame = [string boundingRectWithSize:CGSizeMake(componentWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    return frame.size.height;
}


/// Checks if the string is empty.
- (BOOL)stringIsEmptyOrNull:(NSString*)string
{
    return ![self notEmptyOrNull:string];
}

/// Checks if the string is not empty
- (BOOL)notEmptyOrNull:(NSString*)string
{
    if ([string isKindOfClass:[NSNull class]])
        return NO;
    if ([string isEqual:[NSNull null]] || string==nil) {
        return NO;
    }
    if ([string isKindOfClass:[NSNumber class]]) {
        if (string != nil) {
            return YES;
        }
        return NO;
    }
    else {
        string = [self trimString:string];
        if ( [string isEqualToString:@"null"] || [string isEqualToString:@"(null)"] || [string isEqualToString:@" "]|| [string isEqualToString:@""] || [string isEqualToString:@"<null>"]) {
            return NO;
        }
        if (string != nil && string.length > 0) {
            return YES;
        }
        return NO;
    }
}

/// CropString.
- (NSString*)trimString:(NSString*)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/// Alert view.
/// @param title The title of the reminder
/// @param content The content of the reminder
/// @param actionTitle The title fo the action
/// @param targetController target controller
/// @param completion click completion
- (void)addAlertViewWithTitle:(NSString *)title Content:(NSString *)content actionTitle:(NSString *_Nullable)actionTitle ToView:(UIViewController *)targetController completion:(nullable void (^)(void))completion
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:actionTitle != nil ? actionTitle : @"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
        
    }];
    [alert addAction:sureAction];
    
    [targetController presentViewController:alert animated:YES completion:nil];
}

@end
