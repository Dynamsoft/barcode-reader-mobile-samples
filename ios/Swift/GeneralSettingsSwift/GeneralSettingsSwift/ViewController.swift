//
//  ViewController.swift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DMDLSLicenseVerificationDelegate, DBRTextResultDelegate {
    
    var scanLine: UIImageView = UIImageView()
    var scanLineTimer: Timer?
    var resultView:UITextView!
    var SafeAreaBottomHeight:CGFloat = UIApplication.shared.statusBarFrame.size.height > 20 ? 34 : 0
    var mainHeight = UIScreen.main.bounds.height
    var mainWidth = UIScreen.main.bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is a sample that shows how to make GeneralSettings when using Dynamsoft Barcode Reader.
        configurationDBR()
        
        //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
        configurationDCE()
        
        configurationUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GeneralSettings.instance.dce.resume()
        scanLineTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(startSwipe), userInfo: nil, repeats: true)
        scanLineTimer?.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GeneralSettings.instance.dce.pause()
        self.scanLineTimer?.invalidate()
        self.scanLineTimer = nil
    }
    
    @objc func startSwipe(){
        if scanLine.frame.origin.y > mainHeight * 0.75 {
            scanLine.isHidden = true
            scanLine.frame = CGRect(x: 0, y: mainHeight * 0.25, width: mainWidth, height: 10)
        }else{
            scanLine.isHidden = false
            if scanLine.frame.origin.y < mainHeight * 0.4 {
                scanLine.alpha = 0.8
                scanLine.frame.origin.y += 1.5
            }else if scanLine.frame.origin.y > mainHeight * 0.6 {
                scanLine.alpha = 0.8
                scanLine.frame.origin.y += 1.5
            }else{
                scanLine.alpha = 1
                scanLine.frame.origin.y += 1.8
            }
        }
    }
    
    func configurationDBR() {
        let lts = iDMDLSConnectionParameters()
        // Initialize license for Dynamsoft Barcode Reader.
        // The organization id 200001 here will grant you a time-limited public trial license. Note that network connection is required for this license to work.
        // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
        // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
        lts.organizationID = "200001"
        GeneralSettings.instance.dbr = DynamsoftBarcodeReader(licenseFromDLS: lts, verificationDelegate: self)
        GeneralSettings.instance.isContinueScan = true
        GeneralSettings.instance.runtimeSettings = try? GeneralSettings.instance.dbr.getRuntimeSettings()
    }
    
    func configurationDCE() {
        var barHeight = self.navigationController?.navigationBar.frame.height
        if UIApplication.shared.statusBarFrame.size.height <= 20 {
            barHeight = 20
        }
        //Initialize a camera view for previewing video.
        GeneralSettings.instance.dceView = DCECameraView.init(frame: CGRect(x: 0, y: barHeight!, width: mainWidth, height: mainHeight - SafeAreaBottomHeight - barHeight!))

        // Enable overlay visibility to highlight the recognized barcode results.
        GeneralSettings.instance.dceView.overlayVisible = true
        self.view.addSubview(GeneralSettings.instance.dceView)
        
        GeneralSettings.instance.dce = DynamsoftCameraEnhancer.init(view: GeneralSettings.instance.dceView)
        GeneralSettings.instance.dce.open()

        GeneralSettings.instance.dbr.setCameraEnhancer(GeneralSettings.instance.dce)
        GeneralSettings.instance.dbr.setDBRTextResultDelegate(self, userData: nil)
        GeneralSettings.instance.dbr.startScanning()
    }
    
    func addResultView(){
        let viewHeight:CGFloat = 300
        resultView = UITextView(frame: CGRect(x: 0, y: mainHeight  - SafeAreaBottomHeight - viewHeight , width: self.view.frame.width, height: viewHeight ))
        resultView.layer.borderColor = UIColor.white.cgColor
        resultView.layer.borderWidth = 1.0
        resultView.layer.cornerRadius = 12.0
        resultView.layer.backgroundColor = UIColor.clear.cgColor
        resultView.layoutManager.allowsNonContiguousLayout = false
        resultView.isEditable = false
        resultView.isSelectable = false
        resultView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        resultView.textColor = UIColor.white
        resultView.textAlignment = .center
        resultView.isHidden = true
        self.view.addSubview(resultView)
    }
    
    @objc func clickSettingsButton(){
        self.performSegue(withIdentifier: "ShowMainSettings", sender: nil)
    }
    
    func configurationUI() {
        let rightBarBtn = UIBarButtonItem(title: "", style: .plain, target: self,action: #selector(clickSettingsButton))
        rightBarBtn.image = UIImage(named: "icon_setting")
        self.navigationItem.rightBarButtonItem = rightBarBtn
        addResultView()
        scanLine = UIImageView(frame: CGRect(x: 0, y: mainHeight * 0.25, width: mainWidth, height: 10))
        scanLine.image = UIImage(named: "icon_scanline")
        self.view.addSubview(scanLine)
    }
    
    func dlsLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        self.verificationCallback(isSuccess, error: error)
    }

    func verificationCallback(_ isSuccess: Bool, error: Error?) {
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
    
    // Obtain the barcode results from the callback and display the results.
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
            
            if GeneralSettings.instance.isContinueScan {
                var viewText:String = "\("Total Result(s):") \(results?.count ?? 0)"
                for res in results! {
                    if res.barcodeFormat_2.rawValue != 0 {
                        viewText = viewText + "\n\("Format:") \(res.barcodeFormatString_2!) \n\("Text:") \(res.barcodeText ?? "None")\n"
                    }else{
                        viewText = viewText + "\n\("Format:") \(res.barcodeFormatString!) \n\("Text:") \(res.barcodeText ?? "None")\n"
                    }
                }
                DispatchQueue.main.async{
                    self.resultView.isHidden = false
                    self.resultView.text = viewText
                }
            }else{
                showResult(title, msgText, "OK") {
                }
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
