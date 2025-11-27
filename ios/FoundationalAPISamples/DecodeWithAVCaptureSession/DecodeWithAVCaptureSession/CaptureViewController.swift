/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle
import AVFoundation

class CaptureViewController: UIViewController {

    var capture = CaptureEnhancer()
    let cvr = CaptureVisionRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Barcode Scanning"
        setLicense()
        setupDCV()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        capture.startRunning()
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        cvr.startCapturing(PresetTemplate.readBarcodes.rawValue) { isSuccess, error in
            if (!isSuccess) {
                if let error = error {
                    self.showResult("Error", error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        capture.stopRunning()
        cvr.stopCapturing()
        capture.clearBuffer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updatePreviewLayerOrientation()
        }, completion: nil)
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.dataDetectorTypes = .link
        return textView
    }()
    
    let resultView:UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .gray
        return view
    }()
    
    func setupDCV() {
        capture.setUpCameraView(view)
        // Set the image source adapter you created as the input.
        try! cvr.setInput(capture)
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        cvr.addResultReceiver(self)
    }
    
    func setupUI() {
        let titleView = UIView()
        titleView.backgroundColor = .black
        titleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(resultView)
        resultView.translatesAutoresizingMaskIntoConstraints = false
        
        resultView.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        resultView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            resultView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textView.leadingAnchor.constraint(equalTo: resultView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            textView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.25),
            
            titleView.leadingAnchor.constraint(equalTo: resultView.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: resultView.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: resultView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: textView.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func updatePreviewLayerOrientation() {
        guard let connection = capture.previewLayer.connection else { return }
        guard connection.isVideoOrientationSupported else { return }

        let deviceOrientation = UIDevice.current.orientation
        let videoOrientation: AVCaptureVideoOrientation

        switch deviceOrientation {
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        default:
            videoOrientation = .portrait
        }

        connection.videoOrientation = videoOrientation
        capture.previewLayer.frame = view.layer.bounds
    }
}

extension CaptureViewController: CapturedResultReceiver {
    // Implement the callback method to receive DecodedBarcodesResult.
    // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
    // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        if let items = result.items, items.count > 0 {
            var text = ""
            var index = 1
            for item in items {
                text += String(format: "%2d.\tFormat: %@\n\tText: %@\n\n", index, item.formatString, item.text)
                index += 1
            }
            DispatchQueue.main.async {
                self.resultView.isHidden = false
                self.titleLabel.text = String.init(format: "  Total Results: %d", items.count)
                self.textView.text = text
            }
        }
    }
}

extension CaptureViewController: LicenseVerificationListener {
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
