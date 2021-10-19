//
//  ViewController.swift
//
//

import UIKit

class ViewController: UIViewController, DMDLSLicenseVerificationDelegate, DBRTextResultDelegate, DCELicenseVerificationListener{
    
    var dce:DynamsoftCameraEnhancer! = nil
    var dceView:DCECameraView! = nil
    var barcodeReader:DynamsoftBarcodeReader! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This is a sample that shows how to reach the AccuracyFirstSettings when using Dynamsoft Barcode Reader.
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
        // The organization id 200001 here will grant you a public trial license good for 7 days. Note that network connection is required for this license to work.
        // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
        // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
        dls.organizationID = "200001"
        barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: dls, verificationDelegate: self)
        
        var error : NSError? = NSError()
        
        // Mostly, misreading only occurs on reading oneD barcode.
        guard let settings = try?barcodeReader.getRuntimeSettings() else { return }

        // Here we set expected barcode count to 1.
        settings.expectedBarcodesCount = 1

        // Parameter 1. Set expected barcode format
        // The more precise the barcode format is set, the higher the accuracy.
        // Mostly, misreading only occurs on reading oneD barcode. So here we use OneD barcode format to demonstrate.
        settings.barcodeFormatIds = EnumBarcodeFormat.ONED.rawValue

        // Parameter 2. Set the minimal result confidence.
        // The greater the confidence, the higher the accuracy.
        // Filter by minimal confidence of the decoded barcode. We recommend using 30 as the default minimal confidence value
        settings.minResultConfidence = 30

        // Parameter 3. Sets the minimum length of barcode text for filtering.
        // The more precise the barcode text length is set, the higher the accuracy.
        settings.minBarcodeTextLength = 6

        // Apply the new settings to the instance
        barcodeReader.update(settings, error: &error)

        // Enable result verification for video barcode reading.
        // After the result verification is turned on, the SDK will verify the result among multiple video frames.
        barcodeReader.enableResultVerification = true
    }
    
    func configurationDCE() {
        //Initialize a camera view for previewing video.
        dceView = DCECameraView.init(frame: self.view.bounds)

        // Enable overlay visibility to highlight the recognized barcode results.
        dceView.overlayVisible = true
        self.view.addSubview(dceView)

        // Initialize license for Dynamsoft Camera Enhancer.
        // The string "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" here is a 7-day free license. Note that network connection is required for this license to work.
        // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dce&utm_source=installer&package=ios
        DynamsoftCameraEnhancer.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
        dce = DynamsoftCameraEnhancer.init(view: dceView)
        dce.open()
    
		var error : NSError? = NSError()
        //Frame filter is the feature of Dynamsoft Camera Enhancer. It will improve the barcode scanning accuracy of Dynamsoft barcode reader. Read more about Dynamsoft Camera Enhancer.
        dce.enableFeatures(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue,error: &error)
        
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
        self.verificationCallback(error: error)
    }
    
    func dceLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        self.verificationCallback(error: error)
    }
    
    func verificationCallback(error: Error?){
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
    
    // Get the TestResult object from the callback
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
