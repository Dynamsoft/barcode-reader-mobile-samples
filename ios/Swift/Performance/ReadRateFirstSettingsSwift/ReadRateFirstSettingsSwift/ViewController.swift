//
//  ViewController.swift
//
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, DMDLSLicenseVerificationDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate{
    
    var barcodeReader:DynamsoftBarcodeReader! = nil
    var sourceType:UIImagePickerController.SourceType!
    var loadingView:UIActivityIndicatorView!
    
    let session:AVCaptureSession = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var photoOutput:AVCaptureStillImageOutput?
    var sessionQueue:DispatchQueue!
    var photoButton:UIButton! = UIButton()
    var picButton:UIButton! = UIButton()
    var captureView:UIView! = UIView()
    var leadView:UIView! = UIView()
    var subLeadView:UIView! = UIView()
    var orientationNum:Int = 0
    
    let w = UIScreen.main.bounds.size.width
    let h = UIScreen.main.bounds.size.height
    let safeAreaBottomHeight:CGFloat = UIApplication.shared.statusBarFrame.size.height > 20 ? 34 : 0
    let co = UIColor(red: 254.0/255.0, green: 142.0/255.0, blue: 20.0/255.0, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is a sample that shows how to reach the ReadRateFirstSettings when using Dynamsoft Barcode Reader.
        configurationDBR()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configurationDBR() {
        let lts = iDMDLSConnectionParameters()
        
        // Initialize license for Dynamsoft Barcode Reader.
        // The organization id 200001 here will grant you a public trial license good for 7 days. Note that network connection is required for this license to work.
        // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
        // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
        lts.organizationID = "200001"
        barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: lts, verificationDelegate: self)
        
        var error : NSError? = NSError()
        // LocalizationModes       : LocalizationModes are all enabled as default. Barcode reader will automatically switch between the modes and try decoding continuously until timeout or the expected barcode count is reached. Please manually update the enabled modes list or change the expected barcode count to promote the barcode scanning speed.
        // Read more about localization mode members: https://www.dynamsoft.com/barcode-reader/parameters/enum/parameter-mode-enums.html?ver=latest#localizationmode
        // BarcodeFormatIds        : The simpler barcode format, the faster decoding speed.
        // ExpectedBarcodesCount   : The barcode scanner will try to find 512 barcodes. If the result count does not reach the expected amount, the barcode scanner will try other algorithms in the setting list to find enough barcodes.
        // DeblurModes             : DeblurModes are all enabled as default. Barcode reader will automatically switch between the modes and try decoding continuously until timeout or the expected barcode count is reached. Please manually update the enabled modes list or change the expected barcode count to promote the barcode scanning speed.
        // Read more about deblur mode members: https://www.dynamsoft.com/barcode-reader/parameters/enum/parameter-mode-enums.html#deblurmode
        // ScaleUpModes            : It is a parameter to control the process for scaling up an image used for detecting barcodes with small module size.
        // GrayscaleTransformationModes : The image will be transformed into inverted grayscale with GTM_INVERTED mode.
        // DPMCodeReadingModes     : It is a parameter to control how to read direct part mark (DPM) barcodes.
        let json = "{\"ImageParameter\": {\"BarcodeFormatIds\": [\"BF_ALL\"],\"ExpectedBarcodesCount\": 64,\"RegionPredetectionModes\": [{\"Mode\": \"RPM_GENERAL\"}],\"DPMCodeReadingModes\":[{\"Mode\":\"DPMCRM_GENERAL\"}],\"LocalizationModes\": [{\"Mode\": \"LM_CONNECTED_BLOCKS\"},{\"Mode\": \"LM_SCAN_DIRECTLY\",\"ScanDirection\": 0},{\"Mode\": \"LM_STATISTICS\"},{\"Mode\": \"LM_LINES\"},{\"Mode\": \"LM_STATISTICS_MARKS\"},{\"Mode\": \"LM_STATISTICS_POSTAL_CODE\"}],\"BinarizationModes\": [{\"BlockSizeX\": 0,\"BlockSizeY\": 0,\"EnableFillBinaryVacancy\": 1,\"Mode\": \"BM_LOCAL_BLOCK\",\"ThresholdCompensation\": 10},{\"EnableFillBinaryVacancy\": 0,\"Mode\": \"BM_LOCAL_BLOCK\",\"ThresholdCompensation\": 15}],\"DeblurModes\": [{\"Mode\": \"DM_DIRECT_BINARIZATION\"},{\"Mode\": \"DM_THRESHOLD_BINARIZATION\"},{\"Mode\": \"DM_GRAY_EQUALIZATION\"},{\"Mode\": \"DM_SMOOTHING\"},{\"Mode\": \"DM_MORPHING\"},{\"Mode\": \"DM_DEEP_ANALYSIS\"},{\"Mode\": \"DM_SHARPENING\"}],\"GrayscaleTransformationModes\": [{\"Mode\": \"GTM_ORIGINAL\"},{\"Mode\": \"GTM_INVERTED\"}],\"ScaleUpModes\": [{\"Mode\": \"SUM_AUTO\"}],\"Name\":\"ReadRateFirstSettings\",\"Timeout\":30000}}"
        barcodeReader.initRuntimeSettings(with: json, conflictMode: .overwrite, error: &error)
    }

    func dlsLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        var msg:String? = nil
        if(error != nil)
        {
            let err = error as NSError?
            if err?.code == -1009 {
                msg = "Unable to connect to the public Internet to acquire a license. Please connect your device to the Internet or contact support@dynamsoft.com to acquire an offline license."
                showResult("No Internet", msg!, "Try Again") { [weak self] in
                    self?.configurationDBR()
                }
            }else{
                msg = err!.userInfo[NSUnderlyingErrorKey] as? String
                if(msg == nil)
                {
                    msg = err?.localizedDescription
                }
                showResult("Server license verify failed", msg!, "OK") { [weak self] in
                    
                }
            }
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
    
    private func showResult(_ title: String, _ msg: String, _ acTitle: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
            self.photoButton?.isEnabled = true
        }
    }
    
    @objc func handleOrientationDidChange(){
        DispatchQueue.main.async {
            var mainBounds:CGRect = .zero
            let w = UIScreen.main.bounds.size.width
            let h = UIScreen.main.bounds.size.height
            var avOri :AVCaptureVideoOrientation = .portrait
            switch UIApplication.shared.statusBarOrientation {
            case .portrait:
                mainBounds.size.width = min(h, w)
                mainBounds.size.height = max(h, w)
                self.orientationNum = 0
                avOri = .portrait
            case .landscapeRight:
                mainBounds.size.width = max(h, w)
                mainBounds.size.height = min(h, w)
                self.orientationNum = 2
                avOri = .landscapeRight
            case .landscapeLeft:
                mainBounds.size.width = max(h, w)
                mainBounds.size.height = min(h, w)
                self.orientationNum = 1
                avOri = .landscapeLeft
            default:
                mainBounds.size.width = min(h, w)
                mainBounds.size.height = max(h, w)
                self.orientationNum = 0
                avOri = .portrait
            }
            self.previewLayer?.connection?.videoOrientation = avOri
            self.previewLayer?.frame = mainBounds
            self.captureView.frame = mainBounds
            let SafeAreaBottomHeight = UIApplication.shared.statusBarFrame.size.height
            if (mainBounds.size.width > mainBounds.size.height) {
                self.photoButton.frame = CGRect(x: mainBounds.size.width - 170, y: mainBounds.size.height / 2 - 60, width: 120 , height: 120)
                self.picButton.frame = CGRect(x: mainBounds.size.width - 142, y: mainBounds.size.height / 2 - 153, width: 65 , height: 65)
            }else{
                self.photoButton.frame = CGRect(x: mainBounds.size.width / 2 - 60, y: mainBounds.size.height - 170 - SafeAreaBottomHeight, width: 120, height: 120)
                self.picButton.frame = CGRect(x: mainBounds.size.width / 2 + 88, y: mainBounds.size.height - 142 - SafeAreaBottomHeight, width: 65, height: 65)
            }
            self.loadingView.frame = CGRect(x: mainBounds.size.width / 2 - 25, y: mainBounds.size.height / 2 - 25, width: 50, height: 50)
        }
    }

    
    func setupUI()
    {
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        sessionQueue = DispatchQueue(label: "dbrQueue", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
        loadingView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        loadingView.center = self.view.center
        loadingView.activityIndicatorViewStyle = .gray
        self.view.addSubview(loadingView)
        self.addCamera()
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
        let authStatusAlbm:PHAuthorizationStatus  = .authorized
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.decodeByBuffer(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func decodeByBuffer(image:UIImage){
        DispatchQueue.main.async {
            self.loadingView.startAnimating()
        }
        DispatchQueue.global().async {
            let results = try! self.barcodeReader.decode(image, withTemplate: "")
            self.handresults(results: results)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func addCamera(){
        self.setVideoSession()
        let tabH = UIApplication.shared.statusBarFrame.size.height
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer!.frame = CGRect(x: 0, y: tabH, width: w, height: h - tabH)
        previewLayer!.videoGravity = .resizeAspectFill
        previewLayer!.connection?.videoOrientation = .portrait
        photoButton = UIButton(frame: CGRect(x:w / 2 - 60, y: h - 170 - safeAreaBottomHeight, width: 120, height: 120))
        photoButton.adjustsImageWhenDisabled = false
        photoButton.setImage(UIImage(named: "icon_capture"), for: .normal)
        photoButton.addTarget(self, action: #selector(takePictures), for: .touchUpInside)
        
        picButton = UIButton(frame: CGRect(x:w / 2 + 88, y: h - 142 - safeAreaBottomHeight, width: 65, height: 65))
        picButton.setImage(UIImage(named: "icon_picture"), for: .normal)
        picButton.addTarget(self, action: #selector(selectPic), for: .touchUpInside)
        captureView = UIView(frame: CGRect(x: 0, y: tabH, width: w, height: h - tabH))
        DispatchQueue.main.async {
            self.captureView.layer.addSublayer(self.previewLayer!)
            self.view.insertSubview(self.captureView, belowSubview: self.loadingView)
            self.view.addSubview(self.photoButton)
            self.view.addSubview(self.picButton)
        }
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                self.startSession()
            }
        }
    }
    
    @objc func selectPic(){
        self.getAlertActionType(1)
    }
    
    @objc func takePictures(){
        self.photoButton?.isEnabled = false
        let videoConnection: AVCaptureConnection? = photoOutput!.connection(with: AVMediaType.video)
        if videoConnection == nil {
            self.photoButton?.isEnabled = true
            return
        }
        photoOutput!.captureStillImageAsynchronously(from: videoConnection!, completionHandler: {(_ imageDataSampleBuffer: CMSampleBuffer?, _ error: Error?) -> Void in
            if imageDataSampleBuffer == nil {
                self.photoButton?.isEnabled = true
                return
            }
            let imageData: Data? = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
            var originImage:UIImage? = nil
            if (self.orientationNum == 2) {
                originImage = UIImage(data: imageData!)!
            }else{
                originImage = self.FixOrientation(aImage:UIImage(data: imageData!)!)
            }
            self.decodeByBuffer(image: originImage!)
        })
    }
    
    func addBack(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .reply, target: self, action: #selector(backToHome))
    }
    
    @objc func backToHome(){
        self.stopSession()
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func setVideoSession() {
        guard !session.isRunning else { return }
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do
        {
            if(device.isFocusModeSupported(.continuousAutoFocus)){
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
            }
            if(device.isAutoFocusRangeRestrictionSupported){
                try device.lockForConfiguration()
                device.autoFocusRangeRestriction = .near
                device.unlockForConfiguration()
            }
        }catch{
            print(error)
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        guard session.canAddInput(input) else { return }
        session.addInput(input)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        photoOutput = AVCaptureStillImageOutput()
        guard session.canAddOutput(videoOutput) else { return }
        session.addOutput(videoOutput)
        guard session.canAddOutput(photoOutput!) else { return }
        session.addOutput(photoOutput!)
        if(self.session.canSetSessionPreset(.hd1280x720)){
            session.sessionPreset = .hd1280x720
        }
    }
    
    func startSession() {
        #if targetEnvironment(simulator)
        return
        #endif
        sessionQueue.async {
            if !self.session.isRunning { self.session.startRunning() }
        }
    }
    
    func stopSession(){
        #if targetEnvironment(simulator)
        return
        #endif
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
            DispatchQueue.main.async {
                if (self.previewLayer != nil) { self.previewLayer!.removeFromSuperlayer() }
                self.photoButton.removeFromSuperview()
                self.captureView.removeFromSuperview()
            }
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            for output in self.session.outputs {
                self.session.removeOutput(output)
            }
        }
    }
    
    func presentPickerViewController(){
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            if #available(iOS 11.0, *) {
                UIScrollView.appearance().contentInsetAdjustmentBehavior = .always
            }
            picker.delegate = self
            picker.sourceType = self.sourceType
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        let w = UIScreen.main.bounds.size.width
        let h = UIScreen.main.bounds.size.height
        if w > h {
            return true
        }
        return false
    }
    
    func FixOrientation(aImage: UIImage) -> UIImage {
        if (aImage.imageOrientation == .up) {
            return aImage
        }
        var transform = CGAffineTransform.identity
        switch (aImage.imageOrientation) {
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            break
        case .right, .rightMirrored:
            if orientationNum == 1 {
                transform = transform.translatedBy(x: aImage.size.height, y: aImage.size.width)
                transform = transform.rotated(by: CGFloat(-Double.pi))
            }else{
                transform = transform.translatedBy(x: 0, y: aImage.size.height)
                transform = transform.rotated(by: CGFloat(-Double.pi / 2))
            }
        default:
            break
        }
        switch (aImage.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: aImage.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        default:
            break
        }
        var ctx:CGContext?
        if orientationNum == 1 {
            ctx = CGContext(data: nil, width: Int(aImage.size.height), height: Int(aImage.size.width),
                                bitsPerComponent: aImage.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                space: aImage.cgImage!.colorSpace!,
                                bitmapInfo: aImage.cgImage!.bitmapInfo.rawValue)
        }else{
            ctx = CGContext(data: nil, width: Int(aImage.size.width), height: Int(aImage.size.height),
                                bitsPerComponent: aImage.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                space: aImage.cgImage!.colorSpace!,
                                bitmapInfo: aImage.cgImage!.bitmapInfo.rawValue)
        }
        ctx!.concatenate(transform)
        switch (aImage.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.height, height: aImage.size.width))
            break
        default:
            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.width, height: aImage.size.height))
            break
        }
        let cgimg = ctx!.makeImage()
        return UIImage(cgImage: cgimg!)
    }
}
