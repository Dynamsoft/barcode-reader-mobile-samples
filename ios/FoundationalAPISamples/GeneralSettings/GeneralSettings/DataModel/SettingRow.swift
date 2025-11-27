/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import DynamsoftCaptureVisionBundle

enum RowType: Int {
    case chevronExpand = 0
    case select = 1
    case touchUp = 2
    case switchCell = 3
    case textField = 4
    case jump = 5
    case optionButton = 6
    case pick = 7
    case expandableSwitch = 8
}

enum SimplifiedSettingsTag: String {
    case expectedBarcodeCount
    case confidence
    case scaleDownThreshold
    case barcodeTextRegEx
    case minTextLength
    case timeout
    case minDecodeInterval
    case localization
    case deblur
    case transformation
    case enhancement
    
    case oneDBarcodes
    case twoDBarcodes
    case pharmaBarcodes
    case otherBarcodes
    
    case speedFirst
    case readRateFirst
    case importSetting
    case exportSetting
    
    case multiFrameCrossVerification
    case resultDeduplication
    case duplicateForgetTime
    case toTheLatestOverlapping
    case maxOverlappingFrameCount
    case beep
    case vibrate
    case scanRegion
    case resolution
    case autoZoom
}

class SettingRow {
    var title: String
    var indentationLevel: Int
    let type: RowType
    var children:[SettingRow]?
    var simplifiedSettingsTag: SimplifiedSettingsTag?
    init(title: String, indentationLevel: Int, type: RowType, children: [SettingRow]? = nil, simplifiedSettingsTag: SimplifiedSettingsTag? = nil) {
        self.title = title
        self.indentationLevel = indentationLevel
        self.type = type
        self.children = children
        self.simplifiedSettingsTag = simplifiedSettingsTag
    }
}

class ExpandableRow: SettingRow {
    var isExpanded: Bool = false
    init(title: String, indentationLevel: Int, isExpanded: Bool = false, children: [SettingRow]? = nil, simplifiedSettingsTag: SimplifiedSettingsTag? = nil) {
        self.isExpanded = isExpanded
        super.init(title: title, indentationLevel: indentationLevel, type: .chevronExpand, children: children, simplifiedSettingsTag: simplifiedSettingsTag)
    }
}

class SelectableRow: SettingRow {
    var isSelected: Bool = false
    var barcodeFormat: BarcodeFormat?
    init(title: String, indentationLevel: Int, isSelected: Bool = false, children: [SettingRow]? = nil, barcodeFormat: BarcodeFormat? = nil, simplifiedSettingsTag: SimplifiedSettingsTag? = nil) {
        self.isSelected = isSelected
        self.barcodeFormat = barcodeFormat
        super.init(title: title, indentationLevel: indentationLevel, type: .select, children: children, simplifiedSettingsTag: simplifiedSettingsTag)
    }
}

class TouchUpRow: SettingRow {
    var isTouchUped: Bool
    init(title: String, indentationLevel: Int, isTouchUped: Bool = false, children: [SettingRow]? = nil, simplifiedSettingsTag: SimplifiedSettingsTag? = nil) {
        self.isTouchUped = isTouchUped
        super.init(title: title, indentationLevel: indentationLevel, type: .touchUp, children: children, simplifiedSettingsTag: simplifiedSettingsTag)
    }
}

class JumpRow: SettingRow {
    init(title: String, indentationLevel: Int, children: [SettingRow]? = nil) {
        super.init(title: title, indentationLevel: indentationLevel, type: .jump, children: children)
    }
}

class SwitchRow: SettingRow {
    var isOn: Bool = false
    init(title: String, indentationLevel: Int, isOn: Bool = false, children: [SettingRow]? = nil, simplifiedSettingsTag: SimplifiedSettingsTag? = nil) {
        super.init(title: title, indentationLevel: indentationLevel, type: .switchCell, children: children, simplifiedSettingsTag: simplifiedSettingsTag)
        self.isOn = isOn
    }
}

