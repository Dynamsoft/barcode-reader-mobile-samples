//
//  MainScanner.swift
//
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
        var barHeight = UIViewController.currentViewController()?.navigationController?.navigationBar.frame.height
        if UIApplication.shared.statusBarFrame.size.height <= 20 {
            barHeight = 20
        }
        //Initialize a camera view for previewing video.
        dceView = DCECameraView.init(frame: CGRect(x: 70, y: barHeight! + 80, width: 220, height: 220))
        UIViewController.currentViewController()?.view.addSubview(dceView)
        UIViewController.currentViewController()?.view.bringSubviewToFront(dceView)
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
            wkWebView?.evaluateJavaScript("wkWebviewBridge.onBarcodeRead(" + msgText + ")")
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

