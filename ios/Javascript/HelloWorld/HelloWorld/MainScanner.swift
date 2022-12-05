//
//  MainScanner.swift
//  HelloWorld
//
//  Created by Dynamsoft on 2022/12/5.
//

import WebKit

class MainScanner: NSObject, DBRTextResultListener {
    
    var dce: DynamsoftCameraEnhancer! = nil
    var dceView: DCECameraView! = nil
    var barcodeReader: DynamsoftBarcodeReader! = nil
    var wkWebView: WKWebView?
    
    func pollute(_ _wkWebView: WKWebView) {
        //This is a sample that illustrates how to quickly set up a video barcode scanner with Dynamsoft Barcode Reader.
        configurationDBR()
        
        //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
        configurationDCE()
        
        let configuration = _wkWebView.configuration
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        let userContentController = configuration.userContentController
        userContentController.add(self, name: "setCameraUI")
        userContentController.add(self, name: "startScanning")
        userContentController.add(self, name: "stopScanning")
        _wkWebView.configuration.userContentController = userContentController
        
        wkWebView = _wkWebView
    }
        
    func configurationDBR() {
        barcodeReader = DynamsoftBarcodeReader.init()
        barcodeReader.updateRuntimeSettings(EnumPresetTemplate.videoSingleBarcode)
    }

    func configurationDCE() {
        //Initialize a camera view for previewing video.
        dceView = DCECameraView.init()
        UIViewController.current?.view.addSubview(dceView)
        UIViewController.current?.view.bringSubviewToFront(dceView)
        // Initialize the Camera Enhancer with the camera view.
        dce = DynamsoftCameraEnhancer.init(view: dceView)
        // Open the camera to get video streaming.
        dce.open()
        // Bind Camera Enhancer to the Barcode Reader.
        // The Barcode Reader will get video frame from the Camera Enhancer
        barcodeReader.setCameraEnhancer(dce)

        // Set text result call back to get barcode results.
        barcodeReader.setDBRTextResultListener(self)

        // Start the barcode decoding thread.
        barcodeReader.startScanning()
    }
    
    // Obtain the recognized barcode results from the textResultCallback and display the results
    func textResultCallback(_ frameId: Int, imageData: iImageData, results: [iTextResult]?) {
        if (results != nil){
            var msgText:String = ""
            for item in results! {
                msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", item.barcodeFormatString!,item.barcodeText ?? "noResuslt")
            }
            DispatchQueue.main.async {
                self.wkWebView?.evaluateJavaScript("wkWebviewBridge.onBarcodeRead(`" + msgText + "`)")
            }
        } else {
            return
        }
    }
   
}

extension MainScanner: WKScriptMessageHandler {
    // handle calls from JS here
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name, message.body)
        switch message.name {
            case "setCameraUI":
                let list = message.body as! Array<Int>
                dceView.frame = CGRect(x: list[0], y: list[1], width: list[2], height: list[3])
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

}
