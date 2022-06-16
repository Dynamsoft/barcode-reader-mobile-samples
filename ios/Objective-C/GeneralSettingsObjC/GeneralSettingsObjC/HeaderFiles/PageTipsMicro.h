//
//  PageTipsMicro.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/24.
//

#ifndef PageTipsMicro_h
#define PageTipsMicro_h



static NSString *barcodeFormatEnableAllString = @"Enable All";
static NSString *barcodeFormatDisableAllString = @"Disable All";

static NSString *decodeResultTextPrefix = @"Text:";
static NSString *decodeResultFormatPrefix = @"Format:";

#define kExpectedCountMaxValue 999

static NSString *expectedCountExplain = @"The fewer expected barcode count, the higher barcode decoding speed. When the expected count is set to 0, the barcode reader will try to decode at least one barcode.";

static NSString *enhancedFocusExplain = @"Enhanced focus is one of the Dynamsoft Camera Enhancer features. The specially designed focus mechanism will significantly improve the camera's focusing ability on low-end devices.";

static NSString *frameSharpnessFilterExplain = @"Frame sharpness filter is one of the Dynamsoft Camera Enhancer features. It makes a quick evaluation on each video frames so that the Barcode Reader will be able to skip the blurry frames.";

static NSString *sensorFilterExplain = @"Sensor filter is one of the Dynamsoft Camera Enhancer features. The mobile sensor will help on filtering out the video frames that are captured while the device is shaking";

static NSString *autoZoomExplain = @"Auto-zoom will be available when you are using Dynamsoft Camera Enhancer and Dynamsoft Barcode Reader together. The camera will zoom-in automatically to approach the long-distance barcode.";

static NSString *fastModelExplain = @"Fast mode is one of the Dynamsoft Camera Enhancer features. Frame will be cropped to small size to improve the processing speed";

static NSString *dceScanRegionExplain = @"Set the region of interest via Dynamsoft Camera Enhancer. The frames will be cropped based on the region of interest to improve the barcode decoding speed. Once you have configured the scan region, the fast mode will be negated.";

static NSString *displayOverlayExplain = @"An overlay will be displayed on the successfully decoded barcodes. The display of overlay is controlled by Dynamsoft Camera Enhancer.";



static NSString *const AppDidEnterToBackgroundNotification = @"AppDidEnterToBackgroundNotification";

static NSString *const AppWillEnterToForegroundNotification = @"AppWillEnterToForegroundNotification";

#endif /* PageTipsMicro_h */
