//
//  ViewController.swift
//
//

import UIKit

class ViewController: UIViewController, DMDLSLicenseVerificationDelegate, DBRTextResultDelegate {
    
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
        let dls = iDMDLSConnectionParameters()
        // Initialize license for Dynamsoft Barcode Reader.
        // The organization id 200001 here will grant you a time-limited public trial license. Note that network connection is required for this license to work.
        // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
        // You can also request an extention for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
        dls.organizationID = "200001"
        barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: dls, verificationDelegate: self)
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
        barcodeReader.setDBRTextResultDelegate(self, userData: nil)

        // Start the barcode decoding thread.
        barcodeReader.startScanning()
    }

    // Callback when license is verified or failed to verified.
    // Set alert message when license verification is failed.
    func dlsLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        var msg:String? = nil
        if(error != nil)
        {
            let err = error as NSError?
            msg = err!.userInfo[NSUnderlyingErrorKey] as? String
            if(msg == nil)
            {
                msg = err?.localizedDescription
            }
            showResult("Server license verify failed", msg!, "OK") {
            }
        }
    }
    
    // Obtain the recognized barcode results from the textResultCallback and display the results
    func textResultCallback(_ frameId: Int, results: [iTextResult]?, userData: NSObject?) {
        if results!.count > 0 {
            var msgText:String = ""
            var title:String = "Results"
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
