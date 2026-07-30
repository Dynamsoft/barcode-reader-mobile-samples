//
//  ViewController.swift
//  GridBarcodeReading
//
//  Created by dynamsoft on 2026/6/16.
//

import UIKit
import DynamsoftCaptureVisionBundle

class ViewController: UIViewController {
    
    private let cvr = CaptureVisionRouter()
    private let fastTemplateName = "GridFastScan"
    private let deepTemplateName = "GridDeepDecode"
    private lazy var processor = GridBarcodeProcessor(
        cvr: cvr,
        fastTemplateName: fastTemplateName,
        deepTemplateName: deepTemplateName
    )
    private var sampleImage: UIImage?
    
    private lazy var cameraButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Camera"
        configuration.image = UIImage(systemName: "camera")
        configuration.imagePadding = 8
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var albumButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Gallery"
        configuration.image = UIImage(systemName: "photo.on.rectangle")
        configuration.imagePadding = 8
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var sampleCaptureButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "Scan Sample Image"
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(captureSampleImage), for: .touchUpInside)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let decodedValueLabel = ViewController.makeSummaryValueLabel(color: .systemGreen)
    private let failedValueLabel = ViewController.makeSummaryValueLabel(color: .systemRed)
    private let totalValueLabel = ViewController.makeSummaryValueLabel(color: .label)

    private lazy var summaryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            makeSummaryCard(valueLabel: decodedValueLabel, title: "Decoded"),
            makeSummaryCard(valueLabel: failedValueLabel, title: "Failed"),
            makeSummaryCard(valueLabel: totalValueLabel, title: "Total Cells")
        ])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let resultTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.layer.cornerRadius = 12
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()

    private(set) var results: [GridCellResult] = [] {
        didSet {
            resultTableView.reloadData()
        }
    }

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var isProcessing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLicense()
        setupCaptureVision()
        setupUI()
        loadDefaultImage()
    }
}

// MARK: - Setup
private extension ViewController {
    static func makeSummaryValueLabel(color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textAlignment = .center
        label.textColor = color
        label.text = "0"
        return label
    }

    func setupCaptureVision() {
        guard let path = Bundle.main.path(forResource: "gridBarcodeReading", ofType: "json") else { return }
        do {
            try cvr.initSettingsFromFile(path)
        } catch {
            print("Failed to initialize settings: \(error.localizedDescription)")
        }
    }
    
    func setupUI() {
        let buttonStackView = UIStackView(arrangedSubviews: [cameraButton, albumButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        summaryStackView.translatesAutoresizingMaskIntoConstraints = false
        resultTableView.translatesAutoresizingMaskIntoConstraints = false
        sampleCaptureButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(buttonStackView)
        view.addSubview(imageView)
        view.addSubview(sampleCaptureButton)
        view.addSubview(summaryStackView)
        view.addSubview(resultTableView)
        view.addSubview(activityIndicator)
        imageView.addSubview(overlayView)
        resultTableView.dataSource = self
        resultTableView.delegate = self
        resultTableView.register(GridResultCell.self, forCellReuseIdentifier: GridResultCell.reuseIdentifier)
        
        let safeArea = view.safeAreaLayoutGuide
        let imagePreferredHeight = imageView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.30)
        imagePreferredHeight.priority = .defaultHigh
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            buttonStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),

            imageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            imageView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 16),
            imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 280),
            imagePreferredHeight,

            sampleCaptureButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            sampleCaptureButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            sampleCaptureButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),

            summaryStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            summaryStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            summaryStackView.topAnchor.constraint(equalTo: sampleCaptureButton.bottomAnchor, constant: 12),
            summaryStackView.heightAnchor.constraint(equalToConstant: 84),

            resultTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            resultTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            resultTableView.topAnchor.constraint(equalTo: summaryStackView.bottomAnchor, constant: 12),
            resultTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            resultTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            overlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])

        updateSummary(decoded: 0, failed: 0, total: 0)
    }

    func setActionButtonsEnabled(_ enabled: Bool) {
        cameraButton.isEnabled = enabled
        albumButton.isEnabled = enabled
        sampleCaptureButton.isEnabled = enabled && sampleImage != nil
    }

    func setProcessingState(_ processing: Bool) {
        isProcessing = processing
        setActionButtonsEnabled(!processing)
        if processing {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func loadDefaultImage() {
        guard let image = UIImage(named: "sample_grid") else {
            resultTableView.backgroundView = makeTableMessageLabel("Please make sure `sample_grid.png` is included in the app bundle.")
            sampleCaptureButton.isEnabled = false
            return
        }
        sampleImage = image
        imageView.image = image
        clearBarcodeOverlays()
        resultTableView.backgroundView = makeTableMessageLabel("Tap \"Scan Sample Image\", or take/select a photo to decode.")
        setActionButtonsEnabled(true)
    }
    
    func makeSummaryCard(valueLabel: UILabel, title: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.text = title

        let stackView = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4

        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    func updateSummary(decoded: Int, failed: Int, total: Int) {
        decodedValueLabel.text = "\(decoded)"
        failedValueLabel.text = "\(failed)"
        totalValueLabel.text = "\(total)"
    }

    func clearResults() {
        updateSummary(decoded: 0, failed: 0, total: 0)
        results = []
        resultTableView.backgroundView = nil
    }
    
    func showResults(decoded: Int, failed: Int, total: Int, rows: [GridCellResult]) {
        updateSummary(decoded: decoded, failed: failed, total: total)
        resultTableView.backgroundView = rows.isEmpty ? makeTableMessageLabel("No results yet") : nil
        results = rows
    }

    func makeTableMessageLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }
}

// MARK: - Actions
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func captureSampleImage() {
        guard !isProcessing else { return }
        guard let sampleImage else {
            showAlert(title: "Unavailable", message: "sample_grid.png was not found in the app bundle.")
            return
        }
        processImage(sampleImage)
    }
    
    @objc func takePhoto() {
        guard !isProcessing else { return }
        presentImagePicker(for: .camera)
    }
    
    @objc func selectPhoto() {
        guard !isProcessing else { return }
        presentImagePicker(for: .photoLibrary)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true) { [weak self] in
                self?.setActionButtonsEnabled(true)
            }
            return
        }
        picker.dismiss(animated: true) { [weak self] in
            self?.processImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.setActionButtonsEnabled(true)
        }
    }
}

