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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
    }

    @objc func buttonTapped() {
        let vc = BarcodeScannerViewController()
        let config = BarcodeScannerConfig()
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        config.license = "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9"
        // You can use the following code to specify the barcode format. If you are using a template file, the "BarcodeFormat" can also be specified via the template file.
        /* config.barcodeFormats = [.oneD, .qrCode] */
        // If you have a customized template file, please put it under "DynamsoftResources.bundle\Templates\" and call the following code.
        /* config.templateFile = "ReadSingleBarcode.json" */
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
                    let format = result.barcodes?.first?.formatString ?? ""
                    self.label.text = "Result:\nFormat: " + (format) + "\n" + "Text: " + (result.barcodes?.first?.text ?? "")
                }
            case .canceled:
                DispatchQueue.main.async {
                    self.label.text = "Scan canceled"
                }
            case .exception:
                DispatchQueue.main.async {
                    self.label.text = result.errorString
                }
            @unknown default:
                break
            }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setup() {
        button.backgroundColor = .black
        button.setTitle("Scan a Barcode", for: .normal)
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
            label.bottomAnchor.constraint(lessThanOrEqualTo: button.topAnchor, constant: -8)
        ])
    }
}

