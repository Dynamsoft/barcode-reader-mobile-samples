/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

var activeTextField: UITextField?

class SettingsTableViewController: UIViewController {
    
    private var sections: [SettingSection] = []
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let kSettingsState = "SettingsState"
    var cvr: CaptureVisionRouter!
    var templateName = PresetTemplate.readBarcodesSpeedFirst.rawValue
    var isUsingCustomizedTemplate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        if let saved = loadState() {
            sections = saved
        } else {
            sections = defaultSections()
        }
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
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        tableView.register(OptionButtonCell.self, forCellReuseIdentifier: "OptionButtonCell")
        
        tableView.backgroundColor = .black
        tableView.tableFooterView = createRestoreDefaultFooter()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.delegate = self
        tableView.dataSource = self
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
    
    func defaultSections() -> [SettingSection] {
        
        let presetRow = ExpandableRow(title: "Select preset template", indentationLevel: 1, children: [
            SelectableRow(title: "Speed first", indentationLevel: 2, isSelected: templateName == PresetTemplate.readBarcodesSpeedFirst.rawValue, simplifiedSettingsTag: .speedFirst),
            SelectableRow(title: "Read-rate first", indentationLevel: 2,isSelected: templateName == PresetTemplate.readBarcodesReadRateFirst.rawValue, simplifiedSettingsTag: .readRateFirst)
        ])
        let simplifiedSettingsRow = JumpRow(title: "Configure Simplified Settings", indentationLevel: 1)
        let customizedTemplateRow = ExpandableRow(title: "Work with customized template files", indentationLevel: 1, children: [
            TouchUpRow(title: "Import", indentationLevel: 2, simplifiedSettingsTag: .importSetting),
            TouchUpRow(title: "Export", indentationLevel: 2, simplifiedSettingsTag: .exportSetting)
        ])
        let decodeSettingsSection = SettingSection(title: "Decode Settings", rows: [
            presetRow,
            simplifiedSettingsRow,
            customizedTemplateRow
        ])
        decodeSettingsSection.isExpanded = true
        
        let multiFramecrossRow = SwitchRow(title: "Multi-frame cross verification", indentationLevel: 1, simplifiedSettingsTag: .multiFrameCrossVerification)
        let resultDeduplicationRow = SwitchRow(title: "Result deduplication", indentationLevel: 1, children: [
            TextFieldRow(title: "Duplicate forget time(ms)", indentationLevel: 2, text: "3000", simplifiedSettingsTag: .duplicateForgetTime)
        ], simplifiedSettingsTag: .resultDeduplication)
        let overlappingRow = SwitchRow(title: "To the latest overlapping", indentationLevel: 1, children: [
            TextFieldRow(title: "Max overlapping frame count", indentationLevel: 2, text: "5", simplifiedSettingsTag: .maxOverlappingFrameCount)
        ], simplifiedSettingsTag: .toTheLatestOverlapping)
        let multiFrameSection = SettingSection(title: "Multi-frame cross filter", rows: [
            multiFramecrossRow,
            resultDeduplicationRow,
            overlappingRow
        ])
        
        let feedBackSection = SettingSection(title: "Result feedback", rows: [
            SwitchRow(title: "Beep", indentationLevel: 1, simplifiedSettingsTag: .beep),
            SwitchRow(title: "Vibrate", indentationLevel: 1, simplifiedSettingsTag: .vibrate)
        ])
        
        let cameraSettingsSection = SettingSection(title: "Camera Settings", rows: [
            OptionButtonRow(title: "Scan Region", indentationLevel: 1, options: ["Full Image", "Square", "Rectangular"], selectedIndex: 0, simplifiedSettingsTag: .scanRegion),
            OptionButtonRow(title: "Barcode Colour Option", indentationLevel: 1, options: ["1080P", "4K", "720P"], selectedIndex: 0, simplifiedSettingsTag: .resolution),
            SwitchRow(title: "Auto zoom", indentationLevel: 1, simplifiedSettingsTag: .autoZoom)
        ])
        return [decodeSettingsSection, multiFrameSection, feedBackSection, cameraSettingsSection]
    }
    