// MARK: - Decoding
private extension ViewController {
    func presentImagePicker(for sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            let message = sourceType == .camera ? "This device does not support taking photos." : "This device cannot access the photo library."
            showAlert(title: "Unavailable", message: message)
            return
        }

        setActionButtonsEnabled(false)
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func processImage(_ image: UIImage) {
        guard !isProcessing else { return }
        imageView.image = image
        clearBarcodeOverlays()
        clearResults()
        setProcessingState(true)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let output = self.processor.process(image: image)

            DispatchQueue.main.async {
                self.setProcessingState(false)
                if let alert = output.alert {
                    self.showAlert(title: alert.title, message: alert.message)
                    return
                }
                for overlay in output.overlays {
                    self.drawOverlay(
                        for: overlay.quad,
                        image: image,
                        strokeColor: overlay.stroke,
                        fillColor: overlay.fill
                    )
                }
                self.showResults(decoded: output.decoded, failed: output.failed, total: output.total, rows: output.rows)
            }
        }

    }

    func clearBarcodeOverlays() {
        overlayView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }

    func drawOverlay(for quadrilateral: Quadrilateral,
                     image: UIImage,
                     strokeColor: UIColor,
                     fillColor: UIColor) {
        guard quadrilateral.points.count >= 4 else { return }

        let imageRect = imageDisplayRect(for: image)
        guard imageRect.width > 0, imageRect.height > 0 else { return }

        let coordinateSize = imageCoordinateSize(for: image)
        let scaleX = imageRect.width / coordinateSize.width
        let scaleY = imageRect.height / coordinateSize.height

        let points = quadrilateral.points.prefix(4).map { pointValue in
            let point = pointValue.cgPointValue
            return CGPoint(
                x: imageRect.minX + point.x * scaleX,
                y: imageRect.minY + point.y * scaleY
            )
        }

        let path = UIBezierPath()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.lineWidth = 2
        overlayView.layer.addSublayer(shapeLayer)
    }

    func imageDisplayRect(for image: UIImage) -> CGRect {
        let bounds = imageView.bounds
        guard bounds.width > 0, bounds.height > 0 else { return .zero }

        // Keep display scaling basis consistent with SDK orientation-aware coordinates.
        let imageSize = imageCoordinateSize(for: image)
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }

        let scale = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale
        let originX = (bounds.width - width) / 2
        let originY = (bounds.height - height) / 2
        return CGRect(x: originX, y: originY, width: width, height: height)
    }

    private func imageCoordinateSize(for image: UIImage) -> CGSize {
        let pixelSize = imagePixelSize(for: image)
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            return CGSize(width: pixelSize.height, height: pixelSize.width)
        default:
            return pixelSize
        }
    }

    private func imagePixelSize(for image: UIImage) -> CGSize {
        if let cgImage = image.cgImage {
            return CGSize(width: cgImage.width, height: cgImage.height)
        }
        return image.size
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - LicenseVerificationListener
extension ViewController: LicenseVerificationListener {
    func setupLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: (any Error)?) {
        if let error {
            print("License verification error: \(error.localizedDescription)")
        }
    }
}
