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

class ViewController: UIViewController, CapturedResultReceiver {

    var cameraView:CameraView!
    let dce = CameraEnhancer()
    let cvr = CaptureVisionRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpCamera()
        setUpDCV()
    }

    override func viewWillAppear(_ animated: Bool) {
        dce.open()
        cvr.startCapturing(PresetTemplate.readBarcodes.rawValue) { isSuccess, error in
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
        super.viewWillDisappear(animated)
    }
    
    func setUpCamera() {
        cameraView = .init(frame: view.bounds)
        cameraView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(cameraView, at: 0)
        dce.cameraView = cameraView
    }
    
    func setUpDCV() {
        try! cvr.setInput(dce)
        cvr.addResultReceiver(self)
    }
    
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        if let items = result.items, items.count > 0 {
            DispatchQueue.main.async {
                self.cvr.stopCapturing()
            }
            var message = ""
            for item in items {
                message = String(format:"\nFormat: %@\nText: %@\n", item.formatString, item.text)
            }
            showResult("Results", message) {
                self.cvr.startCapturing(PresetTemplate.readBarcodes.rawValue)
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

