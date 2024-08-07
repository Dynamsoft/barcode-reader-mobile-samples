/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import Photos
import DynamsoftCore
import DynamsoftBarcodeReader
import DynamsoftCaptureVisionRouter
import DynamsoftLicense

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, LicenseVerificationListener {

    let cvr = CaptureVisionRouter()
    let picker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLicense()
        setUp()
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
    
    func setUp() {
        picker.delegate = self
        view.addSubview(self.loadingView)
    }
    
    lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: .large)
        indicator.center = view.center
        return indicator
    }()

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        imageView.image = image
        picker.dismiss(animated: true)
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
    
    @IBAction func selectPhoto(_ sender: Any) {
        self.present(picker, animated: true)
    }
    
    @IBAction func capture(_ sender: Any) {
        self.loadingView.startAnimating()
        if let image = imageView.image {
            // Decode barcodes from a UIImage.
            // The method returns a CapturedResult object that contains an array of CapturedResultItems.
            // CapturedResultItem is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
            let result = cvr.captureFromImage(image, templateName: PresetTemplate.readBarcodesReadRateFirst.rawValue)
            handleCapturedResult(result)
        }
        self.loadingView.stopAnimating()
    }
    
    // This is the method that extract the barcodes info from the CapturedResult.
    func handleCapturedResult(_ result: CapturedResult) -> Void {
        if let items = result.items, items.count > 0 {
            var message = String(format: "Decoded Barcode Count: %d\n", items.count)
            // Get each CapturedResultItem object from the array.
            for item in items {
                if item.type == .barcode {
                    let barcodeItem:BarcodeResultItem = item as! BarcodeResultItem
                    // Extract the barcode format and the barcode text from the CapturedResultItem.
                    message = message.appendingFormat("\nFormat: %@\nText: %@\n", barcodeItem.formatString, barcodeItem.text)
                }
            }
            showResult("Results", message)
        } else {
            if result.errorCode != 0 {
                showResult("Error", result.errorMessage)
            } else {
                showResult("No Result", nil)
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

