/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

final class ViewController: UIViewController {

    // MARK: - UI
    private let countLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let scanButton = UIButton(type: .custom)
    private let storageKey = "CartBuilder.items"

    private let cameraView = CameraView()
    private let dce = CameraEnhancer()
    private let cvr = CaptureVisionRouter()
    var drawingLayer: DrawingLayer?
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    let aimCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let zoomButton = UIButton(type: .system)
    private var zoomLevel: Int = 1 {
        didSet {
            updateZoomButtonTitle()
        }
    }

    // MARK: - Data
    struct Item: Codable {
        let text: String
        let format: String
        var qty: Int
    }

    private var items: [Item] = [] {
        didSet {
            updateCount()
            tableView.reloadData()
            saveItems()
        }
    }
    
    func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Sample Cart"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let clearBarButton = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearList)
        )
        clearBarButton.tintColor = .orange
        navigationItem.rightBarButtonItem = clearBarButton
        
        setupLicense()
        setupHeader()
        setupUI()
        setupCameraOverlay()
        
        loadItems()
    }
    
    private var didLayoutCamera = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didLayoutCamera else { return }
        didLayoutCamera = true

        let safe = view.safeAreaLayoutGuide.layoutFrame
        let side = min(safe.width, safe.height) / 2

        cameraView.frame = CGRect(
            x: safe.maxX - side - 16,
            y: safe.minY + 16,
            width: side,
            height: side
        )
    }

    func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([Item].self, from: data)
        else { return }
        items = saved
    }
}

// MARK: - License
extension ViewController: LicenseVerificationListener {
    
    func setupLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: (any Error)?) {
        if !isSuccess {
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
}

private extension ViewController {
    
    private func createHeaderLabel(text: String, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = alignment
        return label
    }
    
    func setupHeader() {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 50/255.0, green: 50/255.0, blue: 52/255.0, alpha: 1.0)

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        
        let itemLabel = createHeaderLabel(text: "Item", alignment: .left)
        let qtyLabel = createHeaderLabel(text: "Qty", alignment: .center)
        let priceLabel = createHeaderLabel(text: "Price", alignment: .right)
        
        stackView.addArrangedSubview(itemLabel)
        stackView.addArrangedSubview(qtyLabel)
        stackView.addArrangedSubview(priceLabel)
        
        headerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            itemLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.6),
            qtyLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2)
        ])
        
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    func updateCount() {
        let total = items.reduce(0) { $0 + $1.qty }
        countLabel.text = "\(total) Items Scanned"
    }

    @objc func clearList() {
        items.removeAll()
    }
}

private extension ViewController {
    
