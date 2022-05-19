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

//MARK: About BarcodeFormat

/// The instance of all barcode format.
@property (nonatomic) BarcodeFormat allBarcodeFormat;

/// The instance of BarcodeFormatONED.
@property (nonatomic) BarcodeFormatONED barcodeFormatONED;

/// The instance of BarcodeFormatGS1DATABAR.
@property (nonatomic) BarcodeFormatGS1DATABAR barcodeFormatGS1DATABAR;

/// The instance of BarcodeFormat2POSTALCODE.
@property (nonatomic) BarcodeFormat2POSTALCODE barcodeFormat2POSTALCODE;

//MARK: About CameraSettings

/// The instance of CameraSettings.
@property (nonatomic) CameraSettings cameraSettings;

/// The instance of CameraSettings.
@property (nonatomic) ScanRegion scanRegion;

/// The instance of DCEResolution.
@property (nonatomic) DCEResolution dceResolution;

//MARK: About ViewSettings.

/// The instance of DCEViewSettings.
@property (nonatomic) DCEViewSettings dceViewSettings;

//MARK: About DCE and DBR

/// The instance of DynamsoftBarcodeReader.
@property (nonatomic, strong) DynamsoftBarcodeReader *barcodeReader;

/// The instance of DynamsoftCameraEnhancer.
@property (nonatomic, strong) DynamsoftCameraEnhancer *cameraEnhancer;

/// The instance of DCECameraView.
@property (nonatomic, strong) DCECameraView *cameraView;

/// The instance of iPublicRuntimeSettings.
@property (nonatomic, strong) iPublicRuntimeSettings *ipublicRuntimeSettings;

/// Whether to enable continuous decoding.
@property (nonatomic, assign) BOOL continuousScan;

+ (GeneralSettingsHandle *)setting;

/// Set default data.
- (void)setDefaultData;

/// Update ipublicRuntimeSettings.
- (BOOL)updateIpublicRuntimeSettings;

@end

NS_ASSUME_NONNULL_END
