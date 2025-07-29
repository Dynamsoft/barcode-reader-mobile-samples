/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import Foundation
import UIKit
import DynamsoftCaptureVisionBundle

class CameraViewController: UIViewController {

    var cameraView = CameraView()
    let dce = CameraEnhancer()
    let cvr = CaptureVisionRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Barcode Scanning"
        setLicense()
        setupDCV()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dce.open()
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        cvr.startCapturing("ReadGS1AI") { isSuccess, error in
            if (!isSuccess) {
                if let error = error {
                    self.showResult("Error", error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dce.close()
        cvr.stopCapturing()
        dce.clearBuffer()
    }

    func setupDCV() {
        view.insertSubview(cameraView, at: 0)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        dce.cameraView = cameraView
        // Set the camera enhancer as the input.
        try! cvr.setInput(dce)
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        cvr.addResultReceiver(self)
        try! cvr.initSettingsFromFile("ReadGS1AI.json")
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CameraViewController: CapturedResultReceiver {
    
    func onParsedResultsReceived(_ result: ParsedResult) {
        if let item = result.items?.first {
            self.cvr.stopCapturing()
            let fields = item.parsedFields
            var date = ""
            if let value = fields["17Data"] {
                let year = "20" + String(value.prefix(2))
                let month = String(value.dropFirst(2).prefix(2))
                let day = String(value.dropFirst(4).prefix(2))
                if day == "00" {
                    date = "\(year).\(month)"
                } else {
                    date = "\(year).\(month).\(day)"
                }
            }
            
            let msg = (fields["01AI"] ?? "unspecified") + ": " + (fields["01Data"] ?? "unspecified") + "\n" + (fields["10AI"] ?? "unspecified") + ": " + (fields["10Data"] ?? "unspecified") + "\n" + (fields["17AI"] ?? "unspecified") + ": " + date
            showResult("GS1 Result", msg) {
                self.cvr.startCapturing("ReadGS1AI")
            }
        }
    }
}

// MARK: LicenseVerificationListener
extension CameraViewController: LicenseVerificationListener {
    func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if !isSuccess {
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
}
