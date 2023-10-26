/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import AVFoundation
import Photos
import DynamsoftBarcodeReader
import DynamsoftCameraEnhancer
import DynamsoftCaptureVisionRouter
import DynamsoftUtility

class ViewController: UIViewController, CapturedResultReceiver, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var cvr: CaptureVisionRouter!
    var dce: CameraEnhancer!
    var dceView: CameraView!
    lazy var frameResultFilter: MultiFrameResultCrossFilter = {
        let resultFilter = MultiFrameResultCrossFilter()
        resultFilter.enableResultCrossVerification(.barcode, isEnabled: true)
        return resultFilter
    }()
    
    var currentPattern: PresetTemplate = .readSingleBarcode
    var selectedPhoto: UIImage?
    
    lazy var resultView:UITextView = {
        let viewHeight:CGFloat = kScreenHeight / 2.0
        let textView = UITextView(frame: CGRect(x: 0, y: kScreenHeight - kTabBarSafeAreaHeight - viewHeight, width: kScreenWidth, height: viewHeight))
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 12.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.isUserInteractionEnabled = false
        textView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textView.textColor = UIColor.white
        textView.textAlignment = .center
        textView.isHidden = false
        return textView
    }()
    
    lazy var photoLibraryButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: kScreenWidth - 50 - 20, y: kStatusBarHeight + 20, width: 50, height: 50))
        button.setImage(UIImage(named: "icon_select"), for: .normal)
        button.addTarget(self, action: #selector(photoSelectedAction(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var patternView: PatternView = {
        let view = PatternView(frame: CGRect(x: 0, y: kStatusBarHeight, width: kCellWidth, height: PatternView.patternHeight()))
        return view
    }()
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.center = self.view.center
        indicator.top = self.view.center.y - 100
        indicator.style = .medium
        indicator.color = .white
        return indicator
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dce.open()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        configureCVR()
        configureDCE()
        setupUI()
        switchTemplate(with: .singleBarcodePattern)
    }

    private func configureCVR() -> Void {
        cvr = CaptureVisionRouter()
        cvr.addResultReceiver(self)
    }
    
    private func configureDCE() -> Void {
        dceView = CameraView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        dceView.scanLaserVisible = true
        self.view.addSubview(dceView)
        
        let dbrDrawingLayer = dceView.getDrawingLayer(DrawingLayerId.DBR.rawValue)
        dbrDrawingLayer?.visible = true
     
        dce = CameraEnhancer(view: dceView)
        
        // CVR link DCE.
        try? cvr.setInput(dce)
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(patternView)
        self.view.addSubview(resultView)
        self.view.addSubview(photoLibraryButton)
        self.view.addSubview(loadingIndicator)
        
        self.patternView.patternExplainCompletion = {
            [unowned self] pattern in
            self.handleExplain(with: pattern)
        }
        
        self.patternView.patternSelectedCompletion = {
            [unowned self] pattern in
            self.loadingIndicator.startAnimating()
            DispatchQueue.main.async {
                self.switchTemplate(with: pattern)
            }
        }
    }
    
    private func handleExplain(with pattern: BarcodePattern) -> Void {
        if pattern == .singleBarcodePattern {
            ToolsManager.shared.addAlertView(to: self, title: pattern.rawValue, content: singleBarcodePatternExplain, completion: nil)
        } else if pattern == .speedFirstPattern {
            ToolsManager.shared.addAlertView(to: self, title: pattern.rawValue, content: speedFirstPatternExplain, completion: nil)
        } else if pattern == .readRateFirstPattern {
            ToolsManager.shared.addAlertView(to: self, title: pattern.rawValue, content: readRateFirstPatternExplain, completion: nil)
        } else if pattern == .accuracyFirstPattern {
            ToolsManager.shared.addAlertView(to: self, title: pattern.rawValue, content: accuracyFirstPatternExplain, completion: nil)
        }
    }
    
    private func switchTemplate(with pattern: BarcodePattern) -> Void {
        cvr.stopCapturing()
        var template :PresetTemplate!
      
        switch pattern {
        case .singleBarcodePattern:
            photoLibraryButton.isHidden = true
            cvr.removeResultFilter(frameResultFilter)
            try? dce.setScanRegion(nil)
            
            template = .readSingleBarcode
            break
        case .speedFirstPattern:
            photoLibraryButton.isHidden = false
            cvr.removeResultFilter(frameResultFilter)
            let scanRegion = Rect()
            scanRegion.top = 0.3
            scanRegion.bottom = 0.7
            scanRegion.left = 0.15
            scanRegion.right = 0.85
            scanRegion.measuredInPercentage = true
            try? dce.setScanRegion(scanRegion)
            
            template = .readBarcodesSpeedFirst
            guard let cvrRuntimeSettings = try? cvr.getSimplifiedSettings(template.rawValue) else {
                return
            }
            
            cvrRuntimeSettings.barcodeSettings?.barcodeFormatIds = .default
            cvrRuntimeSettings.barcodeSettings?.expectedBarcodesCount = 0
            cvrRuntimeSettings.timeout = 500
            do {
                try cvr.updateSettings(template.rawValue, settings:cvrRuntimeSettings)
            } catch {
                print("update runtimeSettings error:\(error.localizedDescription)")
            }

            break
        case .readRateFirstPattern:
            photoLibraryButton.isHidden = false
            cvr.removeResultFilter(frameResultFilter)
            try? dce.setScanRegion(nil)
            
            template = .readBarcodesReadRateFirst
            guard let cvrRuntimeSettings = try? cvr.getSimplifiedSettings(template.rawValue) else {
                return
            }
            
            cvrRuntimeSettings.barcodeSettings?.barcodeFormatIds = .default
            cvrRuntimeSettings.barcodeSettings?.expectedBarcodesCount = 999
            cvrRuntimeSettings.barcodeSettings?.grayscaleTransformationModes = [GrayscaleTransformationMode.original.rawValue,
                                                                                GrayscaleTransformationMode.inverted.rawValue
            ]
            cvrRuntimeSettings.timeout = 5000
            do {
                try cvr.updateSettings(template.rawValue, settings:cvrRuntimeSettings)
            } catch {
                print("update runtimeSettings error:\(error.localizedDescription)")
            }
            
            break
        case .accuracyFirstPattern:
            photoLibraryButton.isHidden = true
            cvr.addResultFilter(frameResultFilter)
            try? dce.setScanRegion(nil)
            
            template = .readBarcodes
            guard let cvrRuntimeSettings = try? cvr.getSimplifiedSettings(template.rawValue) else {
                return
            }
            cvrRuntimeSettings.barcodeSettings?.barcodeFormatIds = .all
            cvrRuntimeSettings.barcodeSettings?.expectedBarcodesCount = 999
            cvrRuntimeSettings.barcodeSettings?.grayscaleTransformationModes = [GrayscaleTransformationMode.original.rawValue,
                                                                                GrayscaleTransformationMode.inverted.rawValue
            ]
            cvrRuntimeSettings.barcodeSettings?.deblurModes = [DeblurMode.basedOnLocBin.rawValue,
                                                               DeblurMode.thresholdBinarization.rawValue
            ]
            cvrRuntimeSettings.barcodeSettings?.minResultConfidence = 30
            cvrRuntimeSettings.barcodeSettings?.minBarcodeTextLength = 6
            cvrRuntimeSettings.barcodeSettings?.barcodeTextRegExPattern = ""
            do {
                try cvr.updateSettings(template.rawValue, settings:cvrRuntimeSettings)
            } catch {
                print("update runtimeSettings error:\(error.localizedDescription)")
            }
            
            break
        }

        cvr.startCapturing(template.rawValue) {
            [unowned self] isSuccess, error in
            if let error = error {
                self.displayError(msg: error.localizedDescription)
            }
        }
        
        self.loadingIndicator.stopAnimating()
    }
    
    // MARK: - CapturedResultReceiver
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        guard let items = result.items else {
            return
        }
        
        // Parse Results.
        var viewText:String = "\("Total Result(s):") \(items.count)"
        for barcodeRes in items {
            viewText = viewText + "\n\("Format:") \(barcodeRes.formatString) \n\("Text:") \(barcodeRes.text)\n"
        }
        
        DispatchQueue.main.async{
            self.resultView.isHidden = false
            self.resultView.text = viewText
        }
    }
    
    
    // MARK: - PhotoLibrary authorization
    @objc private func photoSelectedAction(_ button: UIButton) -> Void {
        cvr.stopCapturing()
        openPhotoLibrary()
    }
    
    func openPhotoLibrary() -> Void {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.presentPickerViewController()
            } else {
                self.requestAuthorization()
            }
        }
    }
    
    func presentPickerViewController() -> Void {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            if #available(iOS 11.0, *) {
                UIScrollView.appearance().contentInsetAdjustmentBehavior = .always
            }
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        
    }
    
    func requestAuthorization() -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Tips", message: "Settings-Privacy-Camera/Album-Authorization", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let comfirmAction = UIAlertAction(title: "OK", style: .default) { action in
                guard let url = URL(string: UIApplication.openSettingsURLString) else {return}
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(comfirmAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePicker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        cvr.startCapturing(currentPattern.rawValue)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        selectedPhoto = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        decodeByBuffer(image: selectedPhoto)
    }
    
    func decodeByBuffer(image: UIImage?) -> Void {
        guard let image = image else { return }
        let capturedResult = cvr.captureFromImage(image, templateName: currentPattern.rawValue)
        
        let resultCount = capturedResult.items?.count ?? 0
        var resultText:String = ""
        if resultCount > 0 {
            for resultItems in capturedResult.items! {
                if resultItems.type == .barcode {
                    let barcodeItems = resultItems as! BarcodeResultItem
                    resultText = resultText + String(format:"\nFormat: %@\nText: %@\n", barcodeItems.formatString,barcodeItems.text)
                }
            }
        }
       
        displaySingleResult(String(format: "Results(%d)", resultCount), resultText, "OK") {
            [unowned self] in
            self.cvr.startCapturing(self.currentPattern.rawValue)
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

