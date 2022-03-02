//
//  ViewController.swift
//  DBRwithoutDCE
//
//  Created by Amro Ibrahim on 2022-02-23.
//

import UIKit
import AVFoundation
import DynamsoftBarcodeReader

class ViewController: UIViewController {
    @IBOutlet var rectLayerImage: UIImageView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var detectDescLabel: UILabel!
    @IBOutlet weak var choosePictureButton: UIButton!
    
    var cameraPreview: UIView?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var dbrManager: DbrManager?
    var isFlashOn:Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dls = iDMDLSConnectionParameters()
        // The organization id 200001 here will grant you a public trial license good for 7 days. After that, you can send an email to trial@dynamsoft.com (make sure to include the keyword privateTrial in the email title) to obtain a 30-day free private trial license which will also come in the form of an organization id.
        dls.organizationID = "200001"
        dbrManager = DbrManager(DLS: dls)
        
        dbrManager?.setServerLicenseVerificationCallback(sender: self, callBack: #selector(onVerificationCallBack(isSuccess:error:)))
        dbrManager?.setRecognitionCallback(sender: self, callBack: #selector(onReadImageBufferComplete))
        dbrManager?.setVideoSession()
        
        self.configInterface()
    }
    
    @IBAction func addStaticPhoto(){
        dbrManager?.isPauseFramesComing = true
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dbrManager?.isPauseFramesComing = false
        self.turnFlashOn(on: isFlashOn)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showBarcodeTypes"){
            let newBackButton = UIBarButtonItem.init(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = newBackButton
            self.navigationController?.navigationBar.tintColor = UIColor.white
            //let destViewController = segue.destination as! BarcodeTypesTableViewController
            //destViewController.mainView = self
            
            self.turnFlashOn(on: false)
            dbrManager?.isPauseFramesComing = true
        }
    }
    
    @objc func onVerificationCallBack(isSuccess:NSNumber, error:NSError?)
    {
        if(isSuccess.boolValue)
        {
            self.dbrManager?.startVideoSession()
        }
        else
        {
            var msg:String? = nil
            var title = "Server license verify failed"
            var add:Bool = true
            if(error != nil)
            {
                if error?.code == -1009 {
                    msg = "Dynamsoft Barcode Reader is unable to connect to the public Internet to acquire a license. Please connect your device to the Internet or contact support@dynamsoft.com to acquire an offline license."
                    add = false
                    title = "No Internet"
                }else{
                    msg = error!.userInfo[NSUnderlyingErrorKey] as? String
                    if(msg == nil)
                    {
                        msg = error?.localizedDescription
                    }
                }
            }
            let ac = UIAlertController(title: title, message: msg,preferredStyle: .alert)
            self.customizeAC(ac:ac)
            let okButton = UIAlertAction(title: "Try again", style: .default, handler: {
                action in
                let dls = iDMDLSConnectionParameters()
                dls.organizationID = "200001"
                self.dbrManager?.connectServerAfterInit(DLS: dls)
            })
            ac.addAction(okButton)
            if add {
                let cancelButton = UIAlertAction(title: "Continue Anyway", style: .cancel, handler: {
                    action in
                    self.dbrManager?.startVideoSession()
                })
                ac.addAction(cancelButton)
            }
            self.present(ac, animated: false, completion: nil)
        }
    }
    
    @objc func onReadImageBufferComplete(readResult:NSArray)
    {
        let results:[iTextResult]? = readResult as? [iTextResult]
        if(results!.count == 0 || dbrManager?.isPauseFramesComing == true)
        {
            dbrManager?.isCurrentFrameDecodeFinished = true
            return
        }
        let timeInterval = (dbrManager?.startRecognitionDate?.timeIntervalSinceNow)! * -1
        var msgText:String = ""
        var hasEx:Bool = false
        if(results!.count == 0){
            dbrManager?.isCurrentFrameDecodeFinished = true
            return
        }else{
            for item in results! {
                if item.exception != nil && item.exception != "" {
                    let msg = "Email trial@dynamsoft.com to acquire a 30-day trial license, make sure to include the word \"privateTrial\" in the email title."
                    if item.exception!.contains(msg) {
                        hasEx = true
                        msgText = item.exception!
                        let index:Range = msgText.range(of: "message:")!
                        msgText = String(msgText[index.upperBound..<msgText.endIndex])
                        break
                    }
                }
                if item.barcodeFormat_2.rawValue != 0 {
                    msgText = msgText + String(format:"\nType: %@\nValue: %@\n", item.barcodeFormatString_2!, item.barcodeText ?? "noResuslt")
                }else{
                    msgText = msgText + String(format:"\nType: %@\nValue: %@\n", item.barcodeFormatString!,item.barcodeText ?? "noResuslt")
                }
            }
            var msg = ""
            var title = ""
            if (hasEx) {
                msg = msgText
                title = "Exception"
            }else{
                msg = msgText + String(format:"\nInterval: %.03f seconds",timeInterval)
                title = "Result"
            }
            let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            self.customizeAC(ac:ac)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: {
                action in
                self.dbrManager?.isCurrentFrameDecodeFinished = true
                self.dbrManager?.startVidioStreamDate! = NSDate()
            })
            ac.addAction(okButton)
            self.present(ac, animated: false, completion: nil)
        }
    }
    
