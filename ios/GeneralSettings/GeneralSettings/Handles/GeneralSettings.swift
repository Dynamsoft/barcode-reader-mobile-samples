/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class GeneralSettings: NSObject {
    static let shared = GeneralSettings()
    
    // BarcodeFormat description.
    var allBarcodeDescription: BarcodeFormatDescription!
    var barcodeFormatONED: BarcodeFormatONEDDescription!
    var barcodeFormatGS1DATABAR: BarcodeFormatGS1DATABARDescription!
    var barcodeFormat2POSTALCODE: BarcodeFormat2POSTALCODEDescription!
    
    // BarcodeSettings.
    var barcodeSettings: BarcodeSettings!
    
    // CameraSettings.
    var cameraSettings: CameraSettings!
    var scanRegion: ScanRegion!
    var dceResolution: DCEResolution!
    
    // CameraViewSettings.
    var dceViewSettings: DCEViewSettings!
    
    // CVR and DCE.
    var cvr: CaptureVisionRouter!
    var dce: CameraEnhancer!
    var dceView: CameraView!
    var dbrDrawingLayer: DrawingLayer!
    
    var currentCVRRuntimeSettings: SimplifiedCaptureVisionSettings!
    var currentResultCrossFilter: MultiFrameResultCrossFilter!
    
    /// Configure default data.
    func setDefaultData() -> Void {
        // Barcode Format data initialization.
        // Set BarcodeFormat.
        // Specify the barcode formats to match your requirements.
        // The less barcode formats, the higher processing speed.
        allBarcodeDescription = BarcodeFormatDescription()
        allBarcodeDescription.oneD = "OneD"
        allBarcodeDescription.gs1DataBar = "GS1 DataBar"
        allBarcodeDescription.postalCode = "Postal Code"
        allBarcodeDescription.patchCode = "Patch Code"
        allBarcodeDescription.pdf417 = "PDF417"
        allBarcodeDescription.qrCode = "QR Code"
        allBarcodeDescription.dataMatrix = "DataMatrix"
        allBarcodeDescription.aztec = "AZTEC"
        allBarcodeDescription.maxiCode = "MaxiCode"
        allBarcodeDescription.microQR = "Micro QR"
        allBarcodeDescription.microPDF417 = "Micro PDF417"
        allBarcodeDescription.gs1Composite = "GS1 Composite"
        allBarcodeDescription.dotCode = "Dot Code"
        allBarcodeDescription.pharmaCODE = "Pharma Code"
        
        // BarcodeFormatONED description.
        barcodeFormatONED = BarcodeFormatONEDDescription()
        barcodeFormatONED.code39 = "Code 39"
        barcodeFormatONED.code128 = "Code 128"
        barcodeFormatONED.code39Extended = "Code 39 EXtended"
        barcodeFormatONED.code93 = "Code 93"
        barcodeFormatONED.code11 = "Code 11"
        barcodeFormatONED.codabar = "Codabar"
        barcodeFormatONED.itf = "ITF"
        barcodeFormatONED.ean13 = "EAN-13"
        barcodeFormatONED.ean8 = "EAN-8"
        barcodeFormatONED.upca = "UPC-A"
        barcodeFormatONED.upce = "UPC-E"
        barcodeFormatONED.industrial25 = "Industrial 25"
        barcodeFormatONED.msiCode = "MSI Code"
        
        // BarcodeFormatGS1DATABAR description.
        barcodeFormatGS1DATABAR = BarcodeFormatGS1DATABARDescription()
        barcodeFormatGS1DATABAR.gs1DatabarOmnidirectional = "GS1 Databar Omnidirectional"
        barcodeFormatGS1DATABAR.gs1DatabarTrunncated = "GS1 Databar Truncated"
        barcodeFormatGS1DATABAR.gs1DatabarStacked = "GS1 Databar Stacked"
        barcodeFormatGS1DATABAR.gs1DatabarStackedOmnidirectional = "GS1 Databar Stacked Omnidirectional"
        barcodeFormatGS1DATABAR.gs1DatabarExpanded = "GS1 Databar Expanded"
        barcodeFormatGS1DATABAR.gs1DatabarExpanedStacked = "GS1 Databar Expaned Stacked"
        barcodeFormatGS1DATABAR.gs1DatabarLimited = "GS1 Databar Limited"
        
        // BarcodeFormat2POSTALCODE description.
        barcodeFormat2POSTALCODE = BarcodeFormat2POSTALCODEDescription()
        barcodeFormat2POSTALCODE.uspsIntelligentMail = "USPS Intelligent Mail"
        barcodeFormat2POSTALCODE.postnet = "Postnet"
        barcodeFormat2POSTALCODE.planet = "Planet"
        barcodeFormat2POSTALCODE.australianPost = "Australian Post"
        barcodeFormat2POSTALCODE.rm4SCC = "Royal Mail"
        
        // Barcode settings description.
        barcodeSettings = BarcodeSettings()
        barcodeSettings.barcodeFormatStr = "Barcode Formats"
        barcodeSettings.expectedCountStr = "Expected Count"
        barcodeSettings.continuousScanStr = "Continuous Scan"
        barcodeSettings.minimumResultConfidenceStr = "Minimum Result Confidence"
        barcodeSettings.resultCrossVerificationStr = "Result Cross Verification"
        barcodeSettings.resultDeduplicationStr = "Result Deduplication"
        barcodeSettings.duplicateForgetTimeStr = "Duplicate Forget Time"
        barcodeSettings.decodeInvertedBarcodesStr = "Decode Inverted Barcodes"
        barcodeSettings.barcodeTextRegExPatternStr = "Barcode Text RegEx Pattern"
        
        // Camera Settings description.
        // Enhanced focus feature of Dynamsoft Camera Enhancer will enhance the focus ability of low-end device.
        // Frame filter feature of Dynamsoft Camera Enhancer will filter out the blurry video frame.
        // Sensor filter feature of Dynamsoft Camera Enhancer will filter out the frames captured when the device is shaking.
        // Auto zoom feature of Dynamsoft Camera Enhancer will enable the camera to zoom in to apporach the barcodes.
        // Fast mode feature of Dynamsoft Camera Enhancer will crop the frames to reduce the processing size.
        cameraSettings = CameraSettings()
        cameraSettings.dceResolution = "Resolution"
        cameraSettings.dceVibrate = "Vibration"
        cameraSettings.dceBeep = "Beep"
        cameraSettings.dceEnhancedFocus = "Enhanced Focus"
        cameraSettings.dceFrameSharpnessFilter = "Frame Sharpness Filter"
        cameraSettings.dceSensorFilter = "Sensor Filter"
        cameraSettings.dceAutoZoom = "Auto-Zoom"
        cameraSettings.smartTorch = "Smart Torch"
        cameraSettings.dceScanRegion = "Scan Region"
        
        // Set scanRegion description.
        // Specify a scanRegion will help you improve the processing speed.
        scanRegion = ScanRegion()
        scanRegion.scanRegionTop = "Scan Region Top"
        scanRegion.scanRegionBottom = "Scan Region Bottom"
        scanRegion.scanRegionLeft = "Scan Region Left"
        scanRegion.scanRegionRight = "Scan Region Right"
        
        // View Settings data initialization description.
        dceViewSettings = DCEViewSettings()
        dceViewSettings.highlightDecodedBarcodes = "Highlight Decoded Barcodes"
        dceViewSettings.displayTorchButton = "Display Torch Button"
        
        // DCE resolutin default value.
        dceResolution = DCEResolution()
        
        // CVR
        resetToDefault()
    }
    
    /// Make all data to default.
    func resetToDefault() -> Void {
        setDBRToDefault()
        setDCEToDefault()
        setCameraViewToDefault()
    }
    
    private func setDBRToDefault() -> Void {
        try? self.cvr.resetSettings()
        currentCVRRuntimeSettings = try? cvr.getSimplifiedSettings(PresetTemplate.readBarcodes.rawValue)
        
        guard currentCVRRuntimeSettings != nil else {
            return
        }
        
        // Reset dbr showing to default.
        barcodeSettings.expectedCount = 1
        barcodeSettings.minimumResultConfidence = 30
        barcodeSettings.duplicateForgetTime = 3000
        barcodeSettings.decodeInvertedBarcodesIsOpen = false
        barcodeSettings.continuousScanIsOpen = true
        barcodeSettings.resultCrossVerificationIsOpen = false
        barcodeSettings.resultDeduplicationIsOpen = false
        barcodeSettings.decodeInvertedBarcodesIsOpen = false
        barcodeSettings.barcodeTextRegExPatternContent = ""

        // Reset dbr to default.
        currentCVRRuntimeSettings.barcodeSettings?.barcodeFormatIds = BarcodeFormat.default
        currentCVRRuntimeSettings.barcodeSettings?.expectedBarcodesCount = barcodeSettings.expectedCount
        currentCVRRuntimeSettings.barcodeSettings?.minResultConfidence = barcodeSettings.minimumResultConfidence
        currentCVRRuntimeSettings.barcodeSettings?.barcodeTextRegExPattern = barcodeSettings.barcodeTextRegExPatternContent
        
        var grayscaleTransformationModes: [Int] = []
        if barcodeSettings.decodeInvertedBarcodesIsOpen == true {
            grayscaleTransformationModes = [GrayscaleTransformationMode.original.rawValue,
                                            GrayscaleTransformationMode.inverted.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue
            ]
        } else {
            grayscaleTransformationModes = [GrayscaleTransformationMode.original.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue,
                                            GrayscaleTransformationMode.skip.rawValue
            ]
        }
        
        currentCVRRuntimeSettings.barcodeSettings?.grayscaleTransformationModes = grayscaleTransformationModes
        
        let _ = updateCaptureVisionSettings()
        
    
        
        currentCVRRuntimeSettings = try? cvr.getSimplifiedSettings(PresetTemplate.readBarcodes.rawValue)
        
        if currentResultCrossFilter != nil {
            cvr.removeResultFilter(currentResultCrossFilter)
        }
        currentResultCrossFilter = MultiFrameResultCrossFilter()
        currentResultCrossFilter.enableResultCrossVerification(.barcode, isEnabled: barcodeSettings.resultCrossVerificationIsOpen)
        currentResultCrossFilter.enableResultDeduplication(.barcode, isEnabled: barcodeSettings.resultDeduplicationIsOpen)
        currentResultCrossFilter.setDuplicateForgetTime(.barcode, duplicateForgetTime: barcodeSettings.duplicateForgetTime)
        cvr.addResultFilter(currentResultCrossFilter)
    }
    
    private func setDCEToDefault() -> Void {
        // Camera Enhancer Settings
        // Set resolution to default
        dceResolution.selectedResolutionValue = .resolution1080P
        dce.setResolution(dceResolution.selectedResolutionValue)
        
        // Reset dce Showing to default.
        self.cameraSettings.dceVibrateIsOpen = true
        self.cameraSettings.dceBeepIsOpen = true
        self.cameraSettings.dceEnhancedFocusIsOpen = false
        self.cameraSettings.dceFrameSharpnessFilterIsOpen = false
        self.cameraSettings.dceSensorFilterIsOpen = false
        self.cameraSettings.dceAutoZoomIsOpen = false
        self.cameraSettings.dceSmartTorchIsOpen = false
        self.cameraSettings.dceScanRegionIsOpen = false
        
        // Reset dce to default.
        // Set feature mode to default.
        // Enhanced focus feature of Dynamsoft Camera Enhancer will enhance the focus ability of low-end device.
        if (self.cameraSettings.dceEnhancedFocusIsOpen == true) {
            self.dce.enableEnhancedFeatures(.enhancedFocus)
        } else {
            self.dce.disableEnhancedFeatures(.enhancedFocus)
        }
        
        // Frame filter feature of Dynamsoft Camera Enhancer will filter out the blurry video frame.
        if (self.cameraSettings.dceFrameSharpnessFilterIsOpen == true) {
            self.dce.enableEnhancedFeatures(.frameFilter)
        } else {
            self.dce.disableEnhancedFeatures(.frameFilter)
        }
        
        // Sensor filter feature of Dynamsoft Camera Enhancer will filter out the frames captured when the device is shaking.
        if (self.cameraSettings.dceSensorFilterIsOpen == true) {
            self.dce.enableEnhancedFeatures(.sensorControl)
        } else {
            self.dce.disableEnhancedFeatures(.sensorControl)
        }
        
        // Auto zoom feature of Dynamsoft Camera Enhancer will enable the camera to zoom in to apporach the barcodes.
        if (self.cameraSettings.dceAutoZoomIsOpen == true) {
            self.dce.enableEnhancedFeatures(.autoZoom)
        } else {
            self.dce.disableEnhancedFeatures(.autoZoom)
        }
        
        // Smart torch.
        if (self.cameraSettings.dceSmartTorchIsOpen == true) {
            self.dce.enableEnhancedFeatures(.smartTorch)
        } else {
            self.dce.disableEnhancedFeatures(.smartTorch)
        }
        
        // Set the scanRegion with a nil value will reset the scanRegion to the default status.
        // The scanRegion will helps the barcode reader to reduce the processing time.
        self.scanRegion.scanRegionTopValue = 0.0
        self.scanRegion.scanRegionBottomValue = 1.0
        self.scanRegion.scanRegionLeftValue = 0.0
        self.scanRegion.scanRegionRightValue = 1.0
        
        try? self.dce.setScanRegion(nil)
        self.dceView.scanLaserVisible = true
    }
    
    private func setCameraViewToDefault() -> Void {
        // View settings.
        // DCE view set to default.
        // Overlays will be displayed by default.
        // Highlighted overlays will be displayed on the decoded barcodes automatically when overlayVisible is set to true.
        dceViewSettings.highlightDecodedBarcodesIsOpen = true
        dceViewSettings.displayTorchButtonIsOpen = false
        
        dbrDrawingLayer = dceView.getDrawingLayer(DrawingLayerId.DBR.rawValue)
        dbrDrawingLayer?.visible = dceViewSettings.highlightDecodedBarcodesIsOpen
     
        // The torch button will not be displayed by default.
        // Setting the torchButtonVisible to true will display the torch button on the UI.
        // The torch button can control the status of the mobile torch.
        // You can use method setTorchButton to control the position of torch button.
        dceView.torchButtonVisible = dceViewSettings.displayTorchButtonIsOpen
        
        dce.turnOffTorch()
    }
    
    func updateCaptureVisionSettings() -> Bool {
        var isSuccess = true
        
        do {
            try self.cvr.updateSettings(PresetTemplate.readBarcodes.rawValue, settings: currentCVRRuntimeSettings)
        } catch  {
            isSuccess = false
        }
        return isSuccess
    }
    
}
