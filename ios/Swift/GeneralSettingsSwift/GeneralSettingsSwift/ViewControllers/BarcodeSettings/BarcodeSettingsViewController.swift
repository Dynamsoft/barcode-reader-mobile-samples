//
//  BarcodeSettingsViewController.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class BarcodeSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var dbrSettingsDataArray: [String] = []
    
    /// Record DBR switch state dic.
    private var recordDBRSwitchStateDic: [String : Bool] = [:]
    
    private var expectedCount = 0
    
    private var minimumResultConfidence = 0
    
    private var duplicateForgetTime = 0
    
    private var minimumDecodeInterval = 0
    
    private lazy var dbrSettingsTableView: UITableView = {
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
        self.title = "Barcode Settings"
        
        handleData()
        setupUI()
    }
    
    private func handleData() -> Void {
        dbrSettingsDataArray.removeAll()
        recordDBRSwitchStateDic.removeAll()
        
        if GeneralSettings.shared.barcodeSettings.duplicateFliterIsOpen == true {
            dbrSettingsDataArray = [GeneralSettings.shared.barcodeSettings.barcodeFormatStr,
                                    GeneralSettings.shared.barcodeSettings.expectedCountStr,
                                    GeneralSettings.shared.barcodeSettings.continuousScanStr,
                                    GeneralSettings.shared.barcodeSettings.minimumResultConfidenceStr,
                                    GeneralSettings.shared.barcodeSettings.resultVerificationStr,
                                    GeneralSettings.shared.barcodeSettings.duplicateFliterStr,
                                    GeneralSettings.shared.barcodeSettings.duplicateForgetTimeStr,
                                    GeneralSettings.shared.barcodeSettings.minimumDecodeIntervalStr,
                                    GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr
            ]
        } else {
            dbrSettingsDataArray = [GeneralSettings.shared.barcodeSettings.barcodeFormatStr,
                                    GeneralSettings.shared.barcodeSettings.expectedCountStr,
                                    GeneralSettings.shared.barcodeSettings.continuousScanStr,
                                    GeneralSettings.shared.barcodeSettings.minimumResultConfidenceStr,
                                    GeneralSettings.shared.barcodeSettings.resultVerificationStr,
                                    GeneralSettings.shared.barcodeSettings.duplicateFliterStr,
                                    GeneralSettings.shared.barcodeSettings.minimumDecodeIntervalStr,
                                    GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr
            ]
        }
        
        // Switch state dic.
        if GeneralSettings.shared.barcodeSettings.continuousScanIsOpen == true {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.continuousScanStr] = true
        } else {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.continuousScanStr] = false
        }
        
        if GeneralSettings.shared.barcodeSettings.resultVerificationIsOpen == true {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.resultVerificationStr] = true
        } else {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.resultVerificationStr] = false
        }
        
        if GeneralSettings.shared.barcodeSettings.duplicateFliterIsOpen == true {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.duplicateFliterStr] = true
        } else {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.duplicateFliterStr] = false
        }
        
        if GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesIsOpen == true {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr] = true
        } else {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr] = false
        }
        
        expectedCount = GeneralSettings.shared.barcodeSettings.expectedCount
        minimumResultConfidence = GeneralSettings.shared.barcodeSettings.minimumResultConfidence
        duplicateForgetTime = GeneralSettings.shared.barcodeSettings.duplicateForgetTime
        minimumDecodeInterval = GeneralSettings.shared.barcodeSettings.minimumDecodeInterval
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(dbrSettingsTableView)
    }

    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BasicTableViewCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dbrSettingsDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleTag = self.dbrSettingsDataArray[indexPath.row]
        
        if titleTag == GeneralSettings.shared.barcodeSettings.barcodeFormatStr {
            
            let identifier = "BasicTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTableViewCell
            if cell == nil {
                cell = BasicTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            cell?.accessoryType = .disclosureIndicator
            cell?.updateUI(with: titleTag)
            return cell!
        } else if titleTag == GeneralSettings.shared.barcodeSettings.expectedCountStr {
            
            let identifier = "BasicTextTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTextTableViewCell
            if cell == nil {
                cell = BasicTextTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
           
            cell?.questionCompletion = {
                [unowned self] in
                self.handleDBRExplain(with: indexPath, settingString: titleTag)
            }
            
            cell?.inputTFValueChangedCompletion = {
                [unowned self] value in
                self.handleInputValueChanged(with: titleTag, numValue: value)
            }
            
            cell?.setInputCountTFMaxValue(with: kExpectedCountMaxValue)
            cell?.defaultValue = expectedCount
            cell?.updateUI(with: titleTag, valueNum: expectedCount)
            return cell!
        } else if titleTag == GeneralSettings.shared.barcodeSettings.minimumResultConfidenceStr {
            
            let identifier = "BasicTextTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTextTableViewCell
            if cell == nil {
                cell = BasicTextTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            cell?.inputTFValueChangedCompletion = {
                [unowned self] value in
                self.handleInputValueChanged(with: titleTag, numValue: value)
            }
            
            cell?.setInputCountTFMaxValue(with: kMinimumResultConfidenceMaxValue)
            cell?.questionButtonIsHidden = true
            cell?.defaultValue = minimumResultConfidence
            cell?.updateUI(with: titleTag, valueNum: minimumResultConfidence)
            return cell!
        }  else if titleTag == GeneralSettings.shared.barcodeSettings.duplicateForgetTimeStr {
            
            let identifier = "BasicTextTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTextTableViewCell
            if cell == nil {
                cell = BasicTextTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            cell?.questionCompletion = {
                [unowned self] in
                self.handleDBRExplain(with: indexPath, settingString: titleTag)
            }
            
            cell?.inputTFValueChangedCompletion = {
                [unowned self] value in
                self.handleInputValueChanged(with: titleTag, numValue: value)
            }
            
            cell?.setInputCountTFMaxValue(with: kDuplicateForgetTimeMaxValue)
            cell?.titleOffset = 20.0
            cell?.defaultValue = duplicateForgetTime
            cell?.updateUI(with: titleTag, valueNum: duplicateForgetTime)
            return cell!
        } else if titleTag == GeneralSettings.shared.barcodeSettings.minimumDecodeIntervalStr {
            
            let identifier = "BasicTextTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTextTableViewCell
            if cell == nil {
                cell = BasicTextTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            cell?.questionCompletion = {
                [unowned self] in
                self.handleDBRExplain(with: indexPath, settingString: titleTag)
            }
            
            cell?.inputTFValueChangedCompletion = {
                [unowned self] value in
                self.handleInputValueChanged(with: titleTag, numValue: value)
            }
            
            cell?.setInputCountTFMaxValue(with: kMinimumDecodeIntervalMaxValue)
            cell?.defaultValue = minimumDecodeInterval
            cell?.updateUI(with: titleTag, valueNum: minimumDecodeInterval)
            return cell!
        } else if titleTag == GeneralSettings.shared.barcodeSettings.continuousScanStr ||
                  titleTag == GeneralSettings.shared.barcodeSettings.resultVerificationStr ||
                  titleTag == GeneralSettings.shared.barcodeSettings.duplicateFliterStr ||
                  titleTag == GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr {
            
            let identifier = "BasicSwitchTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicSwitchTableViewCell
            if cell == nil {
                cell = BasicSwitchTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            if titleTag == GeneralSettings.shared.barcodeSettings.resultVerificationStr ||
               titleTag == GeneralSettings.shared.barcodeSettings.duplicateFliterStr {
                cell?.questionButton.isHidden = false
            } else {
                cell?.questionButton.isHidden = true
            }
            
            cell?.questionCompletion = {
                [unowned self] in
                self.handleDBRExplain(with: indexPath, settingString: titleTag)
            }
            
            cell?.switchChangedCompletion = {
                [unowned self] isOn in
                self.handleDBRSettingSwitch(with: indexPath, settingString: titleTag, isOn: isOn)
            }
            
            cell?.updateUI(with: titleTag, isOn:recordDBRSwitchStateDic[titleTag]!)
            return cell!
        }
        
       
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let titleTag = self.dbrSettingsDataArray[indexPath.row]
        
        if titleTag == GeneralSettings.shared.barcodeSettings.barcodeFormatStr {
            let barcodeFormatDetailVC = BarcodeFormatDetailViewController()
            self.navigationController?.pushViewController(barcodeFormatDetailVC, animated: true)
        }
    }
    
    private func handleDBRSettingSwitch(with indexPath: IndexPath,
                                        settingString: String,
                                        isOn: Bool) -> Void {
        if settingString == GeneralSettings.shared.barcodeSettings.continuousScanStr {
            
            GeneralSettings.shared.barcodeSettings.continuousScanIsOpen = isOn
        } else if settingString == GeneralSettings.shared.barcodeSettings.resultVerificationStr {
            
            GeneralSettings.shared.barcodeSettings.resultVerificationIsOpen = isOn
            GeneralSettings.shared.barcodeReader.enableResultVerification = isOn
        } else if settingString == GeneralSettings.shared.barcodeSettings.duplicateFliterStr {
            
            GeneralSettings.shared.barcodeSettings.duplicateFliterIsOpen = isOn
            GeneralSettings.shared.barcodeReader.enableDuplicateFilter = isOn
        } else if settingString == GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr {
            
            GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesIsOpen = isOn
            var grayscaleTransformationModes: [Int] = []
            if (isOn == true) {
                grayscaleTransformationModes = [EnumGrayscaleTransformationMode.original.rawValue,
                                                EnumGrayscaleTransformationMode.inverted.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue
                ]
            } else {
                grayscaleTransformationModes = [EnumGrayscaleTransformationMode.original.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue,
                                                EnumGrayscaleTransformationMode.skip.rawValue
                ]
            }
            GeneralSettings.shared.ipublicRuntimeSettings.furtherModes.grayscaleTransformationModes = grayscaleTransformationModes
            let _ = GeneralSettings.shared.updateIpublicRuntimeSettings()
        }
        
        self.handleData()
        self.dbrSettingsTableView.reloadData()
    }
    
    func handleInputValueChanged(with settingString: String,
                                 numValue: Int) -> Void {
        if settingString == GeneralSettings.shared.barcodeSettings.expectedCountStr {
            
            GeneralSettings.shared.barcodeSettings.expectedCount = numValue
            GeneralSettings.shared.ipublicRuntimeSettings.expectedBarcodesCount = numValue
            let _ = GeneralSettings.shared.updateIpublicRuntimeSettings()
        } else if settingString == GeneralSettings.shared.barcodeSettings.minimumResultConfidenceStr {
            
            GeneralSettings.shared.barcodeSettings.minimumResultConfidence = numValue
            GeneralSettings.shared.ipublicRuntimeSettings.minResultConfidence = numValue
            let _ = GeneralSettings.shared.updateIpublicRuntimeSettings()
        } else if settingString == GeneralSettings.shared.barcodeSettings.duplicateForgetTimeStr {
            
            GeneralSettings.shared.barcodeSettings.duplicateForgetTime = numValue
            GeneralSettings.shared.barcodeReader.duplicateForgetTime = numValue
        } else if settingString == GeneralSettings.shared.barcodeSettings.minimumDecodeIntervalStr {
            
            GeneralSettings.shared.barcodeSettings.minimumDecodeInterval = numValue
            GeneralSettings.shared.barcodeReader.minImageReadingInterval = numValue
        }
        
        self.handleData()
        self.dbrSettingsTableView.reloadData()
    }
    
    /// Parameter explain.
    private func handleDBRExplain(with indexPath: IndexPath,
                                  settingString: String) -> Void {
        if settingString == GeneralSettings.shared.barcodeSettings.expectedCountStr {
            ToolsManager.shared.addAlertView(to: self, title: settingString, content: expectedCountExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.barcodeSettings.duplicateForgetTimeStr {
            ToolsManager.shared.addAlertView(to: self, title: settingString, content: duplicateForgetTimeExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.barcodeSettings.minimumDecodeIntervalStr {
            ToolsManager.shared.addAlertView(to: self, title: settingString, content: minimumDecodeIntervalExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.barcodeSettings.resultVerificationStr {
            ToolsManager.shared.addAlertView(to: self, title: settingString, content: resultVerificationExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.barcodeSettings.duplicateFliterStr {
            ToolsManager.shared.addAlertView(to: self, title: settingString, content: duplicateFilterExplain, completion: nil)
        }
    }
}
