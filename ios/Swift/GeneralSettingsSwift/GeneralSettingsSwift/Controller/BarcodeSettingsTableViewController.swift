//
//  BarcodeSettingsTableViewController.swift
//  GeneralSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class BarcodeSettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    let tableDataArr = ["Barcode Formats", "Expected Count :", "Continuous Scan"]
    var expectedCountCellTextField:UITextField!
    var continueScanSwitch:UISwitch!
    var runtimeSettings:iPublicRuntimeSettings!
    
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
        return 3
    }
    
    @objc func doneButtonAction(){
        expectedCountCellTextField.resignFirstResponder()
        GeneralSettings.instance.runtimeSettings.expectedBarcodesCount = Int(expectedCountCellTextField.text!) ?? 0
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "done", style: .done,target: self,action: #selector(doneButtonAction))
        var items:[UIBarButtonItem] = []
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        expectedCountCellTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func clickQuestionBtn(_ sender:UIButton)
    {
        let msg = "The fewer expected barcode count, the higher barcode decoding speed. When the expected count is set to 0, the barcode reader will try to decode at least one barcode. "
        let alertCntrllr = UIAlertController(title: "Expected count", message: msg, preferredStyle: .alert)
        let alrtActn = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
        }
        alertCntrllr.addAction(alrtActn)
        self.present(alertCntrllr, animated: true, completion: nil)
    }
    
    func addQuestionBtn(cell:UITableViewCell,idx:Int,leftMargin:CGFloat)
    {
        let pi = SettingsCommon.getQuestionBtn(cell: cell, leftMargin: leftMargin)
        pi.tag = idx
        pi.addTarget(self, action:#selector(clickQuestionBtn(_:)), for:.touchUpInside)
    }
    
    func expectedCountCell(cell:UITableViewCell)
    {
        let tf = SettingsCommon.getTextField(cell: cell, rightMargin: 20, delegate: self)
        tf.text = String(GeneralSettings.instance.runtimeSettings.expectedBarcodesCount)
        tf.keyboardType = .numberPad
        self.expectedCountCellTextField = tf
        addDoneButtonOnKeyboard()
    }
    
    @objc func continueScanModeVal()
    {
        GeneralSettings.instance.isContinueScan = self.continueScanSwitch.isOn
        self.tableView.reloadSections([0], with: .fade)
    }
    
    func setupContinueScanMode(cell:UITableViewCell)
    {
        let sw = SettingsCommon.getSwitch(cell: cell, rightMargin: 20)
        sw.addTarget(self, action: #selector(continueScanModeVal), for: .valueChanged)
        sw.isOn = GeneralSettings.instance.isContinueScan
        self.continueScanSwitch = sw
    }

    func pushBarcodeFormats()
    {
        self.performSegue(withIdentifier: "ShowBarcodeFormats", sender: nil)
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
            cell.accessoryType = .disclosureIndicator
        case 1:
            self.expectedCountCell(cell:cell)
            self.addQuestionBtn(cell:cell, idx: 1, leftMargin: 150)
        case 2:
            self.setupContinueScanMode(cell: cell)
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0)
        {
            if indexPath.row == 0 {
                self.pushBarcodeFormats()
            }
        }
    }

}
