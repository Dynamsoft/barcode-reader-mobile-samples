//
//  GeneralSettingsHandle.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import "GeneralSettingsHandle.h"

@implementation GeneralSettingsHandle

+ (GeneralSettingsHandle *)setting
{
    static GeneralSettingsHandle *generalSetting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        generalSetting = [super allocWithZone:NULL];
    });
    return generalSetting;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [GeneralSettingsHandle setting];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [GeneralSettingsHandle setting];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [GeneralSettingsHandle setting];
}

//MARK: - Setting default data
- (void)setDefaultData
{
    // continuous scan
    self.continuousScan = YES;
    
    // Barcode Format data initialization.
    // Set BarcodeFormat.
    // Specify the barcode formats to match your requirements.
    // The less barcode formats, the higher processing speed.
    _allBarcodeFormat.format_OneD = @"OneD";
    _allBarcodeFormat.format_GS1DataBar = @"GS1 DataBar";
    _allBarcodeFormat.format_PostalCode = @"Postal Code";
    _allBarcodeFormat.format_PatchCode = @"Patch Code";
    _allBarcodeFormat.format_PDF417 = @"PDF417";
    _allBarcodeFormat.format_QRCode = @"QR Code";
    _allBarcodeFormat.format_DataMatrix = @"DataMatrix";
    _allBarcodeFormat.format_AZTEC = @"AZTEC";
    _allBarcodeFormat.format_MaxiCode = @"MaxiCode";
    _allBarcodeFormat.format_MicroQR = @"Micro QR";
    _allBarcodeFormat.format_MicroPDF417 = @"Micro PDF417";
    _allBarcodeFormat.format_GS1Composite = @"GS1 Composite";
    _allBarcodeFormat.format_DotCode = @"Dot Code";
    _allBarcodeFormat.format_PHARMACODE = @"Pharma Code";
    
    // Set BarcodeFormatONED.
    _barcodeFormatONED.format_Code39 = @"Code 39";
    _barcodeFormatONED.format_Code128 = @"Code 128";
    _barcodeFormatONED.format_Code39Extended = @"Code 39 EXtended";
    _barcodeFormatONED.format_Code93 = @"Code 93";
    _barcodeFormatONED.format_Code_11 = @"Code 11";
    _barcodeFormatONED.format_Codabar = @"Codabar";
    _barcodeFormatONED.format_ITF = @"ITF";
    _barcodeFormatONED.format_EAN13 = @"EAN-13";
    _barcodeFormatONED.format_EAN8 = @"EAN-8";
    _barcodeFormatONED.format_UPCA = @"UPC-A";
    _barcodeFormatONED.format_UPCE = @"UPC-E";
    _barcodeFormatONED.format_Industrial25 = @"Industrial 25";
    _barcodeFormatONED.format_MSICode = @"MSI Code";
    
    // Set barcodeFormatGS1DATABAR.
    _barcodeFormatGS1DATABAR.format_GS1DatabarOmnidirectional = @"GS1 Databar Omnidirectional";
    _barcodeFormatGS1DATABAR.format_GS1DatabarTrunncated = @"GS1 Databar Truncated";
    _barcodeFormatGS1DATABAR.format_GS1DatabarStacked = @"GS1 Databar Stacked";
    _barcodeFormatGS1DATABAR.format_GS1DatabarStackedOmnidirectional = @"GS1 Databar Stacked Omnidirectional";
    _barcodeFormatGS1DATABAR.format_GS1DatabarExpanded = @"GS1 Databar Expanded";
    _barcodeFormatGS1DATABAR.format_GS1DatabarExpanedStacked = @"GS1 Databar Expaned Stacked";
    _barcodeFormatGS1DATABAR.format_GS1DatabarLimited = @"GS1 Databar Limited";
    
    // Set barcodeFormat2POSTALCODE.
    _barcodeFormat2POSTALCODE.format2_USPSIntelligentMail = @"USPS Intelligent Mail";
    _barcodeFormat2POSTALCODE.format2_Postnet = @"Postnet";
    _barcodeFormat2POSTALCODE.format2_Planet = @"Planet";
    _barcodeFormat2POSTALCODE.format2_AustralianPost = @"Australian Post";
    _barcodeFormat2POSTALCODE.format2_RM4SCC = @"Royal Mail";
    
    // Barcode settings.
    _barcodeSettings.barcodeFormatStr = @"Barcode Formats";
    _barcodeSettings.expectedCountStr = @"Expected Count";
    _barcodeSettings.continuousScanStr = @"Continuous Scan";
    _barcodeSettings.minimumResultConfidenceStr = @"Minimum Result Confidence";
    _barcodeSettings.resultVerificationStr = @"Result Verification";
    _barcodeSettings.duplicateFliterStr = @"Duplicate Fliter";
    _barcodeSettings.duplicateForgetTimeStr = @"Duplicate Forget Time";
    _barcodeSettings.minimumDecodeIntervalStr = @"Minimum Decode Interval";
    _barcodeSettings.decodeInvertedBarcodesStr = @"Decode Inverted Barcodes";
    
    // Camera Settings.
    // Enhanced focus feature of Dynamsoft Camera Enhancer will enhance the focus ability of low-end device.
    // Frame filter feature of Dynamsoft Camera Enhancer will filter out the blurry video frame.
    // Sensor filter feature of Dynamsoft Camera Enhancer will filter out the frames captured when the device is shaking.
    // Auto zoom feature of Dynamsoft Camera Enhancer will enable the camera to zoom in to apporach the barcodes.
    // Fast mode feature of Dynamsoft Camera Enhancer will crop the frames to reduce the processing size.
    _cameraSettings.dceResolution = @"Resolution";
    _cameraSettings.dceVibrate = @"Vibration";
    _cameraSettings.dceBeep = @"Beep";
    _cameraSettings.dceEnhancedFocus = @"Enhanced Focus";
    _cameraSettings.dceFrameSharpnessFilter = @"Frame Sharpness Filter";
    _cameraSettings.dceSensorFilter = @"Sensor Filter";
    _cameraSettings.dceAutoZoom = @"Auto-Zoom";
    _cameraSettings.dceFastMode = @"Fast Mode";
    _cameraSettings.smartTorch = @"Smart Torch";
    _cameraSettings.dceScanRegion = @"Scan Region";
    
    // Set scanRegion.
    // Specify a scanRegion will help you improve the processing speed.
    _scanRegion.scanRegionTop = @"Scan Region Top";
    _scanRegion.scanRegionBottom = @"Scan Region Bottom";
    _scanRegion.scanRegionLeft = @"Scan Region Left";
    _scanRegion.scanRegionRight = @"Scan Region Right";
    
    // DCE resolutin default value.
    _dceResolution.selectedResolutionValue = EnumRESOLUTION_1080P;
    [[GeneralSettingsHandle setting].cameraEnhancer setResolution:EnumRESOLUTION_1080P];

    // View Settings data initialization.
    _dceViewSettings.displayOverlay = @"Display Overlay";
    _dceViewSettings.displayTorchButton = @"Display Torch Button";

    [self resetToDefault];
}

