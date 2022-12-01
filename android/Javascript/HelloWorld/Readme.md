# Dynamsoft Barcode Reader sample for Android edition with WebView

This sample demonstrates how to use the [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/) Android Edition in the WebView.

## Get Started

### 1. Add MainScanner

You can copy the file 'MainScanner.java' to your project, same directory as 'MainActivity.java'.

### 2. Pollute your WebView

Class `MainScanner` provides a method `pollute`, which will Inject a global variable into the js code in your WebView.

```java
// void pollute(WebView mWebView)
new MainScanner().pollute(mWebView);
```

### 3. Use global variable in JS

This global variable is an object under the `window` object and contains all your custom methods. you can call them directly, which will make the app execute the corresponding java code.

```javascript
window.DBR_Android.startScanning(); 
```

## Customize MainScanner

### 1. Rename the variable to be injected

The name is set in this line of code in the pollute method, just change the string value.

```java
mWebView.addJavascriptInterface(new WebAppInterface(), "Your name here");
```

### 2. Change the methods to be injected

All methods are defined in the `WebAppInterface` class, you can add, delete, and modify them, but don't forget to add `@JavascriptInterface` annotation

```java
@JavascriptInterface
public String funcName(String foo) {
    return foo;
}
```
