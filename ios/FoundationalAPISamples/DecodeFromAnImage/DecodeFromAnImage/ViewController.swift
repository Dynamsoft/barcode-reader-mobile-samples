/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class ViewController: UIViewController {
    
    var isExpanded = false
    var containerHeightConstraint: NSLayoutConstraint!
    let titleHeight = 40.0
    var selectedImageView: UIImageView?
    var imageThumbnails: [UIImage] = []
    let thumbnailSize: CGFloat = 80
    let spacing: CGFloat = 10
    var isContainerViewVisible = false
    var layer: DrawingLayer!
    let cvr = CaptureVisionRouter()
    var templateName = PresetTemplate.readBarcodes.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Decode From An Image"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .darkText
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
        setupLicense()
        setupDCV()
        setupUI()
        loadThumbnails()
    }
    
    let initialView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.backgroundColor = .customScrollViewColor
        return stackView
    }()

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .customImageViewColor
        view.isHidden = true
        return view
    }()
    
    let imageView: ImageEditorView = {
        let imageView = ImageEditorView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .customImageViewColor
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Results: 0"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    lazy var toggleButton: UIButton = {
        let button = UIButton()
        button.setTitle("View more ▲", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(toggleResultView), for: .touchUpInside)
        return button
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isHidden = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        return textView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .customScrollViewColor
        
        let view = UIView()
        view.backgroundColor = .black
        scrollView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            view.heightAnchor.constraint(equalToConstant: 1)
        ])
        return scrollView
    }()
    
    func createButtonWith(image: UIImage?, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    func setupDCV() {
        if let path = Bundle.main.path(forResource: "ReadFromAnImage", ofType: "json") {
            do {
                try cvr.initSettingsFromFile(path)
                templateName = "ReadFromAnImage"
            } catch {
                print(error)
            }
        }
    }
    
    func setupUI() {
        // setup drawingStyle
        layer = imageView.createDrawingLayer()
        let drawingStyle = DrawingStyleManager.getDrawingStyle(DrawingStyleId.greenStrokeFill.rawValue)
        layer.setDefaultStyle(drawingStyle!.styleId)
        
        let constant = CGFloat(16)
        let safeArea = view.safeAreaLayoutGuide
        
        // setup scrollView
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // setup initialView
        let stackView = UIStackView(arrangedSubviews: [createButtonWith(image: UIImage(named: "bigGallery"), selector: #selector(selectPhoto)), createButtonWith(image: UIImage(named: "bigTakePhoto"), selector: #selector(takePhoto))])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        initialView.addArrangedSubview(stackView)
        
        let label = UILabel()
        label.text = "Or select a sample image below\n↓"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .customLabelColor
        initialView.addArrangedSubview(label)
        
        view.addSubview(initialView)
        initialView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            initialView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            initialView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            initialView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            initialView.bottomAnchor.constraint(equalTo: scrollView.topAnchor),
        ])
        
        // setup containerView
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.topAnchor)
        ])
        
        //setup buttonView
        let buttonStackView = UIStackView(arrangedSubviews: [createButtonWith(image: UIImage(named: "gallery"), selector: #selector(selectPhoto)), createButtonWith(image: UIImage(named: "takePhoto"), selector: #selector(takePhoto))])
        buttonStackView.backgroundColor = .customScrollViewColor
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        
        let borderView = UIView()
        borderView.backgroundColor = .black
        buttonStackView.addSubview(borderView)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            borderView.centerXAnchor.constraint(equalTo: buttonStackView.centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: buttonStackView.centerYAnchor),
            borderView.widthAnchor.constraint(equalToConstant: 1),
            borderView.heightAnchor.constraint(equalTo: buttonStackView.heightAnchor)
        ])
        
        containerView.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        // setup imageView
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: constant),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -constant),
            imageView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: constant),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -titleHeight - constant)
        ])
        
        // setup resultView
        let resultView = UIView()
        resultView.backgroundColor = .customTextViewColor
        
        let titleView = UIView()
        titleView.backgroundColor = .black
        titleView.addSubview(titleLabel)
        titleView.addSubview(toggleButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: constant),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggleButton.leadingAnchor, constant: -constant),
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            
            toggleButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -constant),
            toggleButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
        
        resultView.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: resultView.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: resultView.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: resultView.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: titleHeight),
        ])
        
        resultView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 0),
            textView.leadingAnchor.constraint(equalTo: resultView.leadingAnchor, constant: constant),
            textView.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -constant),
            textView.bottomAnchor.constraint(equalTo: resultView.bottomAnchor, constant: 0)
        ])
        
        containerView.addSubview(resultView)
        resultView.translatesAutoresizingMaskIntoConstraints = false
        containerHeightConstraint = resultView.heightAnchor.constraint(equalToConstant: titleHeight)
        NSLayoutConstraint.activate([
            resultView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerHeightConstraint,
        ])
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Thumbnails
extension ViewController {
    
