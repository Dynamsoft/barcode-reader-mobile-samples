/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftLicense
import DynamsoftCaptureVisionRouter
import DynamsoftCameraEnhancer
import DynamsoftBarcodeReader
import DynamsoftUtility

class ViewController: UIViewController, CapturedResultReceiver {
    
    var didFinish = false
    let multipleName = "ReadMultipleBarcodes"
    let path = Bundle.main.path(forResource: "ReadMultipleBarcodes", ofType: "json")!
    let cvr = CaptureVisionRouter()
    var cameraView:CameraView!
    let dce = CameraEnhancer()
    var data:ImageData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLicense()
        setUpCamera()
        setUpDCV()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Decode Multiple Barcodes"
        dce.open()
        cvr.startCapturing(multipleName) { isSuccess, error in
            if (!isSuccess) {
                if let error = error {
                    self.showResult("Error", error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cvr.stopCapturing()
        dce.close()
        dce.clearBuffer()
    }
    
    func setUpCamera() {
        cameraView = .init()
        view.insertSubview(cameraView, at: 0)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        dce.cameraView = cameraView
        dce.colourChannelUsageType = .fullChannel
    }
    
    func setUpDCV() {
        try! cvr.initSettingsFromFile(path)
        // Set the camera enhancer as the input.
        try! cvr.setInput(dce)
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        cvr.addResultReceiver(self)
        let filter = MultiFrameResultCrossFilter()
        filter.enableLatestOverlapping(.barcode, isEnabled: true)
        filter.setMaxOverlappingFrames(.barcode, maxOverlappingFrames: 10)
        cvr.addResultFilter(filter)
    }
    
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        if didFinish {
            didFinish = false
            if let items = result.items, items.count > 0 {
                cvr.stopCapturing()
                guard let data = cvr.getIntermediateResultManager().getOriginalImage(result.originalImageHashId) else {
                    return
                }
                self.data = data
                DispatchQueue.main.async {
                    let vc = ResultViewController()
                    vc.data = data
                    vc.items = items
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    @IBAction func onTouchUp(_ sender: Any) {
        didFinish = true
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

// MARK: LicenseVerificationListener
extension ViewController: LicenseVerificationListener {
    
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if !isSuccess {
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
}
