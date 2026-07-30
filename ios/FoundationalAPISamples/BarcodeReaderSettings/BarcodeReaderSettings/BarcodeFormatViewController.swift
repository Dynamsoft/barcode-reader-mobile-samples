/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class BarcodeFormatSettingsViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    var sections: [SettingRow] = []
    let kViewControllerState = "BarcodeFormatSettingsViewControllerState"
    var format:BarcodeFormat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BarcodeFormatSettings"
        sections = defaultSections()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveState()
    }
    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ExpandableSwitchCell.self, forCellReuseIdentifier: "ExpandableSwitchCell")
        
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
        let oneDSection = ExpandableSwitchRow(title: "OneD Barcodes", indentationLevel: 0, isExpanded: true, isOn: format.contains([.code39, .code128, .code39Extended, .code93, .code11, .codabar, .itf, .ean13, .ean8, .upca, .upce, .industrial25, .msiCode]), children:[
            SelectableRow(title: "Code 39", indentationLevel: 1, isSelected: format.contains(.code39), barcodeFormat: .code39),
            SelectableRow(title: "Code 128", indentationLevel: 1, isSelected: format.contains(.code128), barcodeFormat: .code128),
            SelectableRow(title: "Code 39 Extended", indentationLevel: 1, isSelected: format.contains(.code39Extended), barcodeFormat: .code39Extended),
            SelectableRow(title: "Code 93", indentationLevel: 1, isSelected: format.contains(.code93), barcodeFormat: .code93),
            SelectableRow(title: "Code 11", indentationLevel: 1, isSelected: format.contains(.code11), barcodeFormat: .code11),
            SelectableRow(title: "Codabar", indentationLevel: 1, isSelected: format.contains(.codabar), barcodeFormat: .codabar),
            SelectableRow(title: "ITF", indentationLevel: 1, isSelected: format.contains(.itf), barcodeFormat: .itf),
            SelectableRow(title: "EAN-13", indentationLevel: 1, isSelected: format.contains(.ean13), barcodeFormat: .ean13),
            SelectableRow(title: "EAN-8", indentationLevel: 1, isSelected: format.contains(.ean8), barcodeFormat: .ean8),
            SelectableRow(title: "UPC-A", indentationLevel: 1, isSelected: format.contains(.upca), barcodeFormat: .upca),
            SelectableRow(title: "UPC-E", indentationLevel: 1, isSelected: format.contains(.upce), barcodeFormat: .upce),
            SelectableRow(title: "Industrial 25", indentationLevel: 1, isSelected: format.contains(.industrial25), barcodeFormat: .industrial25),
            SelectableRow(title: "MSI Code", indentationLevel: 1, isSelected: format.contains(.msiCode), barcodeFormat: .msiCode),
        ])
        oneDSection.simplifiedSettingsTag = .oneDBarcodes
        
        let twoDSection = ExpandableSwitchRow(title: "2D Barcodes", indentationLevel: 0, isExpanded: true, isOn: format.contains([.qrCode, .pdf417, .dataMatrix]), children: [
            SelectableRow(title: "QR Code", indentationLevel: 1, isSelected: format.contains(.qrCode), barcodeFormat: .qrCode),
            SelectableRow(title: "PDF417", indentationLevel: 1, isSelected: format.contains(.pdf417), barcodeFormat: .pdf417),
            SelectableRow(title: "DataMatrix", indentationLevel: 1, isSelected: format.contains(.dataMatrix), barcodeFormat: .dataMatrix)
        ])
        twoDSection.simplifiedSettingsTag = .twoDBarcodes
        
        let pharmaSection = ExpandableSwitchRow(title: "Pharma Barcodes", indentationLevel: 0, isExpanded: true, isOn: format.contains([.pharmaCodeOneTrack, .pharmaCodeTwoTrack]), children: [
            SelectableRow(title: "Pharma Code One Track", indentationLevel: 1, isSelected: format.contains(.pharmaCodeOneTrack), barcodeFormat: .pharmaCodeOneTrack),
            SelectableRow(title: "Pharma Code Two Track", indentationLevel: 1, isSelected: format.contains(.pharmaCodeTwoTrack), barcodeFormat: .pharmaCodeTwoTrack)
        ])
        pharmaSection.simplifiedSettingsTag = .pharmaBarcodes
        
        let otherSection = ExpandableSwitchRow(title: "Other Barcodes", indentationLevel: 0, isExpanded: true, isOn: format.contains([.aztec, .maxiCode, .patchCode, .dotCode, .postalCode, .gs1Databar, .gs1Composite, .microPDF417, .microQR]), children: [
            SelectableRow(title: "Aztec", indentationLevel: 1, isSelected: format.contains(.aztec), barcodeFormat: .aztec),
            SelectableRow(title: "MaxiCode", indentationLevel: 1, isSelected: format.contains(.maxiCode), barcodeFormat: .maxiCode),
            SelectableRow(title: "Patch Code", indentationLevel: 1, isSelected: format.contains(.patchCode), barcodeFormat: .patchCode),
            SelectableRow(title: "Dot Code", indentationLevel: 1, isSelected: format.contains(.dotCode), barcodeFormat: .dotCode),
            SelectableRow(title: "Postal Code", indentationLevel: 1, isSelected: format.contains(.postalCode), barcodeFormat: .postalCode),
            SelectableRow(title: "GS1 Databar", indentationLevel: 1, isSelected: format.contains(.gs1Databar), barcodeFormat: .gs1Databar),
            SelectableRow(title: "GS1 Composite", indentationLevel: 1, isSelected: format.contains(.gs1Composite), barcodeFormat: .gs1Composite),
            SelectableRow(title: "Micro PDF417", indentationLevel: 1, isSelected: format.contains(.microPDF417), barcodeFormat: .microPDF417),
            SelectableRow(title: "Micro QR", indentationLevel: 1, isSelected: format.contains(.microQR), barcodeFormat: .microQR),
        ])
        otherSection.simplifiedSettingsTag = .otherBarcodes
        
        let defalutSections = [oneDSection, twoDSection, pharmaSection, otherSection]
        if let dict = UserDefaults.standard.value(forKey: kViewControllerState) as? [String: Any] {
            for row in defalutSections {
                if let tag = row.simplifiedSettingsTag?.rawValue, let isExpanded = dict[tag] as? Bool {
                    row.isExpanded = isExpanded
                }
            }
        }
        
        return defalutSections
    }
}

