/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import Foundation

// MARK: - Barcode format
/**
 Describes the type of the barcode in BarcodeFormat group 1 and group 2
 */
struct BarcodeFormatDescription {
    var oneD: String!
    var gs1DataBar: String!
    var postalCode: String! // barcode Format group 2
    var patchCode: String!
    var pdf417: String!
    var qrCode: String!
    var dataMatrix: String!
    var aztec: String!
    var maxiCode: String!
    var microQR: String!
    var microPDF417: String!
    var gs1Composite: String!
    var dotCode: String! // barcode Format group 2
    var pharmaCODE: String! // barcode Format group 2
}

/**
 Describes the Combined value of the BarcodeFormatONED
 BarcodeFormatONED is belong to barcode format group1
 */
struct BarcodeFormatONEDDescription {
    var code39: String!
    var code128: String!
    var code39Extended: String!
    var code93: String!
    var code11: String!
    var codabar: String!
    var itf: String!
    var ean13: String!
    var ean8: String!
    var upca: String!
    var upce: String!
    var industrial25: String!
    var msiCode: String!
}

/**
 Describes the Combined value of the BarcodeFormatGS1DATABAR;
 BarcodeFormatGS1DATABAR is belong to barcode format group1
 */
struct BarcodeFormatGS1DATABARDescription {
    var gs1DatabarOmnidirectional: String!
    var gs1DatabarTrunncated: String!
    var gs1DatabarStacked: String!
    var gs1DatabarStackedOmnidirectional: String!
    var gs1DatabarExpanded: String!
    var gs1DatabarExpanedStacked: String!
    var gs1DatabarLimited: String!
}

/**
 Describes the Combined value of the BarcodeFormat2POSTALCODE;
 BarcodeFormat2POSTALCODE is belong to barcode format group2
 */
struct BarcodeFormat2POSTALCODEDescription {
    var uspsIntelligentMail: String!
    var postnet: String!
    var planet: String!
    var australianPost: String!
    var rm4SCC: String! // Royal Mail 4-State Customer Barcode
}

/**
 Describes the name of the subBarcodeFormat
 */
enum SubBarcodeFormatType {
    case oneD
    case gs1DataBar
    case postalCode
}

// MARK: - BarcodeSettings
struct BarcodeSettings {
    // Headers.
    var barcodeFormatStr: String!
    var expectedCountStr: String!
    var continuousScanStr: String!
    var minimumResultConfidenceStr: String!
    var resultCrossVerificationStr: String!
    var resultDeduplicationStr: String!
    var duplicateForgetTimeStr: String!
    var decodeInvertedBarcodesStr: String!
    var barcodeTextRegExPatternStr: String!
    
    // Values.
    var expectedCount: UInt!
    var continuousScanIsOpen: Bool!
    var minimumResultConfidence: UInt!
    var resultCrossVerificationIsOpen: Bool!
    var resultDeduplicationIsOpen: Bool!
    var duplicateForgetTime: Int!
    var decodeInvertedBarcodesIsOpen: Bool!
    var barcodeTextRegExPatternContent: String!
}

// MARK: - Camera Settings
struct CameraSettings {
    // Headers.
    var dceResolution: String!
    var dceEnhancedFocus: String!
    var dceFrameSharpnessFilter: String!
    var dceSensorFilter: String!
    var dceAutoZoom: String!
    var smartTorch: String!
    var dceScanRegion: String!
    var dceVibrate: String!
    var dceBeep: String!
    
    // Values.
    var dceEnhancedFocusIsOpen: Bool!
    var dceFrameSharpnessFilterIsOpen: Bool!
    var dceSensorFilterIsOpen: Bool!
    var dceAutoZoomIsOpen: Bool!
    var dceSmartTorchIsOpen: Bool!
    var dceScanRegionIsOpen: Bool!
    var dceVibrateIsOpen: Bool!
    var dceBeepIsOpen: Bool!
}

struct ScanRegion {
    // Headers.
    var scanRegionTop: String!
    var scanRegionBottom: String!
    var scanRegionLeft: String!
    var scanRegionRight: String!
    
    // Values.
    var scanRegionTopValue: CGFloat!
    var scanRegionBottomValue: CGFloat!
    var scanRegionLeftValue: CGFloat!
    var scanRegionRightValue: CGFloat!
}

struct DCEResolution {
    var selectedResolutionValue: Resolution!
}

// MARK: - ViewSettings
struct DCEViewSettings {
    // Headers.
    var highlightDecodedBarcodes: String!
    var displayTorchButton: String!
    
    // Values.
    var highlightDecodedBarcodesIsOpen: Bool!
    var displayTorchButtonIsOpen: Bool!
}
