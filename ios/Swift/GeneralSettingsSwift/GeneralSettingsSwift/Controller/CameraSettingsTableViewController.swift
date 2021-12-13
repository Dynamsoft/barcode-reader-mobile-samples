//
//  CameraSettingsTableViewController.swift
//  GeneralSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class CameraSettingsTableViewController: UITableViewController, UITextFieldDelegate {

    // Dynamsoft Camera Enhancer is an SDK that helps you configure camera settings and video processing.
    // Optimize the camera settings and enable DCE features can help you improve the barcode processing performance.

    let tableDataArr = [["Resolution ", "Enhanced Focus ", "Frame Sharpness Filter ", "Sensor Filter ", "Auto-zoom ", "Fast mode ","Scan Region "], [" Scan Region Top :", " Scan Region Left :", " Scan Region Right :", " Scan Region Bottom :"]]
    var resolutionCellTextField:UITextField!
    var dceFocusSwitch:UISwitch!
    var frameSharpnessFilterSwitch:UISwitch!
    var sensorFilterSwitch:UISwitch!
    var autoZoomSwitch:UISwitch!
    var fastModeSwitch:UISwitch!
    
    var scanRegionSwitch:UISwitch!
    var topCellTextField:UITextField!
    var leftCellTextField:UITextField!
    var rightCellTextField:UITextField!
    var bottomCellTextField:UITextField!
    
    var curDataArr:[String]!
    var error : NSError? = NSError()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.register(UINib(nibName:"SettingTableViewCell", bundle:nil),forCellReuseIdentifier:"settingCell")
        self.tableView!.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rowCount = 0
        switch section
        {
        case 0:
            rowCount = 7
        case 1:
            rowCount = 4
        default:
            break
        }
        return rowCount
    }
    
    @objc func clickQuestionBtn(_ sender:UIButton)
    {
        var title = ""
        var msg = ""
        switch(sender.tag)
        {
        case 0:
            title = "Enhanced Focus"
            msg = "Enhanced focus is one of the Dynamsoft Camera Enhancer features. The specially designed focus mechanism will significantly improve the camera's focusing ability on low-end devices."
        case 1:
            title = "Frame Sharpness Filter "
            msg = "Frame sharpness filter is one of the Dynamsoft Camera Enhancer features. It makes a quick evaluation on each video frames so that the Barcode Reader will be able to skip the blurry frames."
        case 2:
            title = "Sensor Filter"
            msg = "Sensor filter is one of the Dynamsoft Camera Enhancer features. The mobile sensor will help on filtering out the video frames that are captured while the device is shaking."
        case 3:
            title = "Auto-zoom "
            msg = "Auto-zoom will be available when you are using Dynamsoft Camera Enhancer and Dynamsoft Barcode Reader together. The camera will zoom-in automatically to approach the long-distance barcode."
        case 4:
            title = "Fast mode"
            msg = "Fast mode is one of the Dynamsoft Camera Enhancer features. Frame will be cropped to small size to improve the processing speed."
        case 5:
            title = "Scan Region "
            msg = "Set the region of interest via Dynamsoft Camera Enhancer. The frames will be cropped based on the region of interest to improve the barcode decoding speed. Once you have configured the scan region, the fast mode will be negated."
        default:
            title = ""
            msg = ""
        }
        let alertCntrllr = UIAlertController(title: title, message: msg, preferredStyle: .alert)
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
    
    func setupResoutionCell(cell:UITableViewCell){
        let tf = SettingsCommon.getTextField(cell: cell, rightMargin: 40, delegate: self)
        tf.text = GeneralSettings.instance.cameraSettings.resolution
        tf.isEnabled = false
        self.resolutionCellTextField = tf
        SettingsCommon.addSelectDownImageView(cell: cell, rightMargin: 20)
    }
    
    // You can enable DCE features via method enableFeatures.
    // To enable DCE features, a valid license is required.
    // You when trigger enableFeatures for a second time, the newly enabled feature will be added and the previously enabled features will keep enabled.
    @objc func dceFocusVal()
    {
        if self.dceFocusSwitch.isOn {
            GeneralSettings.instance.dce.enableFeatures(EnumEnhancerFeatures.EnumENHANCED_FOCUS.rawValue, error: &error)
            if error?.code != 0 {
                NSLog("%@",error?.userInfo ?? "")
            }
        }else{
            GeneralSettings.instance.dce.disableFeatures(EnumEnhancerFeatures.EnumENHANCED_FOCUS.rawValue)
        }
    }
    
    func dceFocusMode(cell:UITableViewCell)
    {
        let sw = SettingsCommon.getSwitch(cell: cell, rightMargin: 20)
        sw.addTarget(self, action: #selector(dceFocusVal), for: .valueChanged)
        sw.isOn = GeneralSettings.instance.dce.isFeatureEnabled(EnumEnhancerFeatures.EnumENHANCED_FOCUS.rawValue)
        self.dceFocusSwitch = sw
    }
    
    @objc func frameSharpnessFilterVal()
        {
            if self.frameSharpnessFilterSwitch.isOn {
                GeneralSettings.instance.dce.enableFeatures(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue, error: &error)
                if error?.code != 0 {
                    NSLog("%@",error?.userInfo ?? "")
                }
            }else{
                GeneralSettings.instance.dce.disableFeatures(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue)
            }
        }
        
    func frameSharpnessFilter(cell:UITableViewCell)
    {
        let sw = SettingsCommon.getSwitch(cell: cell, rightMargin: 20)
        sw.addTarget(self, action: #selector(frameSharpnessFilterVal), for: .valueChanged)
        sw.isOn = GeneralSettings.instance.dce.isFeatureEnabled(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue)
        self.frameSharpnessFilterSwitch = sw
    }
    
    @objc func sensorFilterVal()
        {
            if self.sensorFilterSwitch.isOn {
                GeneralSettings.instance.dce.enableFeatures(EnumEnhancerFeatures.EnumSENSOR_CONTROL.rawValue, error: &error)
                if error?.code != 0 {
                    NSLog("%@",error?.userInfo ?? "")
                }
            }else{
                GeneralSettings.instance.dce.disableFeatures(EnumEnhancerFeatures.EnumSENSOR_CONTROL.rawValue)
            }
        }
        
    func sensorFilterMode(cell:UITableViewCell)
    {
        let sw = SettingsCommon.getSwitch(cell: cell, rightMargin: 20)
        sw.addTarget(self, action: #selector(sensorFilterVal), for: .valueChanged)
        sw.isOn = GeneralSettings.instance.dce.isFeatureEnabled(EnumEnhancerFeatures.EnumSENSOR_CONTROL.rawValue)
        self.sensorFilterSwitch = sw
    }
    
    @objc func autoZoomVal()
        {
            if self.autoZoomSwitch.isOn {
                GeneralSettings.instance.dce.enableFeatures(EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue, error: &error)
                if error?.code != 0 {
                    NSLog("%@",error?.userInfo ?? "")
                }
            }else{
                GeneralSettings.instance.dce.disableFeatures(EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue)
            }
        }
        
    func autoZoomMode(cell:UITableViewCell)
    {
        let sw = SettingsCommon.getSwitch(cell: cell, rightMargin: 20)
        sw.addTarget(self, action: #selector(autoZoomVal), for: .valueChanged)
        sw.isOn = GeneralSettings.instance.dce.isFeatureEnabled(EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue)
        self.autoZoomSwitch = sw
    }
    
    @objc func fastModeVal()
        {
            if self.fastModeSwitch.isOn {
                GeneralSettings.instance.dce.enableFeatures(EnumEnhancerFeatures.EnumFAST_MODE.rawValue, error: &error)
                if error?.code != 0 {
                    NSLog("%@",error?.userInfo ?? "")
                }
            }else{
                GeneralSettings.instance.dce.disableFeatures(EnumEnhancerFeatures.EnumFAST_MODE.rawValue)
            }
        }
        
    func fastMode(cell:UITableViewCell)
    {
        let sw = SettingsCommon.getSwitch(cell: cell, rightMargin: 20)
        sw.addTarget(self, action: #selector(fastModeVal), for: .valueChanged)
        sw.isOn = GeneralSettings.instance.dce.isFeatureEnabled(EnumEnhancerFeatures.EnumFAST_MODE.rawValue)
        self.fastModeSwitch = sw
    }
    
    @objc func scanRegionVal()
        {
            GeneralSettings.instance.scanRegion.isScanRegion = self.scanRegionSwitch.isOn
            self.tableView.reloadSections([1], with: .fade)
        }
        
    func scanRegionMode(cell:UITableViewCell)
    {
        let sw = SettingsCommon.getSwitch(cell: cell, rightMargin: 20)
        sw.addTarget(self, action: #selector(scanRegionVal), for: .valueChanged)
        sw.isOn = GeneralSettings.instance.scanRegion.isScanRegion
        self.scanRegionSwitch = sw
    }
    
    @objc func topAction(){
        topCellTextField.resignFirstResponder()
        GeneralSettings.instance.scanRegion.top = Int(topCellTextField.text!) ?? 0
    }
    
    func addTopKeyboard(){
        let doneToolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "done", style: .done,target: self,action: #selector(topAction))
        var items:[UIBarButtonItem] = []
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        topCellTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func leftAction(){
        leftCellTextField.resignFirstResponder()
        GeneralSettings.instance.scanRegion.left = Int(leftCellTextField.text!) ?? 0
    }
    
    func addLeftKeyboard(){
        let doneToolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "done", style: .done,target: self,action: #selector(leftAction))
        var items:[UIBarButtonItem] = []
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        leftCellTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func rightAction(){
        rightCellTextField.resignFirstResponder()
        GeneralSettings.instance.scanRegion.right = Int(rightCellTextField.text!) ?? 100
    }
    
    func addRightKeyboard(){
        let doneToolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "done", style: .done,target: self,action: #selector(rightAction))
        var items:[UIBarButtonItem] = []
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        rightCellTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func bottomAction(){
        bottomCellTextField.resignFirstResponder()
        GeneralSettings.instance.scanRegion.bottom = Int(bottomCellTextField.text!) ?? 100
    }
    
    func addBottomKeyboard(){
        let doneToolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "done", style: .done,target: self,action: #selector(bottomAction))
        var items:[UIBarButtonItem] = []
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        bottomCellTextField.inputAccessoryView = doneToolbar
    }
    
    func topTextCell(cell:UITableViewCell)
    {
        let tf = SettingsCommon.getTextField(cell: cell, rightMargin: 20, delegate: self)
        tf.text = String(GeneralSettings.instance.scanRegion.top)
        tf.keyboardType = .numberPad
        self.topCellTextField = tf
        addTopKeyboard()
    }
    
    func leftTextCell(cell:UITableViewCell)
    {
        let tf = SettingsCommon.getTextField(cell: cell, rightMargin: 20, delegate: self)
        tf.text = String(GeneralSettings.instance.scanRegion.left)
        tf.keyboardType = .numberPad
        self.leftCellTextField = tf
        addLeftKeyboard()
    }
    
    func rightTextCell(cell:UITableViewCell)
    {
        let tf = SettingsCommon.getTextField(cell: cell, rightMargin: 20, delegate: self)
        tf.text = String(GeneralSettings.instance.scanRegion.right)
        tf.keyboardType = .numberPad
        self.rightCellTextField = tf
        addRightKeyboard()
    }
    
    func bottomTextCell(cell:UITableViewCell)
    {
        let tf = SettingsCommon.getTextField(cell: cell, rightMargin: 20, delegate: self)
        tf.text = String(GeneralSettings.instance.scanRegion.bottom)
        tf.keyboardType = .numberPad
        self.bottomCellTextField = tf
        addBottomKeyboard()
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
        cell.textLabel?.text = self.tableDataArr[indexPath.section][indexPath.row]
        if (indexPath.section == 0)
        {
            switch(indexPath.row)
            {
            case 0:
                self.setupResoutionCell(cell: cell)
            case 1:
                self.dceFocusMode(cell: cell)
                self.addQuestionBtn(cell:cell, idx: 0, leftMargin: 180)
            case 2:
                self.frameSharpnessFilter(cell: cell)
                self.addQuestionBtn(cell:cell, idx: 1, leftMargin: 180)
            case 3:
                self.sensorFilterMode(cell: cell)
                self.addQuestionBtn(cell:cell, idx: 2, leftMargin: 180)
            case 4:
                self.autoZoomMode(cell: cell)
                self.addQuestionBtn(cell:cell, idx: 3, leftMargin: 180)
            case 5:
                self.fastMode(cell: cell)
                self.addQuestionBtn(cell:cell, idx: 4, leftMargin: 180)
            case 6:
                self.scanRegionMode(cell: cell)
                self.addQuestionBtn(cell:cell, idx: 5, leftMargin: 180)
            default:
                break
            }
        }else if (indexPath.section == 1) {
            switch(indexPath.row)
            {
            case 0:
                if GeneralSettings.instance.scanRegion.isScanRegion {
                    self.topTextCell(cell: cell)
                    cell.contentView.isHidden = false
                    cell.isHidden = false
                }else {
                    cell.contentView.isHidden = true
                    cell.isHidden = true
                }
            case 1:
                if GeneralSettings.instance.scanRegion.isScanRegion {
                    self.leftTextCell(cell: cell)
                    cell.contentView.isHidden = false
                    cell.isHidden = false
                }else {
                    cell.contentView.isHidden = true
                    cell.isHidden = true
                }
            case 2:
                if GeneralSettings.instance.scanRegion.isScanRegion {
                    self.rightTextCell(cell: cell)
                    cell.contentView.isHidden = false
                    cell.isHidden = false
                }else {
                    cell.contentView.isHidden = true
                    cell.isHidden = true
                }
            case 3:
                if GeneralSettings.instance.scanRegion.isScanRegion {
                    self.bottomTextCell(cell: cell)
                    cell.contentView.isHidden = false
                    cell.isHidden = false
                }else {
                    cell.contentView.isHidden = true
                    cell.isHidden = true
                }
            default:
                break
            }
        }
        return cell
    }
    
    // Higher resolution will benefits the accuracy and read rate but reduce the processing speed.
    func SetTextField(indexPath:IndexPath,val:String)
    {
        if(indexPath.section == 0)
        {
            if indexPath.row == 0 {
                self.resolutionCellTextField.text = val
                GeneralSettings.instance.cameraSettings.resolution = val
                switch(val)
                {
                    case "Auto":
                        GeneralSettings.instance.dce.setResolution(EnumResolution.EnumRESOLUTION_AUTO)
                    case "480p":
                        GeneralSettings.instance.dce.setResolution(EnumResolution.EnumRESOLUTION_480P)
                    case "720p":
                        GeneralSettings.instance.dce.setResolution(EnumResolution.EnumRESOLUTION_720P)
                    case "1080p":
                        GeneralSettings.instance.dce.setResolution(EnumResolution.EnumRESOLUTION_1080P)
                    case "4k":
                        GeneralSettings.instance.dce.setResolution(EnumResolution.EnumRESOLUTION_4K)
                    case "Low":
                        GeneralSettings.instance.dce.setResolution(EnumResolution.EnumRESOLUTION_LOW)
                    case "Mid":
                        GeneralSettings.instance.dce.setResolution(EnumResolution.EnumRESOLUTION_MID)
                    case "High":
                        GeneralSettings.instance.dce.setResolution(EnumResolution.EnumRESOLUTION_HIGH)
                    default:
                    break
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0)
        {
            var isDCEResolution = false
            if indexPath.row == 0 {
                curDataArr = nil
                curDataArr = ["Auto", "480p", "720p", "1080p", "4k", "Low", "Mid","High"]
                isDCEResolution = true
                if(curDataArr != nil)
                {
                    BRStringPickerView.showStringPicker(withTitle: tableDataArr[indexPath.section][indexPath.row], dataSource: curDataArr, defaultSelValue: isDCEResolution ? curDataArr[3]:curDataArr[2])
                    {
                        (selectValue) in
                        self.SetTextField(indexPath: indexPath,val:selectValue as! String)
                    }
                }
            }
        }
    }

}