    @objc func didBecomeActive(notification:NSNotification) {
        if(dbrManager?.isPauseFramesComing == false)
        {
            self.turnFlashOn(on: isFlashOn)
        }
    }
    
    func configInterface()
    {
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let w = UIScreen.main.bounds.size.width
        let h = UIScreen.main.bounds.size.height
        var mainScreenLandscapeBoundary = CGRect.zero
        mainScreenLandscapeBoundary.size.width = min(w, h)
        mainScreenLandscapeBoundary.size.height = max(w, h)
        rectLayerImage?.frame = mainScreenLandscapeBoundary
        rectLayerImage?.contentMode = UIView.ContentMode.topLeft
        self.createRectBorderAndAlignControls()
        isFlashOn = false
        flashButton.layer.zPosition = 1
        detectDescLabel.layer.zPosition = 1
        choosePictureButton.layer.zPosition = 1
        choosePictureButton.sizeToFit()
        flashButton.sizeToFit()
        //flashButton.setTitle("Flash On", for: UIControl.State.normal)
        choosePictureButton.setTitle("Choose Picture from Gallery", for: UIControl.State.normal)
        let captureSession = dbrManager?.getVideoSession()
        if(captureSession == nil)
        {
            return
        }
        previewLayer = AVCaptureVideoPreviewLayer(session:captureSession!)
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer!.frame = mainScreenLandscapeBoundary
        cameraPreview = UIView()
        cameraPreview!.layer.addSublayer(previewLayer!)
        self.view.insertSubview(cameraPreview!, at: 0)
    }
    
