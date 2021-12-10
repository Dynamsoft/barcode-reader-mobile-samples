//
//  ViewSettingsTableViewController.swift
//  GeneralSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class ViewSettingsTableViewController: UITableViewController {

    let tableDataArr = ["Display Overlay", "Display Torch Button"]
    var overlaySwitch:UISwitch!
    var torchSwitch:UISwitch!
    
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
        return 2
    }
    
    @objc func clickQuestionBtn(_ sender:UIButton)
    {
        let msg = "An overlay will be displayed on the successfully decoded barcodes. The display of overlay is controlled by Dynamsoft Camera Enhancer. "
        let alertCntrllr = UIAlertController(title: "Display Overlay", message: msg, preferredStyle: .alert)
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
    
    @objc func overlayVal()
    {
        GeneralSettings.instance.dceView.overlayVisible = self.overlaySwitch.isOn
        self.tableView.reloadSections([0], with: .fade)
    }
    
    func overlayMode(cell:UITableViewCell)
    {
        let sw = SettingsCommon.getSwitch(cell: cell, rightMargin: 20)
        sw.addTarget(self, action: #selector(overlayVal), for: .valueChanged)
        sw.isOn = GeneralSettings.instance.dceView.overlayVisible
        self.overlaySwitch = sw
    }
    
    @objc func torchVal()
    {
        GeneralSettings.instance.dceView.torchButtonVisible = self.torchSwitch.isOn
        self.tableView.reloadSections([0], with: .fade)
    }
    
    func torchMode(cell:UITableViewCell)
    {
        let sw = SettingsCommon.getSwitch(cell: cell, rightMargin: 20)
        sw.addTarget(self, action: #selector(torchVal), for: .valueChanged)
        sw.isOn = GeneralSettings.instance.dceView.torchButtonVisible
        self.torchSwitch = sw
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
        if indexPath.row == 0 {
            self.overlayMode(cell:cell)
            self.addQuestionBtn(cell:cell, idx: 0, leftMargin: 150)
        }else if indexPath.row == 1 {
            self.torchMode(cell:cell)
        }
        return cell
    }

}
