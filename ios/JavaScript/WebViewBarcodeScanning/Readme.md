# Dynamsoft Barcode Reader sample for iOS edition with WKWebView

This sample demonstrates how to use the [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/) iOS Edition in the WKWebView.



## Get Started

### 1. Add DBRWKWebViewHelper

Right-click your project in xcode -> new File -> Swift File -> Save as DBRWKWebViewHelper, and copy the DBRWKWebViewHelper's code in sample to this file.

### 2. Pollute your WKWebView

Class `DBRWKWebViewHelper` provides a method `pollute`, which will Inject a global variable `webkit` into the js code in your WKWebView. 

```swift
DBRWKWebViewHelper().pollute(wkWebView);
```

note: Pollution doesn't modify the WKWebViewConfiguration you set earlier, so don't worry about it.

### 3. Use global variable in JS

This global variable `webkit` is an object under the `window` object and contains all your custom methods. you can call them directly, which will make the app execute the corresponding java code.

more detailes: [Apple Developer Documentation](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler).

```javascript
window.webkit.messageHandlers.startScanning.postMessage("");
```

Also, you can copy the 'DBRWKWebViewBridge.js' file in the sample to your project and import it into html, it provides a DBRWKWebViewBridge class, which encapsulates some methods to facilitate the communication with native code.



## Customize DBRWKWebViewHelper

### 1. Change the methods to be injected

All methods are injected in the method`pollute`, and defined in the method `userContentController` .  You have to modify both of them.

more detailes: [ userContentController - Apple Developer Documentation](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler/1396222-usercontentcontroller) and [add() - Apple Developer Documentation](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-add).

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
