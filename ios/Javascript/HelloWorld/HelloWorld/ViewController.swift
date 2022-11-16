//
//  ViewController.swift
//
//

import UIKit
import WebKit

class ViewController: UIViewController, DBRTextResultListener {
    
    var SafeAreaBottomHeight:CGFloat = UIApplication.shared.statusBarFrame.size.height > 20 ? 34 : 0
    var mainHeight = UIScreen.main.bounds.height
    var mainWidth = UIScreen.main.bounds.width
    var dce:DynamsoftCameraEnhancer! = nil
    var dceView:DCECameraView! = nil
    var barcodeReader:DynamsoftBarcodeReader! = nil
    
    var wkWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is a sample that illustrates how to quickly set up a video barcode scanner with Dynamsoft Barcode Reader.
        configurationDBR()
        
        let configuration = WKWebViewConfiguration()

        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        let userContentController = WKUserContentController()
        // add the name of the methods to inject
        userContentController.add(self, name: "startScanning")
        userContentController.add(self, name: "stopScanning")
        
        configuration.userContentController = userContentController
        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        self.view.addSubview(wkWebView!)
        
        let fileURL =  Bundle.main.url(forResource: "index", withExtension: "html" )
        wkWebView?.loadFileURL(fileURL!,allowingReadAccessTo:Bundle.main.bundleURL);
        
        // let url = URL(string: "https://example.com")
        // let request = URLRequest(url: url!)
        // wkWebView!.load(request)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func configurationDBR() {
        barcodeReader = DynamsoftBarcodeReader.init()
        barcodeReader.updateRuntimeSettings(EnumPresetTemplate.videoSingleBarcode)
    }

    //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
    func configurationDCE() {
        var barHeight = self.navigationController?.navigationBar.frame.height
        if UIApplication.shared.statusBarFrame.size.height <= 20 {
            barHeight = 20
        }
        //Initialize a camera view for previewing video.
        dceView = DCECameraView.init(frame: CGRect(x: 70, y: barHeight! + 80, width: 220, height: 220))
        self.view.addSubview(dceView)
        self.view.bringSubviewToFront(dceView)
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
    
    private func showResult(_ title: String, _ msg: String, _ acTitle: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: WKScriptMessageHandler {
    // handle calls from JS here
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name, message.body)
        switch message.name {
            case "startScanning":
                if(dce === nil) {
                    configurationDCE()
                } else {
                    dce.open()
                    barcodeReader.startScanning()
                }
            case "stopScanning":
                barcodeReader.stopScanning()
                dce.close()
            default:
                print(message.body)
        }
    }

}
