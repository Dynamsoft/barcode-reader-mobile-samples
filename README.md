# Dynamsoft Barcode Reader samples for the Android and iOS editions

This repository contains multiple samples that demonstrates how to use the [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/) Android and iOS Editions.

## Requirements

### Android
- Operating systems:
  - Supported OS: Android 5 or higher (Android 7 or higher recommended)
  - Supported ABI: armeabi-v7a, arm64-v8a, x86, x86_64
- Environment: Android Studio 3.4+

### iOS
- Operating systems:
  - iOS 9.0 and above.
- Environment: Xcode 7.1 - 11.5 and above.
- Recommended: macOS 10.15.4+, Xcode 11.5+, iOS 11+, CocoaPods 1.11.0

## Samples

| Sample | Description | Programming Language(s) |
| ------ | ----------- | -------------------- |
| `HelloWorld` | This is an Android sample that illustrates the simplest way to recognize barcodes from video streaming with Dynamsoft Barcode Reader SDK and Dynamsoft Camera Enhancer SDK. | Java(Android)/Objective-C/Swift |
| `GeneralSettings` | This is an Android sample that illustrates how to make general settings when using Dynamsoft Barcode Reader. | Java(Android)/Objective-C/Swift |
| `SpeedFirstSettings` | This is an Android sample that shows how to configure Dynamsoft Barcode Reader to read barcodes as fast as possible. The downside is that read-rate and accuracy might be affected. | Java(Android)/Objective-C/Swift |
| `ReadRateFirstSettings` | This is an Android sample that shows how to configure Dynamsoft Barcode Reader to read as many barcodes as possible at one time. The downside is that speed and accuracy might be affected. It is recommended to apply these configurations when decoding multiple barcodes from a single image. | Java(Android)/Objective-C/Swift |
| `AccuracyFirstSettings` | This is an Android sample that shows how to configure Dynamsoft Barcode Reader to read barcodes as accurately as possible. The downside is that speed and read-rate might be affected. It is recommended to apply these configurations when misreading is unbearable. | Java(Android)/Objective-C/Swift |
| `ReadADriversLicense` | This is an Android sample that shows how to create a mobile app that focus on decoding the drivers' license barcodes and displaying the parsed information. | Java(Android)/Swift |

### How to build (For iOS Editions)

1. Enter the sample folder, install DLR SDK through `pod` command

    ```bash
    pod install
    ```

2. Open the generated file `[SampleName].xcworkspace`

## License

- If you want to use an offline license, please contact [Dynamsoft Support](https://www.dynamsoft.com/company/contact/)
- You can also request a 30-day trial license in the [customer portal](https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=github)

## Contact Us

https://www.dynamsoft.com/company/contact/
