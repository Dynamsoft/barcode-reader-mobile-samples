//
//  ViewController.swift
//
//

import UIKit

class ViewController: UIViewController, DBRTextResultListener {
    
    var SafeAreaBottomHeight:CGFloat = UIApplication.shared.statusBarFrame.size.height > 20 ? 34 : 0
    var mainHeight = UIScreen.main.bounds.height
    var mainWidth = UIScreen.main.bounds.width
    var dce:DynamsoftCameraEnhancer! = nil
    var dceView:DCECameraView! = nil
    var barcodeReader:DynamsoftBarcodeReader! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is a sample that illustrates how to quickly set up a video barcode scanner with Dynamsoft Barcode Reader.
        configurationDBR()
        
        //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
        configurationDCE()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configurationDBR() {
        barcodeReader = DynamsoftBarcodeReader.init()
		barcodeReader.updateRuntimeSettings(EnumPresetTemplate.videoSingleBarcode)
    }
    
    func configurationDCE() {
        var barHeight = self.navigationController?.navigationBar.frame.height
        if UIApplication.shared.statusBarFrame.size.height <= 20 {
            barHeight = 20
        }
        //Initialize a camera view for previewing video.
        dceView = DCECameraView.init(frame: CGRect(x: 0, y: barHeight!, width: mainWidth, height: mainHeight - SafeAreaBottomHeight - barHeight!))
        self.view.addSubview(dceView)

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
        if results!.count > 0 {
            var msgText:String = ""
            let title:String = "Results"
            for item in results! {
                if item.barcodeFormat_2.rawValue != 0 {
                    msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", item.barcodeFormatString_2!, item.barcodeText ?? "noResuslt")
                }else{
                    msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", item.barcodeFormatString!,item.barcodeText ?? "noResuslt")
                }
            }
            showResult(title, msgText, "OK") {
            }
        }else{
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
