/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class SimplifiedSettingsViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    var sections: [SettingRow] = []
    
    var tempPickerOptions: [String] = []
    var currentPickerIndexPath: IndexPath?

    let kViewControllerState = "SimplifiedSettingsViewControllerState"
    
    let enumLocalizationModesOptions:[LocalizationMode] = [.connectedBlocks, .statistics, .lines, .scanDirectly, .statisticsMarks, .statisticsPostalCode, .centre, .oneDFastScan, .skip]

    let enumDeblurModesOptions:[DeblurMode] = [.directBinarization, .thresholdBinarization, .grayEqualization, .smoothing, .morphing, .deepAnalysis, .sharpening, .basedOnLocBin, .sharpeningSmoothing, .neuralNetwork, .skip]
    
    let enumTransformationModesOptions:[GrayscaleTransformationMode] = [.original, .inverted, .skip]
    
    let enumEnhancementModesOptions:[GrayscaleEnhancementMode] = [.general, .grayEqualize, .graySmooth, .sharpenSmooth, .skip]
    
    var settings: SimplifiedCaptureVisionSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SimplifiedSettings"
        sections = defaultSections()
        setupTableView()
        setupKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveState()
    }
    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        
        tableView.backgroundColor = .black
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    func defaultSections() -> [SettingRow] {
        
        let barcodeFormatSection = JumpRow(title: "Barcode format", indentationLevel: 0)
        let expectedBarcodesCountSection = TextFieldRow(title: "Expected barcodes count", indentationLevel: 0, text: String(settings?.barcodeSettings?.expectedBarcodesCount ?? 0), simplifiedSettingsTag: .expectedBarcodeCount)
        
        let localizationSection = ExpandableRow(title: "Localization modes", indentationLevel: 0, isExpanded: false, simplifiedSettingsTag: .localization)
        var localizationChildren:[PickRow] = []
        let localizationModesOptions = enumLocalizationModesOptions.map { $0.string }
        if let localizationModes = settings?.barcodeSettings?.localizationModes {
            for localizationMode in localizationModes {
                let mode = LocalizationMode(rawValue: (localizationMode as? NSNumber)?.intValue ?? 0) ?? .skip
                if let index = enumLocalizationModesOptions.firstIndex(of: mode) {
                    let row = PickRow(indentationLevel: 1, options: localizationModesOptions, selectedIndex: index)
                    localizationChildren.append(row)
                }
                if mode == .skip {
                    break
                }
            }
        }
        if localizationChildren.count == 0 {
            localizationChildren.append(PickRow(indentationLevel: 1, options: localizationModesOptions, selectedIndex: enumLocalizationModesOptions.firstIndex(of: .skip) ?? 0))
        }
        localizationSection.children = localizationChildren
        
        let deblurSection = ExpandableRow(title: "Deblur modes", indentationLevel: 0, isExpanded: false, simplifiedSettingsTag: .deblur)
        var deblurChildren:[PickRow] = []
        let deblurModesOptions = enumDeblurModesOptions.map { $0.string }
        if let deblurModes = settings?.barcodeSettings?.deblurModes {
            for deblurMode in deblurModes {
                let mode = DeblurMode(rawValue: (deblurMode as? NSNumber)?.intValue ?? 0) ?? .skip
                if let index = enumDeblurModesOptions.firstIndex(of: mode) {
                    let row = PickRow(indentationLevel: 1, options: deblurModesOptions, selectedIndex: index)
                    deblurChildren.append(row)
                }
                if mode == .skip {
                    break
                }
            }
        }
        if deblurChildren.count == 0 {
            deblurChildren.append(PickRow(indentationLevel: 1, options: deblurModesOptions, selectedIndex: enumDeblurModesOptions.firstIndex(of: .skip) ?? 0))
        }
        deblurSection.children = deblurChildren
        
        let transformationSection = ExpandableRow(title: "GrayscaleTransformationModes", indentationLevel: 0, isExpanded: false, simplifiedSettingsTag: .transformation)
        var transformationChildren:[PickRow] = []
        let transformationModesOptions = enumTransformationModesOptions.map { $0.string }
        if let transformationModes = settings?.barcodeSettings?.grayscaleTransformationModes {
            for transformationMode in transformationModes {
                let mode = GrayscaleTransformationMode(rawValue: (transformationMode as? NSNumber)?.intValue ?? 0) ?? .skip
                if let index = enumTransformationModesOptions.firstIndex(of: mode) {
                    let row = PickRow(indentationLevel: 1, options: transformationModesOptions, selectedIndex: index)
                    transformationChildren.append(row)
                }
                if mode == .skip {
                    break
                }
            }
        }
        if transformationChildren.count == 0 {
            transformationChildren.append(PickRow(indentationLevel: 1, options: transformationModesOptions, selectedIndex: enumTransformationModesOptions.firstIndex(of: .skip) ?? 0))
        }
        transformationSection.children = transformationChildren
        
        let enhancementSection = ExpandableRow(title: "GrayscaleEnhancementModes", indentationLevel: 0, isExpanded: false, simplifiedSettingsTag: .enhancement)
        var enhancementChildren:[PickRow] = []
        let enhancementModesOptions = enumEnhancementModesOptions.map { $0.string }
        if let enhancementModes = settings?.barcodeSettings?.grayscaleEnhancementModes {
            for enhancementMode in enhancementModes {
                let mode = GrayscaleEnhancementMode(rawValue: (enhancementMode as? NSNumber)?.intValue ?? 0) ?? .skip
                if let index = enumEnhancementModesOptions.firstIndex(of: mode) {
                    let row = PickRow(indentationLevel: 1, options: enhancementModesOptions, selectedIndex: index)
                    enhancementChildren.append(row)
                }
                if mode == .skip {
                    break
                }
            }
        }
        if enhancementChildren.count == 0 {
            enhancementChildren.append(PickRow(indentationLevel: 1, options: enhancementModesOptions, selectedIndex: enumEnhancementModesOptions.firstIndex(of: .skip) ?? 0))
        }
        enhancementSection.children = enhancementChildren
        
        let confidenceSection = TextFieldRow(title: "Min result confidence", indentationLevel: 0, text: String(settings?.barcodeSettings?.minResultConfidence ?? 0), simplifiedSettingsTag: .confidence)
        
        let scaleDownThresholdSection = TextFieldRow(title: "Scale down threshold", indentationLevel: 0, text: String(settings?.barcodeSettings?.scaleDownThreshold ?? 0), simplifiedSettingsTag: .scaleDownThreshold)
        
        let barcodeTextRegexSection = TextFieldRow(title: "Barcode text RegEx", indentationLevel: 0, text: settings?.barcodeSettings?.barcodeTextRegExPattern ?? "", inputType: .normal, simplifiedSettingsTag: .barcodeTextRegEx)
        
        let minTextLength = TextFieldRow(title: "Minimum text length", indentationLevel: 0, text: String(settings?.barcodeSettings?.minBarcodeTextLength ?? 0), simplifiedSettingsTag: .minTextLength)
        
        let timeoutSection = TextFieldRow(title: "Timeout", indentationLevel: 0, text: String(settings?.timeout ?? 0), simplifiedSettingsTag: .timeout)
        
        let minDecodeInterval = TextFieldRow(title: "Minimum decode interval", indentationLevel: 0, text: String(settings?.minImageCaptureInterval ?? 0), simplifiedSettingsTag: .minDecodeInterval)
        
        let defalutSections = [barcodeFormatSection,
                               expectedBarcodesCountSection,
                               localizationSection,
                               deblurSection,
                               transformationSection,
                               enhancementSection,
                               confidenceSection,
                               scaleDownThresholdSection,
                               barcodeTextRegexSection,
                               minTextLength,
                               timeoutSection,
                               minDecodeInterval]
        
        if let dict = UserDefaults.standard.value(forKey: kViewControllerState) as? [String: Any] {
            for row in defalutSections {
                if let tag = row.simplifiedSettingsTag, let isExpanded = dict[tag.rawValue] as? Bool {
                    (row as? ExpandableRow)?.isExpanded = isExpanded
                }
            }
        }
        
        return defalutSections
    }
}

