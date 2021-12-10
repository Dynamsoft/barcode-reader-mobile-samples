//
//  FormatsTableViewController.swift
//  GeneralSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class FormatsTableViewController: UITableViewController {

    let tableDataArr = ["OneD", "GS1 DataBar", "Postal Code", "PDF417", "QR Code", "DataMatrix", "AZTEC", "MaxiCode", "Micro QR", "Micro PDF417", "GS1 Composite", "Patch Code", "Dot Code"]
    var format_pdf417CkBox:UIButton!
    var format_qrcodeCkBox:UIButton!
    var format_datamatrixCkBox:UIButton!
    var format_aztecCkBox:UIButton!
    var format_maxicodeCkBox:UIButton!
    var format_microqrCkBox:UIButton!
    var format_micropdf417CkBox:UIButton!
    var format_gs1compositeCkBox:UIButton!
    var format_patchcodeCkBox:UIButton!
    var format_dotcodeCkBox:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView!.register(UINib(nibName:"SettingTableViewCell", bundle:nil),forCellReuseIdentifier:"settingCell")
        self.tableView!.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 13
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
        //ComplexSettingsTableViewController.TextColor
        cell.textLabel?.text = self.tableDataArr[indexPath.row]
        switch(indexPath.row)
        {
            case 0:
                cell.accessoryType = .disclosureIndicator
            case 1:
                cell.accessoryType = .disclosureIndicator
            case 2:
                cell.accessoryType = .disclosureIndicator
            case 3:
                self.setupBarcodeFormatPDF417(cell:cell)
            case 4:
                self.setupBarcodeFormatQRCODE(cell:cell)
            case 5:
                self.setupBarcodeFormatDATAMATRIX(cell:cell)
            case 6:
                self.setupBarcodeFormatAZTEC(cell:cell)
            case 7:
                self.setupBarcodeFormatMAXICODE(cell:cell)
            case 8:
                self.setupBarcodeFormatMICROQR(cell:cell)
            case 9:
                self.setupBarcodeFormatMICROPDF417(cell:cell)
            case 10:
                self.setupBarcodeFormatGS1COMPOSITE(cell:cell)
            case 11:
                self.setupBarcodeFormatPATCHCODE(cell:cell)
            default:
                break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row)
        {
        case 0:
            self.pushONED()
            break
        case 1:
            self.pushGS1DataBar()
            break
        case 2:
            self.pushPostalCode()
            break
        case 3:
            self.format_pdf417CkBox.isSelected = !self.format_pdf417CkBox.isSelected
            if(self.format_pdf417CkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | EnumBarcodeFormat.PDF417.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat.PDF417.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & temp
            }
            break;
        case 4:
            self.format_qrcodeCkBox.isSelected = !self.format_qrcodeCkBox.isSelected
            if(self.format_qrcodeCkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | EnumBarcodeFormat.QRCODE.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat.QRCODE.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & temp
            }
            break;
        case 5:
            self.format_datamatrixCkBox.isSelected = !self.format_datamatrixCkBox.isSelected
            if(self.format_datamatrixCkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | EnumBarcodeFormat.DATAMATRIX.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat.DATAMATRIX.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & temp
            }
            break
        case 6:
            self.format_aztecCkBox.isSelected = !self.format_aztecCkBox.isSelected
            if(self.format_aztecCkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | EnumBarcodeFormat.AZTEC.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat.AZTEC.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & temp
            }
            break
        case 7:
            self.format_maxicodeCkBox.isSelected = !self.format_maxicodeCkBox.isSelected
            if(self.format_maxicodeCkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | EnumBarcodeFormat.MAXICODE.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat.MAXICODE.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & temp
            }
            break
        case 8:
            self.format_microqrCkBox.isSelected = !self.format_microqrCkBox.isSelected
            if(self.format_microqrCkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | EnumBarcodeFormat.MICROQR.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat.MICROQR.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & temp
            }
            break
        case 9:
            self.format_micropdf417CkBox.isSelected = !self.format_micropdf417CkBox.isSelected
            if(self.format_micropdf417CkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | EnumBarcodeFormat.MICROPDF417.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat.MICROPDF417.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & temp
            }
            break
        case 10:
            self.format_gs1compositeCkBox.isSelected = !self.format_gs1compositeCkBox.isSelected
            if(self.format_gs1compositeCkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | EnumBarcodeFormat.GS1COMPOSITE.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat.GS1COMPOSITE.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & temp
            }
            break
        case 11:
            self.format_patchcodeCkBox.isSelected = !self.format_patchcodeCkBox.isSelected
            if(self.format_patchcodeCkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds | EnumBarcodeFormat.PATCHCODE.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat.PATCHCODE.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds = GeneralSettings.instance.runtimeSettings.barcodeFormatIds & temp
            }
            break
        default :
            self.format_dotcodeCkBox.isSelected = !self.format_dotcodeCkBox.isSelected
            if(self.format_dotcodeCkBox.isSelected)
            {
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds_2 = GeneralSettings.instance.runtimeSettings.barcodeFormatIds_2 | EnumBarcodeFormat2.DOTCODE.rawValue
            }
            else
            {
                let temp = ~EnumBarcodeFormat2.DOTCODE.rawValue
                GeneralSettings.instance.runtimeSettings.barcodeFormatIds_2 = GeneralSettings.instance.runtimeSettings.barcodeFormatIds_2 & temp
            }
            break
        }
    }
    
    func pushONED()
    {
        self.performSegue(withIdentifier: "ShowONEDSettings", sender: nil)
    }
    
    func pushGS1DataBar()
    {
        self.performSegue(withIdentifier: "ShowGS1DataBarSettings", sender: nil)
    }
    
    func pushPostalCode()
    {
        self.performSegue(withIdentifier: "ShowPostalCodeSettings", sender: nil)
    }
    
    func setupBarcodeFormatPDF417(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.PDF417.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.format_pdf417CkBox = ckBox
    }
    
    func setupBarcodeFormatQRCODE(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.QRCODE.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.format_qrcodeCkBox = ckBox
    }
    
    func setupBarcodeFormatDATAMATRIX(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.DATAMATRIX.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.format_datamatrixCkBox = ckBox
    }
    
    func setupBarcodeFormatAZTEC(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.AZTEC.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.format_aztecCkBox = ckBox
    }
    
    func setupBarcodeFormatMAXICODE(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.MAXICODE.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.format_maxicodeCkBox = ckBox
    }
  
    func setupBarcodeFormatMICROQR(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.MICROQR.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.format_microqrCkBox = ckBox
    }
    
    func setupBarcodeFormatMICROPDF417(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.MICROPDF417.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.format_micropdf417CkBox = ckBox
    }
    
    func setupBarcodeFormatGS1COMPOSITE(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.GS1COMPOSITE.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.format_gs1compositeCkBox = ckBox
    }
    
    func setupBarcodeFormatPATCHCODE(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds | EnumBarcodeFormat.PATCHCODE.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds
        self.format_patchcodeCkBox = ckBox
    }
    
    func setupBarcodeFormatDOTCODE(cell:UITableViewCell)
    {
        let ckBox = SettingsCommon.getCheckBox(cell: cell, rightMargin: 20)
        ckBox.isSelected = (GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2 | EnumBarcodeFormat2.DOTCODE.rawValue) == GeneralSettings.instance.runtimeSettings!.barcodeFormatIds_2
        self.format_dotcodeCkBox = ckBox
    }

}
