//
//  GS1DataBarSettingsTableViewController.swift
//  GeneralSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class GS1DataBarFormatTableViewController: UITableViewController {

    let tableDataArr = ["GS1 Databar Omnidirectional", "GS1 Databar Truncated", "GS1 Databar Stacked", "GS1 Databar Stacked Omnidirectional", "GS1 Databar Expanded", "GS1 Databar Expaned Stacked", "GS1 Databar Limited"]
    var barcodeFormat_omnidirectional_btn:UIButton!
    var barcodeFormat_truncated_btn:UIButton!
    var barcodeFormat_stacked_btn:UIButton!
    var barcodeFormat_stacked_omnidirectional_btn:UIButton!
    var barcodeFormat_expanded_btn:UIButton!
    var barcodeFormat_expaned_stacked_btn:UIButton!
    var barcodeFormat_limited_btn:UIButton!
    var enAll = UIButton()
    var isAll:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        self.tableView!.register(UINib(nibName:"SettingTableViewCell", bundle:nil),forCellReuseIdentifier:"settingCell")
        self.tableView!.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingTableViewCell
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: tableView.bounds.width, height: cell.frame.height)
        cell.contentView.frame = cell.bounds
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byCharWrapping
        cell.textLabel?.font  = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.textColor = UIColor(red: 27.999/255.0, green: 27.999/255.0, blue: 27.999/255.0, alpha: 1)
        cell.textLabel?.text = self.tableDataArr[indexPath.row]
        switch(indexPath.row)
        {
        case 0:
            self.setupBarcodeFormatOMNIDIRECTIONAL(cell:cell)
            break
        case 1:
            self.setupBarcodeFormatTRUNCATED(cell:cell)
            break
        case 2:
            self.setupBarcodeFormatSTACKED(cell: cell)
            break
        case 3:
            self.setupBarcodeFormatSTACKEDOMNIDIRECTIONAL(cell:cell)
            break
        case 4:
            self.setupBarcodeFormatEXPANDED(cell:cell)
            break
        case 5:
            self.setupBarcodeFormatEXPANDEDSTACKED(cell:cell)
            break
        default:
            self.setupBarcodeFormatLIMITED(cell: cell)
            break
        }
        return cell
    }
    
    func setupBarcodeFormatOMNIDIRECTIONAL(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.GS1DATABAROMNIDIRECTIONAL.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_omnidirectional_btn = ckBox
    }
    
    func setupBarcodeFormatTRUNCATED(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.GS1DATABARTRUNCATED.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_truncated_btn = ckBox
    }
    
    func setupBarcodeFormatSTACKED(cell:UITableViewCell) {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.GS1DATABARSTACKED.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_stacked_btn = ckBox
    }
    
    func setupBarcodeFormatSTACKEDOMNIDIRECTIONAL(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.GS1DATABARSTACKEDOMNIDIRECTIONAL.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_stacked_omnidirectional_btn = ckBox
    }
    
    func setupBarcodeFormatEXPANDED(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.GS1DATABAREXPANDED.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_expanded_btn = ckBox
    }
    
    func setupBarcodeFormatEXPANDEDSTACKED(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.GS1DATABAREXPANDEDSTACKED.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_expaned_stacked_btn = ckBox
    }
    
    func setupBarcodeFormatLIMITED(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.GS1DATABARLIMITED.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_limited_btn = ckBox
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
            self.barcodeFormat_omnidirectional_btn.isSelected = !self.barcodeFormat_omnidirectional_btn.isSelected
            break
        case 1:
            self.barcodeFormat_truncated_btn.isSelected = !self.barcodeFormat_truncated_btn.isSelected
            break
        case 2:
            self.barcodeFormat_stacked_btn.isSelected = !self.barcodeFormat_stacked_btn.isSelected
            break
        case 3:
            self.barcodeFormat_stacked_omnidirectional_btn.isSelected = !self.barcodeFormat_stacked_omnidirectional_btn.isSelected
            break
        case 4:
            self.barcodeFormat_expanded_btn.isSelected = !self.barcodeFormat_expanded_btn.isSelected
            break
        case 5:
            self.barcodeFormat_expaned_stacked_btn.isSelected = !self.barcodeFormat_expaned_stacked_btn.isSelected
            break
        default:
            self.barcodeFormat_limited_btn.isSelected = !self.barcodeFormat_limited_btn.isSelected
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var types = 0
        if(self.barcodeFormat_omnidirectional_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.GS1DATABAROMNIDIRECTIONAL.rawValue
        }
        if(self.barcodeFormat_truncated_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.GS1DATABARTRUNCATED.rawValue
        }
        if(self.barcodeFormat_stacked_btn.isSelected) {
            types = types | EnumBarcodeFormat.GS1DATABARSTACKED.rawValue
        }
        if(self.barcodeFormat_stacked_omnidirectional_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.GS1DATABARSTACKEDOMNIDIRECTIONAL.rawValue
        }
        if(self.barcodeFormat_expanded_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.GS1DATABAREXPANDED.rawValue
        }
        if(self.barcodeFormat_expaned_stacked_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.GS1DATABAREXPANDEDSTACKED.rawValue
        }
        if(self.barcodeFormat_limited_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.GS1DATABARLIMITED.rawValue
        }
        
        let allDataBarTypeInvert = ~EnumBarcodeFormat.GS1DATABAR.rawValue
        GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & allDataBarTypeInvert
        GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | types
        super.viewWillDisappear(animated)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0)
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 30))
            view.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1)
            let la = UILabel()
            la.text = "GS1DataBar"
            la.font = UIFont.systemFont(ofSize: 14)
            la.frame = CGRect(x: 16, y: 9, width: 150, height: 13)
            la.backgroundColor = UIColor.clear
            la.textColor = UIColor(red: 123.999/255.0, green:123.999/255.0, blue:123.999/255.0, alpha:1)
            view.addSubview(la)
            getChecked()
            if isAll {
                enAll.setTitle("Enable All", for: .normal)
            }else{
                enAll.setTitle("Disable All", for: .normal)
            }
            enAll.setTitleColor(UIColor(red: 0/255.0, green:191.0/255.0, blue:255.0/255.0, alpha:1), for: .normal)
            enAll.frame = CGRect(x: self.tableView.bounds.width - 100, y: 0, width: 90, height: 30)
            enAll.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            enAll.tintColor = .blue
            enAll.addTarget(self, action: #selector(enableAllClick), for: .touchUpInside)
            view.addSubview(enAll)
            return view
        }
        return nil
    }
    
    @objc func enableAllClick(){
        if isAll {
            self.barcodeFormat_omnidirectional_btn.isSelected = true
            self.barcodeFormat_truncated_btn.isSelected = true
            self.barcodeFormat_stacked_btn.isSelected = true
            self.barcodeFormat_stacked_omnidirectional_btn.isSelected = true
            self.barcodeFormat_expanded_btn.isSelected = true
            self.barcodeFormat_expaned_stacked_btn.isSelected = true
            self.barcodeFormat_limited_btn.isSelected = true
        }else{
            self.barcodeFormat_omnidirectional_btn.isSelected = false
            self.barcodeFormat_truncated_btn.isSelected = false
            self.barcodeFormat_stacked_btn.isSelected = false
            self.barcodeFormat_stacked_omnidirectional_btn.isSelected = false
            self.barcodeFormat_expanded_btn.isSelected = false
            self.barcodeFormat_expaned_stacked_btn.isSelected = false
            self.barcodeFormat_limited_btn.isSelected = false
        }
        isAll = !isAll
        if isAll {
            enAll.setTitle("Enable All", for: .normal)
        }else{
            enAll.setTitle("Disable All", for: .normal)
        }
    }
    
    func getChecked() {
        if !self.barcodeFormat_omnidirectional_btn.isSelected || !self.barcodeFormat_truncated_btn.isSelected || !self.barcodeFormat_stacked_btn.isSelected || !self.barcodeFormat_stacked_omnidirectional_btn.isSelected || !self.barcodeFormat_expanded_btn.isSelected || !self.barcodeFormat_expaned_stacked_btn.isSelected || !self.barcodeFormat_limited_btn.isSelected {
            isAll = true
        }
    }

}