// MARK: - save and load
extension SimplifiedSettingsViewController {
    
    func saveState() {
        
        var settingsDict: [String: Any] = [:]
        var uiDict: [String: Any] = [:]
        for row in sections {
            if let tag = row.simplifiedSettingsTag {
                switch tag {
                case .expectedBarcodeCount:
                    if let unwrappedStr = (row as? TextFieldRow)?.text, let number = UInt(unwrappedStr) {
                        settingsDict[tag.rawValue] = number
                    }
                case .confidence:
                    if let unwrappedStr = (row as? TextFieldRow)?.text, let number = UInt(unwrappedStr) {
                        settingsDict[tag.rawValue] = number
                    }
                case .scaleDownThreshold:
                    if let unwrappedStr = (row as? TextFieldRow)?.text, let number = Int(unwrappedStr) {
                        settingsDict[tag.rawValue] = number
                    }
                case .barcodeTextRegEx:
                    if let str = (row as? TextFieldRow)?.text {
                        settingsDict[tag.rawValue] = str
                    }
                case .minTextLength:
                    if let unwrappedStr = (row as? TextFieldRow)?.text, let number = UInt(unwrappedStr) {
                        settingsDict[tag.rawValue] = number
                    }
                case .timeout:
                    if let unwrappedStr = (row as? TextFieldRow)?.text, let number = Int(unwrappedStr) {
                        settingsDict[tag.rawValue] = number
                    }
                case .minDecodeInterval:
                    if let unwrappedStr = (row as? TextFieldRow)?.text, let number = Int(unwrappedStr) {
                        settingsDict[tag.rawValue] = number
                    }
                case .localization:
                    if let tag = row.simplifiedSettingsTag {
                        uiDict[tag.rawValue] = (row as? ExpandableRow)?.isExpanded
                    }
                    if let children = row.children {
                        var modes:[NSNumber] = []
                        children.forEach {
                            if let pickRow = $0 as? PickRow, pickRow.selectedIndex < enumLocalizationModesOptions.count {
                                modes.append(NSNumber(value: enumLocalizationModesOptions[pickRow.selectedIndex].rawValue))
                            }
                        }
                        settingsDict[tag.rawValue] = modes
                    }
                case .deblur:
                    if let tag = row.simplifiedSettingsTag {
                        uiDict[tag.rawValue] = (row as? ExpandableRow)?.isExpanded
                    }
                    if let children = row.children {
                        var modes:[NSNumber] = []
                        children.forEach {
                            if let pickRow = $0 as? PickRow, pickRow.selectedIndex < enumDeblurModesOptions.count {
                                modes.append(NSNumber(value: enumDeblurModesOptions[pickRow.selectedIndex].rawValue))
                            }
                        }
                        settingsDict[tag.rawValue] = modes
                    }
                case .transformation:
                    if let tag = row.simplifiedSettingsTag {
                        uiDict[tag.rawValue] = (row as? ExpandableRow)?.isExpanded
                    }
                    if let children = row.children {
                        var modes:[NSNumber] = []
                        children.forEach {
                            if let pickRow = $0 as? PickRow, pickRow.selectedIndex < enumTransformationModesOptions.count {
                                modes.append(NSNumber(value: enumTransformationModesOptions[pickRow.selectedIndex].rawValue))
                            }
                        }
                        settingsDict[tag.rawValue] = modes
                    }
                case .enhancement:
                    if let tag = row.simplifiedSettingsTag {
                        uiDict[tag.rawValue] = (row as? ExpandableRow)?.isExpanded
                    }
                    if let children = row.children {
                        var modes:[NSNumber] = []
                        children.forEach {
                            if let pickRow = $0 as? PickRow, pickRow.selectedIndex < enumEnhancementModesOptions.count {
                                modes.append(NSNumber(value: enumEnhancementModesOptions[pickRow.selectedIndex].rawValue))
                            }
                        }
                        settingsDict[tag.rawValue] = modes
                    }
                default:
                    break
                }
            }
        }
        UserDefaults.standard.set(uiDict, forKey: kViewControllerState)
        UserDefaults.standard.set(settingsDict, forKey: kSimplifiedCaptureVisionSettingsState)
    }
}

