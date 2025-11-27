/*
 * This is the sample of Dynamsoft Capture Vision Router.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class CameraViewController: UIViewController, CapturedResultReceiver, LicenseVerificationListener {

    private var cvr: CaptureVisionRouter!
    private var dce: CameraEnhancer!
    private var dceView: CameraView!
    
    private var driveLicenseTemplate = "ReadDriversLicense"
    private var isExistRecognizedText = false
    
    private lazy var resultView: UITextView = {
        let left = 0.0
        let width = self.view.bounds.size.width
        let height = self.view.bounds.size.height / 2.5
        let top = self.view.bounds.size.height - height
        
        let resultView = UITextView(frame: CGRect(x: left, y: top , width: width, height: height))
        resultView.layer.backgroundColor = UIColor.clear.cgColor
        resultView.layoutManager.allowsNonContiguousLayout = false
        resultView.isUserInteractionEnabled = false
        resultView.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        resultView.textColor = UIColor.white
        resultView.textAlignment = .center
        return resultView
    }()
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "DriversLicenseScanner"
        setLicense()
        configureCVR()
        configureDCE()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 59.003 / 255.0, green: 61.9991 / 255.0, blue: 69.0028 / 255.0, alpha: 1)
        
        dce.open()
        cvr.startCapturing(driveLicenseTemplate) {
            [unowned self] isSuccess, error in
            if let error = error {
                self.displayError(msg: error.localizedDescription)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dce.close()
        cvr.stopCapturing()
        dce.clearBuffer()
    }
}

// MARK: - Config.
extension CameraViewController {
    private func configureCVR() -> Void {
        cvr = CaptureVisionRouter()
        cvr.addResultReceiver(self)
    }
    
    private func configureDCE() -> Void {
        dceView = CameraView(frame: CGRect(x: 0, y: kNavigationBarFullHeight, width: kScreenWidth, height: kScreenHeight - kNavigationBarFullHeight))
        dceView.scanLaserVisible = true
        self.view.addSubview(dceView)
        
        let dbrDrawingLayer = dceView.getDrawingLayer(DrawingLayerId.DBR.rawValue)
        dbrDrawingLayer?.visible = true
        dce = CameraEnhancer(view: dceView)
        
        // CVR link DCE.
        try? cvr.setInput(dce)
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(resultView)
    }
}

// MARK: LicenseVerificationListener
extension CameraViewController {
    private func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=cvs&utm_source=samples&package=ios
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
}

// MARK: - CapturedResultReceiver
extension CameraViewController {
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        guard let items = result.items else {
            isExistRecognizedText = false
            return
        }

        isExistRecognizedText = true
        Feedback.vibrate()
        Feedback.beep()
        
        DispatchQueue.main.async{
            self.resultView.text = items.first!.text
        }
    }

    func onParsedResultsReceived(_ result: ParsedResult) {
        guard let items = result.items else {
            if isExistRecognizedText == true {
                DispatchQueue.main.async {
                    self.resultView.text = parseFailedTip + self.resultView.text
                }
            }
            return
        }
        
        let (isLegal, tip) = determineWhetherParsedItemIsLegal(parsedItem: items.first!)
        
        if isLegal == true {
            cvr.stopCapturing()
            dce.clearBuffer()
        }
        
        DispatchQueue.main.async {
            if isLegal == true {
                self.resultView.text = self.resultView.text.replacingOccurrences(of: parseFailedTip, with: "")
                let resultVC = DriverLicenseResultViewController()
                resultVC.driverLicenseResultItem = items.first!
                self.navigationController?.pushViewController(resultVC, animated: true)
            } else {
                self.resultView.text = tip
            }
        }
    }
}

// MARK: - General methods.
extension CameraViewController {
    func determineWhetherParsedItemIsLegal(parsedItem: ParsedResultItem) -> (Bool, String) {
        let allKeys = parsedItem.parsedFields.keys
        var isLegal = false
        var tip = ""
        switch parsedItem.codeType {
        case DriverLicenseType.AAMVA_DL_ID.rawValue:
            if (allKeys.contains("lastName") ||
                allKeys.contains("givenName") ||
                allKeys.contains("firstName") ||
                allKeys.contains("fullName")) &&
                allKeys.contains("licenseNumber") {
                isLegal = true
            } else {
                isLegal = false
                tip = parsedContentDeficiencyTip
            }
            break
        case DriverLicenseType.AAMVA_DL_ID_WITH_MAG_STRIPE.rawValue:
            if  allKeys.contains("name") &&
                allKeys.contains("DLorID_Number") {
                isLegal = true
            } else {
                isLegal = false
                tip = parsedContentDeficiencyTip
            }
            break
        case DriverLicenseType.SOUTH_AFRICA_DL.rawValue:
            if  allKeys.contains("surname") &&
                allKeys.contains("idNumber") {
                isLegal = true
            } else {
                isLegal = false
                tip = parsedContentDeficiencyTip
            }
            break
        default:
            break
        }
        return (isLegal, tip)
    }
    
    private func displayError(_ title: String = "", msg: String, _ acTitle: String = "OK", completion: ConfirmCompletion? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
