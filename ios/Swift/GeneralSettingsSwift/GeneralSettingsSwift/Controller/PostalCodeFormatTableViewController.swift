//
//  SettingTableViewCell.swift
//  GeneralSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import Foundation

class PostalCodeFormatTableViewController: UITableViewController {
    let tableDataArr = ["USPS Intelligent Mail", "Postnet", "Planet", "Australian Post", "Royal Mail"]
    var barcodeFormat_USPSINTELLIGENTMAIL_btn:UIButton!
    var barcodeFormat_POSTNET_btn:UIButton!
    var barcodeFormat_PLANET_btn:UIButton!
    var barcodeFormat_AUSTRALIANPOST_btn:UIButton!
    var barcodeFormat_RM4SCC_btn:UIButton!
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
        return 5
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
            self.setupUSPSINTELLIGENTMAIL(cell:cell)
        case 1:
            self.setupPOSTNET(cell:cell)
        case 2:
            self.setupPLANET(cell: cell)
        case 3:
            self.setupAUSTRALIANPOST(cell:cell)
        default:
            break
        }
        return cell
    }
    
    func setupUSPSINTELLIGENTMAIL(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2 | EnumBarcodeFormat2.USPSINTELLIGENTMAIL.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2
        self.barcodeFormat_USPSINTELLIGENTMAIL_btn = ckBox
    }
    
    func setupPOSTNET(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2 | EnumBarcodeFormat2.POSTNET.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2
        self.barcodeFormat_POSTNET_btn = ckBox
    }
    
    func setupPLANET(cell:UITableViewCell) {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2 | EnumBarcodeFormat2.PLANET.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2
        self.barcodeFormat_PLANET_btn = ckBox
    }
    
    func setupAUSTRALIANPOST(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2 | EnumBarcodeFormat2.AUSTRALIANPOST.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2
        self.barcodeFormat_AUSTRALIANPOST_btn = ckBox
    }
    
    func setupRM4SCC(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2 | EnumBarcodeFormat2.RM4SCC.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2
        self.barcodeFormat_RM4SCC_btn = ckBox
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
        if (indexPath.section == 0)
        {
            switch(indexPath.row)
            {
            case 0:
                self.barcodeFormat_USPSINTELLIGENTMAIL_btn.isSelected = !self.barcodeFormat_USPSINTELLIGENTMAIL_btn.isSelected
            case 1:
                self.barcodeFormat_POSTNET_btn.isSelected = !self.barcodeFormat_POSTNET_btn.isSelected
            case 2:
                self.barcodeFormat_PLANET_btn.isSelected = !self.barcodeFormat_PLANET_btn.isSelected
            case 3:
                self.barcodeFormat_AUSTRALIANPOST_btn.isSelected = !self.barcodeFormat_AUSTRALIANPOST_btn.isSelected
            default:
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var types = 0
        if(self.barcodeFormat_USPSINTELLIGENTMAIL_btn.isSelected)
        {
            types = types | EnumBarcodeFormat2.USPSINTELLIGENTMAIL.rawValue
        }
        if(self.barcodeFormat_POSTNET_btn.isSelected)
        {
            types = types | EnumBarcodeFormat2.POSTNET.rawValue
        }
        if(self.barcodeFormat_PLANET_btn.isSelected) {
            types = types | EnumBarcodeFormat2.PLANET.rawValue
        }
        if(self.barcodeFormat_AUSTRALIANPOST_btn.isSelected)
        {
            types = types | EnumBarcodeFormat2.AUSTRALIANPOST.rawValue
        }
        if(self.barcodeFormat_RM4SCC_btn.isSelected)
        {
            types = types | EnumBarcodeFormat2.RM4SCC.rawValue
        }
        
        let allPostalTypeInvert = ~EnumBarcodeFormat2.POSTALCODE.rawValue
        GeneralSettings.instance.runtimeSettings.barcodeFormatIds_2 = GeneralSettings.instance.runtimeSettings.barcodeFormatIds_2 & allPostalTypeInvert
        GeneralSettings.instance.runtimeSettings.barcodeFormatIds_2 = GeneralSettings.instance.runtimeSettings.barcodeFormatIds_2 | types
        super.viewWillDisappear(animated)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0)
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 30))
            view.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1)
            let la = UILabel()
            la.text = "PostalCode"
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
            self.barcodeFormat_USPSINTELLIGENTMAIL_btn.isSelected = true
            self.barcodeFormat_POSTNET_btn.isSelected = true
            self.barcodeFormat_PLANET_btn.isSelected = true
            self.barcodeFormat_AUSTRALIANPOST_btn.isSelected = true
            self.barcodeFormat_RM4SCC_btn.isSelected = true
        }else{
            self.barcodeFormat_USPSINTELLIGENTMAIL_btn.isSelected = false
            self.barcodeFormat_POSTNET_btn.isSelected = false
            self.barcodeFormat_PLANET_btn.isSelected = false
            self.barcodeFormat_AUSTRALIANPOST_btn.isSelected = false
            self.barcodeFormat_RM4SCC_btn.isSelected = false
        }
        isAll = !isAll
        if isAll {
            enAll.setTitle("Enable All", for: .normal)
        }else{
            enAll.setTitle("Disable All", for: .normal)
        }
    }
    
    func getChecked() {
        if !self.barcodeFormat_USPSINTELLIGENTMAIL_btn.isSelected || !self.barcodeFormat_POSTNET_btn.isSelected || !self.barcodeFormat_PLANET_btn.isSelected || !self.barcodeFormat_AUSTRALIANPOST_btn.isSelected || !self.barcodeFormat_RM4SCC_btn.isSelected  {
            isAll = true
        }
    }
}
