//
//  StructsUtil.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import Foundation

//MARK: - Barcode format
/**
 Describes the type of the barcode in BarcodeFormat group 1 and group 2
 */
struct BarcodeFormat {
    var format_OneD: String!
    var format_GS1DataBar: String!
    var format_PostalCode: String! // barcode Format group 2
    var format_PatchCode: String!
    var format_PDF417: String!
    var format_QRCode: String!
    var format_DataMatrix: String!
    var format_AZTEC: String!
    var format_MaxiCode: String!
    var format_MicroQR: String!
    var format_MicroPDF417: String!
    var format_GS1Composite: String!
    var format_DotCode: String! // barcode Format group 2
    var format_PHARMACODE: String! // barcode Format group 2
}

/**
 Describes the Combined value of the BarcodeFormatONED
 BarcodeFormatONED is belong to barcode format group1
 */
struct BarcodeFormatONED {
    var format_Code39: String!
    var format_Code128: String!
    var format_Code39Extended: String!
    var format_Code93: String!
    var format_Code_11: String!
    var format_Codabar: String!
    var format_ITF: String!
    var format_EAN13: String!
    var format_EAN8: String!
    var format_UPCA: String!
    var format_UPCE: String!
    var format_Industrial25: String!
    var format_MSICode: String!
}

/**
 Describes the Combined value of the BarcodeFormatGS1DATABAR;
 BarcodeFormatGS1DATABAR is belong to barcode format group1
 */
struct BarcodeFormatGS1DATABAR {
    var format_GS1DatabarOmnidirectional: String!
    var format_GS1DatabarTrunncated: String!
    var format_GS1DatabarStacked: String!
    var format_GS1DatabarStackedOmnidirectional: String!
    var format_GS1DatabarExpanded: String!
    var format_GS1DatabarExpanedStacked: String!
    var format_GS1DatabarLimited: String!
}

/**
 Describes the Combined value of the BarcodeFormat2POSTALCODE;
 BarcodeFormat2POSTALCODE is belong to barcode format group2
 */
struct BarcodeFormat2POSTALCODE {
    var format2_USPSIntelligentMail: String!
    var format2_Postnet: String!
    var format2_Planet: String!
    var format2_AustralianPost: String!
    var format2_RM4SCC: String! // Royal Mail 4-State Customer Barcode
}

/**
 Describes the name of the subBarcodeFormat
 */
enum SubBarcodeFormatType {
    case OneD
    case GS1DataBar
    case PostalCode
}

//MARK: - BarcodeSettings
struct BarcodeSettings {
    var barcodeFormatStr: String!
    var expectedCountStr: String!
    var continuousScanStr: String!
    var minimumResultConfidenceStr: String!
    var resultVerificationStr: String!
    var duplicateFliterStr: String!
    var duplicateForgetTimeStr: String!
    var minimumDecodeIntervalStr: String!
    var decodeInvertedBarcodesStr: String!
    
    var expectedCount: Int!
    var minimumResultConfidence: Int!
    var duplicateForgetTime: Int!
    var minimumDecodeInterval: Int!
    var continuousScanIsOpen: Bool!
    var resultVerificationIsOpen: Bool!
    var duplicateFliterIsOpen: Bool!
    var decodeInvertedBarcodesIsOpen: Bool!
}

//MARK: - Camera Settings
struct CameraSettings {
    var dceResolution: String!
    var dceVibrate: String!
    var dceBeep: String!
    var dceEnhancedFocus: String!
    var dceFrameSharpnessFilter: String!
    var dceSensorFilter: String!
    var dceAutoZoom: String!
    var dceFastMode: String!
    var smartTorch: String!
    var dceScanRegion: String!
    
    var dceVibrateIsOpen: Bool!
    var dceBeepIsOpen: Bool!
    var dceEnhancedFocusIsOpen: Bool!
    var dceFrameSharpnessFilterIsOpen: Bool!
    var dceSensorFilterIsOpen: Bool!
    var dceAutoZoomIsOpen: Bool!
    var dceFastModeIsOpen: Bool!
    var dceSmartTorchIsOpen: Bool!
    var dceScanRegionIsOpen: Bool!
}

struct ScanRegion {
    var scanRegionTop: String!
    var scanRegionBottom: String!
    var scanRegionLeft: String!
    var scanRegionRight: String!
    
    var scanRegionTopValue: Int!
    var scanRegionBottomValue: Int!
    var scanRegionLeftValue: Int!
    var scanRegionRightValue: Int!
}

struct DCEResolution {
    var selectedResolutionValue: EnumResolution!
}

//MARK: - ViewSettings
struct DCEViewSettings {
    var displayOverlay: String!
    var displayTorchButton: String!
    var displayOverlayIsOpen: Bool!
    var displayTorchButtonIsOpen: Bool!
}
