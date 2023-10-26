//
//  Dynamsoft.swift
//  TinyBarcode
//
//  Copyright © Dynamsoft. All rights reserved.
//

import Foundation
import UIKit

let kScreenWidth = UIScreen.main.bounds.size.width

let kScreenHeight = UIScreen.main.bounds.size.height

let kTabBarSafeAreaHeight = UIDevice.ds_safeDistanceBottom()

func kFont_Regular(_ fonts: CGFloat) -> UIFont {
    UIFont.systemFont(ofSize: fonts)
}

let kDCEMinimumZoom: CGFloat = 1.5

let KDCEMaximumZoom: CGFloat = 5.0

let kAutoZoomIsOpen = false

let kZoomComponentBottomMargin = 70.0

let KCameraSettingViewAvailableHeight = 60.0

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

let KSliderTrackTintColor = UIColor(red: 112.0 / 255.0, green: 112.0 / 255.0, blue: 112.0 / 255.0, alpha: 1)

typealias ConfirmCompletion = () -> Void
