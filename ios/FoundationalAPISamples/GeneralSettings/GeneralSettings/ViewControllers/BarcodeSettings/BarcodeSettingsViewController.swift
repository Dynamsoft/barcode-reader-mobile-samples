/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class BarcodeSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var dbrSettingsListArray: [String] = []
    
    /// Record DBR switch state.
    private var recordDBRSwitchStateDic: [String : Bool] = [:]
    
    private var expectedCount = 0
    
    private var minimumResultConfidence = 0
    
    private var duplicateForgetTime = 0
    
    private var barcodeRegExPattern = ""
    
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
        dbrSettingsListArray.removeAll()
        recordDBRSwitchStateDic.removeAll()
        
        if GeneralSettings.shared.barcodeSettings.resultDeduplicationIsOpen == true {
            dbrSettingsListArray = [GeneralSettings.shared.barcodeSettings.barcodeFormatStr,
                                    GeneralSettings.shared.barcodeSettings.expectedCountStr,
                                    GeneralSettings.shared.barcodeSettings.continuousScanStr,
                                    GeneralSettings.shared.barcodeSettings.minimumResultConfidenceStr,
                                    GeneralSettings.shared.barcodeSettings.resultCrossVerificationStr,
                                    GeneralSettings.shared.barcodeSettings.resultDeduplicationStr,
                                    GeneralSettings.shared.barcodeSettings.duplicateForgetTimeStr,
                                    GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr,
                                    GeneralSettings.shared.barcodeSettings.barcodeTextRegExPatternStr
            ]
        } else {
            dbrSettingsListArray = [GeneralSettings.shared.barcodeSettings.barcodeFormatStr,
                                    GeneralSettings.shared.barcodeSettings.expectedCountStr,
                                    GeneralSettings.shared.barcodeSettings.continuousScanStr,
                                    GeneralSettings.shared.barcodeSettings.minimumResultConfidenceStr,
                                    GeneralSettings.shared.barcodeSettings.resultCrossVerificationStr,
                                    GeneralSettings.shared.barcodeSettings.resultDeduplicationStr,
                                    GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr,
                                    GeneralSettings.shared.barcodeSettings.barcodeTextRegExPatternStr
            ]
        }
        
        // Switch state dic.
        if GeneralSettings.shared.barcodeSettings.continuousScanIsOpen == true {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.continuousScanStr] = true
        } else {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.continuousScanStr] = false
        }
        
        if GeneralSettings.shared.barcodeSettings.resultCrossVerificationIsOpen == true {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.resultCrossVerificationStr] = true
        } else {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.resultCrossVerificationStr] = false
        }
        
        if GeneralSettings.shared.barcodeSettings.resultDeduplicationIsOpen == true {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.resultDeduplicationStr] = true
        } else {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.resultDeduplicationStr] = false
        }
        
        if GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesIsOpen == true {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr] = true
        } else {
            recordDBRSwitchStateDic[GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr] = false
        }
        
       
        expectedCount =  Int(GeneralSettings.shared.barcodeSettings.expectedCount)
        minimumResultConfidence =  Int(GeneralSettings.shared.barcodeSettings.minimumResultConfidence)
        duplicateForgetTime = GeneralSettings.shared.barcodeSettings.duplicateForgetTime
        barcodeRegExPattern = GeneralSettings.shared.barcodeSettings.barcodeTextRegExPatternContent
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
        return self.dbrSettingsListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleTag = self.dbrSettingsListArray[indexPath.row]
        
        if titleTag == GeneralSettings.shared.barcodeSettings.barcodeFormatStr {
            
            let identifier = BasicTableViewCell.className
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTableViewCell
            if cell == nil {
                cell = BasicTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            cell?.accessoryType = .disclosureIndicator
            cell?.updateUI(with: titleTag)
            return cell!
        } else if titleTag == GeneralSettings.shared.barcodeSettings.expectedCountStr ||
                  titleTag == GeneralSettings.shared.barcodeSettings.minimumResultConfidenceStr ||
                  titleTag == GeneralSettings.shared.barcodeSettings.duplicateForgetTimeStr {
            let identifier = BasicNumberInputTableViewCell.className
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicNumberInputTableViewCell
            if cell == nil {
                cell = BasicNumberInputTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
           
            cell?.questionCompletion = {
                [unowned self] in
                self.handleDBRExplain(with: indexPath, titleTag: titleTag)
            }
            
            cell?.inputTFNumberChangedCompletion = {
                [unowned self] value in
                self.handleInputNumValueChanged(with: titleTag, numValue: value)
            }
            
            switch titleTag {
            case GeneralSettings.shared.barcodeSettings.expectedCountStr:
                cell?.setInputMaxValue(with: kExpectedCountMaxValue)
                cell?.defaultValue = expectedCount
                cell?.updateUI(with: titleTag, valueNum: expectedCount)
                cell?.questionButtonIsHidden = false
                break
            case GeneralSettings.shared.barcodeSettings.minimumResultConfidenceStr:
                cell?.setInputMaxValue(with: kMinimumResultConfidenceMaxValue)
                cell?.defaultValue = minimumResultConfidence
                cell?.updateUI(with: titleTag, valueNum: minimumResultConfidence)
                cell?.questionButtonIsHidden = true
                break
            case GeneralSettings.shared.barcodeSettings.duplicateForgetTimeStr:
                cell?.setInputMaxValue(with: kDuplicateForgetTimeMaxValue)
                cell?.titleOffset = 20.0
                cell?.defaultValue = duplicateForgetTime
                cell?.updateUI(with: titleTag, valueNum: duplicateForgetTime)
                cell?.questionButtonIsHidden = false
                break
            default:
                break
            }
         
            return cell!
        } else if titleTag == GeneralSettings.shared.barcodeSettings.barcodeTextRegExPatternStr {
            let identifier = BasicTextInputTableViewCell.className
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTextInputTableViewCell
            if cell == nil {
                cell = BasicTextInputTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
           
            cell?.questionCompletion = {
                [unowned self] in
                self.handleDBRExplain(with: indexPath, titleTag: titleTag)
            }
            
            cell?.inputTFTextChangedCompletion = {
                [unowned self] value in
                self.handleInputTextValueChanged(with:titleTag, textValue: value)
            }
            
            cell?.setInputMaxLength(with: kRegExPatternMaxLength)
            cell?.defaultString = barcodeRegExPattern
            cell?.updateUI(with: titleTag, valueString: barcodeRegExPattern)
            cell?.questionButtonIsHidden = false
            
            return cell!
        } else if titleTag == GeneralSettings.shared.barcodeSettings.continuousScanStr ||
                  titleTag == GeneralSettings.shared.barcodeSettings.resultCrossVerificationStr ||
                  titleTag == GeneralSettings.shared.barcodeSettings.resultDeduplicationStr ||
                  titleTag == GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr {
              
            let identifier = BasicSwitchTableViewCell.className
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicSwitchTableViewCell
            if cell == nil {
                cell = BasicSwitchTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            if titleTag == GeneralSettings.shared.barcodeSettings.resultCrossVerificationStr ||
               titleTag == GeneralSettings.shared.barcodeSettings.resultDeduplicationStr {
                cell?.questionButton.isHidden = false
            } else {
                cell?.questionButton.isHidden = true
            }
            
            cell?.questionCompletion = {
                [unowned self] in
                self.handleDBRExplain(with: indexPath, titleTag: titleTag)
            }
            
            cell?.switchChangedCompletion = {
                [unowned self] isOn in
                self.handleDBRSettingSwitch(with: indexPath, titleTag: titleTag, isOn: isOn)
            }
            
            cell?.updateUI(with: titleTag, isOn:recordDBRSwitchStateDic[titleTag]!)
            return cell!
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let titleTag = self.dbrSettingsListArray[indexPath.row]
        
        if titleTag == GeneralSettings.shared.barcodeSettings.barcodeFormatStr {
            let barcodeFormatListVC = BarcodeFormatListViewController()
            self.navigationController?.pushViewController(barcodeFormatListVC, animated: true)
        }
    }
    
    private func handleDBRSettingSwitch(with indexPath: IndexPath,
                                        titleTag: String,
                                        isOn: Bool) -> Void {
        
        if titleTag == GeneralSettings.shared.barcodeSettings.continuousScanStr {
            
            GeneralSettings.shared.barcodeSettings.continuousScanIsOpen = isOn
        } else if titleTag == GeneralSettings.shared.barcodeSettings.resultCrossVerificationStr {
            
            GeneralSettings.shared.barcodeSettings.resultCrossVerificationIsOpen = isOn
            GeneralSettings.shared.currentResultCrossFilter.enableResultCrossVerification(.barcode, isEnabled: isOn)
        } else if titleTag == GeneralSettings.shared.barcodeSettings.resultDeduplicationStr {
            
            GeneralSettings.shared.barcodeSettings.resultDeduplicationIsOpen = isOn
            GeneralSettings.shared.currentResultCrossFilter.enableResultDeduplication(.barcode, isEnabled: isOn)
        } else if titleTag == GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesStr {
            
            GeneralSettings.shared.barcodeSettings.decodeInvertedBarcodesIsOpen = isOn
            var grayscaleTransformationModes: [Int] = []
            if isOn == true {
                grayscaleTransformationModes = [GrayscaleTransformationMode.original.rawValue,
                                                GrayscaleTransformationMode.inverted.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue
                ]
            } else {
                grayscaleTransformationModes = [GrayscaleTransformationMode.original.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue,
                                                GrayscaleTransformationMode.skip.rawValue
                ]
            }
            
            GeneralSettings.shared.currentCVRRuntimeSettings.barcodeSettings?.grayscaleTransformationModes = grayscaleTransformationModes
            let _ = GeneralSettings.shared.updateCaptureVisionSettings()
        }
        
        self.handleData()
        self.dbrSettingsTableView.reloadData()
    }
    
    func handleInputNumValueChanged(with titleTag: String,
                                    numValue: Int) -> Void {
        if titleTag == GeneralSettings.shared.barcodeSettings.expectedCountStr {
            GeneralSettings.shared.barcodeSettings.expectedCount = UInt(numValue)
            GeneralSettings.shared.currentCVRRuntimeSettings.barcodeSettings?.expectedBarcodesCount = UInt(numValue)
            let _ = GeneralSettings.shared.updateCaptureVisionSettings()
        } else if titleTag == GeneralSettings.shared.barcodeSettings.minimumResultConfidenceStr {
            GeneralSettings.shared.barcodeSettings.minimumResultConfidence = UInt(numValue)
            GeneralSettings.shared.currentCVRRuntimeSettings.barcodeSettings?.minResultConfidence = UInt(numValue)
            let _ = GeneralSettings.shared.updateCaptureVisionSettings()
        } else if titleTag == GeneralSettings.shared.barcodeSettings.duplicateForgetTimeStr {
            GeneralSettings.shared.barcodeSettings.duplicateForgetTime = numValue
            GeneralSettings.shared.currentResultCrossFilter.setDuplicateForgetTime(.barcode, duplicateForgetTime:numValue)
        }
        
        self.handleData()
        self.dbrSettingsTableView.reloadData()
    }
    
    func handleInputTextValueChanged(with titleTag: String,
                                     textValue: String) -> Void {
        if titleTag == GeneralSettings.shared.barcodeSettings.barcodeTextRegExPatternStr {
            GeneralSettings.shared.barcodeSettings.barcodeTextRegExPatternContent = textValue
            GeneralSettings.shared.currentCVRRuntimeSettings.barcodeSettings?.barcodeTextRegExPattern = textValue
            let _ = GeneralSettings.shared.updateCaptureVisionSettings()
        }
        self.handleData()
        self.dbrSettingsTableView.reloadData()
    }
    
    /// Parameter explain.
    private func handleDBRExplain(with indexPath: IndexPath,
                                  titleTag: String) -> Void {
        if titleTag == GeneralSettings.shared.barcodeSettings.expectedCountStr {
            ToolsManager.shared.addAlertView(to: self, title: titleTag, content: expectedCountExplain, completion: nil)
        } else if titleTag == GeneralSettings.shared.barcodeSettings.duplicateForgetTimeStr {
            ToolsManager.shared.addAlertView(to: self, title: titleTag, content: duplicateForgetTimeExplain, completion: nil)
        } else if titleTag == GeneralSettings.shared.barcodeSettings.resultCrossVerificationStr {
            ToolsManager.shared.addAlertView(to: self, title: titleTag, content: resultVerificationExplain, completion: nil)
        } else if titleTag == GeneralSettings.shared.barcodeSettings.resultDeduplicationStr {
            ToolsManager.shared.addAlertView(to: self, title: titleTag, content: duplicateFilterExplain, completion: nil)
        } else if titleTag == GeneralSettings.shared.barcodeSettings.barcodeTextRegExPatternStr {
            ToolsManager.shared.addAlertView(to: self, title: titleTag, content: barcodeTextRegExPatternExplain, completion: nil)
        }
    }

}
