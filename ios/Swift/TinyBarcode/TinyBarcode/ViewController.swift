//
//  ViewController.swift
//  TinyBarcode
//
//  Created by dynamsoft's mac on 2022/11/24.
//

import UIKit

class ViewController: UIViewController, DBRTextResultListener {
    

    var dce:DynamsoftCameraEnhancer!
    var dceView:DCECameraView!
    var barcodeReader:DynamsoftBarcodeReader!
    
    var cameraZoomFloatingButton: CameraZoomFloatingButton!
    var cameraZoomSlider:CameraZoomSlider!
    var cameraSettingView: CameraSettingView!
    var interestLeadingView: UILabel!
    
    
    var currentCameraZoom: CGFloat = kDCEDefaultZoom
    var autoZoomIsOpen: Bool = kAutoZoomIsOpen
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 59.003 / 255.0, green: 61.9991 / 255.0, blue: 69.0028 / 255.0, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        self.title = "Tiny Barcode"
        
        //This is a sample that illustrates how to quickly set up a video barcode scanner with Dynamsoft Barcode Reader.
        configurationDBR()
        
        //Create a camera module for video barcode scanning. In this section Dynamsoft Camera Enhancer (DCE) will handle the camera settings.
        configurationDCE()
        
        addZoomFloatingButton()
        addZoomSlider()
        addCameraSettingView()
        addInterestLeadingView()
    }

    func configurationDBR() {
        barcodeReader = DynamsoftBarcodeReader.init()
        barcodeReader.updateRuntimeSettings(EnumPresetTemplate.videoSingleBarcode)
        
        // Set text result call back to get barcode results.
        barcodeReader.setDBRTextResultListener(self)
    }
    
    func configurationDCE() {
        //Initialize a camera view for previewing video.
        dceView = DCECameraView.init(frame: self.view.bounds)
        self.view.addSubview(dceView)

        // Initialize the Camera Enhancer with the camera view.
        dce = DynamsoftCameraEnhancer.init(view: dceView)

        // Open the camera to get video streaming.
        dce.open()

        // Set the zoom factor of the camera.
        dce.setZoom(currentCameraZoom)
        
        // Restrict the zoom range. Both zoom and auto-zoom will not exceed this range.
        dce.autoZoomRange = UIFloatRange(minimum: 1.5, maximum: 5.0)
        
        // Trigger a focus at the middel of the screen and keep continuous auto-focus enabled after the focus finished.
        dce.setFocus(CGPointMake(0.5, 0.5), focusMode: .FM_CONTINUOUS_AUTO)
        
        // Bind Camera Enhancer to the Barcode Reader.
        // The Barcode Reader will get video frame from the Camera Enhancer
        barcodeReader.setCameraEnhancer(dce)

        // Start the barcode decoding thread.
        barcodeReader.startScanning()
    }
    
    // MARK: - DBRTextResultListener
    
    // Obtain the recognized barcode results from the textResultCallback and display the results
    func textResultCallback(_ frameId: Int, imageData: iImageData, results: [iTextResult]?) {
        if (results != nil){
            self.barcodeReader.stopScanning()
            DCEFeedback.vibrate()
            //DCEFeedback.beep()
            
            var msgText:String = ""
            let title:String = "Results"
            for item in results! {
                msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", item.barcodeFormatString!,item.barcodeText ?? "noResuslt")
            }

            showResult(title, msgText, "OK") {
                [unowned self] in
                self.barcodeReader.startScanning()
            }
        }
    }

    private func showResult(_ title: String, _ msg: String, _ acTitle: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true)
        }
    }
    
    func addZoomFloatingButton() -> Void {
        var bottomHeight = 0.0
        if kIs_iPhoneXAndLater {
            bottomHeight = kZoomComponentBottomMargin + 34.0
        } else {
            bottomHeight = kZoomComponentBottomMargin
        }
        
        self.cameraZoomFloatingButton = CameraZoomFloatingButton.init(frame: CGRectMake((kScreenWidth - kCameraZoomFloatingButtonWidth) / 2.0, kScreenHeight - bottomHeight - kCameraZoomFloatingButtonWidth, kCameraZoomFloatingButtonWidth, kCameraZoomFloatingButtonWidth))
        self.cameraZoomFloatingButton.currentCameraZoom = currentCameraZoom
        self.view.addSubview(cameraZoomFloatingButton)
        
        self.cameraZoomFloatingButton.tapPressCompletion = {
            [unowned self] in
            self.cameraZoomSlider.isHidden = false
            self.cameraZoomFloatingButton.isHidden = true
        }
    }
    
    func addZoomSlider() -> Void {
        var bottomHeight = 0.0
        if kIs_iPhoneXAndLater {
            bottomHeight = kZoomComponentBottomMargin + 34.0
        } else {
            bottomHeight = kZoomComponentBottomMargin
        }
        
        self.cameraZoomSlider = CameraZoomSlider.init(frame: CGRectMake(0, kScreenHeight - bottomHeight - kCameraZoomSliderViewHeight, kScreenWidth, kCameraZoomSliderViewHeight))
        self.view.addSubview(cameraZoomSlider)
        
        self.cameraZoomSlider.isHidden = true
        self.cameraZoomSlider.cameraMinZoom = kDCEDefaultZoom
        self.cameraZoomSlider.cameraMaxZoom = KDCEMaxZoom
        self.cameraZoomSlider.currentCameraZoom = currentCameraZoom
        
        self.cameraZoomSlider.closeActionCompletion = {
            [unowned self] in
            self.cameraZoomSlider.isHidden = true
            self.cameraZoomFloatingButton.isHidden = false
        }
        
        self.cameraZoomSlider.zoomValueChangedCompletion = {
            [unowned self] zoomValue in
            self.changeCameraZoom(zoomValue)
        }
    }
    
    func changeCameraZoom(_ cameraZoom: CGFloat) -> Void {
        self.cameraZoomFloatingButton.currentCameraZoom = cameraZoom
        self.cameraZoomSlider.currentCameraZoom = cameraZoom
        currentCameraZoom = cameraZoom
        
        if (self.dce.getCameraState() == EnumCameraState.EnumCAMERA_STATE_OPENED) {
            self.dce.setZoom(cameraZoom)
        }
    }
    
    func addCameraSettingView() -> Void {
        var height = 0.0;
        if (kIs_iPhoneXAndLater) {
            height = KCameraSettingAvailableHeight + 34;
        } else {
            height = KCameraSettingAvailableHeight;
        }
        
        self.cameraSettingView = CameraSettingView.init(frame: CGRectMake(0, kScreenHeight - height, kScreenWidth, height))
        self.view.addSubview(cameraSettingView)
        
        self.cameraSettingView.updateSwitch(with: autoZoomIsOpen)
        self.cameraSettingView.switchChangedCompletion = {
            [unowned self] isOn in
            self.refreshAutoZoomState(isOn)
        }
    }
    
    func refreshAutoZoomState(_ isOn: Bool) -> Void {
        autoZoomIsOpen = isOn
        if (autoZoomIsOpen) {
            self.dce.enableFeatures(EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue, error: nil)
            self.cameraZoomFloatingButton.isHidden = true
            self.cameraZoomSlider.isHidden = true
        } else {
            self.dce.disableFeatures(EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue)
            self.cameraZoomFloatingButton.isHidden = false
            self.cameraZoomSlider.isHidden = true
            currentCameraZoom = kDCEDefaultZoom
            self.changeCameraZoom(currentCameraZoom)
        }
    }

    func addInterestLeadingView() -> Void {
        let leadingWidth = 21.0
        
        self.interestLeadingView = UILabel.init(frame: CGRectMake((kScreenWidth - leadingWidth) / 2.0, (kScreenHeight - leadingWidth) / 2.0, leadingWidth, leadingWidth))
        self.interestLeadingView.text = "+"
        self.interestLeadingView.textColor = UIColor(red: 254 / 255.0, green: 142 / 255.0, blue: 20 / 255.0, alpha: 1)
        self.interestLeadingView.font = kFont_SystemDefault(30)
        self.interestLeadingView.textAlignment = .center
        self.view.addSubview(interestLeadingView)
    }
}

