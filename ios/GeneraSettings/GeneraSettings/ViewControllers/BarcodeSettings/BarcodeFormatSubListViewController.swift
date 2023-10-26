/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

enum SubBarcodeOptionalEntireState {
    case all
    case cancelAll
    case incompletion
}

class BarcodeFormatSubListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var subBarcodeFormatType: SubBarcodeFormatType = .oneD

    private var subBarcodeFormatDataArray: [[String : Any]] = []
    
    private var recordSubBarcodeFormatOptionalStateDic: [String : Bool] = [:]
    
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
          case .oneD:
            label.text = "OneD"
          case .gs1DataBar:
            label.text = "GS1DataBar"
          case .postalCode:
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
        recordSubBarcodeFormatOptionalStateDic.removeAll()
        
        switch subBarcodeFormatType {
        case .oneD:
            self.title = "OneDType"
            subBarcodeFormatDataArray = [["title":GeneralSettings.shared.barcodeFormatONED.code39!, "EnumValue":BarcodeFormat.code39.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.code128!, "EnumValue":BarcodeFormat.code128.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.code39Extended!, "EnumValue":BarcodeFormat.code39Extended.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.code93!, "EnumValue":BarcodeFormat.code93.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.code11!, "EnumValue":BarcodeFormat.code11.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.codabar!, "EnumValue":BarcodeFormat.codabar.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.itf!, "EnumValue":BarcodeFormat.itf.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.ean13!, "EnumValue":BarcodeFormat.ean13.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.ean8!, "EnumValue":BarcodeFormat.ean8.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.upca!, "EnumValue":BarcodeFormat.upca.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.upce!, "EnumValue":BarcodeFormat.upce.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.industrial25!, "EnumValue":BarcodeFormat.industrial25.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatONED.msiCode!, "EnumValue":BarcodeFormat.msiCode.rawValue]

            ]
            break
        case .gs1DataBar:
            self.title = "GS1DataBarType"
            subBarcodeFormatDataArray = [["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.gs1DatabarOmnidirectional!, "EnumValue":BarcodeFormat.gs1DatabarOmnidirectional.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.gs1DatabarTrunncated!, "EnumValue":BarcodeFormat.gs1DatabarTruncated.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.gs1DatabarStacked!, "EnumValue":BarcodeFormat.gs1DatabarStacked.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.gs1DatabarStackedOmnidirectional!, "EnumValue":BarcodeFormat.gs1DatabarStackedOmnidirectional.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.gs1DatabarExpanded!, "EnumValue":BarcodeFormat.gs1DatabarExpanded.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.gs1DatabarExpanedStacked!, "EnumValue":BarcodeFormat.gs1DatabarExpandedStacked.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormatGS1DATABAR.gs1DatabarLimited!, "EnumValue":BarcodeFormat.gs1DatabarLimited.rawValue]
            ]
            break
        case .postalCode:
            self.title = "PostalCodeType"
            subBarcodeFormatDataArray = [["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.uspsIntelligentMail!, "EnumValue":BarcodeFormat.uspsIntelligentMail.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.postnet!, "EnumValue":BarcodeFormat.postnet.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.planet!, "EnumValue":BarcodeFormat.planet.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.australianPost!, "EnumValue":BarcodeFormat.australianPost.rawValue],
                                         ["title":GeneralSettings.shared.barcodeFormat2POSTALCODE.rm4SCC!, "EnumValue":BarcodeFormat.rm4scc.rawValue],
            ]
            break
        }
        
        let cvrRuntimeSetting = GeneralSettings.shared.currentCVRRuntimeSettings!
        if let barcodeSettings = cvrRuntimeSetting.barcodeSettings {
            for singleBarcodeInfo in subBarcodeFormatDataArray {
                let barcodeFormatStr = singleBarcodeInfo["title"] as! String
                let barcodeValue = singleBarcodeInfo["EnumValue"] as! UInt
                if ((barcodeSettings.barcodeFormatIds.rawValue & barcodeValue) != 0) {
                    self.recordSubBarcodeFormatOptionalStateDic[barcodeFormatStr] = true
                } else {
                    self.recordSubBarcodeFormatOptionalStateDic[barcodeFormatStr] = false
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
        
        let identifier = BasicOptionalTableViewCell.className
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicOptionalTableViewCell
        if cell == nil {
            cell = BasicOptionalTableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        
        cell?.updateUI(with: titleTag, optionState: self.recordSubBarcodeFormatOptionalStateDic[titleTag]!)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleBarcodeInfo = self.subBarcodeFormatDataArray[indexPath.row]
        let barcodeFormatStr = singleBarcodeInfo["title"] as! String
        let barcodeValue = singleBarcodeInfo["EnumValue"] as! UInt
        
        let specifyFormatIsSelected = self.recordSubBarcodeFormatOptionalStateDic[barcodeFormatStr]!
        
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
       
        guard  let barcodeSettings = GeneralSettings.shared.currentCVRRuntimeSettings.barcodeSettings else {
            return
        }
        
        for singleBarcodeInfo in self.subBarcodeFormatDataArray {
            let barcodeValue = singleBarcodeInfo["EnumValue"] as! UInt
            
            if (isShouldChoiceAll == true) {
                barcodeSettings.barcodeFormatIds = BarcodeFormat(rawValue: barcodeSettings.barcodeFormatIds.rawValue | barcodeValue)
            } else {
                barcodeSettings.barcodeFormatIds = BarcodeFormat(rawValue: barcodeSettings.barcodeFormatIds.rawValue & (~barcodeValue))
            }
        }
        GeneralSettings.shared.currentCVRRuntimeSettings.barcodeSettings = barcodeSettings
        let _ = GeneralSettings.shared.updateCaptureVisionSettings()
        self.handleData()
        self.barcodeFormatTableView.reloadData()
        self.updateChoiceButton()
    }
    
    private func judgeOptionalEntireState() -> SubBarcodeOptionalEntireState {
        var optionalState = SubBarcodeOptionalEntireState.all
        let allOptionalBarcodeValueArray = self.recordSubBarcodeFormatOptionalStateDic.values
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
