# Dynamsoft Barcode Reader sample for Android edition with WebView

This sample demonstrates how to use the [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/) Android Edition in the WebView.

## Get Started

### 1. Add the SDK

You can read this guide: [Dynamsoft Barcode Reader for Android - User Guide](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/android/user-guide.html?ver=latest#add-the-sdk).

Additionally, [Gson](https://github.com/google/gson) is used to handle json conversion in this sample.

### 2. Add DBRWebViewHelper

Copy the file 'DBRWebViewHelper.java' in the sample to your Android project, same directory as 'MainActivity.java'.

This file provides a class: `DBRWebViewHelper`, which will make it very convenient to let the js code in your WebView use DBR Android.

```java
DBRWebViewHelper dbrWebViewHelper = new DBRWebViewHelper();
```

**Initialize the License**

When you create a new instance, BarcodeReader will initialize the license, you may need to change your license key string in the DBRWebViewHelper's constructor:

```java
// Initialize license for Dynamsoft Barcode Reader.
@JavascriptInterface
DBRWebViewHelper() {
    BarcodeReader.initLicense("Your license key string here", new DBRLicenseVerificationListener() {
        // code...
    });
}
```

You can request an extension for your trial license in the customer portal: [Trial License - Dynamsoft](https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android).

### 3. Pollute your WebView

Class `DBRWebViewHelper` provides a method `pollute`, which will inject a global variable `DBR_Android` into the js code in your WebView. 

```java
// public void pollute(WebView webview)
dbrWebViewHelper.pollute(mWebView);
```

The variable is an object that has some methods to communicate with native code, you can call them directly like this: 

```javascript
// e.g. barcodeReader starts scanning
window.DBR_Android.startScanning();
```

Also, you are free to change variable names and all these methods by following: [Customize DBRWebViewHelper and DBRWebViewBridge](#customize-dbrwebviewhelper-and-dbrwebviewbridge).

### 4. Add DBRWebViewBridge

Copy the file 'BridgeInitializer.js' in the sample to your web project and import it.

```html
<script src="./js/BridgeInitializer.js"></script>
```

It provides a global variable `dbrWebViewBridge`, which encapsulates the methods of `DBR_Android` and makes it easier to communicate with native code.

All methods provided by `dbrWebViewBridge` in this sample: [DBRWebViewBridge APIs](#dbrwebviewbridge-apis).

```javascript
// e.g. get barcodeReader's runtimeSettings
const settings = await dbrWebViewBridge.getRuntimeSettings();
```

## Customize DBRWebViewHelper and DBRWebViewBridge

**Notice: when you change variables or methods, you should modify both native code and JS code to avoid errors.**

### 1. Rename the variable to be injected

The name is set in the method `pollute`, just change the string value.

```java
mWebView.addJavascriptInterface(new WebAppInterface(), "e.g. DBR_Android");
```

If you use the file 'BridgeInitializer.js', you also need to modify the variable name in the following location:

```javascript
class DBRWebViewBridge {
    constructor() {
        this.methodsMap = window.DBR_Android; // rename 'DBR_Android' here
        // code...
    }
}
```

### 2. Change the methods to be injected

All methods are defined in the `WebAppInterface` class in 'DBRWebViewHelper.java', you can add  methods you need, or delete and modify them.

For more usage of DBR Android: [Main Page - Dynamsoft Barcode Reader for Android](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/android/).

```java
@JavascriptInterface
public void switchFlashlight(String state) throws CameraEnhancerException {
    if (Objects.equals(state, "true")) {
        mCameraEnhancer.turnOnTorch();
    } else if (Objects.equals(state, "false")) {
        mCameraEnhancer.turnOffTorch();
    }
}
```

### 3. Rename the global variable DBRWebViewBridge provides

The name is set in the 'BridgeInitializer.js', just need to replace the variable name `dbrWebViewBridge` to yours globally.

### 4. Change the methods DBRWebViewBridge provides

For Android only, all methods are defined in the `DBRWebViewBridge` class in 'BridgeInitializer.js', to encapsulate the methods injected.

```javascript
// e.g.
this.switchFlashlight = (state) => {
    this.methodsMap.switchFlashlight(state.toString());
};
```

## DBRWebViewBridge APIs

All variables and methods contained in the class `DBRWebViewBridge`(Android only) in **this sample**.

+ ### methodsMap
  
  A variable used to store all methods in `DBR_Android`.

+ ### setCameraUI
  
  Set the position of DCECameraView(the area where the camera video stream and barcode highlighting etc. are displayed) in the application.
  
  ```javascript
  setCameraUI(list: number[]): void;
  ```
  
  **Parameters**
  
  `list`: an integer array of length 4. `[marginTop, marginLeft, width, height]`, with the unit `px`.

+ ### switchFlashlight
  
  Control flash on and off.
  
  ```javascript
  switchFlashlight(state: boolean): void;
  ```
  
  **Parameters**
  
  `state`: boolean value, pass `true` to open, `false` to close.

+ ### startScanning
  
  Open the camera and starts continuous scanning.
  
  ```javascript
  startScanning(): void;
  ```

+ ### stopScanning
  
  Stops continuous scanning and closes the video stream.
  
  ```javascript
  stopScanning(): void;
  ```

+ ### getRuntimeSettings
  
  Returns the current runtime settings.
  
  ```javascript
  getRuntimeSettings(): Promise<PublicRuntimeSettings>;
  ```
  
  **Return Value**
  
  A promise resolving to a [`PublicRuntimeSettings`](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/android/api-reference/auxiliary-PublicRuntimeSettings.html) json object that contains the settings for barcode reading.

+ ### updateRuntimeSettings
  
  Update runtime settings with a given `PublicRuntimeSettings` object.
  
  ```javascript
  updateRuntimeSettings(settings: PublicRuntimeSettings): Promise<void>;
  ```
  
  **Parameters**
  
  `settings`: The [`PublicRuntimeSettings`](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/android/api-reference/auxiliary-PublicRuntimeSettings.html) object of template settings.

+ ### getEnumBarcodeFormat
  
  Get `EnumBarcodeFormat` json object.
  
  ```javascript
  getEnumBarcodeFormat(): Promise<EnumBarcodeFormat>;
  ```
  
  **Return Value**
  
  A promise resolving to a [`EnumBarcodeFormat`](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/enumeration/barcode-format.html?lang=android) json object that contains the settings for barcode reading.

+ ### onBarcodeRead
  
  Callback to handle the text result array returned by the library, initially empty.
  
  ```javascript
  onBarcodeRead(results: String): void;
  ```
  
  **Parameters**
  
  `results`: JSON string, contains recognized barcode results array. 
  
  ```javascript
  {
      barcodeFormatString: String,
      barcodeText: String
  }
  ```
  
  **Code Snippet**
  
  ```javascript
  dbrWebViewBridge.onBarcodeRead = results => {
    JSON.parse(results).forEach(result => {
      console.log(resule.barcodeText);
    });
  };
  dbrWebViewBridge.startScanning();
  ```
