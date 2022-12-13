//
//  TipsMicro.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import Foundation

let barcodeFormatEnableAllString = "Enable All"

let barcodeFormatDisableAllString = "Disable All"

let decodeResultTextPrefix = "Text:"

let decodeResultFormatPrefix = "Format:"

let expectedCountExplain = "The fewer expected barcode count, the higher barcode decoding speed. When the expected count is set to 0, the barcode reader will try to decode at least one barcode."

let enhancedFocusExplain = "Enhanced focus is one of the Dynamsoft Camera Enhancer features. The specially designed focus mechanism will significantly improve the camera's focusing ability on low-end devices."

let frameSharpnessFilterExplain = "Frame sharpness filter is one of the Dynamsoft Camera Enhancer features. It makes a quick evaluation on each video frames so that the Barcode Reader will be able to skip the blurry frames."

let sensorFilterExplain = "Sensor filter is one of the Dynamsoft Camera Enhancer features. The mobile sensor will help on filtering out the video frames that are captured while the device is shaking."

let autoZoomExplain = "Auto-zoom will be available when you are using Dynamsoft Camera Enhancer and Dynamsoft Barcode Reader together. The camera will zoom-in automatically to approach the long-distance barcode."

let fastModeExplain = "Fast mode is one of the Dynamsoft Camera Enhancer features. Frame will be cropped to small size to improve the processing speed."

let smartTorchExplain = "If enabled, a torch button will appear on the camera view when the environment light level is low."

let dceScanRegionExplain = "Set the region of interest via Dynamsoft Camera Enhancer. The frames will be cropped based on the region of interest to improve the barcode decoding speed. Once you have configured the scan region, the fast mode will be negated."

let displayOverlayExplain = "An overlay will be displayed on the successfully decoded barcodes. The display of overlay is controlled by Dynamsoft Camera Enhancer."

let resultVerificationExplain = "Improve the accuracy at the expense of a bit speed."

let duplicateFilterExplain = "Filter out the duplicate barcode results over a period of time."

let duplicateForgetTimeExplain = "Set the time period for duplicate filter. Measured by millisecond."

let minimumDecodeIntervalExplain = "Set the interval of video barcode decoding. It can reduce the battery consumption. Measured by millisecond."
