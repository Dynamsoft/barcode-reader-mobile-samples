//
//  ViewController.swift
//  PerformanceSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, UITableViewDataSource,  UITableViewDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, DMDLSLicenseVerificationDelegate, DBRTextResultDelegate, DCELicenseVerificationListener{
    
    var SafeAreaBottomHeight:CGFloat = UIApplication.shared.statusBarFrame.size.height > 20 ? 34 : 0
    var mainHeight = UIScreen.main.bounds.height
    var mainWidth = UIScreen.main.bounds.width
    var isSpeed:Bool = false
    let tableDataArr = ["Single Barcode", "Speed First", "Read Rate First", "Accuracy First"]
    var picButton:UIButton! = UIButton()
    var tableView:UITableView!
    var scanLine: UIImageView = UIImageView()
    var scanLineTimer: Timer?
    var resultView:UITextView!
    var loadingView:UIActivityIndicatorView!
    var sourceType:UIImagePickerController.SourceType!
    var dce:DynamsoftCameraEnhancer! = nil
    var dceView:DCECameraView! = nil
    var barcodeReader:DynamsoftBarcodeReader! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This is a sample that shows how to reach the AccuracyFirstSettings when using Dynamsoft Barcode Reader.
        configurationDBR()
        
        //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
        configurationDCE()
        
        configurationUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dce.resume()
        scanLineTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(startSwipe), userInfo: nil, repeats: true)
        scanLineTimer?.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dce.pause()
        self.scanLineTimer?.invalidate()
        self.scanLineTimer = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid = "cellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid)
        if cell==nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellid)
        }
        cell?.backgroundColor = .clear
        cell?.selectionStyle = .gray
        cell?.textLabel?.text = self.tableDataArr[indexPath.row]
        switch(indexPath.row)
        {
        case 0:
            self.addQuestionBtn(cell:cell!, idx: 0, leftMargin: 150)
        case 1:
            self.addQuestionBtn(cell:cell!, idx: 1, leftMargin: 150)
        case 2:
            self.addQuestionBtn(cell:cell!, idx: 2, leftMargin: 150)
        case 3:
            self.addQuestionBtn(cell:cell!, idx: 3, leftMargin: 150)
        default:
            break
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func selectTemplate(index:Int){
        var error : NSError? = NSError()
        switch(index)
        {
        case 0:
            barcodeReader.updateRuntimeSettings(EnumPresetTemplate.videoSingleBarcode)
            dce.setScanRegion(nil, error: nil)
        case 1:
            isSpeed = true
            setDecodeTemplate(index: 1, isImage: false)
        case 2:
            isSpeed = false
            setDecodeTemplate(index: 2, isImage: false)
        case 3:
            barcodeReader.resetRuntimeSettings(&error)
            let settings = try? barcodeReader.getRuntimeSettings()
            settings!.barcodeFormatIds = EnumBarcodeFormat.ALL.rawValue
            settings!.minResultConfidence = 30
            settings!.minBarcodeTextLength = 6
            let deblurModes = [EnumDeblurMode.basedOnLocBin.rawValue,EnumDeblurMode.thresholdBinarization.rawValue]
            settings!.deblurModes = deblurModes
            barcodeReader.update(settings!, error: &error)
            barcodeReader.enableResultVerification = true
            dce.enableFeatures(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue, error: &error)
            dce.setScanRegion(nil, error: nil)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTemplate(index: indexPath.row)
        if indexPath.row == 1 || indexPath.row == 2 {
            DispatchQueue.main.async{
                self.picButton.isHidden = false
            }
        }else{
            DispatchQueue.main.async{
                self.picButton.isHidden = true
            }
        }
    }
    
    func setDecodeTemplate(index:Int, isImage:Bool){
        var error : NSError? = NSError()
        if index == 1 {
            if isImage {
                barcodeReader.updateRuntimeSettings(EnumPresetTemplate.imageSpeedFirst)
                let settings = try? barcodeReader.getRuntimeSettings()
                settings!.barcodeFormatIds = EnumBarcodeFormat.ALL.rawValue
                settings!.expectedBarcodesCount = 0
                settings!.scaleDownThreshold = 2300
                barcodeReader.update(settings!, error: &error)
                dce.setScanRegion(nil, error: nil)
            }else{
                barcodeReader.updateRuntimeSettings(EnumPresetTemplate.videoSpeedFirst)
                let settings = try? barcodeReader.getRuntimeSettings()
                settings!.barcodeFormatIds = EnumBarcodeFormat.ALL.rawValue
                settings!.expectedBarcodesCount = 0
                settings!.scaleDownThreshold = 2300
                settings!.timeout = 500
                barcodeReader.update(settings!, error: &error)
                let region = iRegionDefinition.init()
                region.regionTop = 30
                region.regionBottom = 70
                region.regionLeft = 15
                region.regionRight = 85
                region.regionMeasuredByPercentage = 1
                dce.setScanRegion(region, error: &error)
            }
        }else if index == 2{
            if isImage {
                barcodeReader.updateRuntimeSettings(EnumPresetTemplate.imageReadRateFirst)
                let settings = try? barcodeReader.getRuntimeSettings()
                settings!.barcodeFormatIds = EnumBarcodeFormat.ALL.rawValue
                settings!.expectedBarcodesCount = 512
                settings!.scaleDownThreshold = 2300
                settings!.timeout = 10000
                barcodeReader.update(settings!, error: &error)
                dce.setScanRegion(nil, error: nil)
            }else{
                barcodeReader.updateRuntimeSettings(EnumPresetTemplate.videoReadRateFirst)
                let settings = try? barcodeReader.getRuntimeSettings()
                settings!.barcodeFormatIds = EnumBarcodeFormat.ALL.rawValue
                settings!.expectedBarcodesCount = 512
                settings!.scaleDownThreshold = 2300
                settings!.timeout = 5000
                barcodeReader.update(settings!, error: &error)
                dce.setScanRegion(nil, error: nil)
            }
        }
    }
    
    func configurationUI() {
        addResultView()
        addTableView()
        addLoadView()
        addPicButton()
        scanLine = UIImageView(frame: CGRect(x: 0, y: mainHeight * 0.25, width: mainWidth, height: 10))
        scanLine.image = UIImage(named: "icon_scanline")
        self.view.addSubview(scanLine)
    }
    
    func addLoadView(){
        loadingView = UIActivityIndicatorView(frame: CGRect(x: mainWidth / 2 - 25, y: mainHeight / 2 - 25, width: 50, height: 50))
        loadingView.center = self.view.center
        loadingView.activityIndicatorViewStyle = .gray
        self.view.addSubview(loadingView)
    }
    
    func addPicButton(){
        picButton = UIButton(frame: CGRect(x:mainWidth / 2 + 88, y:SafeAreaBottomHeight + 80, width: 65, height: 65))
        picButton.setImage(UIImage(named: "icon_picture"), for: .normal)
        picButton.addTarget(self, action: #selector(selectPic), for: .touchUpInside)
        picButton.isHidden = true
        self.view.addSubview(self.picButton)
        self.view.insertSubview(self.picButton, belowSubview: self.loadingView)
    }
    
    @objc func selectPic(){
        barcodeReader.stopScanning()
        self.getAlertActionType(1)
    }
    
    
    func getAlertActionType(_ t:Int){
        var type:UIImagePickerControllerSourceType = .photoLibrary
        if (t == 1) {
            type = .photoLibrary
        }else if (t == 2) {
            type = .camera
        }
        sourceType = type
        let cameragranted:Int = self.AVAuthorizationStatusIsGranted()
        if cameragranted == 0 {
            let alertController = UIAlertController(title: "Tips", message: "Settings-Privacy-Camera/Album-Authorization", preferredStyle: .alert)
            let comfirmAction = UIAlertAction(title: "OK", style: .default) { ac in
                let url:URL = URL(fileURLWithPath: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url) { UIApplication.shared.openURL(url) }
            }
            alertController.addAction(comfirmAction)
            self.present(alertController, animated: true, completion: nil)
        }else if cameragranted == 1 {
            self.presentPickerViewController()
        }
    }
    
    func AVAuthorizationStatusIsGranted() -> Int{
        let mediaType:AVMediaType = .video
        let authStatusVideo:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        let authStatusAlbm:PHAuthorizationStatus = .authorized
        let authStatus:Int = sourceType == UIImagePickerControllerSourceType.photoLibrary ? authStatusAlbm.rawValue : authStatusVideo.rawValue
        switch authStatus {
        case 0:
            if sourceType == UIImagePickerControllerSourceType.photoLibrary {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        self.presentPickerViewController()
                    }
                }
            }else{
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.presentPickerViewController()
                    }
                }
            }
            return 2
        case 1: return 0
        case 2: return 0
        case 3: return 1
        default:
            return 0
        }
    }
    
    func presentPickerViewController(){
        let picker = UIImagePickerController()
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .always
        }
        picker.delegate = self
        picker.sourceType = self.sourceType
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.decodeByBuffer(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func decodeByBuffer(image:UIImage){
        self.loadingView.startAnimating()
        if isSpeed {
            setDecodeTemplate(index: 1, isImage: true)
        }else{
            setDecodeTemplate(index: 2, isImage: true)
        }
        let results = try! self.barcodeReader.decode(image, withTemplate: "")
        self.handresults(results: results)
    }
    
    func configurationDBR() {
        let dls = iDMDLSConnectionParameters()
        // Initialize license for Dynamsoft Barcode Reader.
        // The organization id 200001 here will grant you a public trial license good for 7 days. Note that network connection is required for this license to work.
        // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
        // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
        dls.organizationID = "200001"
        barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: dls, verificationDelegate: self)
    }
    
    func configurationDCE() {
        var barHeight = self.navigationController?.navigationBar.frame.height
        if UIApplication.shared.statusBarFrame.size.height <= 20 {
            barHeight = 20
        }
        //Initialize a camera view for previewing video.
        dceView = DCECameraView.init(frame: CGRect(x: 0, y: barHeight!, width: mainWidth, height: mainHeight - SafeAreaBottomHeight - barHeight!))

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
        
        barcodeReader.setCameraEnhancer(dce)
        barcodeReader.setDBRTextResultDelegate(self, userData: nil)
        barcodeReader.startScanning()
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
            return
        }
    }
    
    func handresults(results: [iTextResult]?) {
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
            showResult(title, msgText, "OK") { self.loadingView.stopAnimating()
            }
        }else{
            showResult("No result", "", "OK") { self.loadingView.stopAnimating()
            }
        }
    }
    
    @objc func clickQuestionBtn(_ sender:UIButton)
    {
        var title = ""
        var msg = ""
        switch(sender.tag)
        {
        case 0:
            title = "Single Barcode Scanning"
            msg = "You can optimize the performance of single barcode reading by selecting single barcode template. ."
        case 1:
            title = "Speed First Settings"
            msg = "You can simply optimize the barcode reading speed by selecting speed first template.You can still add your personalized settings to further improve the performance. "
        case 2:
            title = "Read Rate First Template"
            msg = "You can simply optimize the barcode read rate by selecting read rate first template. You can still add your personalized settings to further improve the performance. "
        case 3:
            title = "Accuracy First Template"
            msg = "In addition to the general accuracy settings, you can add your personalized configurations to further improve the accuracy."
        default:
            title = ""
            msg = ""
        }
        let alertCntrllr = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alrtActn = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
        }
        alertCntrllr.addAction(alrtActn)
        self.present(alertCntrllr, animated: true, completion: nil)
    }
    
    func addQuestionBtn(cell:UITableViewCell,idx:Int,leftMargin:CGFloat)
    {
        let pi = SettingsCommon.getQuestionBtn(cell: cell, leftMargin: leftMargin)
        pi.tag = idx
        pi.addTarget(self, action:#selector(clickQuestionBtn(_:)), for:.touchUpInside)
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
    
    func addTableView(){
        var barHeight = self.navigationController?.navigationBar.frame.height
        if UIApplication.shared.statusBarFrame.size.height <= 20 {
            barHeight = 20
        }
        tableView = UITableView.init(frame: CGRect(x: 0, y: barHeight!, width: 200, height: 200), style: .plain)
        tableView.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.5)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        tableView.delegate?.tableView!(tableView.self, didSelectRowAt: IndexPath(row: 0, section: 0))
    }
    
    private func showResult(_ title: String, _ msg: String, _ acTitle: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
            if self.isSpeed {
                self.setDecodeTemplate(index: 1, isImage: false)
            }else{
                self.setDecodeTemplate(index: 2, isImage: false)
            }
            self.barcodeReader.startScanning()
        }
    }
}
