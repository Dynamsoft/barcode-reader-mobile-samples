//
//  SettingsViewController.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

let barcodeSetting = "Barcode"
let cameraSetting = "Camera"
let viewSetting = "View"
let resetAllSetting = "Reset All Settings"

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let settingDataArray = [barcodeSetting, cameraSetting, viewSetting, resetAllSetting]
    lazy var settingTableView: UITableView = {
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
        self.title = "Settings"
        
        setupUI()
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(settingTableView)
    }

    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BasicTableViewCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleTag = self.settingDataArray[indexPath.row]
        
        let identifier = "BasicTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTableViewCell
        if cell == nil {
            cell = BasicTableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        
        if titleTag == resetAllSetting {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .disclosureIndicator
        }
        
        cell?.updateUI(with: titleTag)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let titleTag = self.settingDataArray[indexPath.row]
        
        var pushVC: UIViewController!
        if titleTag == barcodeSetting {
            pushVC = BarcodeSettingsViewController()
        } else if titleTag == cameraSetting {
            pushVC = CameraSettingsViewController()
        } else if titleTag == viewSetting {
            pushVC = ViewSettingsViewController()
        } else if titleTag == resetAllSetting {
            resetToDefault()
        }
        
        guard pushVC != nil  else {
            return
        }
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    private func resetToDefault() -> Void {
        GeneralSettings.shared.resetToDefault()
        ToolsManager.shared.addAlertView(to: self,content: "Reset Successfully", completion: nil)

    }

}
