//
//  CameraZoomFloatingButton.swift
//  TinyBarcode
//
//  Created by dynamsoft's mac on 2022/11/24.
//

import UIKit

typealias TapPressCompletion = () -> Void

class CameraZoomFloatingButton: UIView {
    
    private var cameraZoom: CGFloat = kDCEDefaultZoom
    
    var tapPressCompletion: TapPressCompletion?
    
    var currentCameraZoom: CGFloat {
        get {cameraZoom}
        set {
            cameraZoom = newValue
            self.zoomLabel.text = String(format: "%.1fx", cameraZoom)
        }
    }
    
    private lazy var zoomLabel: UILabel = {
        let label = UILabel.init(frame: CGRectMake(0, 0, self.width, self.height))
        label.backgroundColor = .black.withAlphaComponent(0.42)
        label.textColor = .white
        label.layer.cornerRadius = self.height / 2.0;
        label.layer.masksToBounds = true
        label.font = kFont_SystemDefault(kCameraZoomFloatingLabelTextSize)
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