    func createRestoreDefaultFooter() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        let button = UIButton(type: .system)
        button.setTitle("Restore default", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(restoreDefaults), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 48)
        ])
        return footer
    }
    
    @objc func restoreDefaults() {
        showConfirm("Notice", "All the Settings will be reset to the default value.") { [self] in
            try? cvr.resetSettings()
            templateName = PresetTemplate.readBarcodesSpeedFirst.rawValue
            clearSimplifiedCaptureVisionSettingsState()
            
            sections = defaultSections()
            UserDefaults.standard.removeObject(forKey: kSettingsState)
            tableView.reloadData()
        }
    }
    
}

// MARK: - save and load
extension SettingsTableViewController {
    
    func saveState() {
        let dictArray = sections.map { $0.persist() }
        UserDefaults.standard.set(dictArray, forKey: kSettingsState)
        
        var dict: [String: Any] = [:]
        for section in sections {
            section.rows.forEach { row in
                saveRowState(row, to: &dict)
                if let children = row.children {
                    children.forEach { saveRowState($0, to: &dict) }
                }
            }
        }
        UserDefaults.standard.set(dict, forKey: kOtherSettingsState)
    }
    
    func saveRowState(_ row: SettingRow, to dict: inout [String: Any]) {
        if let tag = row.simplifiedSettingsTag {
            switch tag {
            case .multiFrameCrossVerification:
                dict[tag.rawValue] = (row as? SwitchRow)?.isOn
            case .resultDeduplication:
                dict[tag.rawValue] = (row as? SwitchRow)?.isOn
            case .duplicateForgetTime:
                if let str = (row as? TextFieldRow)?.text, let number = Int(str) {
                    dict[tag.rawValue] = number
                }
            case .toTheLatestOverlapping:
                dict[tag.rawValue] = (row as? SwitchRow)?.isOn
            case .maxOverlappingFrameCount:
                if let str = (row as? TextFieldRow)?.text, let number = Int(str) {
                    dict[tag.rawValue] = number
                }
            case .beep:
                dict[tag.rawValue] = (row as? SwitchRow)?.isOn
            case .vibrate:
                dict[tag.rawValue] = (row as? SwitchRow)?.isOn
            case .scanRegion:
                dict[tag.rawValue] = (row as? OptionButtonRow)?.selectedIndex
            case .resolution:
                dict[tag.rawValue] = (row as? OptionButtonRow)?.selectedIndex
            case .autoZoom:
                dict[tag.rawValue] = (row as? SwitchRow)?.isOn
            default:
                break
            }
        }
    }
    
    func loadState() -> [SettingSection]? {
        guard let dictArray = UserDefaults.standard.array(forKey: kSettingsState) as? [[String: Any]] else {
            return nil
        }
        return dictArray.compactMap { SettingSection(dict: $0) }
    }
    
}

