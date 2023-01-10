# Dynamsoft Barcode Reader sample for iOS edition with WKWebView

This sample demonstrates how to use the [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/) iOS Edition in the WKWebView.

## Get Started

### 1. Add the SDK

You can follow this guide: [User Guide - Dynamsoft Barcode Reader for iOS](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/objectivec-swift/user-guide.html?ver=latest#add-the-sdk).

### 2. Initialize the License

You can follow this guide: [User Guide - Dynamsoft Barcode Reader for iOS](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/objectivec-swift/user-guide.html?ver=latest#initialize-the-license).

### 3. Add DBRWKWebViewHelper

Right-click your project in xcode -> new File -> Swift File -> Save as DBRWKWebViewHelper, and copy the DBRWKWebViewHelper's code in the sample to this file.

`DBRWebViewHelper` which will make it very convenient to let the js code in your WKWebView use DBR iOS.

### 4. Pollute your WKWebView

Class `DBRWKWebViewHelper` provides a method `pollute`, which will Inject a global variable `webkit` into the js code in your WKWebView. 

```swift
DBRWKWebViewHelper().pollute(wkWebView);
```

**Note: pollution doesn't modify the `WKWebViewConfiguration` you set before.**

This global variable `webkit` is an object that contains all your custom methods, and you can call them directly like this: 

```javascript
window.webkit.messageHandlers.startScanning.postMessage("some messages");
```

For more detailes about `webkit`: [Apple Developer Documentation](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler).

Also, you are free to change variable names and all these methods by following: [Customize DBRWKWebViewHelper and DBRWKWebViewBridge](#customize-dbrwkwebviewhelper-and-dbrwkwebviewbridge).

### 5. Add DBRWKWebViewBridge

Copy the file 'BridgeInitializer.js' in the sample to your web project and import it.

```html
<script src="./js/BridgeInitializer.js"></script>
```

It provides a global variable `dbrWebViewBridge`, which encapsulates the methods of `webkit.messageHandlers` and makes it easier to communicate with native code.

All methods provided by `dbrWebViewBridge` in this sample: [DBRWKWebViewBridge APIs](#dbrwkwebviewbridge-apis).

```javascript
// e.g. get barcodeReader's runtimeSettings
const settings = await dbrWebViewBridge.getRuntimeSettings();
```

## Customize DBRWKWebViewHelper and DBRWKWebViewBridge

**Notice: when you change variables or methods, you should modify both native code and JS code to avoid errors.**

### 1. Change the methods to be injected

All methods are injected in the method`pollute`, and defined in the method `userContentController` .  You have to modify both of them.

For more usage of DBR iOS: [Main Page - Dynamsoft Barcode Reader for iOS](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/objectivec-swift/)

For more detailes: [ userContentController - Apple Developer Documentation](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler/1396222-usercontentcontroller) and [add() - Apple Developer Documentation](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-add).

```swift
// func pollute(wkWebView: WKWebView)
let userContentController = configuration.userContentController
// The parameter name is the name of the injected message handler.
// https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-add
userContentController.add(self, name: "startScanning")
userContentController.add(self, name: "stopScanning")
wkWebView.configuration.userContentController = userContentController


// extension DBRWKWebViewHelper: WKScriptMessageHandler
func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    // message.name is the name of the function called in JS.
    // message.body is the parameter passed when calling.
    // Both of them are of type string.
    switch message.name {
        case "startScanning":
            dce.open()
            barcodeReader.startScanning()
        case "stopScanning":
            barcodeReader.stopScanning()
            dce.close()
        default:
            print(message.body)
    }
}
```

### 2. Rename the global variable DBRWKWebViewBridge provides

The name is set in the 'BridgeInitializer.js', just need to replace the variable name `dbrWebViewBridge` to yours globally.

### 3. Change the methods DBRWKWebViewBridge provides

For iOS only, all methods are defined in the `DBRWKWebViewBridge` class in 'BridgeInitializer.js', to encapsulate the methods injected.

```javascript
// e.g.
switchFlashlight(state) {
    this.methodsMap.switchFlashlight.postMessage({ id: generateRandomId(), data: state });
};
```

## DBRWKWebViewBridge APIs

All variables and methods contained in the class `DBRWKWebViewBridge`(iOS only) in **this sample**.

+ ### methodsMap
  
  A variable used to store all properties under `window.webkit.messageHandlers`.
  
  ```javascript
  methodsMap: WKScriptMessageHandler;
  ```
  
  For more details: [`WKScriptMessageHandler`](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler).

+ ### msgHandlersQueue
  
  A message queue for communicating with native code, store the `resolve` and `reject` methods for each asynchronous communication. Based on the unique ID of each communication.
  
  ```javascript
  // e.g. 
  {
      "id1671082445553707": {
          resolve: (data) => void,
          reject: (data) => void
      }
  }
  ```

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
  
  `state`: a boolean value, pass `true` to open, `false` to close.

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
  getRuntimeSettings(): Promise<iPublicRuntimeSettings>;
  ```
  
  **Return Value**
  
  A promise resolving to a [`iPublicRuntimeSettings`](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/objectivec-swift/api-reference/auxiliary-iPublicRuntimeSettings.html) json object that contains the settings for barcode reading.

+ ### updateBarcodeFormatIds
  
  Update property [`barcodeFormatIds`](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/objectivec-swift/api-reference/auxiliary-iPublicRuntimeSettings.html?ver=latest#barcodeformatids) under barcodeReader's `iPublicRuntimeSettings`.
  
  ```javascript
  updateBarcodeFormatIds(data: number): Promise<void>;
  ```
  
  **Parameters**
  
  `data`: a combined value of [`EnumBarcodeFormat`](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/enumeration/barcode-format.html?lang=objc,swift) Enumeration items.

+ ### updateExpectedBarcodesCount
  
  Update property [`expectedBarcodesCount`](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/objectivec-swift/api-reference/auxiliary-iPublicRuntimeSettings.html?ver=latest#expectedbarcodescount) under barcodeReader's `iPublicRuntimeSettings`.
  
  ```javascript
  updateExpectedBarcodesCount(data: number): Promise<void>;
  ```
  
  **Parameters**
  
  `data`: an integer in the range [0, 0x7fffffff].

+ ### getEnumBarcodeFormat
  
  Get `EnumBarcodeFormat` json object.
  
  ```javascript
  getEnumBarcodeFormat(): Promise<EnumBarcodeFormat>;
  ```
  
  **Return Value**
  
  A promise resolving to a [`EnumBarcodeFormat`](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/enumeration/barcode-format.html?lang=objc,swift&&ver=latest) json object that contains the settings for barcode reading.

+ ### onBarcodeRead
  
  Callback to handle the text result array returned by the library, initially empty.
  
  ```javascript
  onBarcodeRead(results: iTextResult): void;
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
  await dbrWebViewBridge.startScanning();
  ```