// MARK: - save and load
extension BarcodeFormatSettingsViewController {
    
    func saveState() {
        
        var dict: [String: Any] = [:]
        for row in sections {
            if let tag = row.simplifiedSettingsTag {
                dict[tag.rawValue] = (row as? ExpandableSwitchRow)?.isExpanded
            }
        }
        UserDefaults.standard.set(dict, forKey: kViewControllerState)
        
        let settingDict: [String: Any] = ["BarcodeFormat":format.rawValue]
        UserDefaults.standard.set(settingDict, forKey: kBarcodeFormatState)
        
    }
    
//    func loadState() -> [SettingRow]? {
////        if let rawValue = (UserDefaults.standard.object(forKey: "BarcodeFormat") as? NSNumber)?.uintValue {
////            format = BarcodeFormat(rawValue: rawValue)
////        }
//        guard let dictArray = UserDefaults.standard.array(forKey: kBarcodeFormatState) as? [[String: Any]] else {
//            return nil
//        }
//        return dictArray.compactMap { SettingRow.create(from: $0) }
//    }
}

extension BarcodeFormatSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        guard let row = section as? ExpandableSwitchRow, row.isExpanded, let children = section.children else { return 1 }
        return 1 + children.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        if indexPath.row == 0 {
            switch section.type {
            case .expandableSwitch:
                let expandableSwitchRow = section as! ExpandableSwitchRow
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandableSwitchCell", for: indexPath) as! ExpandableSwitchCell
                cell.backgroundColor = .customSectionColor
                cell.textLabel?.text = section.title
                cell.textLabel?.textColor = .white
                cell.expandedImageView.image = UIImage(named: expandableSwitchRow.isExpanded ? "arrow-circle-up" : "arrow-circle-down")
                cell.switchControl.isOn = expandableSwitchRow.isOn
                cell.switchChanged = { [weak self] isOn in
                    expandableSwitchRow.isOn = isOn
                    expandableSwitchRow.children?.forEach{ child in
                        if let selectedRow = child as? SelectableRow {
                            selectedRow.isSelected = isOn
                            if let barcodeFormat = selectedRow.barcodeFormat, let self = self {
                                self.format = selectedRow.isSelected ? BarcodeFormat(rawValue: self.format.rawValue | barcodeFormat.rawValue) : BarcodeFormat(rawValue: self.format.rawValue & ~barcodeFormat.rawValue)
                            }
                        }
                    }
                    self?.saveState()
                    tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
                }
                cell.indentationLevel = section.indentationLevel
                return cell
            case .chevronExpand, .textField, .jump, .select, .touchUp, .switchCell, .optionButton, .pick:
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
                case .select:
                    let selectRow = row as! SelectableRow
                    let cell = UITableViewCell()
                    cell.textLabel?.text = selectRow.title + (selectRow.isSelected ? "  ✓" : "")
                    cell.textLabel?.textColor = selectRow.isSelected ? .orange : .customCellTextColor
                    cell.backgroundColor = .customCellColor
                    cell.indentationLevel = selectRow.indentationLevel
                    return cell
                case .chevronExpand, .jump, .optionButton, .pick, .switchCell, .textField, .touchUp, .expandableSwitch:
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

extension BarcodeFormatSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = sections[indexPath.section]
        
        if indexPath.row == 0 {
            switch section.type {
            case .expandableSwitch:
                (section as? ExpandableSwitchRow)?.isExpanded.toggle()
                saveState()
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            case .optionButton, .pick, .select, .switchCell, .textField, .touchUp, .chevronExpand, .jump:
                break
            }
        } else {
            guard let children = section.children, indexPath.row - 1 < children.count,
                  let selectRow = children[indexPath.row - 1] as? SelectableRow, let row = section as? ExpandableSwitchRow else { return }
            selectRow.isSelected.toggle()
            if let barcodeFormat = selectRow.barcodeFormat {
                format = selectRow.isSelected ? BarcodeFormat(rawValue: format.rawValue | barcodeFormat.rawValue) : BarcodeFormat(rawValue: format.rawValue & ~barcodeFormat.rawValue)
            }
            row.isOn = children.allSatisfy { ($0 as? SelectableRow)?.isSelected == true }
            saveState()
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        }
    }
}
