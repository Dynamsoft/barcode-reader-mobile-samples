/*
 * This is the sample of Dynamsoft Capture Vision Router.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

let AAMVA_DL_ID_InfoList: [[String: String]] = [["Title": "Last Name", "FieldName": "lastName"],
                                                ["Title": "Given Name", "FieldName": "givenName"],
                                                ["Title": "First Name", "FieldName": "firstName"],
                                                ["Title": "Full Name", "FieldName": "fullName"],
                                                ["Title": "Street", "FieldName": "street_1", "FieldName2": "street_2"],
                                                ["Title": "City", "FieldName": "city"],
                                                ["Title": "State", "FieldName": "jurisdictionCode"],
                                                ["Title": "License Number", "FieldName": "licenseNumber"],
                                                ["Title": "Issue Date", "FieldName": "issuedDate"],
                                                ["Title": "Expiration Date", "FieldName": "expirationDate"],
                                                ["Title": "Date of Birth", "FieldName": "birthDate"],
                                                ["Title": "Height", "FieldName": "height"],
                                                ["Title": "Sex", "FieldName": "sex"],
                                                ["Title": "Issued Country", "FieldName": "issuingCountry"],
                                                ["Title": "Vehicle Class", "FieldName": "vehicleClass"]
]

let AAMVA_DL_ID_WITH_MAG_STRIPE_InfoList :[[String:String]] = [["Title":"Full Name", "FieldName":"name"],
                                                               ["Title":"Address", "FieldName":"address"],
                                                               ["Title":"City", "FieldName":"city"],
                                                               ["Title":"State or Province", "FieldName":"stateOrProvince"],
                                                               ["Title":"License Number", "FieldName":"DLorID_Number"],
                                                               ["Title":"Expiration Date", "FieldName":"expirationDate"],
                                                               ["Title":"Date of Birth", "FieldName":"birthDate"],
                                                               ["Title":"Height", "FieldName":"height"],
                                                               ["Title":"Sex", "FieldName":"sex"]
]

let SOUTH_AFRICA_DL_InfoList: [[String: String]] = [["Title": "Surname", "FieldName": "surname"],
                                                    ["Title": "ID Number", "FieldName": "idNumber"],
                                                    ["Title": "ID Number Type", "FieldName": "idNumberType"],
                                                    ["Title": "Initials", "FieldName": "initials"],
                                                    ["Title": "License Issue Number", "FieldName": "licenseIssueNumber"],
                                                    ["Title": "License Number", "FieldName": "licenseNumber"],
                                                    ["Title": "Validity from", "FieldName": "licenseValidityFrom"],
                                                    ["Title": "Validity to", "FieldName": "licenseValidityTo"],
                                                    ["Title": "Date of Birth", "FieldName": "birthDate"],
                                                    ["Title": "Gender", "FieldName": "gender"],
                                                    ["Title": "ID Issued Country", "FieldName": "idIssuedCountry"],
                                                    ["Title": "Driver Restriction Codes", "FieldName": "driverRestrictionCodes"]
]


class DriverLicenseResultViewController: UIViewController {

    var driverLicenseResultItem: ParsedResultItem!
    
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
        let headerWidth = kScreenWidth
        let headerHeight = 50.0
        let view = UIView(frame: CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight))
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: headerWidth - 20, height: headerHeight))
        label.text = "Driver License Info"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(label)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "Drive License result"
        handleData()
        setupUI()
    }
    
    private func handleData() -> Void {
        resultListArray.append(["Title" : "Document Type",
                                "Content": driverLicenseResultItem.codeType])
        
        switch driverLicenseResultItem.codeType {
        case DriverLicenseType.AAMVA_DL_ID.rawValue:
            parseResultWith(driverLicenseInfoList: AAMVA_DL_ID_InfoList, parsedFields: driverLicenseResultItem.parsedFields)
            break
        case DriverLicenseType.AAMVA_DL_ID_WITH_MAG_STRIPE.rawValue:
            parseResultWith(driverLicenseInfoList: AAMVA_DL_ID_WITH_MAG_STRIPE_InfoList, parsedFields: driverLicenseResultItem.parsedFields)
            break
        case DriverLicenseType.SOUTH_AFRICA_DL.rawValue:
            parseResultWith(driverLicenseInfoList:SOUTH_AFRICA_DL_InfoList, parsedFields: driverLicenseResultItem.parsedFields)
            break
        default:
            break
        }
    }
    
    func parseResultWith(driverLicenseInfoList: [[String : String]], parsedFields: [String : String]) -> Void {
        for infoItem in driverLicenseInfoList {
            let title = infoItem["Title"]!
            let fieldName = infoItem["FieldName"]!
            let fieldName2 = infoItem["FieldName2"]
            let fieldNameValue = parsedFields[fieldName]
            var showingContent = ""
            
            if fieldNameValue != nil {
                showingContent = fieldNameValue!
            } else {
                continue
            }
            
            if fieldName2 != nil {
                let fieldNameValue2 = parsedFields[fieldName2!]
                if fieldNameValue2 != nil {
                    showingContent = showingContent + " " + fieldNameValue2!
                }
            }
            resultListArray.append(["Title" : title,
                                    "Content": showingContent])
        }
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(resultTableView)
    }
}

extension DriverLicenseResultViewController: UITableViewDelegate, UITableViewDataSource {
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