- (void)resetToDefault {
    [self setDBRToDefault];
    [self setDCEToDefault];
}

- (void)setDBRToDefault {
    
    // Barcode settings
    BarcodeSettings barcodeSettings = [GeneralSettingsHandle setting].barcodeSettings;
    barcodeSettings.expectedCount = 1;
    barcodeSettings.minimumResultConfidence = 30;
    barcodeSettings.duplicateForgetTime = 3000;
    barcodeSettings.minimumDecodeInterval = 0;
    barcodeSettings.continuousScanIsOpen = YES;
    barcodeSettings.resultVerificationIsOpen = NO;
    barcodeSettings.duplicateFliterIsOpen = NO;
    barcodeSettings.decodeInvertedBarcodesIsOpen = NO;
    [GeneralSettingsHandle setting].barcodeSettings = barcodeSettings;
    
    // You can use dbr resetRuntimeSettings to set all runtime parameters to default.
    // NSError *resetError = nil;
    // [[GeneralSettingsHandle setting].barcodeReader resetRuntimeSettings:&resetError];
    
    // Or like this set iPublicRuntimeSettings to default.

    // Barcode Reader Settings.
    // BarcodeFormat to default.
    iPublicRuntimeSettings *setting = [GeneralSettingsHandle setting].ipublicRuntimeSettings;

    // You can specify the barcode formats via PublicRuntimeSettings struct using the combined value of barcodeFormatsIds or barcodeFormatIds_2.
    setting.barcodeFormatIds = EnumBarcodeFormatALL;
    setting.barcodeFormatIds_2 = EnumBarcodeFormat2NULL;
   
    // Set expect count to default.
    // Set the expected barcode count.
    // The default value of barcode count is 1.
    // When the barcode count is set to 0, the barcode reader will try to decode at least 1 barcode.
    setting.expectedBarcodesCount = [GeneralSettingsHandle setting].barcodeSettings.expectedCount;
    setting.minResultConfidence = [GeneralSettingsHandle setting].barcodeSettings.minimumResultConfidence;
    NSArray *grayscaleTransformationModes = @[];
    if ([GeneralSettingsHandle setting].barcodeSettings.decodeInvertedBarcodesIsOpen == YES) {
        grayscaleTransformationModes = @[@(EnumGrayscaleTransformationModeOriginal),
                                         @(EnumGrayscaleTransformationModeInverted),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip)
        ];
    } else {
        grayscaleTransformationModes = @[@(EnumGrayscaleTransformationModeOriginal),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip),
                                         @(EnumGrayscaleTransformationModeSkip)
        ];
    }
    setting.furtherModes.grayscaleTransformationModes = grayscaleTransformationModes;
    [GeneralSettingsHandle setting].ipublicRuntimeSettings = setting;
    
    [[GeneralSettingsHandle setting] updateIpublicRuntimeSettings];
    
    [GeneralSettingsHandle setting].barcodeReader.enableResultVerification = [GeneralSettingsHandle setting].barcodeSettings.resultVerificationIsOpen;
    [GeneralSettingsHandle setting].barcodeReader.enableDuplicateFilter = [GeneralSettingsHandle setting].barcodeSettings.duplicateFliterIsOpen;
    [GeneralSettingsHandle setting].barcodeReader.duplicateForgetTime = [GeneralSettingsHandle setting].barcodeSettings.duplicateForgetTime;
    [GeneralSettingsHandle setting].barcodeReader.minImageReadingInterval = [GeneralSettingsHandle setting].barcodeSettings.minimumDecodeInterval;
}