// MARK: - UITableViewDataSource
extension SettingsTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        return section.isExpanded ? section.visibleRows.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = sections[indexPath.section]
        
        if indexPath.row == 0 {
            let cell = UITableViewCell()
            cell.backgroundColor = .customSectionColor
            cell.textLabel?.text = section.title
            cell.textLabel?.textColor = .white
            cell.accessoryView = UIImageView(image: UIImage(systemName: section.isExpanded ? "chevron.up" : "chevron.down"))
            cell.accessoryView?.tintColor = section.isExpanded ? .orange : .customChevronColor
            cell.indentationLevel = 0
            return cell
        } else {
            let rows = section.visibleRows
            let row = rows[indexPath.row - 1]
            switch row.type {
                
            case .chevronExpand:
                let expandRow = row as! ExpandableRow
                let cell = UITableViewCell()
                cell.textLabel?.text = row.title
                cell.textLabel?.textColor = .customCellTextColor
                cell.backgroundColor = expandRow.indentationLevel == 2 ? .customSubCellColor : .customCellColor
                cell.accessoryView = UIImageView(image: UIImage(systemName: expandRow.isExpanded ? "chevron.up" : "chevron.down"))
                cell.accessoryView?.tintColor = expandRow.isExpanded ? .orange : .customChevronColor
                cell.indentationLevel = expandRow.indentationLevel
                return cell
                
            case .switchCell:
                let switchRow = row as! SwitchRow
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
                cell.textLabel?.text = switchRow.title
                cell.textLabel?.textColor = .customCellTextColor
                cell.backgroundColor = switchRow.indentationLevel == 2 ? .customSubCellColor : .customCellColor
                cell.switchControl.isOn = switchRow.isOn
                cell.indentationLevel = switchRow.indentationLevel
                cell.switchChanged = { [weak self] isOn in
                    switchRow.isOn = isOn
                    self?.saveState()
                    if (switchRow.children != nil) {
                        self?.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
                    }
                }
                cell.selectionStyle = .none
                return cell
                
            case .textField:
                let textRow = row as! TextFieldRow
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
                cell.textLabel?.text = textRow.title
                cell.textLabel?.textColor = .customCellTextColor
                cell.backgroundColor = textRow.indentationLevel == 2 ? .customSubCellColor : .customCellColor
                cell.textField.text = textRow.text
                cell.indentationLevel = textRow.indentationLevel
                cell.textChanged = { [weak self] text in
                    textRow.text = text
                    self?.saveState()
                }
                cell.selectionStyle = .none
                cell.inputType = textRow.inputType
                if textRow.simplifiedSettingsTag == .duplicateForgetTime {
                    cell.minValue = 1
                    cell.maxValue = 180000
                }
                return cell
                
            case .touchUp:
                let cell = UITableViewCell()
                cell.textLabel?.text = row.title
                cell.textLabel?.textColor = .customCellTextColor
                cell.backgroundColor = row.indentationLevel == 2 ? .customSubCellColor : .customCellColor
                cell.indentationLevel = row.indentationLevel
                return cell
                
            case .select:
                let selectRow = row as! SelectableRow
                let cell = UITableViewCell()
                cell.textLabel?.text = selectRow.title + (selectRow.isSelected ? "  ✓" : "")
                cell.textLabel?.textColor = selectRow.isSelected ? .orange : .customCellTextColor
                cell.backgroundColor = selectRow.indentationLevel == 2 ? .customSubCellColor : .customCellColor
                cell.indentationLevel = selectRow.indentationLevel
                return cell
                
            case .jump:
                let cell = UITableViewCell()
                cell.textLabel?.text = row.title
                cell.textLabel?.textColor = .customCellTextColor
                cell.backgroundColor = row.indentationLevel == 2 ? .customSubCellColor : .customCellColor
                cell.indentationLevel = row.indentationLevel
                cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
                cell.accessoryView?.tintColor = .customChevronColor
                return cell
                
            case .optionButton:
                let optionRow = row as! OptionButtonRow
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionButtonCell", for: indexPath) as! OptionButtonCell
                cell.backgroundColor = .customCellColor
                cell.configure(with: optionRow.title, options: optionRow.options, selectedIndex: optionRow.selectedIndex)
                cell.selectionChanged = { [weak self] selectedIndex in
                    optionRow.selectedIndex = selectedIndex
                    self?.saveState()
                }
                cell.selectionStyle = .none
                return cell
            case .pick, .expandableSwitch:
                let cell = UITableViewCell()
                return cell
            }
        }
    }
    
}

