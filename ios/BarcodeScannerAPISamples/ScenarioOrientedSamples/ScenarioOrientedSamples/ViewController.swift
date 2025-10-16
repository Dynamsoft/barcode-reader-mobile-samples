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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setup(){
        // ScrollView
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        
        let guide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
        
        // StackView
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 24
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Logo
        let imageView = UIImageView(image: UIImage(named: "dynamsoft-logo"))
        imageView.contentMode = .scaleAspectFit
        mainStack.addArrangedSubview(imageView)
        
//        let titleLabel = UILabel()
//        titleLabel.text = "Barcode Reader\nScenario Oriented Samples"
//        titleLabel.textColor = .white
//        titleLabel.textAlignment = .center
//        titleLabel.numberOfLines = 0
//        titleLabel.font = UIFont.systemFont(ofSize: 28)
//        mainStack.addArrangedSubview(titleLabel)
        
        // 5. Section 1
        let section1Label = createSectionLabel("Select Scanner by Barcode Format")
        mainStack.addArrangedSubview(section1Label)
        mainStack.addArrangedSubview(createGrid(withItems: [
            ["title": "Any Codes", "icon": "any_codes"],
            ["title": "1D Retail", "icon": "1d_retail"],
            ["title": "1D Industrial", "icon": "1d_industrial"],
            ["title": "QR Code", "icon": "qr_code"],
            ["title": "Data Matrix", "icon": "data_matrix"],
            ["title": "Common 2D codes", "icon": "common_2d"],
            ["title": "Aztec Code", "icon": "aztec_code"],
            ["title": "Dot Code", "icon": "dot_code"],
            ["title": "Direct Part Marking(DPM)", "icon": "dpm_code"]
        ], section: 0))

        // 6. Section 2
        let section2Label = createSectionLabel("Select Scanner by Your Scenario")
        mainStack.addArrangedSubview(section2Label)
        mainStack.addArrangedSubview(createGrid(withItems: [
            ["title": "High-Density Code", "icon": "high_density"]
        ], section: 101))
    }
    
    func createSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .customGreen
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }

    func createGrid(withItems items: [[String: String]], section: Int) -> UIView {
        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.spacing = 16
        
        let itemsPerRow = 3
        for i in stride(from: 0, to: items.count, by: itemsPerRow) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 16
            row.distribution = .fillEqually
            
            for j in 0..<itemsPerRow {
                let index = i + j
                if index < items.count {
                    let item = items[index]
                    let title = item["title"] ?? ""
                    let icon = item["icon"] ?? ""
                    let btn = createButton(title: title, imageName: icon)
                    let itemIndex = index + section
                    btn.backgroundColor = itemIndex % 2 == 0 ? .black : .customGray
                    btn.tag = itemIndex
                    btn.accessibilityIdentifier = title
                    btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                    row.addArrangedSubview(btn)
                } else {
                    let spacer = UIView()
                    row.addArrangedSubview(spacer)
                }
            }
            gridStack.addArrangedSubview(row)
        }
        return gridStack
    }

    func createButton(title: String, imageName: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 12
        btn.clipsToBounds = true
        
        btn.layer.borderColor = UIColor.customDarkGray.cgColor
        btn.layer.borderWidth = 1.0
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImage = UIImage(named: imageName)
        let icon = UIImageView(image: iconImage)
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .white
        
        let label = UILabel()
        label.text = title
        label.textColor = .customLightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(icon)
        btn.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: btn.leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: btn.trailingAnchor, constant: -6)
        ])
        
        btn.heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        return btn
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
    
    @objc func buttonTapped(_ sender: UIButton) {
        
        let vc = BarcodeScannerViewController()
        vc.title = sender.accessibilityIdentifier
        let config = BarcodeScannerConfig()
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        config.license = "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9"
        config.isCloseButtonVisible = false
        switch sender.tag {
        case 0:
            config.templateFile = "ReadCommon1DAnd2D.json"
        case 1:
            config.templateFile = "ReadOneDRetail.json"
        case 2:
            config.templateFile = "ReadOneDIndustrial.json"
        case 3:
            config.templateFile = "ReadQR.json"
        case 4:
            config.templateFile = "ReadDataMatrix.json"
        case 5:
            config.templateFile = "ReadCommon2D.json"
        case 6:
            config.templateFile = "ReadAztec.json"
        case 7:
            config.templateFile = "ReadDotCode.json"
            let region = Rect(left: 0.15, top: 0.35, right: 0.85, bottom: 0.48, measuredInPercentage: true)
            config.scanRegion = region
            config.zoomFactor = 3.0
        case 8:
            config.templateFile = "ReadDPM.json"
        case 101:
            config.templateFile = "ReadDenseBarcodes.json"
        default:
            break
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
                let vc = ResultViewController()
                vc.text = text
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }

        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension UIColor {
    static let customGray = UIColor(red: 29/255.0, green: 29/255.0, blue: 29/255.0, alpha: 1.0)
    static let customLightGray = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
    static let customDarkGray = UIColor(red: 61/255.0, green: 61/255.0, blue: 61/255.0, alpha: 1.0)
    static let customBlack = UIColor(red: 21/255.0, green: 21/255.0, blue: 23/255.0, alpha: 1.0)
    static let customGreen = UIColor(red: 106/255.0, green: 196/255.0, blue: 187/255.0, alpha: 1.0)
}
