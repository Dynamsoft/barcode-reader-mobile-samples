# Dynamsoft Barcode Reader samples for Android and iOS editions

This repository contains multiple samples that demonstrates how to use the [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/) Android and iOS Editions.

## Requirements

### Android

- Supported OS: <a href="https://developer.android.com/about/versions/lollipop" target="_blank">Android 5.0 (API Level 21)</a> or higher.
- Supported ABI: **armeabi-v7a**, **arm64-v8a**, **x86** and **x86_64**.
- Development Environment: Android Studio 3.4+ (Android Studio 4.2+ recommended).

### iOS

- Supported OS: **iOS 11.0** or higher (iOS 13 and higher recommended).
- Supported ABI: **arm64** and **x86_64**.
- Development Environment: Xcode 13 and above (Xcode 14.1+ recommended), CocoaPods 1.11.0+

## Samples

| Sample Name | Description | Programming Language(s) |
| ----------- | ----------- | ----------------------- |
| `DecodeWithCameraEnhancer` | The simplest sample of video streaming barcode scanner using **DynamsoftCameraEnhancer** as the input source. | Java(Android)/Kotlin/Objective-C/Swift |
| `DecodeWithCameraX` | The video streaming barcode scanner sample, but using **CameraX** as the input source. | Java(Android)/Kotlin |
| `DecodeWithAVCaptureSession` | The video streaming barcode scanner sample, but using **AVCaptureSession** as the input source. | Objective-C/Swift |
| `DecodeFromAnImage` | The sample shows how to pick an image from the album for barcode decoding. | Java(Android)/Kotlin/Objective-C/Swift |
| `GeneralSettings` | Displays general barcode decoding settings and camera settings like barcode formats, expected barcode count and scan region settings. The default scan mode is continuous scanning. | Java(Android)/Swift |
| `PerformanceSettings` | Parameter configuration guide on improving the speed, read-rate and accuracy of barcode reading. The sample includes the code of image decoding from the album. | Java(Android)/Swift |
| `TinyBarcodeDecoding` | The sample to tell you how to process the tiny barcodes. Including zoom and focus control. | Java(Android)/Swift |

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
