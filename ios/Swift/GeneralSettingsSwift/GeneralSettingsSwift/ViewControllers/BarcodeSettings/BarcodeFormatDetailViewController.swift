//
//  BarcodeFormatDetailViewController.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class BarcodeFormatDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var allBarcodeFormatDataArray: [[String : Any]] = []
    
    private var saveBarcodeFormatOptionalStateDic: [String : Bool] = [:]
    
    private lazy var barcodeFormatTableView = {
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
        saveBarcodeFormatOptionalStateDic.removeAll()
        
        self.allBarcodeFormatDataArray = [["title":GeneralSettings.shared.allBarcodeFormat.format_OneD!, "EnumValue":EnumBarcodeFormat.ONED.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_GS1DataBar!, "EnumValue":EnumBarcodeFormat.GS1DATABAR.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_PostalCode!, "EnumValue":EnumBarcodeFormat2.POSTALCODE.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_PatchCode!, "EnumValue":EnumBarcodeFormat.PATCHCODE.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_PDF417!, "EnumValue":EnumBarcodeFormat.PDF417.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_QRCode!, "EnumValue":EnumBarcodeFormat.QRCODE.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_DataMatrix!, "EnumValue":EnumBarcodeFormat.DATAMATRIX.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_AZTEC!, "EnumValue":EnumBarcodeFormat.AZTEC.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_MaxiCode!, "EnumValue":EnumBarcodeFormat.MAXICODE.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_MicroQR!, "EnumValue":EnumBarcodeFormat.MICROQR.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_MicroPDF417!, "EnumValue":EnumBarcodeFormat.MICROPDF417.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_GS1Composite!, "EnumValue":EnumBarcodeFormat.GS1COMPOSITE.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_DotCode!, "EnumValue":EnumBarcodeFormat2.DOTCODE.rawValue],
                                          ["title":GeneralSettings.shared.allBarcodeFormat.format_PHARMACODE!, "EnumValue":EnumBarcodeFormat2.PHARMACODE.rawValue],
                                          
        ]
        
        let ipublicRuntimeSettings = GeneralSettings.shared.ipublicRuntimeSettings!
        for singleBarcodeInfo in self.allBarcodeFormatDataArray {
            let barcodeFormatStr = singleBarcodeInfo["title"] as! String
            let barcodeValue = singleBarcodeInfo["EnumValue"] as! Int

            if barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_PatchCode ||
               barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_PDF417 ||
               barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_QRCode ||
               barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_DataMatrix ||
               barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_AZTEC ||
               barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_MaxiCode ||
               barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_MicroQR ||
               barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_MicroPDF417 ||
               barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_GS1Composite {// BarcodeFormat
                
                if ((ipublicRuntimeSettings.barcodeFormatIds & barcodeValue) != 0) {
                    self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr] = true
                } else {
                    self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr] = false
                }
            } else {// BarcodeFormat_2
                if ((ipublicRuntimeSettings.barcodeFormatIds_2 & barcodeValue) != 0) {
                    self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr] = true
                } else {
                    self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr] = false
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
        
        if titleTag == GeneralSettings.shared.allBarcodeFormat.format_OneD ||
           titleTag == GeneralSettings.shared.allBarcodeFormat.format_GS1DataBar ||
           titleTag == GeneralSettings.shared.allBarcodeFormat.format_PostalCode {
            
            let identifier = "BasicTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTableViewCell
            if cell == nil {
                cell = BasicTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            cell?.accessoryType = .disclosureIndicator
            cell?.updateUI(with: titleTag)
            return cell!
        } else {
            let identifier = "BasicOptionalTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicOptionalTableViewCell
            if cell == nil {
                cell = BasicOptionalTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            cell?.updateUI(with: titleTag, optionState: self.saveBarcodeFormatOptionalStateDic[titleTag]!)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleBarcodeInfo = self.allBarcodeFormatDataArray[indexPath.row]
        let titleTag = singleBarcodeInfo["title"] as! String
        
        if !(titleTag == GeneralSettings.shared.allBarcodeFormat.format_OneD ||
             titleTag == GeneralSettings.shared.allBarcodeFormat.format_GS1DataBar ||
             titleTag == GeneralSettings.shared.allBarcodeFormat.format_PostalCode) {
            self.handleSelectedBarcodeFormat(with: indexPath)
            return
        }
        
        let subDetailVC = BarcodeFormatSubDetailViewController()
        if titleTag == GeneralSettings.shared.allBarcodeFormat.format_OneD {
            subDetailVC.subBarcodeFormatType = .OneD
        } else if titleTag == GeneralSettings.shared.allBarcodeFormat.format_GS1DataBar {
            subDetailVC.subBarcodeFormatType = .GS1DataBar
        } else if titleTag == GeneralSettings.shared.allBarcodeFormat.format_PostalCode {
            subDetailVC.subBarcodeFormatType = .PostalCode
        }
        self.navigationController?.pushViewController(subDetailVC, animated: true)
    }
    
    func handleSelectedBarcodeFormat(with indexPath: IndexPath) -> Void {
        let singleBarcodeInfo = self.allBarcodeFormatDataArray[indexPath.row]
        let barcodeFormatStr = singleBarcodeInfo["title"] as! String
        let barcodeValue = singleBarcodeInfo["EnumValue"] as! Int
        
        let specifyFormatIsSelected = self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr]!
        
        if barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_PatchCode ||
           barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_PDF417 ||
           barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_QRCode ||
           barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_DataMatrix ||
           barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_AZTEC ||
           barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_MaxiCode ||
           barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_MicroQR ||
           barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_MicroPDF417 ||
           barcodeFormatStr == GeneralSettings.shared.allBarcodeFormat.format_GS1Composite {// BarcodeFormat
            
            if specifyFormatIsSelected == true {// Remove
                
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds & (~barcodeValue)
            } else {// Add
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds | barcodeValue
            }
        } else {// BarcodeFormat_2
            
            if specifyFormatIsSelected == true {// Remove
                
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 & (~barcodeValue)
            } else {// Add
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 | barcodeValue
            }
        }
        
        let _ = GeneralSettings.shared.updateIpublicRuntimeSettings()
        self.handleData()
        self.barcodeFormatTableView.reloadData()
    }
    

  

}
