//
//  DbrManager.swift
//  DBRwithoutDCE
//
//  Created by Amro Ibrahim on 2022-02-23.
//

import Foundation
import UIKit
import AVFoundation
import DynamsoftBarcodeReader

class DbrManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, DMDLSLicenseVerificationDelegate {
    var barcodeFormat:Int?
    var barcodeFormat2:Int?
    var startRecognitionDate:NSDate?
    var startVidioStreamDate:NSDate?
    var isPauseFramesComing:Bool?
    var isCurrentFrameDecodeFinished:Bool?
    var adjustingFocus:Bool?
    var m_videoCaptureSession:AVCaptureSession!
    var barcodeReader: DynamsoftBarcodeReader!
    var settings:iPublicRuntimeSettings?
    var m_recognitionCallback:Selector?
    var m_recognitionReceiver:ViewController?
    var m_verificationCallback:Selector?
    var m_verificationReceiver:ViewController?

    var inputDevice:AVCaptureDevice?
    var itrFocusFinish:Int!
    var firstFocusFinish:Bool!
    init(DLS:iDMDLSConnectionParameters) {
        super.init()
        barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: DLS, verificationDelegate: self)
        
        self.parametersInit()
    }
    
    init(license:String)
    {
        super.init()
        barcodeReader = DynamsoftBarcodeReader(license: license)
        
        //Best Coverage settings
        //barcodeReader.initRuntimeSettings(with: "{\"ImageParameter\":{\"Name\":\"BestCoverage\",\"DeblurLevel\":9,\"ExpectedBarcodesCount\":512,\"ScaleDownThreshold\":100000,\"LocalizationModes\":[{\"Mode\":\"LM_CONNECTED_BLOCKS\"},{\"Mode\":\"LM_SCAN_DIRECTLY\"},{\"Mode\":\"LM_STATISTICS\"},{\"Mode\":\"LM_LINES\"},{\"Mode\":\"LM_STATISTICS_MARKS\"}],\"GrayscaleTransformationModes\":[{\"Mode\":\"GTM_ORIGINAL\"},{\"Mode\":\"GTM_INVERTED\"}]}}", conflictMode: EnumConflictMode.overwrite, error: nil)
        //Best Speed settings
        //barcodeReader.initRuntimeSettings(with: "{\"ImageParameter\":{\"Name\":\"BestSpeed\",\"DeblurLevel\":3,\"ExpectedBarcodesCount\":512,\"LocalizationModes\":[{\"Mode\":\"LM_SCAN_DIRECTLY\"}],\"TextFilterModes\":[{\"MinImageDimension\":262144,\"Mode\":\"TFM_GENERAL_CONTOUR\"}]}}", conflictMode: EnumConflictMode.overwrite, error: nil)
        //balance settings
        barcodeReader.initRuntimeSettings(with: "{\"ImageParameter\":{\"Name\":\"Balance\",\"DeblurLevel\":5,\"ExpectedBarcodesCount\":512,\"LocalizationModes\":[{\"Mode\":\"LM_CONNECTED_BLOCKS\"},{\"Mode\":\"LM_SCAN_DIRECTLY\"}]}}", conflictMode: EnumConflictMode.overwrite, error:nil)
        settings = try! barcodeReader.getRuntimeSettings()
        settings!.barcodeFormatIds = Int(EnumBarcodeFormat.ONED.rawValue) | Int(EnumBarcodeFormat.PDF417.rawValue) | Int(EnumBarcodeFormat.QRCODE.rawValue) | Int(EnumBarcodeFormat.DATAMATRIX.rawValue)
        settings!.barcodeFormatIds_2 = Int(EnumBarcodeFormat2.Null.rawValue)
        barcodeReader.update(settings!, error: nil)
        self.parametersInit()
    }
    
    deinit {
        barcodeReader = nil
        if(m_videoCaptureSession != nil)
        {
            if(m_videoCaptureSession.isRunning)
            {
                m_videoCaptureSession.stopRunning()
            }
            m_videoCaptureSession = nil
        }
        inputDevice = nil
        m_recognitionReceiver = nil
        m_recognitionCallback = nil
        m_verificationReceiver = nil
        m_verificationCallback = nil
    }
    
    func connectServerAfterInit(DLS:iDMDLSConnectionParameters)
    {
        barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: DLS, verificationDelegate: self)
    }
    
    func parametersInit()
    {
        m_videoCaptureSession = nil
        isPauseFramesComing = false
        isCurrentFrameDecodeFinished = true
        barcodeFormat = Int(EnumBarcodeFormat.ONED.rawValue) | Int(EnumBarcodeFormat.PDF417.rawValue) | Int(EnumBarcodeFormat.QRCODE.rawValue) | Int(EnumBarcodeFormat.DATAMATRIX.rawValue)
        barcodeFormat2 = 0
        startRecognitionDate = nil
        m_recognitionReceiver = nil
        startVidioStreamDate  = NSDate()
        adjustingFocus = true
        itrFocusFinish = 0
        firstFocusFinish = false
    }
    
    func setBarcodeFormat(format:Int, format2:Int)
    {
        do
        {
            barcodeFormat = format
            barcodeFormat2 = format2
            let settings = try barcodeReader.getRuntimeSettings()
            settings.barcodeFormatIds = format
            settings.barcodeFormatIds_2 = format2
            barcodeReader.update(settings, error: nil)
        }
        catch{
            print(error)
        }
    }
    
    func setVideoSession()
    {
        do
        {
            inputDevice = self.getAvailableCamera()
            let tInputDevice = inputDevice!
            let captureInput = try? AVCaptureDeviceInput(device: tInputDevice)
            let captureOutput = AVCaptureVideoDataOutput.init()
            captureOutput.alwaysDiscardsLateVideoFrames = true
            var queue:DispatchQueue
            queue = DispatchQueue(label: "dbrCameraQueue")
            captureOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
            
            // Enable continuous autofocus
            if(tInputDevice.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus))
            {
                try tInputDevice.lockForConfiguration()
                tInputDevice.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                tInputDevice.unlockForConfiguration()
            }
            
            // Enable AutoFocusRangeRestriction
            if(tInputDevice.isAutoFocusRangeRestrictionSupported)
            {
                try tInputDevice.lockForConfiguration()
                tInputDevice.autoFocusRangeRestriction = AVCaptureDevice.AutoFocusRangeRestriction.near
                tInputDevice.unlockForConfiguration()
            }
            //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange and kCVPixelFormatType_32BGRA
            captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
            
            if(captureInput == nil)
            {
                return
            }
            self.m_videoCaptureSession = AVCaptureSession.init()
            self.m_videoCaptureSession.addInput(captureInput!)
            self.m_videoCaptureSession.addOutput(captureOutput)
            
            if(self.m_videoCaptureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1920x1080"))){
                self.m_videoCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1920x1080")
            }
            else if(self.m_videoCaptureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720"))){
                self.m_videoCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720")
            }
            else if(self.m_videoCaptureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset640x480"))){
                self.m_videoCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset640x480")
            }
        }catch{
            print(error)
        }
    }
    
    func startVideoSession()
    {
        if(!self.m_videoCaptureSession.isRunning)
        {
            self.m_videoCaptureSession.startRunning()
        }
    }
    
    func getAvailableCamera() -> AVCaptureDevice {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified
        )
        //let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video)
        let videoDevices = deviceDiscoverySession.devices
        var captureDevice:AVCaptureDevice?
        for device in videoDevices
        {
            if(device.position == AVCaptureDevice.Position.back)
            {
                captureDevice = device
                break
            }
        }
        if(captureDevice != nil)
        {
            captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        }
        return captureDevice!
    }
    
    func getVideoSession() -> AVCaptureSession
    {
        return m_videoCaptureSession
    }
    
    //AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        if(inputDevice == nil)
        {
            return
        }
        
        if(inputDevice?.isAdjustingFocus == false)
        {
            itrFocusFinish = itrFocusFinish + 1
            if(itrFocusFinish == 1)
            {
                firstFocusFinish = true
            }
        }
        if(!firstFocusFinish || isPauseFramesComing == true || isCurrentFrameDecodeFinished == false)
        {
            return
        }

        isCurrentFrameDecodeFinished = false
        let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bufferSize = CVPixelBufferGetDataSize(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let bpr = CVPixelBufferGetBytesPerRow(imageBuffer)
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        startRecognitionDate = NSDate()
        let buffer = Data(bytes: baseAddress!, count: bufferSize)
        guard let results = try? barcodeReader.decodeBuffer(buffer, withWidth: width, height: height, stride: bpr, format: .ARGB_8888, templateName: "") else { return }
        DispatchQueue.main.async{
            self.m_recognitionReceiver?.perform(self.m_recognitionCallback!, with: results as NSArray)
        }
    }
    
    func stillImageDecode(_ image: UIImage) {
        //let image: UIImage? = UIImage()
        //let error: NSError? = NSError()
        guard let results = try? barcodeReader.decode(image, withTemplate: "") else {return}
        isPauseFramesComing = false
        DispatchQueue.main.async{
            self.m_recognitionReceiver?.perform(self.m_recognitionCallback!, with: results as NSArray)
        }
        
        //return result
    }
    
    func setRecognitionCallback(sender:ViewController, callBack:Selector)
    {
        m_recognitionReceiver = sender
        m_recognitionCallback = callBack
    }
    
    func setServerLicenseVerificationCallback(sender:ViewController, callBack:Selector)
    {
        m_verificationReceiver = sender
        m_verificationCallback = callBack
    }
    
    /*func ltsLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        let boolNumber = NSNumber(value: isSuccess)
        DispatchQueue.main.async{
            self.m_verificationReceiver?.perform(self.m_verificationCallback!, with: boolNumber, with: error)
        }
    }*/
    
    func dlsLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        let boolNumber = NSNumber(value: isSuccess)
        DispatchQueue.main.async{
            self.m_verificationReceiver?.perform(self.m_verificationCallback!, with: boolNumber, with: error)
        }
    }
}