    func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(named: "dynamsoft"))
        imageView.contentMode = .scaleAspectFit
        bottomView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        scanButton.backgroundColor = .orange
        scanButton.layer.cornerRadius = 8
        scanButton.setTitle("Scan Barcode", for: .normal)
        scanButton.addTarget(self, action: #selector(openScanner), for: .touchUpInside)

        bottomView.addSubview(scanButton)
        scanButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 120),
            
            imageView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            imageView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            
            scanButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            scanButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -26),
            scanButton.widthAnchor.constraint(equalToConstant: 150),
            scanButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -16)
        ])
        
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let cartView = UIImageView(image: UIImage(named: "cart"))
        cartView.contentMode = .scaleAspectFit
        backgroundView.addSubview(cartView)
        cartView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Scan barcodes \nto add items to cart"
        label.textColor = UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0)
        backgroundView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cartView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            cartView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -10),
            label.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            label.topAnchor.constraint(equalTo: cartView.bottomAnchor, constant: 12),
            
            backgroundView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: tableView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }
    
    func setupCameraOverlay() {
        cameraView.layer.cornerRadius = 12
        cameraView.isHidden = true
        cameraView.clipsToBounds = true
        cameraView.torchButtonVisible = true
        cameraView.setTorchButton(frame: .init(x: 12, y: 12, width: 24, height: 24), torchOnImage: nil, torchOffImage: nil)
        dce.cameraView = cameraView
        dce.setCameraStateListener(self)
    
        try? cvr.setInput(dce)
        cvr.addResultReceiver(self)
        let muti = MultiFrameResultCrossFilter()
        muti.enableLatestOverlapping(.barcode, isEnabled: true)
        cameraView.getDrawingLayer(DrawingLayerId.DBR.rawValue)?.visible = false
        drawingLayer = cameraView.getDrawingLayer(DrawingLayerId.DLR.rawValue)
        
        view.addSubview(cameraView)
        
        let closeButton = UIButton(type: .system)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(image, for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 12
        closeButton.imageView?.contentMode = .scaleAspectFit
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
            closeButton.configuration = config
        } else {
            closeButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        }
        closeButton.addTarget(self, action: #selector(closeScanner), for: .touchUpInside)

        cameraView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: cameraView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        zoomButton.setTitleColor(.white, for: .normal)
        zoomButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        zoomButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        zoomButton.layer.cornerRadius = 12
        zoomButton.addTarget(self, action: #selector(zoomTapped), for: .touchUpInside)
        updateZoomButtonTitle()

        cameraView.addSubview(zoomButton)
        zoomButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            zoomButton.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor, constant: -12),
            zoomButton.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: -12),
            zoomButton.widthAnchor.constraint(equalToConstant: 24),
            zoomButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        cameraView.addSubview(aimCircle)
        aimCircle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aimCircle.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
            aimCircle.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor),
            aimCircle.widthAnchor.constraint(equalToConstant: 24),
            aimCircle.heightAnchor.constraint(equalToConstant: 24),
            
            zoomButton.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor, constant: -12),
            zoomButton.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: -12),
            zoomButton.widthAnchor.constraint(equalToConstant: 24),
            zoomButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let cameraViewPan = UIPanGestureRecognizer(target: self, action: #selector(dragCameraView(_:)))
        cameraView.addGestureRecognizer(cameraViewPan)
        cameraView.isUserInteractionEnabled = true
        
        let buttonPan = UIPanGestureRecognizer(target: self, action: #selector(dragScanButton(_:)))
        scanButton.addGestureRecognizer(buttonPan)
        scanButton.isUserInteractionEnabled = true
    }
}

// MARK: - CapturedResultReceiver
extension ViewController: CapturedResultReceiver {

    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        guard let items = result.items, !items.isEmpty else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch items.count {
            case 1:
                if let item = items.first {
                    self.processSingleBarcode(item)
                }
            default:
                self.processMultipleBarcodes(items)
            }
        }
    }
}

private extension ViewController {
    
    func updateZoomButtonTitle() {
        zoomButton.setTitle("\(zoomLevel)x", for: .normal)
    }
    
    @objc func zoomTapped() {
        zoomLevel = (zoomLevel == 1) ? 2 : 1
        var zoom = CGFloat(zoomLevel)
        let position = dce.getCameraPosition()
        if position == .backDualWideAuto {
            zoom = zoom * 2.0
        }
        dce.setZoomFactor(zoom)
    }
    
    func open() {
        aimCircle.isHidden = true
        cameraView.alpha = 1.0
        cameraView.isHidden = false
        dce.open()
        cvr.startCapturing(PresetTemplate.readBarcodesSpeedFirst.rawValue)
    }
    
    func close() {
        cameraView.isHidden = true
        cvr.stopCapturing()
        dce.clearBuffer()
    }
    
    @objc func openScanner() {
        backgroundView.isHidden = true
        open()
    }

    @objc func closeScanner() {
        close()
    }
    
    @objc func dragScanButton(_ gesture: UIPanGestureRecognizer) {
        guard let v = gesture.view else { return }

        let translation = gesture.translation(in: view)
        let proposedCenter = CGPoint(
            x: v.center.x + translation.x,
            y: v.center.y + translation.y
        )

        v.center = clampedCenter(for: v, proposedCenter: proposedCenter)
        gesture.setTranslation(.zero, in: view)
    }

    @objc func dragCameraView(_ gesture: UIPanGestureRecognizer) {
        guard let v = gesture.view else { return }

        let translation = gesture.translation(in: view)
        let proposedCenter = CGPoint(
            x: v.center.x + translation.x,
            y: v.center.y + translation.y
        )

        v.center = clampedCenter(for: v, proposedCenter: proposedCenter)
        gesture.setTranslation(.zero, in: view)
    }

