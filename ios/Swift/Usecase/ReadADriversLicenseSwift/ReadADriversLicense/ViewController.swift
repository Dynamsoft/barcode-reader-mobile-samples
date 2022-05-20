//
//  ViewController.swift
//
//

import UIKit

let FullScreenSize                  = UIScreen.main.bounds
var FullScreenSizeWidth             = UIScreen.main.bounds.width
var FullScreenSizeHeight            = UIScreen.main.bounds.height
var NavigationH: CGFloat            = 44
var StatusH: CGFloat                = UIApplication.shared.statusBarFrame.size.height
var SafeAreaBottomHeight:CGFloat    = StatusH > 20 ? 34 : 0
let kFootViewHeight:CGFloat         = 44
let KeyWindow                       = UIApplication.shared.keyWindow

class ViewController: UIViewController, DBRTextResultListener, CompleteDelegate {

    var dce:DynamsoftCameraEnhancer! = nil
    var dceView:DCECameraView! = nil
    var alertView:DBRPopDrivingLicenseView! = nil
    var resultView:UITextView!
    var barcodeReader:DynamsoftBarcodeReader! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is a sample that illustrates how to quickly set up a video barcode scanner with Dynamsoft Barcode Reader.
        configurationDBR()
        
        //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
        configurationDCE()
        
        addResultView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configurationDBR() {
        barcodeReader = DynamsoftBarcodeReader.init()
        let settings = try? barcodeReader.getRuntimeSettings()
        settings!.barcodeFormatIds = EnumBarcodeFormat.PDF417.rawValue
        settings!.expectedBarcodesCount = 1
        try? barcodeReader.updateRuntimeSettings(settings!)
    }
    
    func configurationDCE() {
        dceView = DCECameraView.init(frame: self.view.bounds)
        dceView.overlayVisible = true
        self.view.addSubview(dceView)
        dce = DynamsoftCameraEnhancer.init(view: dceView)
        dce.open()
    
        barcodeReader.setCameraEnhancer(dce)
        barcodeReader.setDBRTextResultListener(self)
        barcodeReader.startScanning()
    }
    
    func addResultView(){
        let viewHeight:CGFloat = 300
        resultView = UITextView(frame: CGRect(x: 0, y: FullScreenSizeHeight  - SafeAreaBottomHeight - viewHeight , width: self.view.frame.width, height: viewHeight ))
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
    
    // Get the TestResult object from the callback
    func textResultCallback(_ frameId: Int, imageData: iImageData, results: [iTextResult]?) {
        if results!.count > 0 {
            var isDriverLicense:Bool = false
            let dropfirst:Substring = results!.first!.barcodeText!.dropFirst(4)
            let prefix = dropfirst.prefix(15)
            let subString = prefix.dropFirst(5)
            let rules = NSPredicate(format: "SELF MATCHES %@", "^[0-9]{10}$")
            let isMatch:Bool = rules.evaluate(with: subString)
            let preMatch:Bool = prefix.hasPrefix("AAMVA") || prefix.hasPrefix("ANSI ")
            if isMatch && preMatch{
                isDriverLicense = true
            }

            if isDriverLicense {
                var type:[String] = []
                var typeDes:[String] = []
                type.append(String(results!.first!.barcodeFormat.rawValue))
                typeDes.append(results!.first!.barcodeFormatString!)
                let barcodeData = BarcodeData(type: type,
                                              typeDes: typeDes,
                                              text: results!.map({$0.barcodeText!}),
                                              time: String("0"))
                DispatchQueue.main.async{
                    let tFrm =  CGRect(x: 0, y: StatusH + NavigationH, width: FullScreenSizeWidth, height: FullScreenSizeHeight - StatusH - NavigationH)
                    self.alertView = DBRPopDrivingLicenseView(frame: tFrm, barcodeResults: barcodeData)
                    self.alertView.completeDelegate = self
                    self.alertView.show(animate: false)
//                    self.addBack()
                    self.dce.resume()
                }
                
            }else{
                var msgText:String = "Fail to extract the driver's info.The text of the barcode is:"
                if results!.first!.barcodeFormat_2.rawValue != 0 {
                    msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", results!.first!.barcodeFormatString_2!, results!.first!.barcodeText ?? "noResuslt")
                }else{
                    msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", results!.first!.barcodeFormatString!, results!.first!.barcodeText ?? "noResuslt")
                }
                DispatchQueue.main.async{
                    self.resultView.isHidden = false
                    self.resultView.text = msgText
                }
            }
            
        }else{
            DispatchQueue.main.async{
                self.resultView.isHidden = true
                self.resultView.text = nil
            }
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
    
    func addBack(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .reply, target: self, action: #selector(backToHome))
    }
    
    @objc func backToHome(){
        self.navigationItem.leftBarButtonItem = nil
        self.alertView.hide(animate: false)
    }
    
    func complete() {
    }
    
    func clickFinishBtn() {
    }
}
