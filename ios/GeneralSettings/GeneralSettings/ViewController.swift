/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftBarcodeReader
import DynamsoftCameraEnhancer
import DynamsoftCaptureVisionRouter
import DynamsoftLicense

class ViewController: UIViewController, CapturedResultReceiver, LicenseVerificationListener {

    var scanLineImageV: UIImageView!
    var resultView:UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 59.003 / 255.0, green: 61.9991 / 255.0, blue: 69.0028 / 255.0, alpha: 1)
        
        GeneralSettings.shared.dce.open()
        GeneralSettings.shared.cvr.startCapturing(PresetTemplate.readBarcodes.rawValue) {
            [unowned self] isSuccess, error in
            if let error = error {
                self.displayError(msg: error.localizedDescription)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GeneralSettings.shared.dce.close()
        GeneralSettings.shared.cvr.stopCapturing()
        GeneralSettings.shared.dce.clearBuffer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "General Settings"
        setLicense()
        configureCVR()
        configureDCE()
        setupUI()
        GeneralSettings.shared.setDefaultData()
    }
    
    private func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    private func displayLicenseMessage(message: String) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func configureCVR() -> Void {
        GeneralSettings.shared.cvr = CaptureVisionRouter()
        GeneralSettings.shared.cvr.addResultReceiver(self)
    }
    
    private func configureDCE() -> Void {
        GeneralSettings.shared.dceView = CameraView(frame: CGRect(x: 0, y: kNavigationBarFullHeight, width: kScreenWidth, height: kScreenHeight - kNavigationBarFullHeight))
        GeneralSettings.shared.dce = CameraEnhancer(view: GeneralSettings.shared.dceView)
        self.view.addSubview(GeneralSettings.shared.dceView)
        
        // CVR link DCE.
        try? GeneralSettings.shared.cvr.setInput(GeneralSettings.shared.dce)
    }
    
    private func setupUI() -> Void {
        let settingItem = UIBarButtonItem.init(image: UIImage(named: "icon_setting"), style: .plain, target: self, action: #selector(jumpToSetting(_:)))
        self.navigationItem.rightBarButtonItem = settingItem
        
        let viewHeight:CGFloat = kScreenHeight / 2.0
        resultView = UITextView(frame: CGRect(x: 0, y: kScreenHeight  - kTabBarSafeAreaHeight - viewHeight , width: kScreenWidth, height: viewHeight))
        resultView.layer.borderColor = UIColor.white.cgColor
        resultView.layer.borderWidth = 1.0
        resultView.layer.cornerRadius = 12.0
        resultView.layer.backgroundColor = UIColor.clear.cgColor
        resultView.layoutManager.allowsNonContiguousLayout = false
        resultView.isEditable = false
        resultView.isSelectable = false
        resultView.isUserInteractionEnabled = false
        resultView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        resultView.textColor = UIColor.white
        resultView.textAlignment = .center
        resultView.isHidden = false
        self.view.addSubview(resultView)
    }
    
    @objc func jumpToSetting(_ item: UIBarButtonItem) -> Void {
        let settingVC = SettingsViewController()
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    // MARK: - CapturedResultReceiver
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        guard let items = result.items else {
            return
        }
        
        // Vibrate.
        if (GeneralSettings.shared.cameraSettings.dceVibrateIsOpen == true) {
            
            Feedback.vibrate()
        }
        
        // Beep.
        if (GeneralSettings.shared.cameraSettings.dceBeepIsOpen == true) {
            Feedback.beep()
        }
        
        // Parse Results.
        if (GeneralSettings.shared.barcodeSettings.continuousScanIsOpen == true) {
            var viewText:String = "\("Total Result(s):") \(items.count)"
            for barcodeRes in items {
                viewText = viewText + "\n\("Format:") \(barcodeRes.formatString) \n\("Text:") \(barcodeRes.text)\n"
            }
            
            DispatchQueue.main.async{
                self.resultView.isHidden = false
                self.resultView.text = viewText
            }
        } else {
            GeneralSettings.shared.cvr.stopCapturing()
            GeneralSettings.shared.dce.clearBuffer()
            var resultText:String = ""
            for barcodeRes in items {
                resultText = resultText + String(format:"\nFormat: %@\nText: %@\n", barcodeRes.formatString,barcodeRes.text)
            }
            
            displaySingleResult(String(format: "Results(%d)", items.count), resultText, "OK") {
                GeneralSettings.shared.cvr.startCapturing(PresetTemplate.readBarcodes.rawValue)
            }
        }
        
    }
    
    // MARK: LicenseVerificationListener
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if !isSuccess {
            if let error = error {
                print("\(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.displayLicenseMessage(message: "License initialization failed：" + error.localizedDescription)
                }
            }
        }
    }
    
    private func displaySingleResult(_ title: String, _ msg: String, _ acTitle: String, completion: ConfirmCompletion? = nil) {
        DispatchQueue.main.async {
            self.resultView.isHidden = true
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func displayError(_ title: String = "", msg: String, _ acTitle: String = "OK", completion: ConfirmCompletion? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

