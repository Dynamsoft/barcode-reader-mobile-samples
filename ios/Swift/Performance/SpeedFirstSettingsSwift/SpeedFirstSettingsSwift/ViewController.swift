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
        
        //This is a sample that shows how to make settings to reach the SpeedFirstSettings when using Dynamsoft Barcode Reader.
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
        // LocalizationModes       : LM_ONED_FAST_SCAN is the fastest localization mode for ONED barcodes. For more barcode formats please use LM_SCAN_DIRECTLY Localizes barcodes quickly.
        // ScanDirection           : default value is 0, which means the barcode scanner will scan both vertical and horizontal directions. Read more about localization mode members: https://www.dynamsoft.com/barcode-reader/parameters/enum/parameter-mode-enums.html?ver=latest#localizationmode
        // BarcodeFormatIds        : The simpler barcode format, the faster decoding speed.
        // ExpectedBarcodesCount   : The less barcode count, the faster decoding speed.
        // EnableFillBinaryVacancy : Binarization process might cause vacant area in barcode. The barcode reader will fill the vacant black by default (default value 1). Set the value 0 to disable this process.
        // DeblurModes             : DeblurModes will improve the readability and accuracy but decrease the reading speed. DeblurMode is skipped by default. Please update your settings here is you want to enable Deblur mode.
        let json = "{\"ImageParameter\":{\"BarcodeFormatIds\":[\"BF_ALL\"],\"BinarizationModes\":[{\"BlockSizeX\":0,\"BlockSizeY\":0,\"EnableFillBinaryVacancy\":0,\"Mode\":\"BM_LOCAL_BLOCK\"}],\"DeblurModes\":[{\"LibraryFileName\":\"\",\"LibraryParameters\":\"\",\"Mode\":\"DM_BASED_ON_LOC_BIN\"},{\"LibraryFileName\":\"\",\"LibraryParameters\":\"\",\"Mode\":\"DM_THRESHOLD_BINARIZATION\"}],\"ExpectedBarcodesCount\":1,\"LocalizationModes\":[{\"Mode\":\"LM_ONED_FAST_SCAN\",\"ScanDirection\":0}],\"Name\":\"SpeedFirstSettings\",\"ScaleDownThreshold\":1200,\"Timeout\":500},\"Version\":\"3.0\"}"
        barcodeReader.initRuntimeSettings(with: json, conflictMode: .overwrite, error: &error)
    }
    
    func configurationDCE() {
        // Initialize a camera view for previewing video.
        dceView = DCECameraView.init(frame: self.view.bounds)

        // Enable overlay visibility to highlight the recognized barcode results.
        dceView.overlayVisible = true
        self.view.addSubview(dceView)

        // Initialize license for Dynamsoft Camera Enhancer.
        // The string "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" here is a 7-day free license. Note that network connection is required for this license to work.
        // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dce&utm_source=installer&package=ios.
        DynamsoftCameraEnhancer.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
        dce = DynamsoftCameraEnhancer.init(view: dceView)
        dce.open()
		
		var error : NSError? = NSError()
        //Fast mode is the feature of Dynamsoft Camera Enhancer. It will improve the barcode scanning efficiency of Dynamsoft barcode reader. Read more about Dynamsoft Camera Enhancer.
        dce.enableFeatures(EnumEnhancerFeatures.EnumFAST_MODE.rawValue,error: &error)

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
