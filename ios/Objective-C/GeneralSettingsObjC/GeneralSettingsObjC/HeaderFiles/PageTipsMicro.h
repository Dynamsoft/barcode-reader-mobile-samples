//
//  PageTipsMicro.h
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/24.
//

#ifndef PageTipsMicro_h
#define PageTipsMicro_h

#define kExpectedCountMaxValue 999

#define kMinimumResultConfidenceMaxValue 100

#define kDuplicateForgetTimeMaxValue 600000

#define kMinimumDecodeIntervalMaxValue 0x7fffffff


static NSString *const barcodeFormatEnableAllString = @"Enable All";
static NSString *const barcodeFormatDisableAllString = @"Disable All";

static NSString *const decodeResultTextPrefix = @"Text:";
static NSString *const decodeResultFormatPrefix = @"Format:";

static NSString *const expectedCountExplain = @"The fewer expected barcode count, the higher barcode decoding speed. When the expected count is set to 0, the barcode reader will try to decode at least one barcode.";

static NSString *const enhancedFocusExplain = @"Enhanced focus is one of the Dynamsoft Camera Enhancer features. The specially designed focus mechanism will significantly improve the camera's focusing ability on low-end devices.";

static NSString *const frameSharpnessFilterExplain = @"Frame sharpness filter is one of the Dynamsoft Camera Enhancer features. It makes a quick evaluation on each video frames so that the Barcode Reader will be able to skip the blurry frames.";

static NSString *const sensorFilterExplain = @"Sensor filter is one of the Dynamsoft Camera Enhancer features. The mobile sensor will help on filtering out the video frames that are captured while the device is shaking.";

static NSString *const autoZoomExplain = @"Auto-zoom will be available when you are using Dynamsoft Camera Enhancer and Dynamsoft Barcode Reader together. The camera will zoom-in automatically to approach the long-distance barcode.";

static NSString *const fastModeExplain = @"Fast mode is one of the Dynamsoft Camera Enhancer features. Frame will be cropped to small size to improve the processing speed.";

static NSString *const smartTorchExplain = @"If enabled, a torch button will appear on the camera view when the environment light level is low.";

static NSString *const dceScanRegionExplain = @"Set the region of interest via Dynamsoft Camera Enhancer. The frames will be cropped based on the region of interest to improve the barcode decoding speed. Once you have configured the scan region, the fast mode will be negated.";

static NSString *const displayOverlayExplain = @"An overlay will be displayed on the successfully decoded barcodes. The display of overlay is controlled by Dynamsoft Camera Enhancer.";

static NSString *const resultVerificationExplain = @"Improve the accuracy at the expense of a bit speed.";

static NSString *const duplicateFilterExplain = @"Filter out the duplicate barcode results over a period of time.";

static NSString *const duplicateForgetTimeExplain = @"Set the time period for duplicate filter. Measured by millisecond.";

static NSString *const minimumDecodeIntervalExplain = @"Set the interval of video barcode decoding. It can reduce the battery consumption. Measured by millisecond.";


#endif /* PageTipsMicro_h */
