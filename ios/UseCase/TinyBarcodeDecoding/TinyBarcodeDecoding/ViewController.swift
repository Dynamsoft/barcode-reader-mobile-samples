/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftBarcodeReader
import DynamsoftCameraEnhancer
import DynamsoftCaptureVisionRouter

class ViewController: UIViewController, CapturedResultReceiver {

    var cvr: CaptureVisionRouter!
    var dce: CameraEnhancer!
    var dceView: CameraView!
    
    lazy var cameraZoomFloatingButton: CameraZoomFloatingButton = {
        let bottomHeight = kZoomComponentBottomMargin + kTabBarSafeAreaHeight
        let floatingButton = CameraZoomFloatingButton(frame: CGRect(x: (kScreenWidth - kCameraZoomFloatingButtonWidth) / 2.0, y: kScreenHeight - bottomHeight - kCameraZoomFloatingButtonWidth, width: kCameraZoomFloatingButtonWidth, height: kCameraZoomFloatingButtonWidth))
        floatingButton.currentCameraZoom = currentCameraZoom
        return floatingButton
    }()
    
    lazy var cameraZoomSlider: CameraZoomSlider = {
        let bottomHeight = kZoomComponentBottomMargin + kTabBarSafeAreaHeight
        let slider = CameraZoomSlider(frame: CGRect(x: 0, y: kScreenHeight - bottomHeight - kCameraZoomSliderViewHeight, width: kScreenWidth, height: kCameraZoomSliderViewHeight))
        slider.isHidden = true
        slider.cameraMinZoom = kDCEMinimumZoom
        slider.cameraMaxZoom = KDCEMaximumZoom
        slider.currentCameraZoom = currentCameraZoom
        return slider
    }()
    
    lazy var cameraSettingView: CameraSettingView = {
        let settingHeight = KCameraSettingViewAvailableHeight + kTabBarSafeAreaHeight
        let cameraSetting = CameraSettingView(frame: CGRect(x: 0, y: kScreenHeight - settingHeight, width: kScreenWidth, height: settingHeight))
        cameraSetting.updateSwitch(with: autoZoomIsOpen)
        return cameraSetting
    }()
    
    lazy var interestLeadingView: UILabel = {
        let leadingWidth = 21.0
        let label = UILabel(frame: CGRect(x: (kScreenWidth - leadingWidth) / 2.0, y: (kScreenHeight - leadingWidth) / 2.0, width: leadingWidth, height: leadingWidth))
        label.text = "+"
        label.textColor = UIColor(red: 254 / 255.0, green: 142 / 255.0, blue: 20 / 255.0, alpha: 1)
        label.font = kFont_Regular(30)
        label.textAlignment = .center
        return label
    }()
    
    var currentCameraZoom: CGFloat = kDCEMinimumZoom
    var autoZoomIsOpen: Bool = kAutoZoomIsOpen
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dce.open()
        cvr.startCapturing(PresetTemplate.readSingleBarcode.rawValue) {
            [unowned self] isSuccess, error in
            if let error = error {
                self.displayError(msg: error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white

        configureCVR()
        configureDCE()
        setupUI()
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

        // Set the zoom factor of the camera.
        dce.setZoomFactor(currentCameraZoom)

        // Restrict the zoom range. Both zoom and auto-zoom will not exceed this range.
        dce.autoZoomRange = UIFloatRange(minimum: kDCEMinimumZoom, maximum: KDCEMaximumZoom)

        // Trigger a focus at the middel of the screen and keep continuous auto-focus enabled after the focus finished.
        dce.setFocus(CGPoint(x: 0.5, y: 0.5), focusMode: .continuousAuto)

        //  CVR link DCE.
        try? cvr.setInput(dce)
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(cameraZoomFloatingButton)
        self.view.addSubview(cameraZoomSlider)
        self.view.addSubview(cameraSettingView)
        self.view.addSubview(interestLeadingView)
        
        cameraZoomFloatingButton.tapPressCompletion = {
            [unowned self] in
            self.cameraZoomSlider.isHidden = false
            self.cameraZoomFloatingButton.isHidden = true
        }
        
        cameraZoomSlider.closeActionCompletion = {
            [unowned self] in
            self.cameraZoomSlider.isHidden = true
            self.cameraZoomFloatingButton.isHidden = false
        }
        
        cameraZoomSlider.zoomValueChangedCompletion = {
            [unowned self] zoomValue in
            self.changeCameraZoom(zoomValue)
        }
        
        cameraSettingView.switchChangedCompletion = {
            [unowned self] isOn in
            self.refreshAutoZoomState(isOn)
        }
    }

    // MARK: - CapturedResultReceiver
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        guard let items = result.items else {
            return
        }
        cvr.stopCapturing()
        Feedback.vibrate()
        Feedback.beep()
        
        // Parse Results.
        var resultText:String = ""
        for barcodeRes in items {
            resultText = resultText + String(format:"\nFormat: %@\nText: %@\n", barcodeRes.formatString,barcodeRes.text)
        }
        
        displaySingleResult(String(format: "Results(%d)", items.count), resultText, "OK") {
            [unowned self] in
            self.cvr.startCapturing(PresetTemplate.readBarcodes.rawValue)
        }
        
    }

    private func changeCameraZoom(_ cameraZoom: CGFloat) -> Void {
        cameraZoomFloatingButton.currentCameraZoom = cameraZoom
        cameraZoomSlider.currentCameraZoom = cameraZoom
        currentCameraZoom = cameraZoom
        
        if dce.getCameraState() == .opened {
            dce.setZoomFactor(cameraZoom)
        }
    }
    
    private func refreshAutoZoomState(_ isOn: Bool) -> Void {
        autoZoomIsOpen = isOn
        if (autoZoomIsOpen) {
            dce.enableEnhancedFeatures(.autoZoom)
            cameraZoomFloatingButton.isHidden = true
            cameraZoomSlider.isHidden = true
        } else {
            dce.disableEnhancedFeatures(.autoZoom)
            cameraZoomFloatingButton.isHidden = false
            cameraZoomSlider.isHidden = true
            currentCameraZoom = kDCEMinimumZoom
            changeCameraZoom(currentCameraZoom)
        }
    }
    
    private func displaySingleResult(_ title: String, _ msg: String, _ acTitle: String, completion: ConfirmCompletion? = nil) {
        DispatchQueue.main.async {
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