// MARK: - UITableViewDataSource
extension SimplifiedSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        guard let expandableRow = section as? ExpandableRow, expandableRow.isExpanded, let children = section.children else { return 1 }
        return 1 + children.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        if indexPath.row == 0 {
            switch section.type {
            case .chevronExpand:
                let cell = UITableViewCell()
                cell.backgroundColor = .customSectionColor
                cell.textLabel?.text = section.title
                cell.textLabel?.textColor = .white
                cell.accessoryView = UIImageView(image: UIImage(systemName: (section as! ExpandableRow).isExpanded ? "chevron.up" : "chevron.down"))
                cell.accessoryView?.tintColor = (section as! ExpandableRow).isExpanded ? .orange : .customChevronColor
                cell.indentationLevel = section.indentationLevel
                return cell
            case .textField:
                let textRow = section as! TextFieldRow
                let textFieldCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
                textFieldCell.backgroundColor = .customSectionColor
                textFieldCell.textLabel?.text = textRow.title
                textFieldCell.textLabel?.textColor = .white
                textFieldCell.textField.text = textRow.text
                textFieldCell.textChanged = { [weak self] text in
                    textRow.text = text
                    self?.saveState()
                }
                textFieldCell.selectionStyle = .none
                textFieldCell.inputType = textRow.inputType
                textFieldCell.indentationLevel = textRow.indentationLevel
                if textRow.simplifiedSettingsTag == .confidence {
                    textFieldCell.maxValue = 100
                } else if textRow.simplifiedSettingsTag == .scaleDownThreshold {
                    textFieldCell.minValue = 512
                }
                return textFieldCell
            case .jump:
                let cell = UITableViewCell()
                cell.backgroundColor = .customSectionColor
                cell.textLabel?.text = section.title
                cell.textLabel?.textColor = .white
                cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
                cell.accessoryView?.tintColor = .customChevronColor
                cell.indentationLevel = section.indentationLevel
                cell.selectionStyle = .none
                return cell
            case .select, .touchUp, .switchCell, .optionButton, .pick, .expandableSwitch:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.backgroundColor = .customSectionColor
                cell.textLabel?.text = section.title
                cell.textLabel?.textColor = .white
                cell.indentationLevel = section.indentationLevel
                return cell
            }
        } else {
            if let children = section.children {
                let row = children[indexPath.row - 1]
                switch row.type {
                case .pick:
                    let cell = UITableViewCell()
                    cell.backgroundColor = .customCellColor
                    cell.textLabel?.text = row.title
                    cell.textLabel?.textColor = .customCellTextColor
                    cell.indentationLevel = row.indentationLevel
                    cell.selectionStyle = .none
                    return cell
                case .chevronExpand, .jump, .optionButton, .select, .switchCell, .textField, .touchUp, .expandableSwitch:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                    cell.backgroundColor = .customCellColor
                    cell.textLabel?.text = row.title
                    cell.textLabel?.textColor = .customCellTextColor
                    cell.indentationLevel = row.indentationLevel
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension SimplifiedSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = sections[indexPath.section]
        
        if indexPath.row == 0 {
            switch section.type {
            case .chevronExpand:
                (section as? ExpandableRow)?.isExpanded.toggle()
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
                saveState()
            case .jump:
                onTouchUpPort(action: section.title)
            case .optionButton, .pick, .select, .switchCell, .textField, .touchUp, .expandableSwitch:
                break
            }
        } else {
            guard let children = section.children, indexPath.row - 1 < children.count,
                  let pickRow = children[indexPath.row - 1] as? PickRow else { return }
            
            currentPickerIndexPath = indexPath
            tempPickerOptions = pickRow.options
            
            let pickerPopup = PickerPopupView(frame: view.bounds)
            pickerPopup.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            pickerPopup.pickerOptions = tempPickerOptions
            pickerPopup.initialSelectedIndex = pickRow.selectedIndex
            
            pickerPopup.onConfirm = { [weak self] selectedRow in
                self?.pickerOK(selectedRow: selectedRow)
            }
            
            pickerPopup.onCancel = {
                
            }
            view.addSubview(pickerPopup)
            pickerPopup.updateConstraints(with: view)
        }
    }
    
    private func onTouchUpPort(action: String) {
        let vc = BarcodeFormatSettingsViewController()
        vc.format = settings.barcodeSettings?.barcodeFormatIds
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Picker confirm
extension SimplifiedSettingsViewController {
    
    func pickerOK(selectedRow: Int) {
        guard let ip = currentPickerIndexPath else { return }
        let header = sections[ip.section]
        guard var children = header.children,
              ip.row - 1 < children.count,
              let pickRow = children[ip.row - 1] as? PickRow else { return }
        
        let selectedOption = tempPickerOptions[selectedRow]
        // Update selectedIndex to ensure that the current option is selected by default next time the popup appears
        pickRow.selectedIndex = selectedRow
        
        if selectedOption != "Skip" {
            let duplicate = children.enumerated().contains { (idx, row) in
                if idx == ip.row - 1 { return false }
                return row.title == selectedOption
            }
            if duplicate {
                let alert = UIAlertController(title: "Warning", message: "Option '\(selectedOption)' is already selected!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
        }
        
        if ip.row - 1 == children.count - 1 {
            // last line
            if selectedOption == "Skip" {
                // no change
            } else {
                pickRow.title = selectedOption
                if let newIndex = pickRow.options.firstIndex(of: "Skip") {
                    let newPick = PickRow(title: "Skip", indentationLevel: 1, options: pickRow.options, selectedIndex: newIndex)
                    children.append(newPick)
                }
            }
        } else {
            if selectedOption == "Skip" {
                pickRow.title = selectedOption
                children = Array(children.prefix(ip.row))
            } else {
                pickRow.title = selectedOption
                if children.last?.title != "Skip", let newIndex = pickRow.options.firstIndex(of: "Skip") {
                    let newPick = PickRow(title: "Skip", indentationLevel: 1, options: pickRow.options, selectedIndex: newIndex)
                    children.append(newPick)
                }
            }
        }
        header.children = children
        tableView.reloadSections(IndexSet(integer: ip.section), with: .automatic)
        saveState()
    }
}

// MARK: - Keyboard
extension SimplifiedSettingsViewController {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let activeField = activeTextField else { return }

        let keyboardY = self.view.frame.height - keyboardFrame.height
        
        let activeFieldFrame = activeField.convert(activeField.bounds, to: self.view)
        let activeFieldBottom = activeFieldFrame.maxY

        let overlap = activeFieldBottom - keyboardY
        
        UIView.animate(withDuration: duration) {
            if overlap > 0 {
                self.view.frame.origin.y = -overlap - 10
            } else {
                self.view.frame.origin.y = 0
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = 0
        }
    }
}
