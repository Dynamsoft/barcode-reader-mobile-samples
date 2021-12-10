//
//  OneDSettingsTableViewController.swift
//  GeneralSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class OneDFormatTableViewController: UITableViewController {
    
    let tableDataArr = ["Code 39", "Code 128", "Code 39 Extended", "Code 93", "Codabar", "ITF", "EAN-13", "EAN-8", "UPC-A", "UPC-E", "Industrial 25", "MSI Code"]
    var barcodeFormat_code39_btn:UIButton!
    var barcodeFormat_code128_btn:UIButton!
    var barcodeFormat_code39_extended_btn:UIButton!
    var barcodeFormat_code93_btn:UIButton!
    var barcodeFormat_codebar_btn:UIButton!
    var barcodeFormat_itf_btn:UIButton!
    var barcodeFormat_ean13_btn:UIButton!
    var barcodeFormat_ean8_btn:UIButton!
    var barcodeFormat_upca_btn:UIButton!
    var barcodeFormat_upce_btn:UIButton!
    var barcodeFormat_industrial25_btn:UIButton!
    var barcodeFormat_msicode_btn:UIButton!
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
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
            self.setupBarcodeFormatCODE39(cell:cell)
            break
        case 1:
            self.setupBarcodeFormatCODE128(cell:cell)
            break
        case 2:
            self.setupBarcodeFormatCODE39EXTENDED(cell: cell)
            break
        case 3:
            self.setupBarcodeFormatCODE93(cell:cell)
            break
        case 4:
            self.setupBarcodeFormatCODEBAR(cell:cell)
            break
        case 5:
            self.setupBarcodeFormatITF(cell:cell)
            break
        case 6:
            self.setupBarcodeFormatEAN13(cell:cell)
            break
        case 7:
            self.setupBarcodeFormatEAN8(cell:cell)
            break
        case 8:
            self.setupBarcodeFormatUPCA(cell:cell)
            break
        case 9:
            self.setupBarcodeFormatUPCE(cell:cell)
            break
        case 10:
            self.setupBarcodeFormatINDUSTRIAL25(cell:cell)
            break
        default:
            break
        }
        return cell
    }
    
    func setupBarcodeFormatCODE39(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.CODE39.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_code39_btn = ckBox
    }
    
    func setupBarcodeFormatCODE128(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.CODE128.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_code128_btn = ckBox
    }
    
    func setupBarcodeFormatCODE39EXTENDED(cell:UITableViewCell) {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.CODE39EXTENDED.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_code39_extended_btn = ckBox
    }
    
    func setupBarcodeFormatCODE93(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.CODE93.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_code93_btn = ckBox
    }
    
    func setupBarcodeFormatCODEBAR(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.CODABAR.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_codebar_btn = ckBox
    }
    
    func setupBarcodeFormatITF(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.ITF.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_itf_btn = ckBox
    }
    
    func setupBarcodeFormatEAN13(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.EAN13.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_ean13_btn = ckBox
    }
    
    func setupBarcodeFormatEAN8(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.EAN8.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_ean8_btn = ckBox
    }
    
    func setupBarcodeFormatUPCA(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.UPCA.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_upca_btn = ckBox
    }
    
    func setupBarcodeFormatUPCE(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.UPCE.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_upce_btn = ckBox
    }
    
    func setupBarcodeFormatINDUSTRIAL25(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.INDUSTRIAL.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_industrial25_btn = ckBox
    }
    
    func setupBarcodeFormatmsicode(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.MSICODE.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.barcodeFormat_msicode_btn = ckBox
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row)
        {
        case 0:
            self.barcodeFormat_code39_btn.isSelected = !self.barcodeFormat_code39_btn.isSelected
            break
        case 1:
            self.barcodeFormat_code128_btn.isSelected = !self.barcodeFormat_code128_btn.isSelected
            break
        case 2:
            self.barcodeFormat_code39_extended_btn.isSelected = !self.barcodeFormat_code39_extended_btn.isSelected
            break
        case 3:
            self.barcodeFormat_code93_btn.isSelected = !self.barcodeFormat_code93_btn.isSelected
            break
        case 4:
            self.barcodeFormat_codebar_btn.isSelected = !self.barcodeFormat_codebar_btn.isSelected
            break
        case 5:
            self.barcodeFormat_itf_btn.isSelected = !self.barcodeFormat_itf_btn.isSelected
            break
        case 6:
            self.barcodeFormat_ean13_btn.isSelected = !self.barcodeFormat_ean13_btn.isSelected
            break
        case 7:
            self.barcodeFormat_ean8_btn.isSelected = !self.barcodeFormat_ean8_btn.isSelected
            break
        case 8:
            self.barcodeFormat_upca_btn.isSelected = !self.barcodeFormat_upca_btn.isSelected
            break
        case 9:
            self.barcodeFormat_upce_btn.isSelected = !self.barcodeFormat_upce_btn.isSelected
            break
        case 10:
            self.barcodeFormat_industrial25_btn.isSelected = !self.barcodeFormat_industrial25_btn.isSelected
            break
        default:
            break
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        var types = 0
        if(self.barcodeFormat_code39_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.CODE39.rawValue
        }
        if(self.barcodeFormat_code128_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.CODE128.rawValue
        }
        if (self.barcodeFormat_code39_extended_btn.isSelected) {
            types = types | EnumBarcodeFormat.CODE39EXTENDED.rawValue
        }
        if(self.barcodeFormat_code93_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.CODE93.rawValue
        }
        if(self.barcodeFormat_codebar_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.CODABAR.rawValue
        }
        if(self.barcodeFormat_itf_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.ITF.rawValue
        }
        if(self.barcodeFormat_ean13_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.EAN13.rawValue
        }
        if(self.barcodeFormat_ean8_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.EAN8.rawValue
        }
        if(self.barcodeFormat_upca_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.UPCA.rawValue
        }
        if(self.barcodeFormat_upce_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.UPCE.rawValue
        }
        if(self.barcodeFormat_industrial25_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.INDUSTRIAL.rawValue
        }
        if(self.barcodeFormat_msicode_btn.isSelected)
        {
            types = types | EnumBarcodeFormat.MSICODE.rawValue
        }
        let allOneDTypeInvert = ~EnumBarcodeFormat.ONED.rawValue
        GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & allOneDTypeInvert
        GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | types
        super.viewWillDisappear(animated)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0)
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 30))
            view.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1)
            let la = UILabel()
            la.text = "OneD"
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
    
    @objc func enableAllClick()
    {
        if isAll {
            self.barcodeFormat_code39_btn.isSelected = true
            self.barcodeFormat_code128_btn.isSelected = true
            self.barcodeFormat_code39_extended_btn.isSelected = true
            self.barcodeFormat_code93_btn.isSelected = true
            self.barcodeFormat_codebar_btn.isSelected = true
            self.barcodeFormat_itf_btn.isSelected = true
            self.barcodeFormat_ean13_btn.isSelected = true
            self.barcodeFormat_ean8_btn.isSelected = true
            self.barcodeFormat_upca_btn.isSelected = true
            self.barcodeFormat_upce_btn.isSelected = true
            self.barcodeFormat_industrial25_btn.isSelected = true
            self.barcodeFormat_msicode_btn.isSelected = true
        }else{
            self.barcodeFormat_code39_btn.isSelected = false
            self.barcodeFormat_code128_btn.isSelected = false
            self.barcodeFormat_code39_extended_btn.isSelected = false
            self.barcodeFormat_code93_btn.isSelected = false
            self.barcodeFormat_codebar_btn.isSelected = false
            self.barcodeFormat_itf_btn.isSelected = false
            self.barcodeFormat_ean13_btn.isSelected = false
            self.barcodeFormat_ean8_btn.isSelected = false
            self.barcodeFormat_upca_btn.isSelected = false
            self.barcodeFormat_upce_btn.isSelected = false
            self.barcodeFormat_industrial25_btn.isSelected = false
            self.barcodeFormat_msicode_btn.isSelected = false
        }
        isAll = !isAll
        if isAll {
            enAll.setTitle("Enable All", for: .normal)
        }else{
            enAll.setTitle("Disable All", for: .normal)
        }
    }
    
    func getChecked() {
        if !self.barcodeFormat_code39_btn.isSelected || !self.barcodeFormat_code128_btn.isSelected || !self.barcodeFormat_code39_extended_btn.isSelected || !self.barcodeFormat_code93_btn.isSelected || !self.barcodeFormat_codebar_btn.isSelected || !self.barcodeFormat_itf_btn.isSelected || !self.barcodeFormat_ean13_btn.isSelected || !self.barcodeFormat_ean8_btn.isSelected || !self.barcodeFormat_upca_btn.isSelected || !self.barcodeFormat_upce_btn.isSelected || !self.barcodeFormat_industrial25_btn.isSelected || !self.barcodeFormat_msicode_btn.isSelected {
            isAll = true
        }
    }

}
