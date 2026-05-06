/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

let VIN_InfoList: [[String: String]] = [["Title": "VIN String", "FieldName": "vinString"],
                                        ["Title": "WMI", "FieldName": "WMI"],
                                        ["Title": "Region", "FieldName": "region"],
                                        ["Title": "VDS", "FieldName": "VDS"],
                                        ["Title": "Check Digit", "FieldName": "checkDigit"],
                                        ["Title": "Model Year", "FieldName": "modelYear"],
                                        ["Title": "Manufacturer plant", "FieldName": "plantCode"],
                                        ["Title": "Serial Number", "FieldName": "serialNumber"],
]

class VINResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var vinResultItem: ParsedResultItem!
    
    private var resultListArray: [[String : String]] = []
    
    private lazy var resultTableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.flashScrollIndicators()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableHeaderView = self.tableviewHeader
        return tableView
    }()
    
    lazy var tableviewHeader: UIView = {
        let headerWidth = view.bounds.size.width
        let headerHeight = 50.0
        let view = UIView(frame: CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight))
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: headerWidth - 20, height: headerHeight))
        label.text = "VIN Info"
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(label)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "VIN result"
        // Do any additional setup after loading the view.

        handleData()
        setupUI()
    }
    
    private func handleData() -> Void {
        parseResultWith(vinInfoList: VIN_InfoList, parsedFields: vinResultItem.parsedFields)
    }
    
    func parseResultWith(vinInfoList: [[String : String]], parsedFields: [String : String]) -> Void {
        for infoItem in vinInfoList {
            let title = infoItem["Title"]!
            let fieldName = infoItem["FieldName"]!
            let showingContent = parsedFields[fieldName]
            
            if showingContent != nil {
                resultListArray.append(["Title" : title,
                                        "Content": showingContent!])
            }
        }
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(resultTableView)
    }

}

extension VINResultViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataInfo = self.resultListArray[indexPath.row]
        let title = dataInfo["Title"] ?? ""
        let subTitle = dataInfo["Content"] ?? ""
    
        let identifier = "DCPResultCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        cell?.selectionStyle = .none
        cell?.textLabel?.text = title
        cell?.textLabel?.textColor = .lightGray
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.detailTextLabel?.text = subTitle
        cell?.detailTextLabel?.numberOfLines = 0
        cell?.detailTextLabel?.textColor = .label.withAlphaComponent(0.6)
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell!
    }
}
