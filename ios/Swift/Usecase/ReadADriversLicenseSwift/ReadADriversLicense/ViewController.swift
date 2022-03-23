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
    }
    
    // Get the TestResult object from the callback
    func textResultCallback(_ frameId: Int, imageData: iImageData, results: [iTextResult]?) {
        if results!.count > 0 {
            var isDriverLicense:Bool = false
            if results!.first!.barcodeFormatString == "PDF417"{
                isDriverLicense = true
            }else{
                isDriverLicense = false
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
                    self.addBack()
                    self.dce.resume()
                }
                
            }else{
                var msgText:String = ""
                let title:String = "Results"
                if results!.first!.barcodeFormat_2.rawValue != 0 {
                    msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", results!.first!.barcodeFormatString_2!, results!.first!.barcodeText ?? "noResuslt")
                }else{
                    msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", results!.first!.barcodeFormatString!, results!.first!.barcodeText ?? "noResuslt")
                }
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
