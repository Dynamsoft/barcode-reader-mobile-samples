/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

enum ColourMode {
    case colour
    case grayscale
    case binary
}

enum ScanRegion {
    case fullImage
    case square
    case rectangular
}

class CameraViewController: UIViewController {

    var cameraView = CameraView()
    let dce = CameraEnhancer()
    let cvr = CaptureVisionRouter()
    let imageDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var maxFrames = 10
    private var scanRegion: ScanRegion = .fullImage
    private var colourMode: ColourMode = .grayscale
    private var savedImageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Scanning"
        setLicense()
        setupDCV()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dce.open()
        
        if let savedFrames = UserDefaults.standard.value(forKey: maxFramesKey) as? Int {
            maxFrames = savedFrames
        }
        if let savedScanRegionIndex = UserDefaults.standard.value(forKey: scanRegionKey) as? Int {
            switch savedScanRegionIndex {
            case 0:
                self.scanRegion = .fullImage
                try! self.dce.setScanRegion(nil)
            case 1:
                self.scanRegion = .square
                let region = Rect(left: 0.15, top: 0.2, right: 0.85, bottom: 0.6, measuredInPercentage: true)
                try? self.dce.setScanRegion(region)
            case 2:
                self.scanRegion = .rectangular
                let region = Rect(left: 0.05, top: 0.3, right: 0.95, bottom: 0.55, measuredInPercentage: true)
                try? self.dce.setScanRegion(region)
            default:
                break
            }
        }

        if let savedColourModeIndex = UserDefaults.standard.value(forKey: colourModeKey) as? Int {
            switch savedColourModeIndex {
            case 0:
                self.colourMode = .colour
                dce.colourChannelUsageType = .fullChannel
            case 1:
                self.colourMode = .grayscale
            case 2:
                self.colourMode = .binary
            default:
                break
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
        cvr.getIntermediateResultManager().addResultReceiver(self)
    }
    
    func setupUI() {
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )
        navigationItem.rightBarButtonItem = settingsButton
        
        let button  = UIButton(type: .system)
        button.setTitle("Capture Video Frames", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onTouchUp), for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -48),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    @objc func onTouchUp() {
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        savedImageCount = 0
        cvr.startCapturing(PresetTemplate.readBarcodes.rawValue) { isSuccess, error in
            if (!isSuccess) {
                if let error = error {
                    self.showResult("Error", error.localizedDescription)
                }
            }
        }
    }
    
    @objc func openSettings() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CameraViewController: IntermediateResultReceiver {

    func onColourImageUnitReceived(_ unit: ColourImageUnit, info: IntermediateResultExtraInfo) {
        if let imageData = unit.getImageData(), self.colourMode == .colour {
            if savedImageCount >= maxFrames {
                stopAndAlert()
            } else {
                if saveImageToDocumentsDirectory(imageData: imageData, fileName: String(savedImageCount)) {
                    savedImageCount += 1
                }
            }
        }
    }
    
    func onGrayscaleImageUnitReceived(_ unit: GrayscaleImageUnit, info: IntermediateResultExtraInfo) {
        if let imageData = unit.getImageData(), self.colourMode == .grayscale {
            if savedImageCount >= maxFrames {
                stopAndAlert()
            } else {
                if saveImageToDocumentsDirectory(imageData: imageData, fileName: String(savedImageCount)) {
                    savedImageCount += 1
                }
            }
        }
    }
    
    func onBinaryImageUnitReceived(_ unit: BinaryImageUnit, info: IntermediateResultExtraInfo) {
        if let imageData = unit.getImageData(), self.colourMode == .binary {
            if savedImageCount >= maxFrames {
                stopAndAlert()
            } else {
                if saveImageToDocumentsDirectory(imageData: imageData, fileName: String(savedImageCount)) {
                    savedImageCount += 1
                }
            }
        }
    }
    
    func stopAndAlert() {
        self.cvr.stopCapturing()
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("DebugImages")
        showResult("Capture finished", "You can find the captured images under:\n \(dir)")
    }
    
    func saveImageToDocumentsDirectory(imageData: ImageData, fileName: String) -> Bool {
        do {
            let image = try imageData.toUIImage()
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let debugImagesDirectory = documentsDirectory.appendingPathComponent("DebugImages")
            
            if !fileManager.fileExists(atPath: debugImagesDirectory.path) {
                do {
                    try fileManager.createDirectory(at: debugImagesDirectory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    return false
                }
            }
            
            let fileURL = debugImagesDirectory.appendingPathComponent(fileName + ".png")
            
            if let data = image.pngData() {
                do {
                    try data.write(to: fileURL)
                    return true
                } catch {
                    return false
                }
            } else {
                return false
            }
        } catch {
            return false
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
