/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class CameraViewController: UIViewController {

    var cameraView = CameraView()
    let dce = CameraEnhancer()
    let cvr = CaptureVisionRouter()
    var templateName = PresetTemplate.readBarcodesSpeedFirst.rawValue
    var isBeepOn = false
    var isVibrateOn = false
    let scanRegionOption:[Rect?] = [nil, Rect(left: 0.15, top: 0.2, right: 0.85, bottom: 0.6, measuredInPercentage: true),
                                    Rect(left: 0.05, top: 0.3, right: 0.95, bottom: 0.55, measuredInPercentage: true)]
    let resolutionOption:[Resolution] = [.resolution1080P, .resolution4K, .resolution720P]
    let filter = MultiFrameResultCrossFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Barcode Scanning"
        setLicense()
        setupDCV()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dce.open()
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        loadState()
        cvr.startCapturing(templateName) { isSuccess, error in
            if (!isSuccess) {
                if let error = error {
                    self.showResult("Error", error.localizedDescription)
                }
            }
        }
    }
    
    func loadState() {
        if let dict = UserDefaults.standard.value(forKey: kTemplateState) as? [String: Any],
            let name = dict["templateName"] as? String,
            let isUsingCustomizedTemplate = dict["isUsingCustomizedTemplate"] as? Bool {
            if isUsingCustomizedTemplate {
                if let path = kSettingFilePath?.path {
                    do {
                        try cvr.initSettingsFromFile(path)
                        templateName = name
                    } catch {
                        print(error)
                    }
                }
            } else {
                templateName = name
            }
        }
        
        let settings = try? cvr.getSimplifiedSettings(templateName)
        
        if let dict = UserDefaults.standard.value(forKey: kBarcodeFormatState) as? [String: Any], let rawValue = dict["BarcodeFormat"] as? UInt {
            let format = BarcodeFormat(rawValue: rawValue)
            settings?.barcodeSettings?.barcodeFormatIds = format
        }
        
        if let dict = UserDefaults.standard.value(forKey: kSimplifiedCaptureVisionSettingsState) as? [String: Any] {
            if let expectedBarcodesCount = dict[SimplifiedSettingsTag.expectedBarcodeCount.rawValue] as? UInt {
                settings?.barcodeSettings?.expectedBarcodesCount = expectedBarcodesCount
            }
            if let minResultConfidence = dict[SimplifiedSettingsTag.confidence.rawValue] as? UInt {
                settings?.barcodeSettings?.minResultConfidence = minResultConfidence
            }
            if let scaleDownThreshold = dict[SimplifiedSettingsTag.scaleDownThreshold.rawValue] as? Int {
                settings?.barcodeSettings?.scaleDownThreshold = scaleDownThreshold
            }
            if let barcodeTextRegExPattern = dict[SimplifiedSettingsTag.barcodeTextRegEx.rawValue] as? String {
                settings?.barcodeSettings?.barcodeTextRegExPattern = barcodeTextRegExPattern
            }
            if let minBarcodeTextLength = dict[SimplifiedSettingsTag.minTextLength.rawValue] as? UInt {
                settings?.barcodeSettings?.minBarcodeTextLength = minBarcodeTextLength
            }
            if let timeout = dict[SimplifiedSettingsTag.timeout.rawValue] as? Int {
                settings?.timeout = timeout
            }
            if let minImageCaptureInterval = dict[SimplifiedSettingsTag.minDecodeInterval.rawValue] as? Int {
                settings?.minImageCaptureInterval = minImageCaptureInterval
            }
            if let localizationModes = dict[SimplifiedSettingsTag.localization.rawValue] as? [NSNumber] {
                settings?.barcodeSettings?.localizationModes = localizationModes
            }
            if let deblur = dict[SimplifiedSettingsTag.deblur.rawValue] as? [NSNumber] {
                settings?.barcodeSettings?.deblurModes = deblur
            }
            if let transformation = dict[SimplifiedSettingsTag.transformation.rawValue] as? [NSNumber] {
                settings?.barcodeSettings?.grayscaleTransformationModes = transformation
            }
            if let enhancement = dict[SimplifiedSettingsTag.enhancement.rawValue] as? [NSNumber] {
                settings?.barcodeSettings?.grayscaleEnhancementModes = enhancement
            }
        }
        
        if let settings = settings {
            try? cvr.updateSettings(templateName, settings: settings)
        }
        
        if let dict = UserDefaults.standard.value(forKey: kOtherSettingsState) as? [String: Any] {
            if let multiFrameCrossVerification = dict[SimplifiedSettingsTag.multiFrameCrossVerification.rawValue] as? Bool {
                filter.enableResultCrossVerification(.barcode, isEnabled: multiFrameCrossVerification)
            }
            if let resultDeduplication = dict[SimplifiedSettingsTag.resultDeduplication.rawValue] as? Bool {
                filter.enableResultDeduplication(.barcode, isEnabled: resultDeduplication)
            }
            if let duplicateForgetTime = dict[SimplifiedSettingsTag.duplicateForgetTime.rawValue] as? Int {
                filter.setDuplicateForgetTime(.barcode, duplicateForgetTime: duplicateForgetTime)
            }
            if let toTheLatestOverlapping = dict[SimplifiedSettingsTag.toTheLatestOverlapping.rawValue] as? Bool {
                filter.enableLatestOverlapping(.barcode, isEnabled: toTheLatestOverlapping)
            }
            if let maxOverlappingFrameCount = dict[SimplifiedSettingsTag.maxOverlappingFrameCount.rawValue] as? Int {
                filter.setMaxOverlappingFrames(.barcode, maxOverlappingFrames: maxOverlappingFrameCount)
            }
            
            if let beep = dict[SimplifiedSettingsTag.beep.rawValue] as? Bool {
                isBeepOn = beep
            }
            if let vibrate = dict[SimplifiedSettingsTag.vibrate.rawValue] as? Bool {
                isVibrateOn = vibrate
            }
            if let selectIndex = dict[SimplifiedSettingsTag.scanRegion.rawValue] as? Int {
                try? dce.setScanRegion(scanRegionOption[selectIndex])
            }
            if let selectIndex = dict[SimplifiedSettingsTag.resolution.rawValue] as? Int {
                dce.setResolution(resolutionOption[selectIndex])
            }
            if let autoZoom = dict[SimplifiedSettingsTag.autoZoom.rawValue] as? Bool {
                if autoZoom {
                    dce.enableEnhancedFeatures(.autoZoom)
                } else {
                    dce.disableEnhancedFeatures(.autoZoom)
                }
            }
        }
        cvr.addResultFilter(filter)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dce.close()
        cvr.stopCapturing()
        dce.clearBuffer()
        cvr.removeResultFilter(filter)
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.dataDetectorTypes = .link
        return textView
    }()
    
    let resultView:UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .gray
        return view
    }()

    func setupDCV() {
        view.insertSubview(cameraView, at: 0)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        dce.cameraView = cameraView
        // Set the camera enhancer as the input.
        try! cvr.setInput(dce)
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        cvr.addResultReceiver(self)
    }
    
    func setupUI() {
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )
        navigationItem.rightBarButtonItem = settingsButton
        
        let titleView = UIView()
        titleView.backgroundColor = .black
        titleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(resultView)
        resultView.translatesAutoresizingMaskIntoConstraints = false
        
        resultView.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        resultView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            resultView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textView.leadingAnchor.constraint(equalTo: resultView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            textView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.25),
            
            titleView.leadingAnchor.constraint(equalTo: resultView.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: resultView.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: resultView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: textView.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])
    }
    
    @objc func openSettings() {
        let vc = SettingsTableViewController()
        vc.cvr = cvr
        vc.templateName = templateName
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CameraViewController: CapturedResultReceiver {
    // Implement the callback method to receive DecodedBarcodesResult.
    // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
    // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        if let items = result.items, items.count > 0 {
            if isBeepOn {
                Feedback.beep()
            }
            if isVibrateOn {
                Feedback.vibrate()
            }
            var text = ""
            var index = 1
            for item in items {
                text += String(format: "%2d.\tFormat: %@\n\tText: %@\n\n", index, item.formatString, item.text)
                index += 1
            }
            DispatchQueue.main.async {
                self.resultView.isHidden = false
                self.titleLabel.text = String.init(format: "  Total Results: %d", items.count)
                self.textView.text = text
            }
        }
    }
}

// MARK: LicenseVerificationListener
extension CameraViewController: LicenseVerificationListener {
    func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if !isSuccess {
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
}
