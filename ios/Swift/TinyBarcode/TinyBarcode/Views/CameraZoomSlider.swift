//
//  CameraZoomSlider.swift
//  TinyBarcode
//
//  Created by dynamsoft's mac on 2022/11/25.
//

import UIKit

typealias CloseActionCompletion = () -> Void

typealias ZoomValueChangedCompletion = (_ zoomValue: CGFloat) -> Void

class CameraZoomSlider: UIView {

    var closeActionCompletion: CloseActionCompletion?
    
    var zoomValueChangedCompletion: ZoomValueChangedCompletion?
    
    var cameraMinZoom: CGFloat {
        get {CGFloat(self.zoomSlider.minimumValue)}
        set {self.zoomSlider.minimumValue = Float(newValue)}
    }
    
    var cameraMaxZoom: CGFloat {
        get {CGFloat(self.zoomSlider.maximumValue)}
        set {self.zoomSlider.maximumValue = Float(newValue)}
    }
    
    private var cameraZoom: CGFloat = kDCEDefaultZoom
    
    var currentCameraZoom: CGFloat {
        get {cameraZoom}
        set {
            cameraZoom = newValue
            self.zoomLabel.text = String(format: "%.1fx", cameraZoom)
            self.zoomSlider.value = Float(cameraZoom)
        }
    }
    
    private lazy var zoomLabel: UILabel = {
        let label = UILabel.init(frame: CGRectMake((self.width - kCameraZoomFloatingButtonWidth) / 2.0, 0, kCameraZoomFloatingButtonWidth, kCameraZoomFloatingButtonWidth))
        label.backgroundColor = .black.withAlphaComponent(0.42)
        label.textColor = .white
        label.layer.cornerRadius = label.width / 2.0;
        label.layer.masksToBounds = true
        label.font = kFont_SystemDefault(kCameraZoomFloatingLabelTextSize)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var zoomSlider: UISlider = {
        let slider = UISlider.init(frame: CGRectMake(40, 40, self.width - 80, 34))
        slider.thumbTintColor = .white
        slider.minimumTrackTintColor = UIColor(red: 112.0 / 255.0, green: 112.0 / 255.0, blue: 112.0 / 255.0, alpha: 1)
        slider.maximumTrackTintColor = UIColor(red: 112.0 / 255.0, green: 112.0 / 255.0, blue: 112.0 / 255.0, alpha: 1)
        slider.addTarget(self, action: #selector(zoomValueChanged(_:)), for: .valueChanged)
        slider.minimumValue = 1.0
        return slider
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() -> Void {
        let viewHeight = kCameraZoomSliderViewHeight
        
        self.addSubview(zoomLabel)
        
        let sliderBackground = UIView.init(frame: CGRectMake(0, viewHeight - 80, self.width, 80))
        sliderBackground.backgroundColor = .black.withAlphaComponent(0.6)
        self.addSubview(sliderBackground)
        
        let arrowIcon = UIImageView.init(frame: CGRectMake((self.width - 17) / 2.0, 10, 17, 10))
        arrowIcon.image = UIImage.init(named: "icon_arrow_camera_zoom_close")
        sliderBackground.addSubview(arrowIcon)
        
        let arrowActionView = UIView.init(frame: CGRectMake(arrowIcon.left - 10, arrowIcon.top - 10, arrowIcon.width + 20, arrowIcon.height + 20))
        arrowActionView.backgroundColor = .clear
        sliderBackground.addSubview(arrowActionView)
        
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(closeAction(_:)))
        arrowActionView.addGestureRecognizer(tapGes)
        
        sliderBackground.addSubview(zoomSlider)
    }
    
    @objc private func closeAction(_ tapGes: UITapGestureRecognizer) -> Void {
        self.closeActionCompletion?()
    }
    
    @objc private func zoomValueChanged(_ slider: UISlider) -> Void {
        self.zoomLabel.text = String(format: "%.1fx", slider.value)
        self.zoomValueChangedCompletion?(CGFloat(slider.value))
    }
}
