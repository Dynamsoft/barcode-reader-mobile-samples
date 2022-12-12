//
//  MainScanner.swift
//  HelloWorld
//
//  Created by Dynamsoft on 2022/12/5.
//

import WebKit

class DBRWKWebViewHelper: NSObject, DBRTextResultListener {

    var dce: DynamsoftCameraEnhancer! = nil
    var dceView: DCECameraView! = nil
    var barcodeReader: DynamsoftBarcodeReader! = nil
    var wkWebView: WKWebView?
    
    func pollute(_ _wkWebView: WKWebView) {
        wkWebView = _wkWebView
        
        // Init DBR
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
        userContentController.add(self, name: "switchFlashlight")
        userContentController.add(self, name: "startScanning")
        userContentController.add(self, name: "stopScanning")
        userContentController.add(self, name: "getRuntimeSettings")
        userContentController.add(self, name: "updateBarcodeFormatIds")
        userContentController.add(self, name: "updateExpectedBarcodesCount")
        userContentController.add(self, name: "getEnumBarcodeFormat")
        wkWebView!.configuration.userContentController = userContentController
        
        //
        wkWebView!.isOpaque = false
        wkWebView!.backgroundColor = UIColor.clear
        wkWebView!.scrollView.backgroundColor = UIColor.clear
        
    }
        
    func configurationDBR() {
        barcodeReader = DynamsoftBarcodeReader.init()
        barcodeReader.updateRuntimeSettings(EnumPresetTemplate.videoSingleBarcode)
    }

    func configurationDCE() {
        //Initialize a camera view for previewing video.
        dceView = DCECameraView.init()
        dceView.overlayVisible = true 
        wkWebView!.superview!.self.addSubview(dceView)
        wkWebView!.superview!.self.sendSubviewToBack(dceView)
        // Initialize the Camera Enhancer with the camera view.
        dce = DynamsoftCameraEnhancer.init(view: dceView)
        // Bind Camera Enhancer to the Barcode Reader.
        // The Barcode Reader will get video frame from the Camera Enhancer
        barcodeReader.setCameraEnhancer(dce)

        // Set text result call back to get barcode results.
        barcodeReader.setDBRTextResultListener(self)
    }
    
    // Obtain the recognized barcode results from the textResultCallback and display the results
    func textResultCallback(_ frameId: Int, imageData: iImageData, results: [iTextResult]?) {
        if (results != nil){
            var msgText:String = ""
            for item in results! {
                msgText = msgText + String(format:"Format: %@ Text: %@", item.barcodeFormatString!,item.barcodeText ?? "noResuslt")
            }
            DispatchQueue.main.async {
                self.wkWebView!.evaluateJavaScript("dbrWKWebViewBridge.onBarcodeRead(`" + msgText + "`)")
            }
        } else {
            return
        }
    }
    
    func getRuntimeSettings() -> String {
        let settings = try! barcodeReader.getRuntimeSettings()
        struct Settings: Codable {
            let barcodeFormatIds: Int
            let expectedBarcodesCount: Int
        }
        let foramts = Settings(barcodeFormatIds: settings.barcodeFormatIds, expectedBarcodesCount: settings.expectedBarcodesCount)
        let data = try! JSONEncoder().encode(foramts)
        return String(data: data, encoding: .utf8)!
    }
    
    func updateRuntimeSettings(key: String, value: Any) {
        let settings = try! barcodeReader.getRuntimeSettings()
        settings.setValue(value, forKey: key)
        try! barcodeReader.updateRuntimeSettings(settings)
    }
    
    func switchFlashlight(state: Bool) {
        if (state == true) {
            dce.turnOnTorch();
        } else {
            dce.turnOffTorch();
        }
    }
    
