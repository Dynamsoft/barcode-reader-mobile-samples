//
//  ViewController.swift
//
//

import UIKit

class ViewController: UIViewController, DMDLSLicenseVerificationDelegate, DBRTextResultDelegate {
    
    var dce:DynamsoftCameraEnhancer! = nil
    var dceView:DCECameraView! = nil
    var barcodeReader:DynamsoftBarcodeReader! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is a sample that shows how to make GeneralSettings when using Dynamsoft Barcode Reader.
        configurationDBR()
        
        //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
        configurationDCE()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configurationDBR() {
        let lts = iDMDLSConnectionParameters()
        // Initialize license for Dynamsoft Barcode Reader.
        // The organization id 200001 here will grant you a public trial license good for 7 days. Note that network connection is required for this license to work.
        // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
        // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
        lts.organizationID = "200001"
        barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: lts, verificationDelegate: self)
        
        var error : NSError? = NSError()
        // General settings (including barcode format, barcode count and scan region) for the instance.
        // Obtain current runtime settings of instance.
        let settings = try? barcodeReader.getRuntimeSettings()

        // Set the expected barcode format you want to read.
        // The barcode format our library will search for is composed of BarcodeFormat group 1 and BarcodeFormat group 2.
        // So you need to specify the barcode format in group 1 and group 2 individually.
        settings!.barcodeFormatIds = EnumBarcodeFormat.ONED.rawValue | EnumBarcodeFormat.PDF417.rawValue | EnumBarcodeFormat.QRCODE.rawValue | EnumBarcodeFormat.DATAMATRIX.rawValue | EnumBarcodeFormat.AZTEC.rawValue
        
        // Set the expected barcode count you want to read.
        settings!.expectedBarcodesCount = 5

        // Set the ROI(region of insterest) to speed up the barcode reading process.
        // Note: DBR supports setting coordinates by pixels or percentages. The origin of the coordinate system is the upper left corner point.
        settings!.region.regionTop      = 15 //The int value 15 means the top of the scan region margins 15% from the top of screen.
        settings!.region.regionBottom   = 85
        settings!.region.regionLeft     = 30
        settings!.region.regionRight    = 70
        settings!.region.regionMeasuredByPercentage = 1

        // Apply the new settings to the instance
        barcodeReader.update(settings!, error: &error)
    }
    
    func configurationDCE() {
        //Initialize a camera view for previewing video.
        dceView = DCECameraView.init(frame: self.view.bounds)

        // Enable overlay visibility to highlight the recognized barcode results.
        dceView.overlayVisible = true
        self.view.addSubview(dceView)
        dce = DynamsoftCameraEnhancer.init(view: dceView)
        dce.open()

        // Create settings of video barcode reading.
        let para = iDCESettingParameters.init()

        // This cameraInstance is the instance of the Camera Enhancer.
        // The Barcode Reader will use this instance to take control of the camera and acquire frames from the camera to start the barcode decoding process.
        para.cameraInstance = dce

        // Make this setting to get the result. The result will be an object that contains text result and other barcode information.
        para.textResultDelegate = self

        // Bind the Camera Enhancer instance to the Barcode Reader instance.
        barcodeReader.setCameraEnhancerPara(para)
    }

    func dlsLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        var msg:String? = nil
        if(error != nil)
        {
            let err = error as NSError?
            if err?.code == -1009 {
                msg = "Unable to connect to the public Internet to acquire a license. Please connect your device to the Internet or contact support@dynamsoft.com to acquire an offline license."
                showResult("No Internet", msg!, "Try Again") { [weak self] in
                    self?.configurationDBR()
                    self?.configurationDCE()
                }
            }else{
                msg = err!.userInfo[NSUnderlyingErrorKey] as? String
                if(msg == nil)
                {
                    msg = err?.localizedDescription
                }
                showResult("Server license verify failed", msg!, "OK") {
                }
            }
        }
    }
    
    // Obtain the barcode results from the callback and display the results.
    func textResultCallback(_ frameId: Int, results: [iTextResult]?, userData: NSObject?) {
        if results!.count > 0 {
            var msgText:String = ""
            var title:String = "Results"
            let msg = "Please visit: https://www.dynamsoft.com/customer/license/trialLicense?"
            for item in results! {
                if results!.first!.exception != nil && results!.first!.exception!.contains(msg) {
                    msgText = "\(msg)product=dbr&utm_source=installer&package=ios to request for 30 days extension."
                    title = "Exception"
                    break
                }
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
