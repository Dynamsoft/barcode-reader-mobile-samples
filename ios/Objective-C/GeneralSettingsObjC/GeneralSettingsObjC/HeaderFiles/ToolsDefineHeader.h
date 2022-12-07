//
//  ToolsDefineHeader.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/18.
//

#ifndef ToolsDefineHeader_h
#define ToolsDefineHeader_h
#import <UIKit/UIKit.h>


/// The width of the screen
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

/// The height of the screen
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

/// Determine if it's an iPhone
#define kIs_iphone [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone

/// Check if it's an iphoneX or later
#define kIs_iPhoneXAndLater kScreenWidth >=375.0f && kScreenHeight >=812.0f&& kIs_iphone

/// The height of the statusBar
#define kStatusBarHeight (CGFloat)(kIs_iPhoneXAndLater?(44.0):(20.0))

/// The height of the navigationBar and statusBar
#define kNaviBarAndStatusBarHeight (CGFloat)(kIs_iPhoneXAndLater?(88.0):(64.0))

/// The height of the tabbar
#define kTabBarHeight (CGFloat)(kIs_iPhoneXAndLater?(49.0 + 34.0):(49.0))

/// The height of the tabbar
#define kTabBarAreaHeight (CGFloat)(kIs_iPhoneXAndLater?(34.0):(0))

/// Navigation backgroundColor
#define kNavigationBackgroundColor  [UIColor colorWithRed:59.003/255.0 green:61.9991/255.0 blue:69.0028/255.0 alpha:1]

#define kScreenAdaptationRadio kScreenWidth / 375.0

//MARK: - PageList
#define kCellTitleFontSize 14 * kScreenAdaptationRadio

#define kCellInputCountFontSize 13 * kScreenAdaptationRadio

#define kCellPullTextFontSize 13 * kScreenAdaptationRadio

#define kCellLeftMargin 16 * kScreenAdaptationRadio

#define kCellRightMargin 18 * kScreenAdaptationRadio

#define kCellTextFormatName @"UICTFontTextStyleBody"

#define kTextFormatName @"PingFangSC-Regular"

#define kFont_Regular(fonts) [UIFont fontWithName:kTextFormatName size:fonts]

#define kCellHeight 44 * kScreenAdaptationRadio

#define kCellMarginBetweenTextAndQuestion 20

#define kCellInputTFTextColor  [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1]

#define KCellSeparationLineHeight 1.0/UIScreen.mainScreen.scale

#define kCellSeparationLineBackgroundColor [UIColor colorWithRed:233 / 255.0 green:233 / 255.0 blue:233 / 255.0 alpha:1]

#define kTableViewHeaderBackgroundColor [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1]

#define kTableViewHeaderTitleColor [UIColor colorWithRed:123.999/255.0 green:123.999/255.0 blue:123.999/255.0 alpha:1]

#define kTableViewHeaderTitleFont [UIFont fontWithName:kTextFormatName size:14]

#define kTableViewHeaderButtonColor [UIColor colorWithRed:0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:1]

#define kTableViewHeaderButtonFont [UIFont fontWithName:kTextFormatName size:14]

//MARK: - DecodeResultsView
/// CentreType
#define kDecodeResultsHeaderHeight 40 * kScreenAdaptationRadio

#define kDecodeResultsFooterHeight 44 * kScreenAdaptationRadio

#define kDecodeResultsBackgroundWidth 320 * kScreenAdaptationRadio

#define kDecodeResultsCellHeight 65 * kScreenAdaptationRadio

#define kDecodeResultContentCellWidth (kDecodeResultsBackgroundWidth - 70 * kScreenAdaptationRadio)

#define kDecodeResultContentCellTextFont kFont_Regular(14 * kScreenAdaptationRadio)

/// BottomType
#define KDecodeResultBottomTypeBackgroundHeight 200 * kScreenAdaptationRadio

#define kDecodeResultBottomTypeTableHeaderViewHeight 30 * kScreenAdaptationRadio

#define kDecodeResultBottomTypeContentCellHeight 60 * kScreenAdaptationRadio

#define kDecodeResultBottomTypeContentCellWidth (kScreenWidth - 40 * kScreenAdaptationRadio)

#define kDecodeResultBottomTypeContentCellTextFont kFont_Regular(16 * kScreenAdaptationRadio)


// scanBarWidth
#define kScanLineWidth 300 * kScreenAdaptationRadio

#endif /* ToolsDefineHeader_h */