    func initFormatsJSON() -> String {
        class Formats: NSObject, Codable {
            var BF_ALL: Int = EnumBarcodeFormat.ALL.rawValue
            var BF_ONED: Int = EnumBarcodeFormat.ONED.rawValue
            var BF_GS1_DATABAR: Int = EnumBarcodeFormat.GS1DATABAR.rawValue
            var BF_NULL: Int = EnumBarcodeFormat.Null.rawValue
            var BF_CODE_39: Int = EnumBarcodeFormat.CODE39.rawValue
            var BF_CODE_128: Int = EnumBarcodeFormat.CODE128.rawValue
            var BF_CODE_93: Int = EnumBarcodeFormat.CODE93.rawValue
            var BF_CODABAR: Int = EnumBarcodeFormat.CODABAR.rawValue
            var BF_EAN_13: Int = EnumBarcodeFormat.EAN13.rawValue
            var BF_EAN_8: Int = EnumBarcodeFormat.EAN8.rawValue
            var BF_UPC_A: Int = EnumBarcodeFormat.UPCA.rawValue
            var BF_UPC_E: Int = EnumBarcodeFormat.UPCE.rawValue
            var BF_INDUSTRIAL_25: Int = EnumBarcodeFormat.INDUSTRIAL.rawValue
            var BF_CODE_39_EXTENDED: Int = EnumBarcodeFormat.CODE39EXTENDED.rawValue
            var BF_GS1_DATABAR_OMNIDIRECTIONAL: Int = EnumBarcodeFormat.GS1DATABAROMNIDIRECTIONAL.rawValue
            var BF_GS1_DATABAR_TRUNCATED: Int = EnumBarcodeFormat.GS1DATABARTRUNCATED.rawValue
            var BF_GS1_DATABAR_STACKED: Int = EnumBarcodeFormat.GS1DATABARSTACKED.rawValue
            var BF_GS1_DATABAR_STACKED_OMNIDIRECTIONAL: Int = EnumBarcodeFormat.GS1DATABARSTACKEDOMNIDIRECTIONAL.rawValue
            var BF_GS1_DATABAR_EXPANDED: Int = EnumBarcodeFormat.GS1DATABAREXPANDED.rawValue
            var BF_GS1_DATABAR_EXPANDED_STACKED: Int = EnumBarcodeFormat.GS1DATABAREXPANDEDSTACKED.rawValue
            var BF_GS1_DATABAR_LIMITED: Int = EnumBarcodeFormat.GS1DATABARLIMITED.rawValue
            var BF_PATCHCODE: Int = EnumBarcodeFormat.PATCHCODE.rawValue
            var BF_PDF417: Int = EnumBarcodeFormat.PDF417.rawValue
            var BF_QR_CODE: Int = EnumBarcodeFormat.QRCODE.rawValue
            var BF_DATAMATRIX: Int = EnumBarcodeFormat.DATAMATRIX.rawValue
            var BF_AZTEC: Int = EnumBarcodeFormat.AZTEC.rawValue
            var BF_MAXICODE: Int = EnumBarcodeFormat.MAXICODE.rawValue
            var BF_MICRO_QR: Int = EnumBarcodeFormat.MICROQR.rawValue
            var BF_MICRO_PDF417: Int = EnumBarcodeFormat.MICROPDF417.rawValue
            var BF_GS1_COMPOSITE: Int = EnumBarcodeFormat.GS1COMPOSITE.rawValue
            var BF_MSI_CODE: Int = EnumBarcodeFormat.MSICODE.rawValue
            var BF_CODE_11: Int = EnumBarcodeFormat.CODE_11.rawValue
        }
        let foramts = Formats()
        let data = try! JSONEncoder().encode(foramts)
        return String(data: data, encoding: .utf8)!
    }
   
}

extension DBRWKWebViewHelper: WKScriptMessageHandler {
    // handle calls from JS here
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name, message.body)
        switch message.name {
            case "setCameraUI":
                let list = message.body as! Array<Int>
                let navBarHeight = UINavigationController().navigationBar.frame.height
                var statusBarHeight = UIApplication.shared.statusBarFrame.size.height
                if statusBarHeight <= 20 {
                    statusBarHeight = 20
                }
                dceView.frame = CGRect(x: list[0], y: Int(navBarHeight) + Int(statusBarHeight) + list[1], width: list[2], height: list[3])
            case "startScanning":
                dceView.isHidden = false
                // Open the camera to get video streaming.
                dce.open()
                // Start the barcode decoding thread.
                barcodeReader.startScanning()
            case "stopScanning":
                dceView.isHidden = true
                barcodeReader.stopScanning()
                dce.close()
            case "getRuntimeSettings":
                let id = message.body as! String
                wkWebView!.evaluateJavaScript("dbrWKWebViewBridge.postMessage('" + id + "'," + getRuntimeSettings() + ")")
            case "updateBarcodeFormatIds":
                updateRuntimeSettings(key: "barcodeFormatIds", value: message.body)
            case "updateExpectedBarcodesCount":
                updateRuntimeSettings(key: "expectedBarcodesCount", value: message.body)
            case "getEnumBarcodeFormat":
                let id = message.body as! String
                wkWebView!.evaluateJavaScript("dbrWKWebViewBridge.postMessage('" + id + "'," + initFormatsJSON() + ")")
            case "switchFlashlight":
                let state = message.body as! Bool
                switchFlashlight(state: state)
            default:
                print(message.body)
        }
    }

}