    func loadThumbnails() {
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            do {
                let files = try fileManager.contentsOfDirectory(atPath: resourcePath)
                let imageFiles = files.filter { $0.hasSuffix(".png") || $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") || $0.hasSuffix(".heif") || $0.hasSuffix(".heic") }
                for imageFile in imageFiles {
                    let fullPath = "\(resourcePath)/\(imageFile)"
                    if let image = UIImage(contentsOfFile: fullPath) {
                        imageThumbnails.append(image)
                    } else {
                        print("Failed to load image: \(imageFile)")
                    }
                }
            } catch {
                print("Error reading contents of resource folder: \(error)")
            }
        }
        addThumbnailsToScrollView()
    }
    
    func addThumbnailsToScrollView() {
        for (index, image) in imageThumbnails.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.backgroundColor = .white
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: spacing + CGFloat(index) * (thumbnailSize + spacing), y: spacing, width: thumbnailSize, height: thumbnailSize)
            imageView.isUserInteractionEnabled = true
            imageView.tag = index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(imageThumbnails.count) * (thumbnailSize + spacing) + spacing, height: 100)
    }
    
    func addToScrollView(image: UIImage) {
        let index = imageThumbnails.count
        imageThumbnails.append(image)
        
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: spacing + CGFloat(index) * (thumbnailSize + spacing), y: spacing, width: thumbnailSize, height: thumbnailSize)
        imageView.isUserInteractionEnabled = true
        imageView.tag = index
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
        scrollView.addSubview(imageView)
        
        scrollView.contentSize = CGSize(width: CGFloat(imageThumbnails.count) * (thumbnailSize + spacing) + spacing, height: 100)
        
        // select imageView
        tapImageView(tappedImageView: imageView)
        
        // scroll to the new image
        if scrollView.contentSize.width > scrollView.frame.width {
            let targetOffsetX = CGFloat(index) * (thumbnailSize + spacing) - (scrollView.frame.width - thumbnailSize) / 2
            let maxOffsetX = scrollView.contentSize.width - scrollView.frame.width
            let contentOffsetX = min(max(targetOffsetX, 0), maxOffsetX)
            
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentOffset = CGPoint(x: contentOffsetX, y: 0)
            }
        }
    }
}

// MARK: - Actions
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func takePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc func selectPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc func toggleResultView() {
        isExpanded.toggle()
        if isExpanded {
            textView.isHidden = false
            toggleButton.setTitle("Scroll down ▼", for: .normal)
            containerHeightConstraint.constant = min(250, view.frame.height - scrollView.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        } else {
            textView.isHidden = true
            toggleButton.setTitle("View more ▲", for: .normal)
            containerHeightConstraint.constant = titleHeight
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func thumbnailTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        tapImageView(tappedImageView: tappedImageView)
    }
    
    private func tapImageView(tappedImageView: UIImageView) {
        if !isContainerViewVisible {
            isContainerViewVisible = true
            containerView.isHidden = false
            initialView.isHidden = true
        }
        selectedImageView?.layer.borderWidth = 0
        selectedImageView?.layer.borderColor = UIColor.clear.cgColor
        
        tappedImageView.layer.borderWidth = 2
        tappedImageView.layer.borderColor = UIColor.orange.cgColor
        
        selectedImageView = tappedImageView
        
        if let image = tappedImageView.image {
            self.imageView.image = image

            let result = cvr.captureFromImage(image, templateName: templateName)
            if let message = result.errorMessage, result.errorCode != 0 {
                layer.drawingItems = nil
                titleLabel.text = "Total Results: 0"
                textView.text = ""
                showResult("Error", message)
                return
            }
            guard let items = result.decodedBarcodesResult?.items, items.count > 0 else {
                layer.drawingItems = nil
                titleLabel.text = "Total Results: 0"
                textView.text = ""
                return
            }
            var drawingItems:[QuadDrawingItem] = .init()
            var text = ""
            var index = 1
            for item in items {
                drawingItems.append(.init(quadrilateral: item.location))
                text += String(format: "%2d. Format: %@\n    Text: %@\n\n", index, item.formatString, item.text)
                index += 1
            }
            layer.drawingItems = drawingItems
            
            titleLabel.text = String.init(format: "Total Results: %d", items.count)
            textView.text = text
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            addToScrollView(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: LicenseVerificationListener {
    func setupLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: (any Error)?) {
        
    }
}

extension UIColor {
    static let customLabelColor = UIColor(red: 109/255.0, green: 109/255.0, blue: 109/255.0, alpha: 1.0)
    static let customScrollViewColor = UIColor(red: 50/255.0, green: 50/255.0, blue: 52/255.0, alpha: 1.0)
    static let customImageViewColor = UIColor(red: 23/255.0, green: 23/255.0, blue: 23/255.0, alpha: 1.0)
    static let customTextViewColor = UIColor(red: 46/255.0, green: 46/255.0, blue: 47/255.0, alpha: 1.0)
}
