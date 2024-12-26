/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import Foundation

let kScreenWidth = UIScreen.main.bounds.size.width

let kScreenHeight = UIScreen.main.bounds.size.height

let kNavigationBarFullHeight = UIDevice.ds_navigationFullHeight()

let kTabBarSafeAreaHeight = UIDevice.ds_safeDistanceBottom()

let KCellSeparationLineHeight = 1.0 / UIScreen.main.scale

func kFont_Regular(_ fonts: CGFloat) -> UIFont {
    UIFont.systemFont(ofSize: fonts)
}

let kExpectedCountMaxValue = 999

let kMinimumResultConfidenceMaxValue = 100

let kDuplicateForgetTimeMaxValue = 600000

let kRegExPatternMaxLength = 100

let kScanRegionMaxValue = 1.0

typealias QuestionCompletion = () -> Void

typealias InputTFNumberChangedCompletion = (_ value: Int) -> Void

typealias InputTFDecimalChangedCompletion = (_ value: CGFloat) -> Void

typealias InputTFTextChangedCompletion = (_ value: String) -> Void

typealias SwitchChangedCompletion = (_ isOn: Bool) -> Void

typealias ConfirmCompletion = () -> Void
