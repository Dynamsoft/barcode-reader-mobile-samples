/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class CameraViewSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    private var viewSettingsDataArray: [String] = []
    
    /// Record view-settings switch state.
    private var recordViewSettingsSwitchStateDic: [String : Bool] = [:]
    
    private lazy var viewSettingsTableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "View Settings";
        
        handleData()
        setupUI()
    }
    
    private func handleData() -> Void {
        viewSettingsDataArray.removeAll()
        recordViewSettingsSwitchStateDic.removeAll()
        
        let basicDataArray: [String] = [GeneralSettings.shared.dceViewSettings.highlightDecodedBarcodes,
                                        GeneralSettings.shared.dceViewSettings.displayTorchButton
        ]
        viewSettingsDataArray.append(contentsOf: basicDataArray)
        
        if GeneralSettings.shared.dceViewSettings.highlightDecodedBarcodesIsOpen == true {
            recordViewSettingsSwitchStateDic[GeneralSettings.shared.dceViewSettings.highlightDecodedBarcodes] = true
        } else {
            recordViewSettingsSwitchStateDic[GeneralSettings.shared.dceViewSettings.highlightDecodedBarcodes] = false
        }
        
        if GeneralSettings.shared.dceViewSettings.displayTorchButtonIsOpen == true {
            recordViewSettingsSwitchStateDic[GeneralSettings.shared.dceViewSettings.displayTorchButton] = true
        } else {
            recordViewSettingsSwitchStateDic[GeneralSettings.shared.dceViewSettings.displayTorchButton] = false
        }
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(viewSettingsTableView)
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BasicTableViewCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewSettingsDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleTag = self.viewSettingsDataArray[indexPath.row]
        
        let identifier = BasicSwitchTableViewCell.className
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicSwitchTableViewCell
        if cell == nil {
            cell = BasicSwitchTableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        
        cell?.questionButton.isHidden = true
        cell?.switchChangedCompletion = {
            [unowned self] isOn in
            self.handleViewSettingSwitch(with: indexPath, settingString: titleTag, isOn: isOn)
        }
        
        cell?.updateUI(with: titleTag, isOn:recordViewSettingsSwitchStateDic[titleTag]!)
        return cell!
    }
    
    // MARK: - HandleOperation
    
    private func handleViewSettingSwitch(with indexPath: IndexPath,
                                         settingString: String,
                                         isOn: Bool) -> Void {
        if settingString == GeneralSettings.shared.dceViewSettings.highlightDecodedBarcodes {
            
            // Make configurations for overlays.
            // Highlighted overlays will be displayed on the successfully decoded barcodes when overlayVisible is set to true.
            GeneralSettings.shared.dbrDrawingLayer?.visible = isOn
            GeneralSettings.shared.dceViewSettings.highlightDecodedBarcodesIsOpen = isOn
        } else if settingString == GeneralSettings.shared.dceViewSettings.displayTorchButton {
            
            // Make configurations for overlays.
            // Setting the torchButtonVisible to true will display a torch button on the UI.
            // The torch button can control the status of the mobile torch.
            GeneralSettings.shared.dceView.torchButtonVisible = isOn
            GeneralSettings.shared.dceViewSettings.displayTorchButtonIsOpen = isOn
        }
    }
}
