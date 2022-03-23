//
//  SettingTableViewCell.swift
//  GeneralSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import Foundation

class MainSettingsTableViewController: UITableViewController {
    let tableDataArr = ["Barcode", "Camera", "View", "Reset All Settings"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView!.register(UINib(nibName:"SettingTableViewCell", bundle:nil),forCellReuseIdentifier:"settingCell")
        self.tableView!.tableFooterView = UIView(frame: CGRect.zero)
        
        let button =   UIButton(type: .system)
        button.frame = CGRect(x:0, y:0, width:40, height:36)
        button.setImage(UIImage(named:"arrow"), for: .normal)
        button.setTitle("  Back", for: .normal)
        button.addTarget(self, action: #selector(backToView), for: .touchUpInside)
         
        let leftBarBtn = UIBarButtonItem(customView: button)
         
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
                                     action: nil)
        spacer.width = -10;
         
        self.navigationItem.leftBarButtonItems = [spacer,leftBarBtn]
    }
    
    @objc func backToView(){
        var error : NSError? = NSError()
        try!GeneralSettings.instance.dbr.updateRuntimeSettings(GeneralSettings.instance.runtimeSettings)
        let region = iRegionDefinition()
        region.regionTop = GeneralSettings.instance.scanRegion.top
        region.regionLeft = GeneralSettings.instance.scanRegion.left
        region.regionRight = GeneralSettings.instance.scanRegion.right
        region.regionBottom = GeneralSettings.instance.scanRegion.bottom
        region.regionMeasuredByPercentage = 1
        if GeneralSettings.instance.scanRegion.isScanRegion {
            GeneralSettings.instance.dce.setScanRegion(region, error: &error)
            if error?.code != 0 {
                GeneralSettings.instance.scanRegion = GeneralSettings.ScanRegionSettings(isScanRegion: false, top: 0, left: 0, right: 100, bottom: 100)
                GeneralSettings.instance.dce.scanRegionVisible = false
            }
        }else{
            GeneralSettings.instance.dce.scanRegionVisible = false
        }
        
        self.navigationController?.popViewController(animated: true);
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingTableViewCell
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: tableView.bounds.width, height: cell.frame.height)
        cell.contentView.frame = cell.bounds
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byCharWrapping
        cell.textLabel?.font  = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.textColor = UIColor(red: 27.999/255.0, green: 27.999/255.0, blue: 27.999/255.0, alpha: 1)
        cell.textLabel?.text = self.tableDataArr[indexPath.row]
        return cell
    }
    
    func pushBarcodeSettings()
    {
        self.performSegue(withIdentifier: "ShowBarcodeSettings", sender: nil)
    }
    
    func pushCameraSettings(){
        self.performSegue(withIdentifier: "ShowCameraSettings", sender: nil)
    }
    
    func pushViewSettings(){
        self.performSegue(withIdentifier: "ShowViewSettings", sender: nil)
    }
    
    func resetAllSettings(){
        GeneralSettings.instance.runtimeSettings.barcodeFormatIds = EnumBarcodeFormat.ALL.rawValue
        GeneralSettings.instance.runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat2.Null.rawValue
        GeneralSettings.instance.runtimeSettings.expectedBarcodesCount = 0
        GeneralSettings.instance.isContinueScan = true
        
        GeneralSettings.instance.dce.disableFeatures(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue |
                                                 EnumEnhancerFeatures.EnumSENSOR_CONTROL.rawValue |
                                                 EnumEnhancerFeatures.EnumENHANCED_FOCUS.rawValue |
                                                 EnumEnhancerFeatures.EnumFAST_MODE.rawValue |
                                                 EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue)
        GeneralSettings.instance.cameraSettings.resolution = "Auto"
        GeneralSettings.instance.dce.setResolution(EnumResolution.EnumRESOLUTION_AUTO)
        GeneralSettings.instance.scanRegion = GeneralSettings.ScanRegionSettings(isScanRegion: false, top: 0, left: 0, right: 100, bottom: 100)
        
        GeneralSettings.instance.dceView.torchButtonVisible = false
        GeneralSettings.instance.dceView.overlayVisible = true
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: "Reset successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if #available(iOS 13.0, *) {
            let currentMode = UITraitCollection.current.userInterfaceStyle
            if (currentMode == .dark) {
                cell.backgroundColor = UIColor.white
                tableView.backgroundColor = UIColor.white
            } else if (currentMode == .light) {
            } else {
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            switch(indexPath.row)
            {
            case 0:
                self.pushBarcodeSettings()
                break
            case 1:
                self.pushCameraSettings()
                break
            case 2:
                self.pushViewSettings()
                break
            case 3:
                self.resetAllSettings()
                break
            default:
                break
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}
