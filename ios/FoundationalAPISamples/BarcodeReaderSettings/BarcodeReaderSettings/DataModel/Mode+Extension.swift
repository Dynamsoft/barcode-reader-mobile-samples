/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import DynamsoftCaptureVisionBundle

let kSettingFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("settings.json")
let kSimplifiedCaptureVisionSettingsState = "simplifiedCaptureVisionSettingsState"
let kBarcodeFormatState = "barcodeFormatState"
let kTemplateState = "templateState"
let kOtherSettingsState = "otherSettingsState"

extension LocalizationMode {
    var string: String {
        switch self {
        case .skip:
            return "Skip"
        case .auto:
            return "Auto"
        case .connectedBlocks:
            return "Connected Blocks"
        case .statistics:
            return "Statistics"
        case .lines:
            return "Lines"
        case .scanDirectly:
            return "Scan Directly"
        case .statisticsMarks:
            return "Statistics Marks"
        case .statisticsPostalCode:
            return "Statistics Postal Code"
        case .centre:
            return "Centre"
        case .oneDFastScan:
            return "1D Fast Scan"
        case .neuralNetwork:
            return "Neural Network"
        case .end:
            return "End"
        case .rev:
            return "Rev"
        default:
            return "Unknown"
        }
    }
}

extension DeblurMode {
    var string: String {
        switch self {
        case .skip:
            return "Skip"
        case .directBinarization:
            return "Direct Binarization"
        case .thresholdBinarization:
            return "Threshold Binarization"
        case .grayEqualization:
            return "Gray Equalization"
        case .smoothing:
            return "Smoothing"
        case .morphing:
            return "Morphing"
        case .deepAnalysis:
            return "Deep Analysis"
        case .sharpening:
            return "Sharpening"
        case .basedOnLocBin:
            return "Based On Loc Bin"
        case .sharpeningSmoothing:
            return "Sharpening Smoothing"
        case .neuralNetwork:
            return "Neural Network"
        case .end:
            return "End"
        case .rev:
            return "Rev"
        default:
            return "Unknown"
        }
    }
}

extension GrayscaleEnhancementMode {
    var string: String {
        switch self {
        case .skip:
            return "Skip"
        case .auto:
            return "Auto"
        case .general:
            return "General"
        case .grayEqualize:
            return "Gray Equalize"
        case .graySmooth:
            return "Gray Smooth"
        case .sharpenSmooth:
            return "Sharpen Smooth"
        case .end:
            return "End"
        case .rev:
            return "Rev"
        default:
            return "Unknown"
        }
    }
}

extension GrayscaleTransformationMode {
    var string: String {
        switch self {
        case .skip:
            return "Skip"
        case .inverted:
            return "Inverted"
        case .original:
            return "Original"
        case .auto:
            return "Auto"
        case .end:
            return "End"
        case .rev:
            return "Rev"
        default:
            return "Unknown"
        }
    }
}
