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

//MARK: setting default data
- (void)setDefaultData
{
    // continuous scan
    self.continuousScan = YES;
    
    // Barcode Format data initialization
    // Set BarcodeFormat
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
    
    // Set BarcodeFormatONED
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
    
    // Set barcodeFormatGS1DATABAR
    _barcodeFormatGS1DATABAR.format_GS1DatabarOmnidirectional = @"GS1 Databar Omnidirectional";
    _barcodeFormatGS1DATABAR.format_GS1DatabarTrunncated = @"GS1 Databar Truncated";
    _barcodeFormatGS1DATABAR.format_GS1DatabarStacked = @"GS1 Databar Stacked";
    _barcodeFormatGS1DATABAR.format_GS1DatabarStackedOmnidirectional = @"GS1 Databar Stacked Omnidirectional";
    _barcodeFormatGS1DATABAR.format_GS1DatabarExpanded = @"GS1 Databar Expanded";
    _barcodeFormatGS1DATABAR.format_GS1DatabarExpanedStacked = @"GS1 Databar Expaned Stacked";
    _barcodeFormatGS1DATABAR.format_GS1DatabarLimited = @"GS1 Databar Limited";
    
    // Set barcodeFormat2POSTALCODE
    _barcodeFormat2POSTALCODE.format2_USPSIntelligentMail = @"USPS Intelligent Mail";
    _barcodeFormat2POSTALCODE.format2_Postnet = @"Postnet";
    _barcodeFormat2POSTALCODE.format2_Planet = @"Planet";
    _barcodeFormat2POSTALCODE.format2_AustralianPost = @"Australian Post";
    _barcodeFormat2POSTALCODE.format2_RM4SCC = @"Royal Mail";
    
    // Camera Settings data initialization
    
    // Camera Settings
    // Enhanced focus feature of Dynamsoft Camera Enhancer will enhance the focus ability of low-end device.
    // Frame filter feature of Dynamsoft Camera Enhancer will filter out the blurry video frame.
    // Sensor filter feature of Dynamsoft Camera Enhancer will filter out the frames captured when the device is shaking.
    // Auto zoom feature of Dynamsoft Camera Enhancer will enable the camera to zoom in to apporach the barcodes.
    // Fast mode feature of Dynamsoft Camera Enhancer will crop the frames to reduce the processing size.
    _cameraSettings.dceResolution = @"Resolution";
    _cameraSettings.dceEnhancedFocus = @"Enhanced Focus";
    _cameraSettings.dceFrameSharpnessFilter = @"Frame Sharpness Filter";
    _cameraSettings.dceSensorFilter = @"Sensor Filter";
    _cameraSettings.dceAutoZoom = @"Auto-Zoom";
    _cameraSettings.dceFastMode = @"Fast Model";
    _cameraSettings.dceScanRegion = @"Scan Region";
    _cameraSettings.dceEnhancedFocusIsOpen = NO;
    _cameraSettings.dceFrameSharpnessFilterIsOpen = NO;
    _cameraSettings.dceSensorFilterIsOpen = NO;
    _cameraSettings.dceAutoZoomIsOpen = NO;
    _cameraSettings.dceFastModeIsOpen = NO;
    _cameraSettings.dceScanRegionIsOpen = NO;
    
    // Set scanRegion
    // Specify a scanRegion will help you improve the processing speed.
    _scanRegion.scanRegionTop = @"Scan Region Top";
    _scanRegion.scanRegionBottom = @"Scan Region Bottom";
    _scanRegion.scanRegionLeft = @"Scan Region Left";
    _scanRegion.scanRegionRight = @"Scan Region Right";
    _scanRegion.scanRegionTopValue = 0;
    _scanRegion.scanRegionBottomValue = 100;
    _scanRegion.scanRegionLeftValue = 0;
    _scanRegion.scanRegionRightValue = 100;
    
    // DCE resolutin default value
    _dceResolution.selectedResolutionValue = EnumRESOLUTION_HIGH;
    

    // View Settings data initialization
    _dceViewSettings.displayOverlay = @"Display Overlay";
    _dceViewSettings.displayTorchButton = @"Display Torch Button";
    _dceViewSettings.displayOverlayIsOpen = YES;
    _dceViewSettings.displayTorchButtonIsOpen = NO;

}

/**
 update ipublicRuntimeSettings
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
    NSLog(@"ipublicRuntime configure failure!");
    return NO;
}

@end
