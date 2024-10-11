/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCameraEnhancer
import DynamsoftCaptureVisionRouter
import DynamsoftBarcodeReader
import DynamsoftCore
import DynamsoftLicense

class ViewController: UIViewController, CapturedResultReceiver, LicenseVerificationListener {

    var cameraView:CameraView!
    let dce = CameraEnhancer()
    let cvr = CaptureVisionRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLicense()
        setUpCamera()
        setUpDCV()
    }

    override func viewWillAppear(_ animated: Bool) {
        dce.open()
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        cvr.startCapturing(PresetTemplate.readSingleBarcode.rawValue) { isSuccess, error in
            if (!isSuccess) {
                if let error = error {
                    self.showResult("Error", error.localizedDescription)
                }
            }
        }
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dce.close()
        cvr.stopCapturing()
        dce.clearBuffer()
        super.viewWillDisappear(animated)
    }
    
    func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    func displayLicenseMessage(message: String) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func setUpCamera() {
        cameraView = .init(frame: view.bounds)
        cameraView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(cameraView, at: 0)
        dce.cameraView = cameraView
    }
    
    func setUpDCV() {
        // Set the camera enhancer as the input.
        try! cvr.setInput(dce)
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        cvr.addResultReceiver(self)
    }

    // Implement the callback method to receive DecodedBarcodesResult.
    // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
    // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        if let items = result.items, items.count > 0 {
            DispatchQueue.main.async {
                self.cvr.stopCapturing()
                self.dce.clearBuffer()
            }
            var message = ""
            for item in items {
                // Extract the barcode format and the barcode text from the BarcodeResultItem.
                message = String(format:"\nFormat: %@\nText: %@\n", item.formatString, item.text)
            }
            showResult("Results", message) {
                // Restart the capture
                self.cvr.startCapturing(PresetTemplate.readSingleBarcode.rawValue)
            }
        }
    }
    
    // MARK: LicenseVerificationListener
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if !isSuccess {
            if let error = error {
                print("\(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.displayLicenseMessage(message: "License initialization failed：" + error.localizedDescription)
                }
            }
        }
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

