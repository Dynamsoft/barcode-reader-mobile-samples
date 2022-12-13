# Dynamsoft Barcode Reader samples for Android and iOS editions

This repository contains multiple samples that demonstrates how to use the [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/) Android and iOS Editions.

## Requirements

### Android

- Supported OS: <a href="https://developer.android.com/about/versions/lollipop" target="_blank">Android 5.0 (API Level 21)</a> or higher.
- Supported ABI: **armeabi-v7a**, **arm64-v8a**, **x86** and **x86_64**.
- Development Environment: Android Studio 3.4+ (Android Studio 4.2+ recommended).

### iOS

- Supported OS: **iOS 9.0** or higher.
- Supported ABI: **arm64** and **x86_64**.
- Development Environment: Xcode 7.1 and above (Xcode 13.0+ recommended), CocoaPods 1.11.0+

## Samples

| Sample Name | Description | Programming Language(s) |
| ----------- | ----------- | ----------------------- |
| `HelloWorld` | This is a sample that illustrates the simplest way to recognize barcodes from video streaming with Dynamsoft Barcode Reader SDK and Dynamsoft Camera Enhancer SDK. | Java(Android)/Kotlin/Objective-C/Swift |
| `GeneralSettings` | This is a sample that illustrates how to make general settings when using Dynamsoft Barcode Reader and Dynamsoft Camera Enhancer. | Java(Android)/Objective-C/Swift |
| `PerformanceSettings` | In this sample, you will read about how speed, read rate and accuracy performance can be optimized when using Dynamsoft Barcode Reader and Dynamsoft Camera Enhancer. In addition, as one of the common usage scenarios, single barcode decoding settings are also illustrated in the sample. | Java(Android)/Objective-C/Swift |
| `ReadADriversLicense` | This is a sample that shows how to create a mobile app that focuses on decoding the drivers' license barcodes and displaying the parsed information. | Java(Android)/Swift |
| `DecodeWithCameraX` | This is a sample that shows how to integrate DBR and Android CameraX module to decode barcodes from camera. | Java(Android) |
| `DecodeWithAVCaptureSession` | This is a sample that shows how to integrate DBR and AVFoundation framework to decode barcodes from camera. | Objective-C/Swift |
| `WebViewBarcodeScanning` | This is a sample that shows how to integrate DBR and WebView to decode barcodes. | JavaScript |

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
