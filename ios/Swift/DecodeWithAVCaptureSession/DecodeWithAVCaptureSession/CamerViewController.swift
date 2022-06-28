//
//  CamerViewController.swift
//  DecodeWithAVCaptureSession
//
//  Created by admin on 2022/6/16.
//

import Foundation
import AVFoundation
import DynamsoftBarcodeReader

class CamerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ImageSource, DBRTextResultListener{
    
    var barcodeReader:DynamsoftBarcodeReader! = nil
    var imageData:iImageData! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setDBR()
        setSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        barcodeReader.startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        barcodeReader.stopScanning()
    }
    
    func setDBR() {
        barcodeReader = DynamsoftBarcodeReader.init()
        barcodeReader.updateRuntimeSettings(EnumPresetTemplate.videoSpeedFirst)
        barcodeReader.setImageSource(self)
        barcodeReader.setDBRTextResultListener(self)
    }

    func setSession() {
        let session = AVCaptureSession.init()
        session.sessionPreset = .hd1920x1080
        let device = AVCaptureDevice.default(
            for: .video)
        var input: AVCaptureDeviceInput? = nil
        do {
            if let device = device {
                input = try AVCaptureDeviceInput(
                    device: device)
            }
        } catch {
        }
        
        if (input == nil) {
            // Handling the error appropriately.
        }
        session.addInput(input!)
        
        let output = AVCaptureVideoDataOutput.init()
        session.addOutput(output)
        var queue:DispatchQueue
        queue = DispatchQueue(label: "queue")
        output.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
        
        let w = UIScreen.main.bounds.size.width
        let h = UIScreen.main.bounds.size.height
        var mainScreen = CGRect.zero
        mainScreen.size.width = min(w, h)
        mainScreen.size.height = max(w, h)
            
        let preLayer = AVCaptureVideoPreviewLayer(session: session)
        preLayer.frame = mainScreen
        preLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preLayer)
        session.startRunning()
    }
    
    func getImage() -> iImageData? {
        return imageData
    }
    
    func textResultCallback(_ frameId: Int, imageData: iImageData, results: [iTextResult]?) {
        if results!.count > 0 {
            var msgText:String = ""
            let title:String = "Results"
            for item in results! {
                if item.barcodeFormat_2.rawValue != 0 {
                    msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", item.barcodeFormatString_2!, item.barcodeText ?? "noResuslt")
                }else{
                    msgText = msgText + String(format:"\nFormat: %@\nText: %@\n", item.barcodeFormatString!,item.barcodeText ?? "noResuslt")
                }
            }
            showResult(title, msgText, "OK") {
            }
        }else{
            return
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bufferSize = CVPixelBufferGetDataSize(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let bpr = CVPixelBufferGetBytesPerRow(imageBuffer)
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        let buffer = Data(bytes: baseAddress!, count: bufferSize)
        
        if (imageData == nil) {
            imageData = iImageData.init()
        }
        imageData.bytes = buffer
        imageData.width = width
        imageData.height = height
        imageData.stride = bpr
        imageData.format = .ARGB_8888
        
    }
    
    private func showResult(_ title: String, _ msg: String, _ acTitle: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
