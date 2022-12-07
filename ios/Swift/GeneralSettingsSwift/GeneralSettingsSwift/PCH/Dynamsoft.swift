//
//  Dynamsoft.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
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

let kStatusBarHeight = kIs_iPhoneXAndLater ? 44.0:20.0

/// The height of the tabbar
let kTabBarHeight = kIs_iPhoneXAndLater ? (49.0 + 34.0):49.0

let kTabBarAreaHeight = kIs_iPhoneXAndLater ? 34.0:0.0

let KCellSeparationLineHeight = 1.0 / UIScreen.main.scale

func kFont_Regular(_ fonts: CGFloat) -> UIFont {
    UIFont.systemFont(ofSize: fonts)
}

let kExpectedCountMaxValue = 999

let kMinimumResultConfidenceMaxValue = 100

let kDuplicateForgetTimeMaxValue = 600000

let kMinimumDecodeIntervalMaxValue = 0x7fffffff

typealias QuestionCompletion = () -> Void

typealias InputTFValueChangedCompletion = (_ value: Int) -> Void

typealias SwitchChangedCompletion = (_ isOn: Bool) -> Void
