//
//  Dynamsoft.swift
//  TinyBarcode
//
//  Created by dynamsoft's mac on 2022/11/24.
//

import Foundation

let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height

/// Determine if it's an iPhone
let kIs_iPhone = UIDevice.current.userInterfaceIdiom == .phone

/// Check if it's an iphoneX or later
let kIs_iPhoneXAndLater = kScreenWidth >= 375.0 && kScreenHeight >= 812.0 && kIs_iPhone

/// The height of the navigationBar and statusBar
let kNaviBarAndStatusBarHeight = kIs_iPhoneXAndLater ? 88.0:64.0

func kFont_SystemDefault(_ fonts: CGFloat) -> UIFont {
    UIFont.systemFont(ofSize: fonts)
}

let kDCEDefaultZoom: CGFloat = 1.5

let KDCEMaxZoom: CGFloat = 5.0

let kAutoZoomIsOpen = false

let kZoomComponentBottomMargin = 70.0

let KCameraSettingAvailableHeight = 60.0

let kLeftMarginOfContainer = 16.0

let kRightMarginOfContainer = 16.0

let kCameraZoomFloatingLabelTextSize = 12.0

let kCameraZoomFloatingButtonWidth = 35.0

let kCameraZoomSliderViewHeight = 80.0 + 35.0 + 15.0

let KCameraSettingTitleTextSize = 17.0

let kSwitchOnTintColor = UIColor(red: 254/255.0, green: 142/255.0, blue: 20/255.0, alpha: 1.0)

let kSwitchOffTintColor = UIColor(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1.0)

let kSwitchOnThumbColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)

let kSwitchOffThumbColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0)