class TextFieldRow: SettingRow {
    var text: String
    var inputType: TextFieldInputType
    init(title: String, indentationLevel: Int, text: String, children: [SettingRow]? = nil, inputType: TextFieldInputType = .numeric, simplifiedSettingsTag: SimplifiedSettingsTag? = nil) {
        self.text = text
        self.inputType = inputType
        super.init(title: title, indentationLevel: indentationLevel, type: .textField, children: children, simplifiedSettingsTag: simplifiedSettingsTag)
    }
}

class OptionButtonRow: SettingRow {
    var options: [String]
    var selectedIndex: Int
    init(title: String, indentationLevel: Int, options: [String], selectedIndex: Int, children: [SettingRow]? = nil, simplifiedSettingsTag: SimplifiedSettingsTag? = nil) {
        self.options = options
        self.selectedIndex = selectedIndex
        super.init(title: title, indentationLevel: indentationLevel, type: .optionButton, children: children, simplifiedSettingsTag: simplifiedSettingsTag)
    }
}

class PickRow: SettingRow {
    var options: [String]
    var selectedIndex: Int
    init(title: String, indentationLevel: Int, options: [String], selectedIndex: Int, children: [SettingRow]? = nil) {
        self.options = options
        self.selectedIndex = selectedIndex
        super.init(title: title, indentationLevel: indentationLevel, type: .pick, children: children)
    }
    
    init(indentationLevel: Int, options: [String], selectedIndex: Int, children: [SettingRow]? = nil) {
        self.options = options
        self.selectedIndex = selectedIndex
        super.init(title: options[selectedIndex], indentationLevel: indentationLevel, type: .pick, children: children)
    }
}

class ExpandableSwitchRow: SettingRow {
    var isExpanded: Bool = false
    var isOn: Bool = false
    init(title: String, indentationLevel: Int, isExpanded: Bool = false, isOn: Bool = false, children: [SettingRow]? = nil) {
        self.isExpanded = isExpanded
        self.isOn = isOn
        super.init(title: title, indentationLevel: indentationLevel, type: .expandableSwitch, children: children)
    }
}

class SettingSection {
    var title: String
    var rows: [SettingRow]
    
    var isExpanded: Bool = false
    
    init(title: String, rows: [SettingRow] = []) {
        self.title = title
        self.rows = rows
    }
    
    var visibleRows: [SettingRow] {
        guard self.isExpanded else { return [] }
        var rows: [SettingRow] = []
        for row in self.rows {
            rows.append(row)
            if let children = row.children {
                switch row.type {
                case .chevronExpand:
                    if let parent = row as? ExpandableRow, parent.isExpanded {
                        rows.append(contentsOf: children)
                    }
                case .switchCell:
                    if let parent = row as? SwitchRow, parent.isOn {
                        rows.append(contentsOf: children)
                    }
                case .expandableSwitch:
                    if let parent = row as? ExpandableSwitchRow, parent.isExpanded {
                        rows.append(contentsOf: children)
                    }
                case .select, .touchUp, .textField, .jump, .optionButton, .pick: break
                    
                }
            }
        }
        return rows
    }

}

extension SettingSection {
    
    func persist() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["title"] = self.title
        dict["isExpanded"] = self.isExpanded
        
        dict["rows"] = self.rows.map { $0.persist() }
        return dict
    }
    
    convenience init?(dict: [String: Any]) {
        guard let title = dict["title"] as? String,
              let rowsArray = dict["rows"] as? [[String: Any]] else { return nil }
        self.init(title: title)
        self.isExpanded = dict["isExpanded"] as? Bool ?? false
        self.rows = rowsArray.compactMap { SettingRow.create(from: $0) }
    }
}

extension SettingRow {
    
    func persist() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["title"] = self.title
        dict["indentationLevel"] = self.indentationLevel
        dict["type"] = self.type.rawValue
        
