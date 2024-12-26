//
//  CameraZoomFloatingButton.swift
//  TinyBarcode
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

typealias TapPressCompletion = () -> Void

class CameraZoomFloatingButton: UIView {
    
    private var cameraZoom: CGFloat = kDCEMinimumZoom
    
    var tapPressCompletion: TapPressCompletion?
    
    var currentCameraZoom: CGFloat {
        get {cameraZoom}
        set {
            cameraZoom = newValue
            self.zoomLabel.text = String(format: "%.1fx", cameraZoom)
        }
    }
    
    private lazy var zoomLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        label.backgroundColor = .black.withAlphaComponent(0.42)
        label.textColor = .white
        label.layer.cornerRadius = self.height / 2.0;
        label.layer.masksToBounds = true
        label.font = kFont_Regular(kCameraZoomFloatingLabelTextSize)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() -> Void {
        self.addSubview(zoomLabel)
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tapGesAction(_:)))
        self.addGestureRecognizer(tapGes)
    }
    
    @objc private func tapGesAction(_ tapGes: UITapGestureRecognizer) -> Void {
        self.tapPressCompletion?()
    }

}
