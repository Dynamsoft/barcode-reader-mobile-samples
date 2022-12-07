//
//  GeneralSettings.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class GeneralSettings: NSObject {
    static let shared = GeneralSettings()
    
    // About BarcodeFormat description.
    var allBarcodeFormat: BarcodeFormat!
    var barcodeFormatONED: BarcodeFormatONED!
    var barcodeFormatGS1DATABAR: BarcodeFormatGS1DATABAR!
    var barcodeFormat2POSTALCODE: BarcodeFormat2POSTALCODE!
    
    // About CameraSettings.
    var barcodeSettings: BarcodeSettings!
    var cameraSettings: CameraSettings!
    var scanRegion: ScanRegion!
    var dceResolution: DCEResolution!
    
    // About ViewSettings.
    var dceViewSettings: DCEViewSettings!
    
    // About DCE and DBR.
    var barcodeReader: DynamsoftBarcodeReader!
    var cameraEnhancer: DynamsoftCameraEnhancer!
    var cameraView: DCECameraView!
    
    var ipublicRuntimeSettings: iPublicRuntimeSettings!
    
    /// Configure default data.
    func setDefaultData() -> Void {
        
        // Barcode Format data initialization.
        // Set BarcodeFormat.
        // Specify the barcode formats to match your requirements.
        // The less barcode formats, the higher processing speed.
        self.allBarcodeFormat = BarcodeFormat()
        self.allBarcodeFormat.format_OneD = "OneD"
        self.allBarcodeFormat.format_GS1DataBar = "GS1 DataBar"
        self.allBarcodeFormat.format_PostalCode = "Postal Code"
        self.allBarcodeFormat.format_PatchCode = "Patch Code"
        self.allBarcodeFormat.format_PDF417 = "PDF417"
        self.allBarcodeFormat.format_QRCode = "QR Code"
        self.allBarcodeFormat.format_DataMatrix = "DataMatrix"
        self.allBarcodeFormat.format_AZTEC = "AZTEC"
        self.allBarcodeFormat.format_MaxiCode = "MaxiCode"
        self.allBarcodeFormat.format_MicroQR = "Micro QR"
        self.allBarcodeFormat.format_MicroPDF417 = "Micro PDF417"
        self.allBarcodeFormat.format_GS1Composite = "GS1 Composite"
        self.allBarcodeFormat.format_DotCode = "Dot Code"
        self.allBarcodeFormat.format_PHARMACODE = "Pharma Code"
        
        // Set BarcodeFormatONED.
        self.barcodeFormatONED = BarcodeFormatONED()
        self.barcodeFormatONED.format_Code39 = "Code 39"
        self.barcodeFormatONED.format_Code128 = "Code 128"
        self.barcodeFormatONED.format_Code39Extended = "Code 39 EXtended"
        self.barcodeFormatONED.format_Code93 = "Code 93"
        self.barcodeFormatONED.format_Code_11 = "Code 11"
        self.barcodeFormatONED.format_Codabar = "Codabar"
        self.barcodeFormatONED.format_ITF = "ITF"
        self.barcodeFormatONED.format_EAN13 = "EAN-13"
        self.barcodeFormatONED.format_EAN8 = "EAN-8"
        self.barcodeFormatONED.format_UPCA = "UPC-A"
        self.barcodeFormatONED.format_UPCE = "UPC-E"
        self.barcodeFormatONED.format_Industrial25 = "Industrial 25"
        self.barcodeFormatONED.format_MSICode = "MSI Code"
        
        // Set barcodeFormatGS1DATABAR.
        self.barcodeFormatGS1DATABAR = BarcodeFormatGS1DATABAR()
        self.barcodeFormatGS1DATABAR.format_GS1DatabarOmnidirectional = "GS1 Databar Omnidirectional"
        self.barcodeFormatGS1DATABAR.format_GS1DatabarTrunncated = "GS1 Databar Truncated"
        self.barcodeFormatGS1DATABAR.format_GS1DatabarStacked = "GS1 Databar Stacked"
        self.barcodeFormatGS1DATABAR.format_GS1DatabarStackedOmnidirectional = "GS1 Databar Stacked Omnidirectional"
        self.barcodeFormatGS1DATABAR.format_GS1DatabarExpanded = "GS1 Databar Expanded"
        self.barcodeFormatGS1DATABAR.format_GS1DatabarExpanedStacked = "GS1 Databar Expaned Stacked"
        self.barcodeFormatGS1DATABAR.format_GS1DatabarLimited = "GS1 Databar Limited"
        
        // Set barcodeFormat2POSTALCODE.
        self.barcodeFormat2POSTALCODE = BarcodeFormat2POSTALCODE()
        self.barcodeFormat2POSTALCODE.format2_USPSIntelligentMail = "USPS Intelligent Mail"
        self.barcodeFormat2POSTALCODE.format2_Postnet = "Postnet"
        self.barcodeFormat2POSTALCODE.format2_Planet = "Planet"
        self.barcodeFormat2POSTALCODE.format2_AustralianPost = "Australian Post"
        self.barcodeFormat2POSTALCODE.format2_RM4SCC = "Royal Mail"
        
        // Barcode settings.
        self.barcodeSettings = BarcodeSettings()
        self.barcodeSettings.barcodeFormatStr = "Barcode Formats"
        self.barcodeSettings.expectedCountStr = "Expected Count"
        self.barcodeSettings.continuousScanStr = "Continuous Scan"
        self.barcodeSettings.minimumResultConfidenceStr = "Minimum Result Confidence"
        self.barcodeSettings.resultVerificationStr = "Result Verification"
        self.barcodeSettings.duplicateFliterStr = "Duplicate Fliter"
        self.barcodeSettings.duplicateForgetTimeStr = "Duplicate Forget Time"
        self.barcodeSettings.minimumDecodeIntervalStr = "Minimum Decode Interval"
        self.barcodeSettings.decodeInvertedBarcodesStr = "Decode Inverted Barcodes"
        
        // Camera Settings.
        // Enhanced focus feature of Dynamsoft Camera Enhancer will enhance the focus ability of low-end device.
        // Frame filter feature of Dynamsoft Camera Enhancer will filter out the blurry video frame.
        // Sensor filter feature of Dynamsoft Camera Enhancer will filter out the frames captured when the device is shaking.
        // Auto zoom feature of Dynamsoft Camera Enhancer will enable the camera to zoom in to apporach the barcodes.
        // Fast mode feature of Dynamsoft Camera Enhancer will crop the frames to reduce the processing size.
        self.cameraSettings = CameraSettings()
        self.cameraSettings.dceResolution = "Resolution"
        self.cameraSettings.dceVibrate = "Vibration"
        self.cameraSettings.dceBeep = "Beep"
        self.cameraSettings.dceEnhancedFocus = "Enhanced Focus"
        self.cameraSettings.dceFrameSharpnessFilter = "Frame Sharpness Filter"
        self.cameraSettings.dceSensorFilter = "Sensor Filter"
        self.cameraSettings.dceAutoZoom = "Auto-Zoom"
        self.cameraSettings.dceFastMode = "Fast Mode"
        self.cameraSettings.smartTorch = "Smart Torch"
        self.cameraSettings.dceScanRegion = "Scan Region"
        
        // Set scanRegion.
        // Specify a scanRegion will help you improve the processing speed.
        self.scanRegion = ScanRegion()
        self.scanRegion.scanRegionTop = "Scan Region Top"
        self.scanRegion.scanRegionBottom = "Scan Region Bottom"
        self.scanRegion.scanRegionLeft = "Scan Region Left"
        self.scanRegion.scanRegionRight = "Scan Region Right"
        
        // DCE resolutin default value.
        self.dceResolution = DCEResolution()
        self.dceResolution.selectedResolutionValue = .EnumRESOLUTION_1080P
        
        // View Settings data initialization.
        self.dceViewSettings = DCEViewSettings()
        self.dceViewSettings.displayOverlay = "Display Overlay"
        self.dceViewSettings.displayTorchButton = "Display Torch Button"
        
        resetToDefault()
    }
    
    /// Make all data to default.
    func resetToDefault() -> Void {
        setDBRToDefault()
        setDCEToDefault()
    }
    
    private func setDBRToDefault() -> Void {
        // Barcode settings
        self.barcodeSettings.expectedCount = 1
        self.barcodeSettings.minimumResultConfidence = 30
        self.barcodeSettings.duplicateForgetTime = 3000
        self.barcodeSettings.minimumDecodeInterval = 0
        self.barcodeSettings.continuousScanIsOpen = true
        self.barcodeSettings.resultVerificationIsOpen = false
        self.barcodeSettings.duplicateFliterIsOpen = false
        self.barcodeSettings.decodeInvertedBarcodesIsOpen = false
        
        // You can use dbr resetRuntimeSettings to set all runtime parameters to default.
        try? self.barcodeReader.resetRuntimeSettings()
        
        // Or like this set iPublicRuntimeSettings to default.
        
        // Barcode Reader Settings.
        // BarcodeFormat to default.
        self.ipublicRuntimeSettings.barcodeFormatIds = EnumBarcodeFormat.ALL.rawValue
        self.ipublicRuntimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2.Null.rawValue
        self.ipublicRuntimeSettings.expectedBarcodesCount = self.barcodeSettings.expectedCount
        self.ipublicRuntimeSettings.minResultConfidence = self.barcodeSettings.minimumResultConfidence
        var grayscaleTransformationModes: [Int] = []
        if (self.barcodeSettings.decodeInvertedBarcodesIsOpen == true) {
            grayscaleTransformationModes = [EnumGrayscaleTransformationMode.original.rawValue,
                                            EnumGrayscaleTransformationMode.inverted.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue
            ]
        } else {
            grayscaleTransformationModes = [EnumGrayscaleTransformationMode.original.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue,
                                            EnumGrayscaleTransformationMode.skip.rawValue
            ]
        }
        self.ipublicRuntimeSettings.furtherModes.grayscaleTransformationModes = grayscaleTransformationModes
        let _ = updateIpublicRuntimeSettings()
        
        self.barcodeReader.enableResultVerification = self.barcodeSettings.resultVerificationIsOpen
        self.barcodeReader.enableDuplicateFilter = self.barcodeSettings.duplicateFliterIsOpen
        self.barcodeReader.duplicateForgetTime = self.barcodeSettings.duplicateForgetTime
        self.barcodeReader.minImageReadingInterval = self.barcodeSettings.minimumDecodeInterval
    }
    
    private func setDCEToDefault() -> Void {
        // Camera Enhancer Settings
        // Set resolution to default
        self.dceResolution.selectedResolutionValue = .EnumRESOLUTION_1080P
        self.cameraEnhancer.setResolution(dceResolution.selectedResolutionValue)
        
        // Set cameraSettings to default.
        self.cameraSettings.dceVibrateIsOpen = true
        self.cameraSettings.dceBeepIsOpen = true
        self.cameraSettings.dceEnhancedFocusIsOpen = false
        self.cameraSettings.dceFrameSharpnessFilterIsOpen = false
        self.cameraSettings.dceSensorFilterIsOpen = false
        self.cameraSettings.dceAutoZoomIsOpen = false
        self.cameraSettings.dceFastModeIsOpen = false
        self.cameraSettings.dceSmartTorchIsOpen = false
        self.cameraSettings.dceScanRegionIsOpen = false
        
        // Set feature mode to default.
        // Enhanced focus feature of Dynamsoft Camera Enhancer will enhance the focus ability of low-end device.
        if (self.cameraSettings.dceEnhancedFocusIsOpen == true) {
            self.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumENHANCED_FOCUS.rawValue, error: nil)
        } else {
            self.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumENHANCED_FOCUS.rawValue)
        }
        
        // Frame filter feature of Dynamsoft Camera Enhancer will filter out the blurry video frame.
        if (self.cameraSettings.dceFrameSharpnessFilterIsOpen == true) {
            self.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue, error: nil)
        } else {
            self.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue)
        }
        
        // Sensor filter feature of Dynamsoft Camera Enhancer will filter out the frames captured when the device is shaking.
        if (self.cameraSettings.dceSensorFilterIsOpen == true) {
            self.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumSENSOR_CONTROL.rawValue, error: nil)
        } else {
            self.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumSENSOR_CONTROL.rawValue)
        }
        
        // Auto zoom feature of Dynamsoft Camera Enhancer will enable the camera to zoom in to apporach the barcodes.
        if (self.cameraSettings.dceAutoZoomIsOpen == true) {
            self.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue, error: nil)
        } else {
            self.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue)
        }
        
        // Fast mode feature of Dynamsoft Camera Enhancer will crop the frames to reduce the processing size.
        if (self.cameraSettings.dceFastModeIsOpen == true) {
            self.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumFAST_MODE.rawValue, error: nil)
        } else {
            self.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumFAST_MODE.rawValue)
        }
        
        // Smart torch.
        if (self.cameraSettings.dceSmartTorchIsOpen == true) {
            self.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumSMART_TORCH.rawValue, error: nil)
        } else {
            self.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumSMART_TORCH.rawValue)
        }
        
        // Set the scanRegion with a nil value will reset the scanRegion to the default status.
        // The scanRegion will helps the barcode reader to reduce the processing time.
        self.scanRegion.scanRegionTopValue = 0
        self.scanRegion.scanRegionBottomValue = 100
        self.scanRegion.scanRegionLeftValue = 0
        self.scanRegion.scanRegionRightValue = 100
        
        let dceScanRegion = iRegionDefinition.init()
        dceScanRegion.regionTop = self.scanRegion.scanRegionTopValue
        dceScanRegion.regionBottom = self.scanRegion.scanRegionBottomValue
        dceScanRegion.regionLeft = self.scanRegion.scanRegionLeftValue
        dceScanRegion.regionRight = self.scanRegion.scanRegionRightValue
        dceScanRegion.regionMeasuredByPercentage = 1
        self.cameraEnhancer.setScanRegion(dceScanRegion, error: nil)
        
        // Set scanRegionVisible to false
        self.cameraEnhancer.scanRegionVisible = false
        
        
        // View settings.
        // DCE view set to default.
        // Overlays will be displayed by default.
        // Highlighted overlays will be displayed on the decoded barcodes automatically when overlayVisible is set to true.
        self.dceViewSettings.displayOverlayIsOpen = true
        self.dceViewSettings.displayTorchButtonIsOpen = false
        
        self.cameraView.overlayVisible = self.dceViewSettings.displayOverlayIsOpen ? true : false
        // The torch button will not be displayed by default.
        // Setting the torchButtonVisible to true will display the torch button on the UI.
        // The torch button can control the status of the mobile torch.
        // You can use method setTorchButton to control the position of torch button.
        self.cameraView.torchButtonVisible = self.dceViewSettings.displayTorchButtonIsOpen ? true : false
        
        self.cameraEnhancer.turnOffTorch()
    }
    
    func updateIpublicRuntimeSettings() -> Bool {
        var isSuccess = true
        
        do {
            try self.barcodeReader.updateRuntimeSettings(ipublicRuntimeSettings)
        } catch  {
            isSuccess = false
        }
        print("update Runtime:\(isSuccess ? "success": "failure")")
        return isSuccess
    }
}
