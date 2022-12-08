# Dynamsoft Barcode Reader sample for Android edition with WebView

This sample demonstrates how to use the [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/) Android Edition in the WebView.



## Get Started

### 1. Add DBRWebViewHelper

You can copy the file 'DBRWebViewHelper.java' to your project, same directory as 'MainActivity.java'.

### 2. Pollute your WebView

Class `DBRWebViewHelper` provides a method `pollute`, which will Inject a global variable into the js code in your WebView.

```java
// void pollute(WebView mWebView)
new DBRWebViewHelper().pollute(mWebView);
```

### 3. Use global variable in JS

This global variable is an object under the `window` object and contains all your custom methods. you can call them directly, which will make the app execute the corresponding java code.

```javascript
// The following field 'DBR_Android' and methods like 'startScanning' are specified in the relevant code of the DBRWebViewHelper
window.DBR_Android.startScanning(); 
```

Also, you can copy the 'DBRWebViewBridge.js' file in the sample to your project and import it into html, it provides a DBRWebViewBridge class, which encapsulates some methods to facilitate the communication with native code.



## Customize DBRWebViewHelper

### 1. Rename the variable to be injected

The name is set in this line of code in the pollute method, just change the string value.

```java
mWebView.addJavascriptInterface(new WebAppInterface(), "e.g. DBR_Android");
```

### 2. Change the methods to be injected

All methods are defined in the `WebAppInterface` class, you can add, delete, and modify them, but don't forget to add `@JavascriptInterface` annotation

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