- (void)setDCEToDefault {
    // Camera Enhancer Settings
    // Set resolution to default
    DCEResolution dceResolution = [GeneralSettingsHandle setting].dceResolution;
    dceResolution.selectedResolutionValue = EnumRESOLUTION_1080P;
    [GeneralSettingsHandle setting].dceResolution = dceResolution;
    [[GeneralSettingsHandle setting].cameraEnhancer setResolution:EnumRESOLUTION_1080P];

    // Set cameraSettings to default.
    CameraSettings cameraSettings = [GeneralSettingsHandle setting].cameraSettings;
    cameraSettings.dceVibrateIsOpen = YES;
    cameraSettings.dceBeepIsOpen = YES;
    cameraSettings.dceEnhancedFocusIsOpen = NO;
    cameraSettings.dceFrameSharpnessFilterIsOpen = NO;
    cameraSettings.dceSensorFilterIsOpen = NO;
    cameraSettings.dceAutoZoomIsOpen = NO;
    cameraSettings.dceFastModeIsOpen = NO;
    cameraSettings.dceSmartTorchIsOpen = NO;
    cameraSettings.dceScanRegionIsOpen = NO;
    [GeneralSettingsHandle setting].cameraSettings = cameraSettings;
    
    // Set feature mode to default.
    // Enhanced focus feature of Dynamsoft Camera Enhancer will enhance the focus ability of low-end device.
    if ([GeneralSettingsHandle setting].cameraSettings.dceEnhancedFocusIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumENHANCED_FOCUS error:nil];
    } else {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumENHANCED_FOCUS];
    }
    
    // Frame filter feature of Dynamsoft Camera Enhancer will filter out the blurry video frame.
    if ([GeneralSettingsHandle setting].cameraSettings.dceFrameSharpnessFilterIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumFRAME_FILTER error:nil];
    } else {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumFRAME_FILTER];
    }
    
    // Sensor filter feature of Dynamsoft Camera Enhancer will filter out the frames captured when the device is shaking.
    if ([GeneralSettingsHandle setting].cameraSettings.dceSensorFilterIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumSENSOR_CONTROL error:nil];
    } else {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumSENSOR_CONTROL];
    }
    
    // Auto zoom feature of Dynamsoft Camera Enhancer will enable the camera to zoom in to apporach the barcodes.
    if ([GeneralSettingsHandle setting].cameraSettings.dceAutoZoomIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumAUTO_ZOOM error:nil];
    } else {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumAUTO_ZOOM];
    }
    
    // Fast mode feature of Dynamsoft Camera Enhancer will crop the frames to reduce the processing size.
    if ([GeneralSettingsHandle setting].cameraSettings.dceFastModeIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumFAST_MODE error:nil];
    } else {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumFAST_MODE];
    }
    
    // Smart torch.
    if ([GeneralSettingsHandle setting].cameraSettings.dceSmartTorchIsOpen == YES) {
        [[GeneralSettingsHandle setting].cameraEnhancer enableFeatures:EnumSMART_TORCH error:nil];
    } else {
        [[GeneralSettingsHandle setting].cameraEnhancer disableFeatures:EnumSMART_TORCH];
    }
    
    // Set the scanRegion with a nil value will reset the scanRegion to the default status.
    // The scanRegion will helps the barcode reader to reduce the processing time.
    ScanRegion scanRegion = [GeneralSettingsHandle setting].scanRegion;
    
    scanRegion.scanRegionTopValue = 0;
    scanRegion.scanRegionBottomValue = 100;
    scanRegion.scanRegionLeftValue = 0;
    scanRegion.scanRegionRightValue = 100;
    [GeneralSettingsHandle setting].scanRegion = scanRegion;
    
    NSError *scanRegionError = nil;
    iRegionDefinition *dceScanRegion = [[iRegionDefinition alloc] init];
    dceScanRegion.regionTop = scanRegion.scanRegionTopValue;
    dceScanRegion.regionBottom = scanRegion.scanRegionBottomValue;
    dceScanRegion.regionLeft = scanRegion.scanRegionLeftValue;
    dceScanRegion.regionRight = scanRegion.scanRegionRightValue;
    dceScanRegion.regionMeasuredByPercentage = 1;
    
    [[GeneralSettingsHandle setting].cameraEnhancer setScanRegion:dceScanRegion error:&scanRegionError];
   
    // Set scanRegionVisible to false
    [[GeneralSettingsHandle setting].cameraEnhancer setScanRegionVisible:false];
    
    // View settings.
    // DCE view set to default.
    // Overlays will be displayed by default.
    // Highlighted overlays will be displayed on the decoded barcodes automatically when overlayVisible is set to true.
    DCEViewSettings dceViewSettings = [GeneralSettingsHandle setting].dceViewSettings;
    dceViewSettings.displayOverlayIsOpen = YES;
    dceViewSettings.displayTorchButtonIsOpen = NO;
    [GeneralSettingsHandle setting].dceViewSettings = dceViewSettings;
    
    if ([GeneralSettingsHandle setting].dceViewSettings.displayOverlayIsOpen) {
        [GeneralSettingsHandle setting].cameraView.overlayVisible = YES;
    } else {
        [GeneralSettingsHandle setting].cameraView.overlayVisible = NO;
    }
    
    // The torch button will not be displayed by default.
    // Setting the torchButtonVisible to true will display the torch button on the UI.
    // The torch button can control the status of the mobile torch.
    // You can use method setTorchButton to control the position of torch button.
    if ([GeneralSettingsHandle setting].dceViewSettings.displayTorchButtonIsOpen) {
        [GeneralSettingsHandle setting].cameraView.torchButtonVisible = YES;
    } else {
        [GeneralSettingsHandle setting].cameraView.torchButtonVisible = NO;
    }
    [[GeneralSettingsHandle setting].cameraEnhancer turnOffTorch];
}

/**
 Update ipublicRuntimeSettings.
 */
- (BOOL)updateIpublicRuntimeSettings
{
    NSError *error = nil;
    // Add or update the settings to the runtime settings
    [self.barcodeReader updateRuntimeSettings:self.ipublicRuntimeSettings error:&error];
    
    if (error != nil) {
        NSString *msg = error.userInfo[NSUnderlyingErrorKey];
        
        if ([msg isEqualToString:@"Successful."]) {
            NSLog(@"ipublicRuntime configure success!");
            return YES;
        } else {
            NSLog(@"ipublicRuntime configure failure!");
            return NO;
        }
        
    }
    NSLog(@"ipublicRuntime configure success!");
    return YES;
}

@end