    func clampedCenter(
        for view: UIView,
        proposedCenter: CGPoint,
        padding: CGFloat = 10
    ) -> CGPoint {

        let safe = self.view.safeAreaLayoutGuide.layoutFrame

        let halfW = view.bounds.width / 2
        let halfH = view.bounds.height / 2

        let minX = safe.minX + halfW + padding
        let maxX = safe.maxX - halfW - padding
        let minY = safe.minY + halfH + padding
        let maxY = safe.maxY - halfH - padding

        let x = min(max(proposedCenter.x, minX), maxX)
        let y = min(max(proposedCenter.y, minY), maxY)

        return CGPoint(x: x, y: y)
    }
}

// MARK: - Help Func
extension ViewController {
    
    private func handleScan(text: String, format: String) {
        if let index = items.firstIndex(where: {
            $0.text == text && $0.format == format
        }) {
            var item = items.remove(at: index)
            item.qty += 1
            items.insert(item, at: 0)
        } else {
            items.insert(Item(text: text, format: format, qty: 1), at: 0)
        }
    }
    
    private func stopCaptureAndProcess(item: BarcodeResultItem) {
        Feedback.beep()
        Feedback.vibrate()
        dce.close()
        cvr.stopCapturing()
        dce.clearBuffer()
        
        drawingLayer?.drawingItems = [QuadDrawingItem(quadrilateral: item.location)]
        handleScan(text: item.text, format: item.formatString)
        
        animateCameraViewHide()
    }
    
    private func viewRect(for quad: Quadrilateral) -> CGRect {
        guard quad.points.count >= 4 else { return .zero }
        
        let viewPoints = quad.points.prefix(4).map {
            dce.convertPointToViewCoordinates($0.cgPointValue)
        }
        
        let xs = viewPoints.map(\.x)
        let ys = viewPoints.map(\.y)
        
        guard let minX = xs.min(), let maxX = xs.max(),
              let minY = ys.min(), let maxY = ys.max() else {
            return .zero
        }
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    private func animateCameraViewHide() {
        UIView.animate(withDuration: 0.8,
                       delay: 0.3,
                       options: .curveEaseInOut,
                       animations: {
            self.cameraView.alpha = 0.0
        }) { [weak self] finished in
            guard let self = self, finished else { return }
            self.drawingLayer?.clearDrawingItems()
            self.cameraView.isHidden = true
        }
    }
    
    private func processSingleBarcode(_ item: BarcodeResultItem) {
        if aimCircle.isHidden {
            stopCaptureAndProcess(item: item)
        } else {
            let rect = viewRect(for: item.location)
            if aimCircle.frame.intersects(rect) {
                stopCaptureAndProcess(item: item)
            }
        }
    }
    
    private func processMultipleBarcodes(_ items: [BarcodeResultItem]) {
        aimCircle.isHidden = false
        
        for item in items {
            let rect = viewRect(for: item.location)
            if aimCircle.frame.intersects(rect) {
                stopCaptureAndProcess(item: item)
                break
            }
        }
    }
}

// MARK: - UITableView
extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .destructive,
                                        title: "Delete") { [weak self] _, _, completion in
            self?.items.remove(at: indexPath.row)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]

        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill

        let itemLabel = UILabel()
        itemLabel.text = item.text
        itemLabel.font = .systemFont(ofSize: 15)

        let qtyLabel = UILabel()
        qtyLabel.text = "\(item.qty)"
        qtyLabel.textAlignment = .center
        qtyLabel.font = .systemFont(ofSize: 15)

        let priceLabel = UILabel()
        priceLabel.text = "$0.00"
        priceLabel.textAlignment = .right
        priceLabel.font = .systemFont(ofSize: 15)
        
        [itemLabel, qtyLabel, priceLabel].forEach { stackView.addArrangedSubview($0) }
        
        cell.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            itemLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.6),
            qtyLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2)
        ])
        
        return cell
    }
}

extension ViewController: CameraStateListener {
    public func onCameraStateChanged(_ currentState: CameraState) {
        if currentState == .opened {
            DispatchQueue.main.async {
                let region = self.cameraView.getVisibleRegionOfVideo()
                try? self.dce.setScanRegion(region)
                self.cameraView.scanRegionMaskVisible = false
            }
        }
    }
}
