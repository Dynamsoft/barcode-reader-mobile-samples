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
    var drawingLayer: DrawingLayer?
    
    private var savedBarcodeSet = Set<String>()
    private var savedBarcodes: [(format: String, text: String)] = []
    private var isConfirmed = false
    
    private let collapsedHeight: CGFloat = 50
    private let expandedHeightMultiplier: CGFloat = 0.4
    private var resultViewHeightConstraint: NSLayoutConstraint!
    private var isExpanded = false
    
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
    let arrowButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .orange
        btn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        return btn
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
        
        cameraView.getDrawingLayer(DrawingLayerId.DBR.rawValue)?.visible = false
        drawingLayer = cameraView.createDrawingLayer()
    }
    
    func setupUI() {
        let captureButton  = UIButton(type: .system)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.backgroundColor = .orange
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        captureButton.layer.cornerRadius = 8
        captureButton.layer.masksToBounds = true
        captureButton.addTarget(self, action: #selector(onTouchUp), for: .touchUpInside)
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48),
            captureButton.widthAnchor.constraint(equalToConstant: 120),
            captureButton.heightAnchor.constraint(equalToConstant: 48),
        ])
        
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
        
        arrowButton.addTarget(self, action: #selector(toggleResultView), for: .touchUpInside)
        titleView.addSubview(arrowButton)
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrowButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            arrowButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            arrowButton.widthAnchor.constraint(equalToConstant: 36),
            arrowButton.heightAnchor.constraint(equalToConstant: 36),
        ])
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            resultView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textView.leadingAnchor.constraint(equalTo: resultView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            textView.bottomAnchor.constraint(equalTo: resultView.bottomAnchor),
            
            titleView.leadingAnchor.constraint(equalTo: resultView.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: resultView.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: resultView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: textView.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: arrowButton.leadingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
        ])
        
        resultViewHeightConstraint = resultView.heightAnchor.constraint(equalToConstant: collapsedHeight)
        resultViewHeightConstraint.isActive = true
    }
}

extension CameraViewController: CapturedResultReceiver {
    // Implement the callback method to receive DecodedBarcodesResult.
    // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
    // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {

        guard let items = result.items, !items.isEmpty else {
            DispatchQueue.main.async {
                self.drawingLayer?.clearDrawingItems()
            }
            return
        }
        if isConfirmed {
            isConfirmed = false
            savedBarcodeSet.removeAll()
            savedBarcodes.removeAll()
            for item in items {
                    let format = item.formatString
                    let text = item.text

                    let key = "\(format)|\(text)"

                    if savedBarcodeSet.contains(key) {
                        continue
                    }

                    savedBarcodeSet.insert(key)
                    savedBarcodes.append((format: format, text: text))
                }

            DispatchQueue.main.async {
                self.showBarcodes()
            }
        } else {
            var drawingItems: [QuadDrawingItem] = []
            for item in items {
                let format = item.formatString
                let text = item.text
                let key = "\(format)|\(text)"
                if savedBarcodeSet.contains(key) {
                    drawingItems.append(QuadDrawingItem(drawingStyleId: DrawingStyleId.greenStroke.rawValue, state: .default, coordinateBase: .image, quadrilateral: item.location))
                } else {
                    drawingItems.append(QuadDrawingItem(drawingStyleId: DrawingStyleId.orangeStroke.rawValue, state: .default, coordinateBase: .image, quadrilateral: item.location))
                }
            }
            
            DispatchQueue.main.async {
                self.drawingLayer?.drawingItems = drawingItems
            }
        }
    }
    
    func showBarcodes() {

        let output = savedBarcodes.enumerated().map { index, item in
            """
            \(index + 1). Format: \(item.format)
               Text: \(item.text)
            """
        }.joined(separator: "\n\n")

        resultView.isHidden = false
        titleLabel.text = "Scanned \(savedBarcodes.count) Unique Barcodes"
        textView.text = output
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

// MARK: Selector
extension CameraViewController {
    @objc private func toggleResultView() {
        isExpanded.toggle()

        resultViewHeightConstraint.isActive = false

        if isExpanded {
            resultViewHeightConstraint = resultView.heightAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor,
                            multiplier: expandedHeightMultiplier)

            arrowButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            resultView.isHidden = false
        } else {
            resultViewHeightConstraint = resultView.heightAnchor
                .constraint(equalToConstant: collapsedHeight)

            arrowButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        }

        resultViewHeightConstraint.isActive = true

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func onBack() {
        self.resultView.isHidden = true
    }
    
    @objc func onTouchUp() {
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
