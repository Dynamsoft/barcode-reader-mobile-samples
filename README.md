# Dynamsoft Barcode Reader samples for Android and iOS editions

This repository contains multiple samples that demonstrate how to use the [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/) Android and iOS Editions.

- User Guide
  - [Android](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/android/user-guide.html)
  - [iOS](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/objectivec-swift/user-guide.html?lang=swift)
- API Reference
  - [Android](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/android/api-reference/)
  - [iOS](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/objectivec-swift/api-reference/)

## Requirements

### Android

- Supported OS: <a href="https://developer.android.com/about/versions/lollipop" target="_blank">Android 5.0 (API Level 21)</a> or higher.
- Supported ABI: **armeabi-v7a**, **arm64-v8a**, **x86** and **x86_64**.
- Development Environment: Android Studio 2022.2.1 or higher.

### iOS

- Supported OS: **iOS 11.0** or higher (iOS 13 and higher recommended).
- Supported ABI: **arm64** and **x86_64**.
- Development Environment: Xcode 13 and above (Xcode 14.1+ recommended), CocoaPods 1.11.0+

## Samples

### Barcode Reader Samples

| Sample Name | Description | Programming Language(s) |
| ----------- | ----------- | ----------------------- |
| `DecodeWithCameraEnhancer` | The simplest sample of video streaming barcode scanner using **DynamsoftCameraEnhancer** as the input source. | Java(Android)/Kotlin/Objective-C/Swift |
| `DecodeWithCameraX` | The video streaming barcode scanner sample, but using **CameraX** as the input source. | Java(Android)/Kotlin |
| `DecodeWithAVCaptureSession` | The video streaming barcode scanner sample, but using **AVCaptureSession** as the input source. | Objective-C/Swift |
| `DecodeFromAnImage` | The sample shows how to pick an image from the album for barcode decoding. | Java(Android)/Kotlin/Objective-C/Swift |
| `GeneralSettings` | Displays general barcode decoding settings and camera settings like barcode formats, expected barcode count and scan region settings. The default scan mode is continuous scanning. | Java(Android)/Swift |
| `PerformanceSettings` | Parameter configuration guide on improving the speed, read-rate and accuracy of barcode reading. The sample includes the code of image decoding from the album. | Java(Android)/Swift |
| `TinyBarcodeDecoding` | The sample to tell you how to process the tiny barcodes. Including zoom and focus control. | Java(Android)/Swift |

### Capture Vision Samples

The following samples aggregate multiple products under `DynamsoftCaptureVision` architecture. They include the barcode decoding feature and implement it in more specific usage scenarios with the help of the other Dynamsoft functional products.

> Note: Move to the [DynamsoftCaptureVison samples repo](https://github.com/Dynamsoft/capture-vision-mobile-samples) to view the following samples.

| Sample Name | Description | Programming Language(s) | Products |
| ----------- | ----------- | ----------------------- | -------- |
| `DriversLicenseScanner` | Scan the PDF417 barcodes on a drivers' license and extract the drivers information. | Java(Android)/Swift | [DynamsoftBarcodeReader](https://www.dynamsoft.com/barcode-reader/overview/)<br> [DynamsoftCodeParser](https://www.dynamsoft.com/code-parser/docs/core/introduction/) |
| `VINScanner` | Scan the vin barcode or text and extract the vehicle information. | Java(Android)/Swift | [DynamsoftBarcodeReader](https://www.dynamsoft.com/barcode-reader/overview/) <br> [DynamsoftLabelRecognizer](https://www.dynamsoft.com/label-recognition/overview/)<br> [DynamsoftCodeParser](https://www.dynamsoft.com/code-parser/docs/core/introduction/) |

### How to build (For iOS Editions)

1. Enter the sample folder, install DBR SDK through `pod` command

    ```bash
    pod install
    ```

2. Open the generated file `[SampleName].xcworkspace`

## License

- If you want to use an offline license, please contact [Dynamsoft Support](https://www.dynamsoft.com/company/contact/)
- You can also request an extension for your trial license in the [customer portal](https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=github)

## Contact Us

https://www.dynamsoft.com/company/contact/
