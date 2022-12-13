//
//  BarcodeFormatSubDetailViewController.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

enum SubBarcodeOptionalEntireState {
    case all
    case cancelAll
    case incompletion
}

class BarcodeFormatSubDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var subBarcodeFormatType: SubBarcodeFormatType = .OneD

    private var subBarcodeFormatDataArray: [[String : Any]] = []
    
    private var saveBarcodeFormatOptionalStateDic: [String : Bool] = [:]
    
    private lazy var barcodeFormatTableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var topHeaderView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 30))
        view.backgroundColor = kTableViewHeaderBackgroundColor
        return view
    }()
    
    lazy var subBarcodeTypeLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: kCellLeftMargin, y: 0, width: 100, height: self.topHeaderView.height))
        label.textColor = kTableViewHeaderTitleColor
        label.font = kFont_Regular(14)
        switch subBarcodeFormatType {
          case .OneD:
            label.text = "OneD"
          case .GS1DataBar:
            label.text = "GS1DataBar"
          case .PostalCode:
            label.text = "PostalCode"
        }
        return label
    }()
    
    lazy var selectAllBarcodeTypeButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: kScreenWidth - kCellRightMargin - 100, y: 0, width: 100, height: self.topHeaderView.height)
        button.setTitleColor(kTableViewHeaderButtonColor, for: .normal)
        button.contentHorizontalAlignment = .right
        button.titleLabel?.font = kFont_Regular(14)
        button.addTarget(self, action: #selector(barcodeTypeChangedAction(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        handleData()
        setupUI()
    }
    
    private func handleData() -> Void {
        subBarcodeFormatDataArray.removeAll()
        saveBarcodeFormatOptionalStateDic.removeAll()
        
        switch subBarcodeFormatType {
        case .OneD:
            self.title = "OneDType"
            subBarcodeFormatDataArray = [["title":GeneralSettings.shared.barcodeFormatONED.format_Code39!, "EnumValue":EnumBarcodeFormat.CODE39.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_Code128!, "EnumValue":EnumBarcodeFormat.CODE128.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_Code39Extended!, "EnumValue":EnumBarcodeFormat.CODE39EXTENDED.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_Code93!, "EnumValue":EnumBarcodeFormat.CODE93.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_Code_11!, "EnumValue":EnumBarcodeFormat.CODE_11.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_Codabar!, "EnumValue":EnumBarcodeFormat.CODABAR.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_ITF!, "EnumValue":EnumBarcodeFormat.ITF.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_EAN13!, "EnumValue":EnumBarcodeFormat.EAN13.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_EAN8!, "EnumValue":EnumBarcodeFormat.EAN8.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_UPCA!, "EnumValue":EnumBarcodeFormat.UPCA.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_UPCE!, "EnumValue":EnumBarcodeFormat.UPCE.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_Industrial25!, "EnumValue":EnumBarcodeFormat.INDUSTRIAL.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.format_MSICode!, "EnumValue":EnumBarcodeFormat.MSICODE.rawValue],
            ]
            
            let ipublicRuntimeSettings = GeneralSettings.shared.ipublicRuntimeSettings!
            for singleBarcodeInfo in self.subBarcodeFormatDataArray {
                let barcodeFormatStr = singleBarcodeInfo["title"] as! String
                let barcodeValue = singleBarcodeInfo["EnumValue"] as! Int
                
                if ((ipublicRuntimeSettings.barcodeFormatIds & barcodeValue) != 0) {
                    self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr] = true
                } else {
                    self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr] = false
                }
            }
        case .GS1DataBar:
            self.title = "GS1DataBarType"
            subBarcodeFormatDataArray = [["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.format_GS1DatabarOmnidirectional!, "EnumValue":EnumBarcodeFormat.GS1DATABAROMNIDIRECTIONAL.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.format_GS1DatabarTrunncated!, "EnumValue":EnumBarcodeFormat.GS1DATABARTRUNCATED.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.format_GS1DatabarStacked!, "EnumValue":EnumBarcodeFormat.GS1DATABARSTACKED.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.format_GS1DatabarStackedOmnidirectional!, "EnumValue":EnumBarcodeFormat.GS1DATABARSTACKEDOMNIDIRECTIONAL.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.format_GS1DatabarExpanded!, "EnumValue":EnumBarcodeFormat.GS1DATABAREXPANDED.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.format_GS1DatabarExpanedStacked!, "EnumValue":EnumBarcodeFormat.GS1DATABAREXPANDEDSTACKED.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.format_GS1DatabarLimited!, "EnumValue":EnumBarcodeFormat.GS1DATABARLIMITED.rawValue]
            ]
            
            let ipublicRuntimeSettings = GeneralSettings.shared.ipublicRuntimeSettings!
            for singleBarcodeInfo in self.subBarcodeFormatDataArray {
                let barcodeFormatStr = singleBarcodeInfo["title"] as! String
                let barcodeValue = singleBarcodeInfo["EnumValue"] as! Int
                
                if ((ipublicRuntimeSettings.barcodeFormatIds & barcodeValue) != 0) {
                    self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr] = true
                } else {
                    self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr] = false
                }
            }
        case .PostalCode:
            self.title = "PostalCodeType"
            subBarcodeFormatDataArray = [["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.format2_USPSIntelligentMail!, "EnumValue":EnumBarcodeFormat2.USPSINTELLIGENTMAIL.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.format2_Postnet!, "EnumValue":EnumBarcodeFormat2.POSTNET.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.format2_Planet!, "EnumValue":EnumBarcodeFormat2.PLANET.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.format2_AustralianPost!, "EnumValue":EnumBarcodeFormat2.AUSTRALIANPOST.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.format2_RM4SCC!, "EnumValue":EnumBarcodeFormat2.RM4SCC.rawValue],
            ]
            
            let ipublicRuntimeSettings = GeneralSettings.shared.ipublicRuntimeSettings!
            for singleBarcodeInfo in self.subBarcodeFormatDataArray {
                let barcodeFormatStr = singleBarcodeInfo["title"] as! String
                let barcodeValue = singleBarcodeInfo["EnumValue"] as! Int
                
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
        
        self.barcodeFormatTableView.tableHeaderView = topHeaderView
        self.topHeaderView.addSubview(subBarcodeTypeLabel)
        self.topHeaderView.addSubview(selectAllBarcodeTypeButton)
        self.updateChoiceButton()
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BasicTableViewCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subBarcodeFormatDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let singleBarcodeInfo = self.subBarcodeFormatDataArray[indexPath.row]
        let titleTag = singleBarcodeInfo["title"] as! String
        
        let identifier = "BasicOptionalTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicOptionalTableViewCell
        if cell == nil {
            cell = BasicOptionalTableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        
        cell?.updateUI(with: titleTag, optionState: self.saveBarcodeFormatOptionalStateDic[titleTag]!)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleBarcodeInfo = self.subBarcodeFormatDataArray[indexPath.row]
        let barcodeFormatStr = singleBarcodeInfo["title"] as! String
        let barcodeValue = singleBarcodeInfo["EnumValue"] as! Int
        
        let specifyFormatIsSelected = self.saveBarcodeFormatOptionalStateDic[barcodeFormatStr]!
        
        switch self.subBarcodeFormatType {
          case .OneD:
            if specifyFormatIsSelected == true {// Remove
                
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds & (~barcodeValue)
            } else {// Add
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds | barcodeValue
            }
          case .GS1DataBar:
            if specifyFormatIsSelected == true {// Remove
                
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds & (~barcodeValue)
            } else {// Add
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds | barcodeValue
            }
          case .PostalCode:
            if specifyFormatIsSelected == true {// Remove
                
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 & (~barcodeValue)
            } else {// Add
                GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 | barcodeValue
            }
        }
        
        let _ = GeneralSettings.shared.updateIpublicRuntimeSettings()
        self.handleData()
        self.barcodeFormatTableView.reloadData()
        self.updateChoiceButton()
    }
    
    // MARK: - Utility methods
    
    @objc private func barcodeTypeChangedAction(_ button: UIButton) -> Void {
        let optionalState = self.judgeOptionalEntireState()
        var isShouldChoiceAll = true
        switch optionalState {
          case .all:// Should cancel all.
            isShouldChoiceAll = false
          case .cancelAll:// Should choose all.
            isShouldChoiceAll = true
          case .incompletion:// Should choose all.
            isShouldChoiceAll = true
        }
       
        if self.subBarcodeFormatType == .OneD || self.subBarcodeFormatType == .GS1DataBar {
            
            for singleBarcodeInfo in self.subBarcodeFormatDataArray {
                let barcodeValue = singleBarcodeInfo["EnumValue"] as! Int
                
                if (isShouldChoiceAll == true) {
                    GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds | barcodeValue
                } else {
                    GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds & (~barcodeValue)
                }
            }
        } else if self.subBarcodeFormatType == .PostalCode {
            
            for singleBarcodeInfo in self.subBarcodeFormatDataArray {
                let barcodeValue = singleBarcodeInfo["EnumValue"] as! Int
                
                if (isShouldChoiceAll == true) {
                    GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 | barcodeValue
                } else {
                    GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 = GeneralSettings.shared.ipublicRuntimeSettings.barcodeFormatIds_2 & (~barcodeValue)
                }
            }
        }
        
        let _ = GeneralSettings.shared.updateIpublicRuntimeSettings()
        self.handleData()
        self.barcodeFormatTableView.reloadData()
        self.updateChoiceButton()
    }
    
    private func judgeOptionalEntireState() -> SubBarcodeOptionalEntireState {
        var optionalState = SubBarcodeOptionalEntireState.all
        let allOptionalBarcodeValueArray = self.saveBarcodeFormatOptionalStateDic.values
        if allOptionalBarcodeValueArray.contains(true) &&  allOptionalBarcodeValueArray.contains(false){
            optionalState = .incompletion
        } else if !allOptionalBarcodeValueArray.contains(true) == true {
            optionalState = .cancelAll
        } else if !allOptionalBarcodeValueArray.contains(false) == true {
            optionalState = .all
        }
        return optionalState
    }
    
    func updateChoiceButton() -> Void{
        switch self.judgeOptionalEntireState() {
          case .all:
            self.selectAllBarcodeTypeButton.setTitle(barcodeFormatDisableAllString, for: .normal)
          case .cancelAll:
            self.selectAllBarcodeTypeButton.setTitle(barcodeFormatEnableAllString, for: .normal)
          case .incompletion:
            self.selectAllBarcodeTypeButton.setTitle(barcodeFormatEnableAllString, for: .normal)
        }
    }
}
