//
//  ViewController.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DBRTextResultListener {
    
    var scanLineImageV: UIImageView!
    var resultView:UITextView!
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 59.003 / 255.0, green: 61.9991 / 255.0, blue: 69.0028 / 255.0, alpha: 1)
        
        GeneralSettings.shared.cameraEnhancer.open()
        GeneralSettings.shared.barcodeReader.startScanning()
        
        self.scanLineTurnOn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        GeneralSettings.shared.cameraEnhancer.close()
        GeneralSettings.shared.barcodeReader.stopScanning()
        GeneralSettings.shared.cameraEnhancer.turnOffTorch()
        
        self.scanlineTurnOff()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "General Settings"
        
        configureDefaultDBR()
        configureDefaultDCE()
        setupUI()
        GeneralSettings.shared.setDefaultData()
        
        // Register Notification.
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func configureDefaultDBR() -> Void {
        GeneralSettings.shared.barcodeReader = DynamsoftBarcodeReader.init()
        GeneralSettings.shared.barcodeReader.setDBRTextResultListener(self)
        
        GeneralSettings.shared.ipublicRuntimeSettings = try? GeneralSettings.shared.barcodeReader.getRuntimeSettings()
    }
    
    func configureDefaultDCE() -> Void {
        GeneralSettings.shared.cameraView = DCECameraView.init(frame: CGRect(x: 0, y: kNaviBarAndStatusBarHeight, width: kScreenWidth, height: kScreenHeight - kNaviBarAndStatusBarHeight))
        GeneralSettings.shared.cameraView.overlayVisible = true;
        self.view.addSubview(GeneralSettings.shared.cameraView)
        
        GeneralSettings.shared.cameraEnhancer = DynamsoftCameraEnhancer(view: GeneralSettings.shared.cameraView)
        
        // DBR link DCE
        GeneralSettings.shared.barcodeReader.setCameraEnhancer(GeneralSettings.shared.cameraEnhancer)
    }

    func setupUI() -> Void {
        let settingItem = UIBarButtonItem.init(image: UIImage(named: "icon_setting"), style: .plain, target: self, action: #selector(jumpToSetting(_:)))
        self.navigationItem.rightBarButtonItem = settingItem
        
        self.scanLineImageV = UIImageView.init(frame: CGRect(x: (kScreenWidth - kScanLineWidth) / 2.0, y: kNaviBarAndStatusBarHeight + 50, width: kScanLineWidth, height: 10))
        self.scanLineImageV.image = UIImage.init(named: "scan_line")
        self.view.addSubview(self.scanLineImageV)
        
        let viewHeight:CGFloat = kScreenHeight / 3.0
        resultView = UITextView(frame: CGRect(x: 0, y: kScreenHeight  - kTabBarAreaHeight - viewHeight , width: kScreenWidth, height: viewHeight))
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
        resultView.isHidden = false
        self.view.addSubview(resultView)
    }
    
    @objc func jumpToSetting(_ item: UIBarButtonItem) -> Void {
        let settingVC = SettingsViewController()
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    func scanLineTurnOn() -> Void {
        
        let scanLineTransform3D = CATransform3DMakeTranslation(0, kScreenHeight - kNaviBarAndStatusBarHeight - kTabBarHeight - 100, 0)
        let scanLineAnimation = CABasicAnimation.init(keyPath: "transform")
        scanLineAnimation.toValue = scanLineTransform3D
        scanLineAnimation.duration = 2.0
        scanLineAnimation.repeatCount = 999
        self.scanLineImageV.layer.add(scanLineAnimation, forKey: "scanLine")
    }
    
    func scanlineTurnOff() -> Void {
        DispatchQueue.main.async {
            self.scanLineImageV.layer.removeAllAnimations()
        }
    }
    
    // MARK: - DBRTextResultDelegate
    // Obtain the barcode results from the callback and display the results.
    func textResultCallback(_ frameId: Int, imageData: iImageData, results: [iTextResult]?) {
        if (results != nil) {
            guard results!.count != 0 else {
                return
            }
            // Vibrate.
            if (GeneralSettings.shared.cameraSettings.dceVibrateIsOpen == true) {
                DCEFeedback.vibrate()
            }
            
            // Beep.
            if (GeneralSettings.shared.cameraSettings.dceBeepIsOpen == true) {
                DCEFeedback.beep()
            }
            
            // Parse Results.
            if (GeneralSettings.shared.barcodeSettings.continuousScanIsOpen == true) {
                var viewText:String = "\("Total Result(s):") \(results?.count ?? 0)"
                for res in results! {
                    viewText = viewText + "\n\("Format:") \(res.barcodeFormatString!) \n\("Text:") \(res.barcodeText ?? "None")\n"
                }
                
                DispatchQueue.main.async{
                    self.resultView.isHidden = false
                    self.resultView.text = viewText
                }
            } else {
                GeneralSettings.shared.barcodeReader.stopScanning()
                var msgText:String = ""
                let title:String = "Results"
                for item in results! {
                    msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", item.barcodeFormatString!,item.barcodeText ?? "No Resuslt")
                }
                
                showSingleResult(title, msgText, "OK") {
                    GeneralSettings.shared.barcodeReader.startScanning()
                }
            }
        
        }
    }
    
    private func showSingleResult(_ title: String, _ msg: String, _ acTitle: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.resultView.isHidden = true
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Notification
    @objc private func appEnterForeground(_ noti: Notification) -> Void {
        self.scanLineTurnOn()
    }
    
    // MARK: - Notification
    @objc private func appEnterBackground(_ noti: Notification) -> Void {
        self.scanlineTurnOff()
    }

}

