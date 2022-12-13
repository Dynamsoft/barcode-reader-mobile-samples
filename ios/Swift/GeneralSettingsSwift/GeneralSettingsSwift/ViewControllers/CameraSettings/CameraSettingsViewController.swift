//
//  CameraSettingsViewController.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class CameraSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    static var dceIsFirstOpenScanRegion = true
    
    private var cameraSettingsDataArray: [String] = []
    
    /// Record DCE switch state dic.
    private var recordDCESwitchStateDic: [String : Bool] = [:]
    
    /// Record scan Region dic.
    private var recordScanRegionValueDic: [String: Int] = [:]
    
    /// Save DCE resolution available value.
    private var resolutionOptionalArray: [[String : Any]] = [["showName":"480p", "valueTag":EnumResolution.EnumRESOLUTION_480P],
                                                     ["showName":"720p", "valueTag":EnumResolution.EnumRESOLUTION_720P],
                                                     ["showName":"1080p", "valueTag":EnumResolution.EnumRESOLUTION_1080P],
                                                     ["showName":"4k", "valueTag":EnumResolution.EnumRESOLUTION_4K]
    ]
    
    ///  Save DCE resolution selected dic.
    var saveResolutionSelectedDic: [String : Any] = [:]
    
    private lazy var cameraSettingsTableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    deinit {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "Camera Settings";
        
        handleData()
        setupUI()
    }
    
    private func handleData() -> Void {
        cameraSettingsDataArray.removeAll()
        recordDCESwitchStateDic.removeAll()
        recordScanRegionValueDic.removeAll()
        
        let currentResolution = GeneralSettings.shared.dceResolution.selectedResolutionValue
        for singleResolutionElement in resolutionOptionalArray {
            
            let resolution = singleResolutionElement["valueTag"] as! EnumResolution
            if currentResolution == resolution {
                saveResolutionSelectedDic = singleResolutionElement
                break
            }
        }
        
        // Showing data array.
        let basicDataArray: [String] = [GeneralSettings.shared.cameraSettings.dceResolution,
                                        GeneralSettings.shared.cameraSettings.dceVibrate,
                                        GeneralSettings.shared.cameraSettings.dceBeep,
                                        GeneralSettings.shared.cameraSettings.dceEnhancedFocus,
                                        GeneralSettings.shared.cameraSettings.dceFrameSharpnessFilter,
                                        GeneralSettings.shared.cameraSettings.dceSensorFilter,
                                        GeneralSettings.shared.cameraSettings.dceAutoZoom,
                                        GeneralSettings.shared.cameraSettings.dceFastMode,
                                        GeneralSettings.shared.cameraSettings.smartTorch,
                                        GeneralSettings.shared.cameraSettings.dceScanRegion
        ]
        
        cameraSettingsDataArray.append(contentsOf: basicDataArray)
     
        if GeneralSettings.shared.cameraSettings.dceScanRegionIsOpen == true {
            let scanRegionArray: [String] = [GeneralSettings.shared.scanRegion.scanRegionTop,
                                             GeneralSettings.shared.scanRegion.scanRegionBottom,
                                             GeneralSettings.shared.scanRegion.scanRegionLeft,
                                             GeneralSettings.shared.scanRegion.scanRegionRight
            ]
            cameraSettingsDataArray.append(contentsOf: scanRegionArray)
            
            recordScanRegionValueDic[GeneralSettings.shared.scanRegion.scanRegionTop] = GeneralSettings.shared.scanRegion.scanRegionTopValue
            recordScanRegionValueDic[GeneralSettings.shared.scanRegion.scanRegionBottom] = GeneralSettings.shared.scanRegion.scanRegionBottomValue
            recordScanRegionValueDic[GeneralSettings.shared.scanRegion.scanRegionLeft] = GeneralSettings.shared.scanRegion.scanRegionLeftValue
            recordScanRegionValueDic[GeneralSettings.shared.scanRegion.scanRegionRight] = GeneralSettings.shared.scanRegion.scanRegionRightValue
        }
        
        // Switch state dic.
        if GeneralSettings.shared.cameraSettings.dceVibrateIsOpen == true {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceVibrate] = true
        } else {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceVibrate] = false
        }
        
        if GeneralSettings.shared.cameraSettings.dceBeepIsOpen == true {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceBeep] = true
        } else {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceBeep] = false
        }
        
        if GeneralSettings.shared.cameraSettings.dceEnhancedFocusIsOpen == true {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceEnhancedFocus] = true
        } else {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceEnhancedFocus] = false
        }
        
        if GeneralSettings.shared.cameraSettings.dceFrameSharpnessFilterIsOpen == true {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceFrameSharpnessFilter] = true
        } else {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceFrameSharpnessFilter] = false
        }
        
        if GeneralSettings.shared.cameraSettings.dceSensorFilterIsOpen == true {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceSensorFilter] = true
        } else {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceSensorFilter] = false
        }
        
        if GeneralSettings.shared.cameraSettings.dceAutoZoomIsOpen == true {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceAutoZoom] = true
        } else {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceAutoZoom] = false
        }
        
        if GeneralSettings.shared.cameraSettings.dceFastModeIsOpen == true {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceFastMode] = true
        } else {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceFastMode] = false
        }
        
        if GeneralSettings.shared.cameraSettings.dceSmartTorchIsOpen == true {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.smartTorch] = true
        } else {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.smartTorch] = false
        }
        
        if GeneralSettings.shared.cameraSettings.dceScanRegionIsOpen == true {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceScanRegion] = true
        } else {
            recordDCESwitchStateDic[GeneralSettings.shared.cameraSettings.dceScanRegion] = false
        }
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(cameraSettingsTableView)
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BasicTableViewCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cameraSettingsDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleTag = self.cameraSettingsDataArray[indexPath.row]
        
        if titleTag == GeneralSettings.shared.cameraSettings.dceResolution {
            let identifier = "BasicTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicPullTableViewCell
            if cell == nil {
                cell = BasicPullTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            cell?.updateUI(with: titleTag, content: self.saveResolutionSelectedDic["showName"] as! String)
            return cell!
        } else if titleTag == GeneralSettings.shared.cameraSettings.dceVibrate ||
                  titleTag == GeneralSettings.shared.cameraSettings.dceBeep ||
                  titleTag == GeneralSettings.shared.cameraSettings.dceEnhancedFocus ||
                  titleTag == GeneralSettings.shared.cameraSettings.dceFrameSharpnessFilter ||
                  titleTag == GeneralSettings.shared.cameraSettings.dceSensorFilter ||
                  titleTag == GeneralSettings.shared.cameraSettings.dceAutoZoom ||
                  titleTag == GeneralSettings.shared.cameraSettings.dceFastMode ||
                  titleTag == GeneralSettings.shared.cameraSettings.smartTorch ||
                  titleTag == GeneralSettings.shared.cameraSettings.dceScanRegion {
            let identifier = "BasicSwitchTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicSwitchTableViewCell
            if cell == nil {
                cell = BasicSwitchTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
            
            if titleTag == GeneralSettings.shared.cameraSettings.dceVibrate ||
                titleTag == GeneralSettings.shared.cameraSettings.dceBeep {
                cell?.questionButton.isHidden = true
            } else {
                cell?.questionButton.isHidden = false
            }
            
            cell?.questionCompletion = {
                [unowned self] in
                self.handleDCEExplain(with: indexPath, settingString: titleTag)
            }
            
            cell?.switchChangedCompletion = {
                [unowned self] isOn in
                self.handleDCESettingSwitch(with: indexPath, settingString: titleTag, isOn: isOn)
            }
            
            cell?.updateUI(with: titleTag, isOn:recordDCESwitchStateDic[titleTag]!)
            return cell!
        } else if titleTag == GeneralSettings.shared.scanRegion.scanRegionTop ||
                  titleTag == GeneralSettings.shared.scanRegion.scanRegionBottom ||
                  titleTag == GeneralSettings.shared.scanRegion.scanRegionLeft ||
                  titleTag == GeneralSettings.shared.scanRegion.scanRegionRight {
            
            let identifier = "BasicTextTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BasicTextTableViewCell
            if cell == nil {
                cell = BasicTextTableViewCell.init(style: .default, reuseIdentifier: identifier)
            }
           
            cell?.inputTFValueChangedCompletion = {
                [unowned self] value in
                self.handleScanRegion(with: indexPath, settingString: titleTag, scanRegionInputValue: value)
            }
            
            cell?.defaultValue = recordScanRegionValueDic[titleTag]!
            cell?.setInputCountTFMaxValue(with: 100)
            cell?.titleOffset = 20.0
            cell?.updateUI(with: titleTag, valueNum: recordScanRegionValueDic[titleTag]!)
            cell?.questionButtonIsHidden = true
            return cell!
        }
       
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let titleTag = self.cameraSettingsDataArray[indexPath.row]
        
        if titleTag == GeneralSettings.shared.cameraSettings.dceResolution {
    
            PullListView.showPullList(with: self.resolutionOptionalArray, title: "Resolution", selectedDicInfo: saveResolutionSelectedDic) { selectedDic in
                print("selectedDic:\(selectedDic)")
                self.handleSelectedResolution(with: selectedDic)
            }
        }
    }
    
    private func handleSelectedResolution(with infoDic:[String:Any]) -> Void {
        saveResolutionSelectedDic = infoDic
        
        GeneralSettings.shared.dceResolution.selectedResolutionValue = infoDic["valueTag"] as? EnumResolution
        GeneralSettings.shared.cameraEnhancer.setResolution(GeneralSettings.shared.dceResolution.selectedResolutionValue)
        self.cameraSettingsTableView.reloadData()
    }

    
    // MARK: - HandleOperation
    
    /// Enhanced focus feature of Dynamsoft Camera Enhancer will enhance the focus ability of low-end device.
    /// Frame filter feature of Dynamsoft Camera Enhancer will filter out the blurry video frame.
    /// Sensor filter feature of Dynamsoft Camera Enhancer will filter out the frames captured when the device is shaking.
    /// Auto zoom feature of Dynamsoft Camera Enhancer will enable the camera to zoom in to apporach the barcodes.
    /// Fast mode feature of Dynamsoft Camera Enhancer will crop the frames to reduce the processing size.
    private func handleDCESettingSwitch(with indexPath: IndexPath,
                                settingString: String, isOn:
                                Bool) -> Void {
        var settingError : NSError?
        
        if settingString == GeneralSettings.shared.cameraSettings.dceVibrate {
            
            GeneralSettings.shared.cameraSettings.dceVibrateIsOpen = isOn
        } else if settingString == GeneralSettings.shared.cameraSettings.dceBeep {
            
            GeneralSettings.shared.cameraSettings.dceBeepIsOpen = isOn
        } else if settingString == GeneralSettings.shared.cameraSettings.dceEnhancedFocus {
            
            if isOn == true {
                GeneralSettings.shared.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumENHANCED_FOCUS.rawValue, error: &settingError)
            } else {
                GeneralSettings.shared.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumENHANCED_FOCUS.rawValue)
            }
            
            if settingError != nil {
                self.handleDCEConfigFailure(with: settingError!)
                return
            }
            
            GeneralSettings.shared.cameraSettings.dceEnhancedFocusIsOpen = isOn
        } else if settingString == GeneralSettings.shared.cameraSettings.dceFrameSharpnessFilter {
            
            if isOn == true {
                GeneralSettings.shared.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue, error: &settingError)
            } else {
                GeneralSettings.shared.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumFRAME_FILTER.rawValue)
            }
            
            if settingError != nil {
                self.handleDCEConfigFailure(with: settingError!)
                return
            }
            
            GeneralSettings.shared.cameraSettings.dceFrameSharpnessFilterIsOpen = isOn
        } else if settingString == GeneralSettings.shared.cameraSettings.dceSensorFilter {
            
            if isOn == true {
                GeneralSettings.shared.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumSENSOR_CONTROL.rawValue, error: &settingError)
            } else {
                GeneralSettings.shared.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumSENSOR_CONTROL.rawValue)
            }
            
            if settingError != nil {
                self.handleDCEConfigFailure(with: settingError!)
                return
            }
            
            GeneralSettings.shared.cameraSettings.dceSensorFilterIsOpen = isOn
        } else if settingString == GeneralSettings.shared.cameraSettings.dceAutoZoom {
            
            if isOn == true {
                GeneralSettings.shared.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue, error: &settingError)
            } else {
                GeneralSettings.shared.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumAUTO_ZOOM.rawValue)
            }
            
            if settingError != nil {
                self.handleDCEConfigFailure(with: settingError!)
                return
            }
            
            GeneralSettings.shared.cameraSettings.dceAutoZoomIsOpen = isOn
        } else if settingString == GeneralSettings.shared.cameraSettings.dceFastMode {
            
            if isOn == true {
                GeneralSettings.shared.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumFAST_MODE.rawValue, error: &settingError)
            } else {
                GeneralSettings.shared.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumFAST_MODE.rawValue)
            }
            
            if settingError != nil {
                self.handleDCEConfigFailure(with: settingError!)
                return
            }
            
            GeneralSettings.shared.cameraSettings.dceFastModeIsOpen = isOn
        } else if settingString == GeneralSettings.shared.cameraSettings.smartTorch {
            
            if isOn == true {
                GeneralSettings.shared.cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EnumSMART_TORCH.rawValue, error: &settingError)
            } else {
                GeneralSettings.shared.cameraEnhancer.disableFeatures(EnumEnhancerFeatures.EnumSMART_TORCH.rawValue)
            }
            
            if settingError != nil {
                self.handleDCEConfigFailure(with: settingError!)
                return
            }
            
            GeneralSettings.shared.cameraSettings.dceSmartTorchIsOpen = isOn
        } else if settingString == GeneralSettings.shared.cameraSettings.dceScanRegion {
            
            if isOn == true {
                if CameraSettingsViewController.dceIsFirstOpenScanRegion == true {
                    CameraSettingsViewController.dceIsFirstOpenScanRegion = false

                    let dceScanRegion = iRegionDefinition.init()
                    dceScanRegion.regionTop = 0
                    dceScanRegion.regionBottom = 100
                    dceScanRegion.regionLeft = 0
                    dceScanRegion.regionRight = 100
                    dceScanRegion.regionMeasuredByPercentage = 1
                    
                    GeneralSettings.shared.cameraEnhancer.setScanRegion(dceScanRegion, error: &settingError)
                    
                    if settingError != nil {
                        self.handleDCEConfigFailure(with: settingError!)
                        return
                    }
                    
                    GeneralSettings.shared.scanRegion.scanRegionTopValue = 0
                    GeneralSettings.shared.scanRegion.scanRegionBottomValue = 100
                    GeneralSettings.shared.scanRegion.scanRegionLeftValue = 0
                    GeneralSettings.shared.scanRegion.scanRegionRightValue = 100
                    GeneralSettings.shared.cameraSettings.dceScanRegionIsOpen = isOn
                } else {
                    GeneralSettings.shared.cameraEnhancer.scanRegionVisible = true
                }
            } else {
                GeneralSettings.shared.cameraEnhancer.scanRegionVisible = false
            }
            
            GeneralSettings.shared.cameraSettings.dceScanRegionIsOpen = isOn
        }
        
        recordDCESwitchStateDic[settingString] = isOn
       
        self.handleData()
        self.cameraSettingsTableView.reloadData()
    }
    
    /// Configure DCE scanRegion.
    /// The scanRegion will helps the barcode reader to reduce the processing time.
    /// Set the scanRegion with a nil value will reset the scanRegion to the default status.
    private func handleScanRegion(with indexPath: IndexPath,
                                  settingString: String,
                                  scanRegionInputValue: Int) -> Void {
        var scanRegionError : NSError?
        let dceScanRegion = iRegionDefinition.init()
    
        if settingString == GeneralSettings.shared.scanRegion.scanRegionTop {// SettingScanRegionTop.
            dceScanRegion.regionTop = scanRegionInputValue
            dceScanRegion.regionBottom = GeneralSettings.shared.scanRegion.scanRegionBottomValue
            dceScanRegion.regionLeft = GeneralSettings.shared.scanRegion.scanRegionLeftValue
            dceScanRegion.regionRight = GeneralSettings.shared.scanRegion.scanRegionRightValue
            dceScanRegion.regionMeasuredByPercentage = 1
            GeneralSettings.shared.cameraEnhancer.setScanRegion(dceScanRegion, error: &scanRegionError)
            
            if scanRegionError != nil {
                self.handleDCEConfigFailure(with: scanRegionError!)
                return
            }
            
            GeneralSettings.shared.scanRegion.scanRegionTopValue = scanRegionInputValue
        } else if settingString == GeneralSettings.shared.scanRegion.scanRegionBottom {// SettingScanRegionBottom.
            dceScanRegion.regionTop = GeneralSettings.shared.scanRegion.scanRegionTopValue
            dceScanRegion.regionBottom = scanRegionInputValue
            dceScanRegion.regionLeft = GeneralSettings.shared.scanRegion.scanRegionLeftValue
            dceScanRegion.regionRight = GeneralSettings.shared.scanRegion.scanRegionRightValue
            dceScanRegion.regionMeasuredByPercentage = 1
            GeneralSettings.shared.cameraEnhancer.setScanRegion(dceScanRegion, error: &scanRegionError)
            
            if scanRegionError != nil {
                self.handleDCEConfigFailure(with: scanRegionError!)
                return
            }
            
            GeneralSettings.shared.scanRegion.scanRegionBottomValue = scanRegionInputValue
        } else if settingString == GeneralSettings.shared.scanRegion.scanRegionLeft {// SettingScanRegionLeft.
            dceScanRegion.regionTop = GeneralSettings.shared.scanRegion.scanRegionTopValue
            dceScanRegion.regionBottom = GeneralSettings.shared.scanRegion.scanRegionBottomValue
            dceScanRegion.regionLeft = scanRegionInputValue
            dceScanRegion.regionRight = GeneralSettings.shared.scanRegion.scanRegionRightValue
            dceScanRegion.regionMeasuredByPercentage = 1
            GeneralSettings.shared.cameraEnhancer.setScanRegion(dceScanRegion, error: &scanRegionError)
            
            if scanRegionError != nil {
                self.handleDCEConfigFailure(with: scanRegionError!)
                return
            }
            
            GeneralSettings.shared.scanRegion.scanRegionLeftValue = scanRegionInputValue
        } else if settingString == GeneralSettings.shared.scanRegion.scanRegionRight {// SettingScanRegionRight.
            dceScanRegion.regionTop = GeneralSettings.shared.scanRegion.scanRegionTopValue
            dceScanRegion.regionBottom = GeneralSettings.shared.scanRegion.scanRegionBottomValue
            dceScanRegion.regionLeft = GeneralSettings.shared.scanRegion.scanRegionLeftValue
            dceScanRegion.regionRight = scanRegionInputValue
            dceScanRegion.regionMeasuredByPercentage = 1
            GeneralSettings.shared.cameraEnhancer.setScanRegion(dceScanRegion, error: &scanRegionError)
            
            if scanRegionError != nil {
                self.handleDCEConfigFailure(with: scanRegionError!)
                return
            }
            
            GeneralSettings.shared.scanRegion.scanRegionRightValue = scanRegionInputValue
        }
        
        self.handleData()
        self.cameraSettingsTableView.reloadData()
    }
    
    private func handleDCEConfigFailure(with error: NSError) -> Void {
        let msg = error.userInfo[NSUnderlyingErrorKey] as! String
        ToolsManager.shared.addAlertView(to: self, content: msg) {
            self.handleData()
            self.cameraSettingsTableView.reloadData()
        }
    }
    
    /// Parameter explain.
    private func handleDCEExplain(with indexPath: IndexPath,
                          settingString: String) -> Void {
        if settingString == GeneralSettings.shared.cameraSettings.dceEnhancedFocus {
            
            ToolsManager.shared.addAlertView(to: self,title: settingString, content: enhancedFocusExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.cameraSettings.dceFrameSharpnessFilter {
            
            ToolsManager.shared.addAlertView(to: self,title: settingString, content: frameSharpnessFilterExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.cameraSettings.dceSensorFilter {
            
            ToolsManager.shared.addAlertView(to: self,title: settingString, content: sensorFilterExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.cameraSettings.dceAutoZoom {
            
            ToolsManager.shared.addAlertView(to: self,title: settingString, content: autoZoomExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.cameraSettings.dceFastMode {
            
            ToolsManager.shared.addAlertView(to: self,title: settingString, content: fastModeExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.cameraSettings.smartTorch {
            
            ToolsManager.shared.addAlertView(to: self,title: settingString, content: smartTorchExplain, completion: nil)
        } else if settingString == GeneralSettings.shared.cameraSettings.dceScanRegion {
            
            ToolsManager.shared.addAlertView(to: self,title: settingString, content: dceScanRegionExplain, completion: nil)
        }
    }
}
