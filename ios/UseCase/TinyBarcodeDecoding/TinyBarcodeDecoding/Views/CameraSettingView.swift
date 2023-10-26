//
//  CameraSettingView.swift
//  TinyBarcode
//
//  Created by dynamsoft's mac on 2022/11/25.
//

import UIKit

typealias SwitchChangedCompletion = (_ isOn: Bool) -> Void

class CameraSettingView: UIView {

    var switchChangedCompletion: SwitchChangedCompletion?
    
    private var autoZoomLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: kLeftMarginOfContainer, y: 0, width: 100, height: KCameraSettingViewAvailableHeight))
        label.textColor = .white
        label.text = "Auto Zoom"
        label.font = kFont_Regular(KCameraSettingTitleTextSize)
        label.textAlignment = .left
        return label
    }()
    
    private var controlSwitch: UISwitch = {
        let controlSwitch = UISwitch.init()
        controlSwitch.left = kScreenWidth - kRightMarginOfContainer -  controlSwitch.width
        controlSwitch.top = (KCameraSettingViewAvailableHeight - controlSwitch.height) / 2.0
        controlSwitch.onTintColor = kSwitchOnTintColor
        controlSwitch.tintColor = kSwitchOffTintColor
        controlSwitch.backgroundColor = kSwitchOffTintColor
        controlSwitch.layer.cornerRadius = controlSwitch.height / 2.0
        return controlSwitch
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() -> Void {
        self.backgroundColor = UIColor(red: 40 / 255.0, green: 40 / 255.0, blue: 40 / 255.0, alpha: 1)
        self.addSubview(autoZoomLabel)
        self.addSubview(controlSwitch)
        controlSwitch.addTarget(self, action: #selector(controlSwitchChange(_:)), for: .valueChanged)
    }
    
    func updateSwitch(with switchState: Bool) -> Void {
        self.controlSwitch.isOn = switchState
        if (controlSwitch.isOn) {
            controlSwitch.thumbTintColor = kSwitchOnThumbColor
        } else {
            controlSwitch.thumbTintColor = kSwitchOffThumbColor
        }
    }
    
    @objc private func controlSwitchChange(_ controlSwitch: UISwitch) -> Void {
        if (controlSwitch.isOn) {
            controlSwitch.thumbTintColor = kSwitchOnThumbColor
        } else {
            controlSwitch.thumbTintColor = kSwitchOffThumbColor
        }
        
        self.switchChangedCompletion?(controlSwitch.isOn)
    }

}
