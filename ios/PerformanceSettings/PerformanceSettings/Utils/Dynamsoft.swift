/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import Foundation

let kScreenWidth = UIScreen.main.bounds.size.width

let kScreenHeight = UIScreen.main.bounds.size.height

let kStatusBarHeight = UIDevice.ds_statusBarHeight()

let kNavigationBarFullHeight = UIDevice.ds_navigationFullHeight()

let kTabBarSafeAreaHeight = UIDevice.ds_safeDistanceBottom()

func kFont_Regular(_ fonts: CGFloat) -> UIFont {
    UIFont.systemFont(ofSize: fonts)
}

typealias QuestionCompletion = () -> Void

typealias PatternSelectedCompletion = (_ pattern: BarcodePattern) -> Void

typealias ConfirmCompletion = () -> Void
