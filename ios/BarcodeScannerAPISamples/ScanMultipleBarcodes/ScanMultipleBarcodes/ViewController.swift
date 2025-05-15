/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftBarcodeReaderBundle

class ViewController: UIViewController {
    
    let button = UIButton()
    let label = UILabel()
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "ScanMultipleBarcodes"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .darkText
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    @objc func buttonTapped() {
        let vc = BarcodeScannerViewController()
        let config = BarcodeScannerConfig()
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        config.license = "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9"
        config.scanningMode = .multiple
        // You can use the following code to specify the barcode format. If you are using a template file, the "BarcodeFormat" can also be specified via the template file.
        /* config.barcodeFormats = [.oneD, .qrCode] */
        // If you have a customized template file, please put it under "DynamsoftResources.bundle\Templates\" and call the following code.
        /* config.templateFile = "ReadMultipleBarcodes.json" */
        // The following settings will display a scan region on the view. Only the barcode in the scan region can be decoded.
        /*
         let region = Rect()
         region.left = 0.15
         region.top = 0.3
         region.right = 0.85
         region.bottom = 0.7
         config.scanRegion = region
         */
        // Uncomment the following line to enable the beep sound when a barcode is scanned.
        /* config.isBeepEnabled = true */
        // Uncomment the following line if you don't want to display the torch button.
        /* config.isTorchButtonVisible = false */
        // Uncomment the following line if you don't want to display the close button.
        /* config.isCloseButtonVisible = false */
        // Uncomment the following line if you want to hide the scan laser.
        /* config.isScanLaserVisible = false */
        // Uncomment the following line if you want the camera to auto-zoom when the barcode is far away.
        /* config.isAutoZoomEnabled = true */
        vc.config = config
        
        vc.onScannedResult = { [weak self] result in
            guard let self = self else { return }
            switch result.resultStatus {
            case .finished:
                DispatchQueue.main.async {
                    if let items = result.barcodes {
                        var text:String = " Total Results: \(items.count)\n\n"
                        var index = 1
                        for item in result.barcodes! {
                            text += String(format: "%2d. Format: %@\n    Text: %@\n\n", index, item.formatString, item.text)
                            index += 1
                        }
                        self.textView.text = text
                    }
                    self.textView.isHidden = false
                    self.label.isHidden = true
                }
            case .canceled:
                DispatchQueue.main.async {
                    self.label.text = "Scan canceled"
                    self.textView.isHidden = true
                    self.label.isHidden = false
                }
            case .exception:
                DispatchQueue.main.async {
                    self.label.text = result.errorString
                    self.textView.isHidden = true
                    self.label.isHidden = false
                }
            @unknown default:
                break
            }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setup() {
        button.backgroundColor = .black
        button.setTitle("Scan Barcodes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -32),
            button.heightAnchor.constraint(equalToConstant: 48),
            button.widthAnchor.constraint(equalToConstant: 160),
            
            label.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -32),
            label.bottomAnchor.constraint(lessThanOrEqualTo: button.topAnchor, constant: -8),
            
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 32),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -32),
            textView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16)
        ])
    }
}

