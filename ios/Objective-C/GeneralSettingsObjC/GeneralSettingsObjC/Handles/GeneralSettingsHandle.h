//
//  GeneralSettingsHandle.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/22.
//

#import <Foundation/Foundation.h>
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
#import <DynamsoftCameraEnhancer/DynamsoftCameraEnhancer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GeneralSettingsHandle : NSObject<NSCopying, NSMutableCopying>

//MARK: about BarcodeFormat
/**
 the instance of all barcode format
 */
@property (nonatomic) BarcodeFormat allBarcodeFormat;

/**
 the instance of BarcodeFormatONED
 */
@property (nonatomic) BarcodeFormatONED barcodeFormatONED;

/**
 the instance of BarcodeFormatGS1DATABAR
 */
@property (nonatomic) BarcodeFormatGS1DATABAR barcodeFormatGS1DATABAR;

/**
 the instance of BarcodeFormat2POSTALCODE
 */
@property (nonatomic) BarcodeFormat2POSTALCODE barcodeFormat2POSTALCODE;

//MARK: about Camera Settings

/**
 the instance of CameraSettings
 */
@property (nonatomic) CameraSettings cameraSettings;

/**
 the instance of CameraSettings
 */
@property (nonatomic) ScanRegion scanRegion;

/**
 the instance of DCEResolution
 */
@property (nonatomic) DCEResolution dceResolution;

//MARK: about View Settings

/**
 the instance of DCEViewSettings
 */
@property (nonatomic) DCEViewSettings dceViewSettings;

//MARK: about DCE and DBR
/**
 the instance of DynamsoftBarcodeReader
 */
@property (nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;


/**
 the instance of DynamsoftCameraEnhancer
 */
@property (nonatomic, strong) DynamsoftCameraEnhancer *cameraEnhancer;


/**
 the instance of DCECameraView
 */
@property (nonatomic, strong) DCECameraView *cameraView;


/**
 the instance of iPublicRuntimeSettings
 */
@property (nonatomic, strong) iPublicRuntimeSettings *ipublicRuntimeSettings;


/**
 Whether to enable continuous decoding
 */
@property (nonatomic, assign) BOOL continuousScan;

+ (GeneralSettingsHandle *)setting;

/**
 set default data
 */
- (void)setDefaultData;

/**
 update ipublicRuntimeSettings
 */
- (BOOL)updateIpublicRuntimeSettings;

@end

NS_ASSUME_NONNULL_END