    func createRectBorderAndAlignControls()
    {
        let width = rectLayerImage.bounds.size.width
        let height = rectLayerImage.bounds.size.height
        let widthMargin = width * 0.1
        let heightMargin = (height - width + 2 * widthMargin) / 2
        UIGraphicsBeginImageContext(self.rectLayerImage.bounds.size)
        let ctx = UIGraphicsGetCurrentContext()
        //1. draw gray rect
        UIColor.black.setFill()
        ctx!.fill(CGRect(x: 0, y: 0, width: widthMargin, height: height))
        ctx!.fill(CGRect(x: 0, y: 0, width: width, height: heightMargin))
        ctx!.fill(CGRect(x: width - widthMargin, y: 0, width: widthMargin, height: height))
        ctx!.fill(CGRect(x: 0, y: height - heightMargin, width: width, height: heightMargin))
        //2. draw red line
        var points = [CGPoint](repeating:CGPoint.zero, count: 2)
        //3. draw white rect
        UIColor.white.setStroke()
        ctx!.setLineWidth(1.0)
        // draw left side
        points[0] = CGPoint(x:widthMargin,y:heightMargin)
        points[1] = CGPoint(x:widthMargin,y:height - heightMargin)
        ctx!.strokeLineSegments(between: points)
        // draw right side
        points[0] = CGPoint(x:width - widthMargin,y:heightMargin)
        points[1] = CGPoint(x:width - widthMargin,y:height - heightMargin)
        ctx!.strokeLineSegments(between: points)
        // draw top side
        points[0] = CGPoint(x:widthMargin,y:heightMargin)
        points[1] = CGPoint(x:width - widthMargin,y:heightMargin)
        ctx!.strokeLineSegments(between: points)
        // draw bottom side
        points[0] = CGPoint(x:widthMargin,y:height - heightMargin)
        points[1] = CGPoint(x:width - widthMargin,y:height - heightMargin)
        ctx!.strokeLineSegments(between: points)
        //4. draw orange corners
        UIColor.orange.setStroke()
        ctx!.setLineWidth(2.0)
        // draw left up corner
        points[0] = CGPoint(x:widthMargin - 2,y:heightMargin - 2)
        points[1] = CGPoint(x:widthMargin + 18,y:heightMargin - 2)
        ctx!.strokeLineSegments(between: points)
        points[0] = CGPoint(x:widthMargin - 2,y:heightMargin - 2)
        points[1] = CGPoint(x:widthMargin - 2,y:heightMargin + 18)
        ctx!.strokeLineSegments(between: points)
        // draw left bottom corner
        points[0] = CGPoint(x:widthMargin - 2,y:height - heightMargin + 2)
        points[1] = CGPoint(x:widthMargin + 18,y:height - heightMargin + 2)
        ctx!.strokeLineSegments(between: points)
        points[0] = CGPoint(x:widthMargin - 2,y:height - heightMargin + 2)
        points[1] = CGPoint(x:widthMargin - 2,y:height - heightMargin - 18)
        ctx!.strokeLineSegments(between: points)
        // draw right up corner
        points[0] = CGPoint(x:width - widthMargin + 2,y:heightMargin - 2)
        points[1] = CGPoint(x:width - widthMargin - 18,y:heightMargin - 2)
        ctx!.strokeLineSegments(between: points)
        points[0] = CGPoint(x:width - widthMargin + 2,y:heightMargin - 2)
        points[1] = CGPoint(x:width - widthMargin + 2,y:heightMargin + 18)
        ctx!.strokeLineSegments(between: points)
        // draw right bottom corner
        points[0] = CGPoint(x:width - widthMargin + 2,y:height - heightMargin + 2)
        points[1] = CGPoint(x:width - widthMargin - 18,y:height - heightMargin + 2)
        ctx!.strokeLineSegments(between: points)
        points[0] = CGPoint(x:width - widthMargin + 2,y:height - heightMargin + 2)
        points[1] = CGPoint(x:width - widthMargin + 2,y:height - heightMargin - 18)
        ctx!.strokeLineSegments(between: points)
        //5. set image
        rectLayerImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //6. align detectDescLabel horizontal center
        var tempFrame = detectDescLabel.frame
        tempFrame.origin.x = (width - detectDescLabel.bounds.size.width) / 2
        tempFrame.origin.y = heightMargin * 0.6
        detectDescLabel.frame = tempFrame
        //7. align flashButton horizontal center
        tempFrame = flashButton.frame
        tempFrame.origin.x = (width - flashButton.bounds.size.width) / 2
        tempFrame.origin.y = (heightMargin + (width - widthMargin * 2) + height) * 0.5 - flashButton.bounds.size.height * 0.5
        flashButton.frame = tempFrame
        //7. align flashButton horizontal center
        tempFrame = choosePictureButton.frame
        tempFrame.origin.x = (width - choosePictureButton.bounds.size.width) / 1.5
        tempFrame.origin.y = (heightMargin + (width - widthMargin * 2) + height) * 0.55 - choosePictureButton.bounds.size.height * 0.5
        choosePictureButton.frame = tempFrame
        return
    }
    
    func turnFlashOn(on: Bool){
        do
        {
            let device = AVCaptureDevice.default(for: AVMediaType.video)
            if (device != nil && device!.hasTorch){
                try device!.lockForConfiguration()
                if (on == true) {
                    device!.torchMode = AVCaptureDevice.TorchMode.on
                    flashButton.setImage(UIImage(named: "flash_off"), for: UIControl.State.normal)
                    flashButton.setTitle("Flash off", for: UIControl.State.normal)
                } else {
                    device?.torchMode = AVCaptureDevice.TorchMode.off
                    flashButton.setImage(UIImage(named: "flash_on"), for: UIControl.State.normal)
                    flashButton.setTitle("Flash on", for: UIControl.State.normal)
                }
                device?.unlockForConfiguration()
            }
        
        }
        catch{
            print(error)
        }
    }
    
    func customizeAC(ac: UIAlertController){
        
        let subView1 = ac.view.subviews[0] as UIView
        let subView2 = subView1.subviews[0] as UIView
        let subView3 = subView2.subviews[0] as UIView
        let subView4 = subView3.subviews[0] as UIView
        let subView5 = subView4.subviews[0] as UIView
        
        for i in 0 ..< subView5.subviews.count
        {
            if(subView5.subviews[i].isKind(of: UILabel.self))
            {
                let label = subView5.subviews[i] as! UILabel
                label.textAlignment = NSTextAlignment.left
            }
        }
    }
    
    @IBAction func onFlashButtonClick(_ sender: Any) {
        isFlashOn = isFlashOn == true ? false : true
        self.turnFlashOn(on: isFlashOn)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            
            dbrManager?.stillImageDecode(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
