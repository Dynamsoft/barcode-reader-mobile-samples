/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftBarcodeReaderBundle

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .customBlack
        setupAppearance()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setup(){
        let imageView = UIImageView(image: UIImage(named: "dynamsoft"))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Barcode Reader\nScenario Oriented Samples"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 28)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Customization for barcode types"
        descriptionLabel.textColor = .customLightGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let highDensityView = createBarcodeTypesView(color: .black, text: "High-Density QRCode", image: UIImage(named: "High-Density"), tag: 1, action: #selector(barcodeTypesViewTapped))
        highDensityView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(highDensityView)
        
        let dpmView = createBarcodeTypesView(color: .customGray, text: "Direct Part Marking (DPM)", image: UIImage(named: "DPM"), tag: 2, action: #selector(barcodeTypesViewTapped))
        dpmView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dpmView)
        
        let dotCodeView = createBarcodeTypesView(color: .black, text: "DotCode", image: UIImage(named: "DotCode"), tag: 3, action: #selector(barcodeTypesViewTapped))
        dotCodeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dotCodeView)
        
        let aztecView = createBarcodeTypesView(color: .customGray, text: "Aztec Code", image: UIImage(named: "Aztec"), tag: 4, action: #selector(barcodeTypesViewTapped))
        aztecView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(aztecView)
        
        let bottomLabel = UILabel()
        bottomLabel.text = "Powered by Dynamsoft"
        bottomLabel.textColor = .gray
        bottomLabel.textAlignment = .center
        bottomLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            
            titleLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.9),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            descriptionLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.7),
            
            dpmView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            dpmView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            dpmView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 1/3, constant: -12),
            dpmView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.2),
            
            highDensityView.topAnchor.constraint(equalTo: dpmView.topAnchor),
            highDensityView.trailingAnchor.constraint(equalTo: dpmView.leadingAnchor, constant: -9),
            highDensityView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 1/3, constant: -12),
            highDensityView.heightAnchor.constraint(equalTo: dpmView.heightAnchor),
            
            dotCodeView.topAnchor.constraint(equalTo: dpmView.topAnchor),
            dotCodeView.leadingAnchor.constraint(equalTo: dpmView.trailingAnchor, constant: 9),
            dotCodeView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 1/3, constant: -12),
            dotCodeView.heightAnchor.constraint(equalTo: dpmView.heightAnchor),
            
            aztecView.topAnchor.constraint(equalTo: highDensityView.bottomAnchor, constant: 16),
            aztecView.leadingAnchor.constraint(equalTo: highDensityView.leadingAnchor),
            aztecView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 1/3, constant: -12),
            aztecView.heightAnchor.constraint(equalTo: dpmView.heightAnchor),
            
            bottomLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -32)
        ])
    }
    
    private func createBarcodeTypesView(color: UIColor, text: String, image: UIImage?, tag: Int, action: Selector) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.customDarkGray.cgColor
        view.tag = tag
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tapGesture)
        
        let label = UILabel()
        label.text = text
        label.textColor = .customLightGray
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(lessThanOrEqualTo: imageView.topAnchor, constant: -10),
            
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        return view
    }
    
    func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    @objc func barcodeTypesViewTapped(_ sender: UITapGestureRecognizer) {
        if let tappedView = sender.view {
            let vc = BarcodeScannerViewController()
            let config = BarcodeScannerConfig()
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
            config.license = "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9"
            
            switch tappedView.tag {
            case 1:
                config.templateFile = "ReadDenseQRCode.json"
            case 2:
                config.templateFile = "ReadDPM.json"
            case 3:
                config.templateFile = "ReadDotcode.json"
            case 4:
                config.templateFile = "ReadAztec.json"
            default: break
            }
            
            vc.config = config
            vc.onScannedResult = { [weak self] result in
                guard let self = self else { return }
                var text:String = ""
                switch result.resultStatus {
                case .finished:
                    DispatchQueue.main.async {
                        let format = result.barcodes?.first?.formatString ?? ""
                        text = "Result:\nFormat: " + (format) + "\n" + "Text: " + (result.barcodes?.first?.text ?? "")
                    }
                case .canceled:
                    DispatchQueue.main.async {
                        text = "Scan canceled"
                    }
                case .exception:
                    DispatchQueue.main.async {
                        text = result.errorString ?? ""
                    }
                @unknown default:
                    break
                }
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: false)
                    let vc = ResultViewController()
                    vc.text = text
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

extension UIColor {
    static let customGray = UIColor(red: 29/255.0, green: 29/255.0, blue: 29/255.0, alpha: 1.0)
    static let customLightGray = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
    static let customDarkGray = UIColor(red: 61/255.0, green: 61/255.0, blue: 61/255.0, alpha: 1.0)
    static let customBlack = UIColor(red: 21/255.0, green: 21/255.0, blue: 23/255.0, alpha: 1.0)
}
