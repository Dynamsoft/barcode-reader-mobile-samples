//
//  UtilityHeader.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/19.
//

#ifndef UtilityHeader_h
#define UtilityHeader_h

//MARK: Barcode Format
/**
 Describes the type of the barcode in BarcodeFormat group 1 and group 2
 */
struct BarcodeFormat {
    NSString *format_OneD;
    NSString *format_GS1DataBar;
    NSString *format_PostalCode;// barcode Format group 2
    NSString *format_PatchCode;
    NSString *format_PDF417;
    NSString *format_QRCode;
    NSString *format_DataMatrix;
    NSString *format_AZTEC;
    NSString *format_MaxiCode;
    NSString *format_MicroQR;
    NSString *format_MicroPDF417;
    NSString *format_GS1Composite;
    NSString *format_DotCode;// barcode Format group 2
    NSString *format_PHARMACODE;// barcode Format group 2
};
typedef struct BarcodeFormat BarcodeFormat;

/**
 Describes the Combined value of the BarcodeFormatONED
 BarcodeFormatONED is belong to barcode format group1
 */
struct BarcodeFormatONED {
    NSString *format_Code39;
    NSString *format_Code128;
    NSString *format_Code39Extended;
    NSString *format_Code93;
    NSString *format_Code_11;
    NSString *format_Codabar;
    NSString *format_ITF;
    NSString *format_EAN13;
    NSString *format_EAN8;
    NSString *format_UPCA;
    NSString *format_UPCE;
    NSString *format_Industrial25;
    NSString *format_MSICode;
    
};
typedef struct BarcodeFormatONED BarcodeFormatONED;

/**
 Describes the Combined value of the BarcodeFormatGS1DATABAR;
 BarcodeFormatGS1DATABAR is belong to barcode format group1
 */
struct BarcodeFormatGS1DATABAR {
    NSString *format_GS1DatabarOmnidirectional;
    NSString *format_GS1DatabarTrunncated;
    NSString *format_GS1DatabarStacked;
    NSString *format_GS1DatabarStackedOmnidirectional;
    NSString *format_GS1DatabarExpanded;
    NSString *format_GS1DatabarExpanedStacked;
    NSString *format_GS1DatabarLimited;
};
typedef struct BarcodeFormatGS1DATABAR BarcodeFormatGS1DATABAR;

/**
 Describes the Combined value of the BarcodeFormat2POSTALCODE;
 BarcodeFormat2POSTALCODE is belong to barcode format group2
 */
struct BarcodeFormat2POSTALCODE {
    NSString *format2_USPSIntelligentMail;
    NSString *format2_Postnet;
    NSString *format2_Planet;
    NSString *format2_AustralianPost;
    /**
     Royal Mail 4-State Customer Barcode
     */
    NSString *format2_RM4SCC;
};
typedef struct BarcodeFormat2POSTALCODE BarcodeFormat2POSTALCODE;

/**
 Describes the name of the subBarcodeFormat
 */
typedef NS_ENUM(NSInteger, EnumSubBarcodeFormatName){
    EnumSubBarcodeONED             = 0,
    EnumSubBarcodeGS1DataBar       = 1,
    EnumSubBarcodePostalCode       = 3
};

//MARK: Camera Settings
struct CameraSettings {
    NSString *dceResolution;
    NSString *dceVibrate;
    NSString *dceBeep;
    NSString *dceEnhancedFocus;
    NSString *dceFrameSharpnessFilter;
    NSString *dceSensorFilter;
    NSString *dceAutoZoom;
    NSString *dceFastMode;
    NSString *dceScanRegion;
    
    BOOL dceVibrateIsOpen;
    BOOL dceBeepIsOpen;
    BOOL dceEnhancedFocusIsOpen;
    BOOL dceFrameSharpnessFilterIsOpen;
    BOOL dceSensorFilterIsOpen;
    BOOL dceAutoZoomIsOpen;
    BOOL dceFastModeIsOpen;
    BOOL dceScanRegionIsOpen;
};

typedef struct CameraSettings CameraSettings;

struct ScanRegion {
    NSString *scanRegionTop;
    NSString *scanRegionBottom;
    NSString *scanRegionLeft;
    NSString *scanRegionRight;
    NSInteger scanRegionTopValue;
    NSInteger scanRegionBottomValue;
    NSInteger scanRegionLeftValue;
    NSInteger scanRegionRightValue;
    
};

typedef struct ScanRegion ScanRegion;

struct DCEResolution {
    /**
     Default is High. You can replace the other value you want to
     */
    NSInteger selectedResolutionValue;
};
typedef struct DCEResolution DCEResolution;

//MARK: ViewSettings

struct DCEViewSettings {
    NSString *displayOverlay;
    NSString *displayTorchButton;
    BOOL displayOverlayIsOpen;
    BOOL displayTorchButtonIsOpen;
};

typedef struct DCEViewSettings DCEViewSettings;



#endif /* UtilityHeader_h */
