/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class BarcodeFormatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var allBarcodeFormatDataArray: [[String : Any]] = []
    
    private var recordBarcodeFormatOptionalStateDic: [String : Bool] = [:]
    
    private lazy var barcodeFormatTableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "Barcode Formats"
        
        handleData()
        setupUI()
    }
    
    private func handleData() -> Void {
        allBarcodeFormatDataArray.removeAll()
        recordBarcodeFormatOptionalStateDic.removeAll()
        
        self.allBarcodeFormatDataArray = [["title":GeneralSettings.shared.allBarcodeDescription.oneD!, "EnumValue":BarcodeFormat.oneD.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.gs1DataBar!, "EnumValue":BarcodeFormat.gs1Databar.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.postalCode!, "EnumValue":BarcodeFormat.postalCode.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.patchCode!, "EnumValue":BarcodeFormat.patchCode.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.pdf417!, "EnumValue":BarcodeFormat.pdf417.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.qrCode!, "EnumValue":BarcodeFormat.qrCode.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.dataMatrix!, "EnumValue":BarcodeFormat.dataMatrix.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.aztec!, "EnumValue":BarcodeFormat.aztec.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.maxiCode!, "EnumValue":BarcodeFormat.maxiCode.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.microQR!, "EnumValue":BarcodeFormat.microQR.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.microPDF417!, "EnumValue":BarcodeFormat.microPDF417.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.gs1Composite!, "EnumValue":BarcodeFormat.gs1Composite.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.dotCode!, "EnumValue":BarcodeFormat.dotCode.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeDescription.pharmaCODE!, "EnumValue":BarcodeFormat.pharmaCode.rawValue]
                                          
        ]
        let cvrRuntimeSetting = GeneralSettings.shared.currentCVRRuntimeSettings!
        if let barcodeSettings = cvrRuntimeSetting.barcodeSettings {
            for singleBarcodeInfo in self.allBarcodeFormatDataArray {
                let barcodeFormatStr = singleBarcodeInfo["title"] as! String
                let barcodeValue = singleBarcodeInfo["EnumValue"] as! UInt
                if ((barcodeSettings.barcodeFormatIds.rawValue & barcodeValue) != 0) {
                    self.recordBarcodeFormatOptionalStateDic[barcodeFormatStr] = true
                } else {
                    self.recordBarcodeFormatOptionalStateDic[barcodeFormatStr] = false
                }
            }
        }
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(barcodeFormatTableView)
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BasicTableViewCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allBarcodeFormatDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let singleBarcodeInfo = self.allBarcodeFormatDataArray[indexPath.row]
        let titleTag = singleBarcodeInfo["title"] as! String
        
        if titleTag == GeneralSettings.shared.allBarcodeDescription.oneD ||
           titleTag == GeneralSettings.shared.allBarcodeDescription.gs1DataBar ||
           titleTag == GeneralSettings.shared.allBarcodeDescription.postalCode {
            
            let identifier = BasicTableViewCell.className
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTableViewCell
            if cell == nil {
                cell = BasicTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            cell?.accessoryType = .disclosureIndicator
            cell?.updateUI(with: titleTag)
            return cell!
        } else {
            let identifier = BasicOptionalTableViewCell.className
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicOptionalTableViewCell
            if cell == nil {
                cell = BasicOptionalTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            cell?.updateUI(with: titleTag, optionState: self.recordBarcodeFormatOptionalStateDic[titleTag]!)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleBarcodeInfo = self.allBarcodeFormatDataArray[indexPath.row]
        let titleTag = singleBarcodeInfo["title"] as! String
        
        if !(titleTag == GeneralSettings.shared.allBarcodeDescription.oneD ||
             titleTag == GeneralSettings.shared.allBarcodeDescription.gs1DataBar ||
             titleTag == GeneralSettings.shared.allBarcodeDescription.postalCode) {
            self.handleSelectedBarcodeFormat(with: indexPath)
            return
        }
        
        let subListVC = BarcodeFormatSubListViewController()
        if titleTag == GeneralSettings.shared.allBarcodeDescription.oneD {
            subListVC.subBarcodeFormatType = .oneD
        } else if titleTag == GeneralSettings.shared.allBarcodeDescription.gs1DataBar {
            subListVC.subBarcodeFormatType = .gs1DataBar
        } else if titleTag == GeneralSettings.shared.allBarcodeDescription.postalCode {
            subListVC.subBarcodeFormatType = .postalCode
        }
        self.navigationController?.pushViewController(subListVC, animated: true)
    }
    
    func handleSelectedBarcodeFormat(with indexPath: IndexPath) -> Void {
        let singleBarcodeInfo = self.allBarcodeFormatDataArray[indexPath.row]
        let barcodeFormatStr = singleBarcodeInfo["title"] as! String
        let barcodeValue = singleBarcodeInfo["EnumValue"] as! UInt
        
        let specifyFormatIsSelected = self.recordBarcodeFormatOptionalStateDic[barcodeFormatStr]!
        
        guard  let barcodeSettings = GeneralSettings.shared.currentCVRRuntimeSettings.barcodeSettings else {
            return
        }
        if specifyFormatIsSelected == true {// Remove
            barcodeSettings.barcodeFormatIds = BarcodeFormat(rawValue: barcodeSettings.barcodeFormatIds.rawValue & (~barcodeValue))
        } else {// Add
            barcodeSettings.barcodeFormatIds = BarcodeFormat(rawValue: barcodeSettings.barcodeFormatIds.rawValue | barcodeValue)
        }
        GeneralSettings.shared.currentCVRRuntimeSettings.barcodeSettings = barcodeSettings
        let _ = GeneralSettings.shared.updateCaptureVisionSettings()
        self.handleData()
        self.barcodeFormatTableView.reloadData()
    }
    
}
