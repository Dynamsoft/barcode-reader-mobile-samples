/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class CameraViewController: UIViewController {

    var cameraView = CameraView()
    let dce = CameraEnhancer()
    let cvr = CaptureVisionRouter()
    var isConfirmed = false
    
    struct BarcodeSummary {
        let format: String
        let text: String
        var qty: Int
    }

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
        dce.open()
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
        dce.close()
        cvr.stopCapturing()
        dce.clearBuffer()
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
        
        let filter = MultiFrameResultCrossFilter()
        filter.enableLatestOverlapping(.barcode, isEnabled: true)
        cvr.addResultFilter(filter)
    }
    
    func setupUI() {
        let confirm = UIButton(type: .system)
        confirm.setTitle("Confirm", for: .normal)
        confirm.setTitleColor(.white, for: .normal)
        confirm.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        confirm.backgroundColor = .orange
        confirm.layer.cornerRadius = 8
        confirm.layer.masksToBounds = true
        confirm.addTarget(self, action: #selector(onConfirm), for: .touchUpInside)
        
        view.addSubview(confirm)
        confirm.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        
        let titleView = UIView()
        titleView.backgroundColor = .black
        titleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
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
            titleLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            
            button.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 30),
            
            confirm.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -30),
            confirm.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            confirm.widthAnchor.constraint(equalToConstant: 120),
            confirm.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc func onBack() {
        self.resultView.isHidden = true
        dce.open()
    }
    
    @objc func onConfirm() {
        isConfirmed = true
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
    // Implement the callback method to receive DecodedBarcodesResult.
    // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
    // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {

        guard isConfirmed, let items = result.items, !items.isEmpty else { return }
        isConfirmed = false
        dce.close()
        dce.clearBuffer()
        var map: [String: BarcodeSummary] = [:]

        for item in items {
            let format = item.formatString
            let text = item.text

            let key = "\(format)|\(text)"

            if var existing = map[key] {
                existing.qty += 1
                map[key] = existing
            } else {
                map[key] = BarcodeSummary(
                    format: format,
                    text: text,
                    qty: 1
                )
            }
        }

        let summaries = Array(map.values)

        DispatchQueue.main.async {
            self.showBarcodes(summaries)
        }
    }
    
    func showBarcodes(_ summaries: [BarcodeSummary]) {

        var output = ""

        for (index, item) in summaries.enumerated() {
            output += """
            \(index + 1). Format: \(item.format)
               Text: \(item.text)
               Qty \(item.qty)\n\n
            """
        }

        self.resultView.isHidden = false
        self.titleLabel.text = "Scanned \(summaries.reduce(0) { $0 + $1.qty }) Barcodes"
        self.textView.text = output
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