// MARK: - UITableView Delegate
extension SettingsTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("Detail clicked，index：\(indexPath)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        if indexPath.row == 0 {
            return 50
        } else {
            let rows = section.visibleRows
            let row = rows[indexPath.row - 1]
            if row.type == .optionButton {
                return 90
            } else {
                return 50
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = sections[indexPath.section]
        
        if indexPath.row == 0 {
            section.isExpanded.toggle()
            saveState()
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        } else {
            let rows = section.visibleRows
            let row = rows[indexPath.row - 1]
            tableView.deselectRow(at: indexPath, animated: true)
            switch row.type {
            case .chevronExpand:
                (row as! ExpandableRow).isExpanded.toggle()
                saveState()
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            case .select:
                let selectRow = row as! SelectableRow
                if selectRow.isSelected {
                    selectRow.isSelected = false
                } else {
                    if let parentRow = section.rows.first(where: { $0.children?.contains(where: { $0 === selectRow }) == true }) {
                        parentRow.children?.forEach { ($0 as! SelectableRow).isSelected = false }
                    }
                    selectRow.isSelected = true
                }
                if selectRow.isSelected, let tag = selectRow.simplifiedSettingsTag {
                    onSelectTemplate(tag)
                }
                saveState()
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            case .touchUp:
                onTouchUpPort(row)
            case .jump:
                onJumpPort(row.title)
            case .switchCell, .textField, .optionButton, .pick, .expandableSwitch: break
            }
        }
        
    }
    
    private func onJumpPort(_ title: String) {
        if let settings = try? cvr.getSimplifiedSettings(templateName) {
            let vc = SimplifiedSettingsViewController()
            vc.settings = settings
            navigationController?.pushViewController(vc, animated: true)
        } else {
            showResult("Error", "Can't getSimplifiedSettings, pleas restore first.")
        }
    }
    
    private func onSelectTemplate(_ tag: SimplifiedSettingsTag) {
        try? cvr.resetSettings()
        if tag == .speedFirst {
            templateName = PresetTemplate.readBarcodesSpeedFirst.rawValue
        } else if tag == .readRateFirst {
            templateName = PresetTemplate.readBarcodesReadRateFirst.rawValue
        }
        isUsingCustomizedTemplate = false
        saveTemplateState()
        clearSimplifiedCaptureVisionSettingsState()
    }
    
    private func onTouchUpPort(_ row: SettingRow) {
        let tag = row.simplifiedSettingsTag
        if tag == .importSetting {
            showInputAlert()
        } else if tag == .exportSetting {
            if let path = kSettingFilePath?.path {
                do {
                    try cvr.outputSettingsToFile(templateName, filePath: path, includeDefaultValues: true)
                    showConfirm("Notice", "Do you want to share the settings.json file?\nThe file has been saved to \(path)") {
                        self.shareFile(kSettingFilePath)
                    }
                } catch {
                    showResult("Export failed", error.localizedDescription)
                }
            }
        }
    }
    
    private func switchCustomizedTemplate(_ jsonString: String) {
        do {
            try cvr.initSettings(jsonString)
            templateName = ""
            if let path = kSettingFilePath?.path {
                try cvr.outputSettingsToFile(templateName, filePath: path, includeDefaultValues: true)
            }
            isUsingCustomizedTemplate = true
            saveTemplateState()
            
            if let children = sections.first(where: { section in
                section.rows.contains(where: { $0.title == "Select preset template" })
            })?.rows.first(where: { $0.title == "Select preset template" })?.children {
                for row in children {
                    (row as? SelectableRow)?.isSelected = false
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
            saveState()
            
            clearSimplifiedCaptureVisionSettingsState()
        } catch {
            showResult("InitSettings Error", error.localizedDescription)
        }
    }
    
    private func clearSimplifiedCaptureVisionSettingsState() {
        UserDefaults.standard.removeObject(forKey: kTemplateState)
        UserDefaults.standard.removeObject(forKey: kBarcodeFormatState)
        UserDefaults.standard.removeObject(forKey: kSimplifiedCaptureVisionSettingsState)
        UserDefaults.standard.removeObject(forKey: kOtherSettingsState)
    }
    
    func showInputAlert() {
        let alertController = UIAlertController(title: "Please input a JSON URL", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "https://www.example.com/data.json"
        }
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let urlString = alertController.textFields?.first?.text,
                  let url = URL(string: urlString) else {
                self?.showResult("Error", "Please input a valid URL")
                return
            }
            self?.fetchJSON(from: url)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func fetchJSON(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                self?.showResult("Request Error", error.localizedDescription)
                return
            }
            guard let data = data else {
                self?.showResult("Error", "No data returned")
                return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    self?.switchCustomizedTemplate(jsonString)
                }
            } catch {
                self?.showResult("Parsing Error", error.localizedDescription)
            }
        }.resume()
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showConfirm(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
        
    func shareFile(_ url: URL?) {
        guard let path = url, FileManager.default.fileExists(atPath: path.path) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    private func saveTemplateState() {
        var dict: [String: Any] = [:]
        dict["templateName"] = templateName
        dict["isUsingCustomizedTemplate"] = isUsingCustomizedTemplate
        UserDefaults.standard.set(dict, forKey: kTemplateState)
    }
}

// MARK: - Keyboard
extension SettingsTableViewController {
    
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
