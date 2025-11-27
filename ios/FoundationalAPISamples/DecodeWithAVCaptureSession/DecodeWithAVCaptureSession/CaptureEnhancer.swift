/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import Foundation
import UIKit
import AVFoundation
import DynamsoftCaptureVisionBundle

// Let the class implement ImageSourceAdapter so that is can be set as the standard input of Dynamsoft Capture Vision.
class CaptureEnhancer: ImageSourceAdapter, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    override init() {
        super.init()
        setUpCamera()
    }
    
    func setUpCamera() {
        let device = AVCaptureDevice.default(for: .video)
        if let device {
            var input: AVCaptureDeviceInput?
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch {
                print(error)
            }
            if let input {
                if session.canAddInput(input) {
                    session.addInput(input)
                }
            }
        } else {
            print("AVCaptureDevice init failed")
        }
        let output = AVCaptureVideoDataOutput.init()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        output.setSampleBufferDelegate(self, queue: queue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
    }
    
    func setUpCameraView(_ view: UIView) -> Void {
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
    }
    
    func startRunning() {
        if !session.isRunning {
            queue.async {
                self.session.startRunning()
            }
            setImageFetchState(true)
        }
    }
    
    func stopRunning() {
        if session.isRunning {
            queue.async {
                self.session.stopRunning()
            }
            setImageFetchState(false)
            clearBuffer()
        }
    }
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }()
    
    lazy var queue: DispatchQueue = {
        let queue = DispatchQueue(label: "queue")
        return queue
    }()
    
    lazy var session: AVCaptureSession = {
        let session = AVCaptureSession.init()
        session.sessionPreset = .hd1920x1080
        return session
    }()
    
    // Receive the video input and generate ImageData.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bufferSize = CVPixelBufferGetDataSize(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        let buffer = Data(bytes: baseAddress!, count: bufferSize)
        
        let imageData = ImageData(bytes: buffer, width: UInt(width), height: UInt(height), stride: UInt(bytesPerRow), format: .ARGB8888, orientation: 0, tag: nil)
        addImageToBuffer(imageData)
    }
}