        switch self.type {
        case .chevronExpand:
            if let row = self as? ExpandableRow {
                dict["isExpanded"] = row.isExpanded
            }
        case .select:
            if let row = self as? SelectableRow {
                dict["isSelected"] = row.isSelected
                if let barcodeFormat = row.barcodeFormat {
                    dict["barcodeFormat"] = barcodeFormat.rawValue
                }
            }
        case .touchUp:
            if let row = self as? TouchUpRow {
                dict["isTouchUped"] = row.isTouchUped
            }
        case .switchCell:
            if let row = self as? SwitchRow {
                dict["isOn"] = row.isOn
            }
        case .textField:
            if let row = self as? TextFieldRow {
                dict["text"] = row.text
                dict["inputType"] = row.inputType.rawValue
            }
        case .optionButton:
            if let row = self as? OptionButtonRow {
                dict["options"] = row.options
                dict["selectedIndex"] = row.selectedIndex
            }
        case .pick:
            if let row = self as? PickRow {
                dict["options"] = row.options
                dict["selectedIndex"] = row.selectedIndex
            }
        case .jump:
            break
        case .expandableSwitch:
            if let row = self as? ExpandableSwitchRow {
                dict["isExpanded"] = row.isExpanded
                dict["isOn"] = row.isOn
            }
        }
        
        if let children = self.children {
            dict["children"] = children.map { $0.persist() }
        }
        if let tag = simplifiedSettingsTag {
            dict["simplifiedSettingsTag"] = tag.rawValue
        }
        return dict
    }
    
    static func create(from dict: [String: Any]) -> SettingRow? {
        guard let title = dict["title"] as? String,
              let indentationLevel = dict["indentationLevel"] as? Int,
              let typeRaw = dict["type"] as? Int,
              let type = RowType(rawValue: typeRaw) else { return nil }
        
        var row: SettingRow
        
        switch type {
        case .chevronExpand:
            let isExpanded = dict["isExpanded"] as? Bool ?? false
            row = ExpandableRow(title: title, indentationLevel: indentationLevel, isExpanded: isExpanded)
        case .select:
            let isSelected = dict["isSelected"] as? Bool ?? false
            let selectableRow = SelectableRow(title: title, indentationLevel: indentationLevel, isSelected: isSelected)
            if let rawValue = dict["barcodeFormat"] as? UInt {
                selectableRow.barcodeFormat = BarcodeFormat(rawValue: rawValue)
            }
            row = selectableRow
        case .touchUp:
            let isTouchUped = dict["isTouchUped"] as? Bool ?? false
            row = TouchUpRow(title: title, indentationLevel: indentationLevel, isTouchUped: isTouchUped)
        case .switchCell:
            let isOn = dict["isOn"] as? Bool ?? false
            row = SwitchRow(title: title, indentationLevel: indentationLevel, isOn: isOn)
        case .textField:
            let text = dict["text"] as? String ?? ""
            let inputTypeRaw = dict["inputType"] as? Int ?? 0
            let inputType = TextFieldInputType(rawValue: inputTypeRaw) ?? .numeric
            row = TextFieldRow(title: title, indentationLevel: indentationLevel, text: text, inputType: inputType)
        case .jump:
            row = JumpRow(title: title, indentationLevel: indentationLevel)
        case .optionButton:
            let options = dict["options"] as? [String] ?? []
            let selectedIndex = dict["selectedIndex"] as? Int ?? 0
            row = OptionButtonRow(title: title, indentationLevel: indentationLevel, options: options, selectedIndex: selectedIndex)
        case .pick:
            let options = dict["options"] as? [String] ?? []
            let selectedIndex = dict["selectedIndex"] as? Int ?? 0
            row = PickRow(title: title, indentationLevel: indentationLevel, options: options, selectedIndex: selectedIndex)
        case .expandableSwitch:
            let isExpanded = dict["isExpanded"] as? Bool ?? false
            let isOn = dict["isOn"] as? Bool ?? false
            row = ExpandableSwitchRow(title: title, indentationLevel: indentationLevel, isExpanded: isExpanded, isOn: isOn)
        }
        
        if let childrenArray = dict["children"] as? [[String: Any]] {
            row.children = childrenArray.compactMap { SettingRow.create(from: $0) }
        }
        if let tag = dict["simplifiedSettingsTag"] as? String {
            row.simplifiedSettingsTag = SimplifiedSettingsTag(rawValue: tag)
        }
        return row
    }
}
