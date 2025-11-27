/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import Foundation
import UIKit
import DynamsoftCaptureVisionBundle

class CameraViewController: UIViewController, CapturedResultReceiver {
    
    weak var delegate: PopViewControllerDelegate?
    var text:String?
    var isStartSearching:Bool = false
    let multipleName = "ReadMultipleBarcodes"
    let defaultName = PresetTemplate.readBarcodes.rawValue
    let path = Bundle.main.path(forResource: "ReadMultipleBarcodes", ofType: "json")!
    let cvr = CaptureVisionRouter()
    var cameraView:CameraView!
    let dce = CameraEnhancer()
    var drawingLayer:DrawingLayer!
    let greenStyleId = DrawingStyleManager.createDrawingStyle(.green, strokeWidth: 2.0, fill: .green, textColor: .white, font: UIFont.systemFont(ofSize: 15.0))
    let redStyleId = DrawingStyleManager.createDrawingStyle(.red, strokeWidth: 2.0, fill: .red, textColor: .white, font: UIFont.systemFont(ofSize: 15.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLicense()
        setUpCamera()
        setUpDCV()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Locate Item"
        self.navigationController?.navigationBar.isHidden = false
        dce.open()
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        var name:String
        if isStartSearching {
            name = multipleName
        } else {
            name = defaultName
            try! cvr.resetSettings()
        }
        cvr.startCapturing(name) { isSuccess, error in
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
        cameraView.torchButtonVisible = true
        let layer = cameraView.getDrawingLayer(DrawingLayerId.DBR.rawValue)
        layer?.visible = false
        drawingLayer = cameraView.createDrawingLayer()
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
    
    func setUpUI() {
        let safeArea = view.safeAreaLayoutGuide
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Locate another item", for: .normal)
        button.backgroundColor = .orange
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.tintColor = .white
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            button.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc
    func click() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        if let items = result.items, items.count > 0 {
            if !isStartSearching {
                DispatchQueue.main.async {
                    self.cvr.stopCapturing()
                    self.dce.clearBuffer()
                    self.delegate?.didReceiveText(text: items.first?.text)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                var drawingItems:[DrawingItem] = []
                for item in items {
                    let radius = 30.0
                    let arcItem = ArcDrawingItem(centre: item.location.centrePoint, radius: radius)
                    var str = ""
                    if item.text == text {
                        str = "+"
                    } else {
                        str = "✕"
                    }
                    let font = DrawingStyleManager.getDrawingStyle(arcItem.drawingStyleId)?.font ?? UIFont.systemFont(ofSize: 15)
                    let size = (str as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
                    let width = ceil(size.width)
                    let height = ceil(size.height)
                    let point = dce.convertPointToViewCoordinates(item.location.centrePoint)
                    let symbolTextItem = TextDrawingItem(text: str, topLeftPoint: CGPoint(x: point.x - width/2, y: point.y - height/2), width: UInt(width), height: 0)
                    symbolTextItem.coordinateBase = .view
                    if item.text == text {
                        let textItem = TextDrawingItem(text: item.text, topLeftPoint: CGPoint(x: item.location.centrePoint.x - item.location.boundingRect.width/2, y: item.location.centrePoint.y + radius + 10), width: UInt(item.location.boundingRect.width), height: 0)
                        arcItem.drawingStyleId  = greenStyleId
                        symbolTextItem.drawingStyleId = greenStyleId
                        textItem.drawingStyleId = greenStyleId
                        drawingItems.append(contentsOf: [arcItem, symbolTextItem, textItem])
                    } else {
                        arcItem.drawingStyleId  = redStyleId
                        symbolTextItem.drawingStyleId = redStyleId
                        drawingItems.append(contentsOf: [arcItem, symbolTextItem])
                    }
                }
                drawingLayer.drawingItems = drawingItems
            }
        } else {
            drawingLayer.drawingItems = nil
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

// MARK: LicenseVerificationListener
extension CameraViewController: LicenseVerificationListener {
    
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
