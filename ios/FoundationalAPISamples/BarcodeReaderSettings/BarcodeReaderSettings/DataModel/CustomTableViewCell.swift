/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

let IndentConstant = 16.0
let IntervalConstant = 10.0

class SwitchCell: UITableViewCell {
    let switchControl = UISwitch()
    var switchChanged: ((Bool) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switchControl)
        NSLayoutConstraint.activate([
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -IndentConstant),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    @objc func switchValueChanged() {
        switchChanged?(switchControl.isOn)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class ExpandableSwitchCell: UITableViewCell {
    let switchControl = UISwitch()
    var switchChanged: ((Bool) -> Void)?
    let expandedImageView = UIImageView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switchControl)
        NSLayoutConstraint.activate([
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -IndentConstant),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        expandedImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(expandedImageView)
        NSLayoutConstraint.activate([
            expandedImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            expandedImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            expandedImageView.widthAnchor.constraint(equalToConstant: 20),
            expandedImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    @objc func switchValueChanged() {
        switchChanged?(switchControl.isOn)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

enum TextFieldInputType: Int {
    case numeric
    case normal
}

class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    let textField = UITextField()
    var textChanged: ((String) -> Void)?
    var minValue = 0
    var maxValue = Int.max
    var inputType: TextFieldInputType = .numeric {
        didSet {
            updateKeyboardType()
            textField.inputAccessoryView = (inputType == .numeric) ? accessoryToolbar : nil
        }
    }
    
    private lazy var accessoryToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([space, doneButton], animated: false)
        toolbar.updateConstraintsIfNeeded()
        return toolbar
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -IndentConstant),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
        ])
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.returnKeyType = .done
        textField.textAlignment = .center
        textField.clearsOnBeginEditing = true
        
        updateKeyboardType()
        textField.inputAccessoryView = (inputType == .numeric) ? accessoryToolbar : nil
    }
    
    private func updateKeyboardType() {
        switch inputType {
        case .numeric:
            textField.keyboardType = .numberPad
        case .normal:
            textField.keyboardType = .default
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        textChanged?(textField.text ?? "")
        activeTextField = nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if inputType == .numeric {
            if let text = textField.text, let value = Int(text), value >= minValue && value <= maxValue {
                return true
            }
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if inputType == .numeric {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            if Int(currentText) != nil {
                return allowedCharacters.isSuperset(of: characterSet)
            }
            return string.isEmpty
        }
        return true
    }
    
    @objc private func doneButtonTapped() {
        textField.resignFirstResponder()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


class OptionButtonCell: UITableViewCell {
    let stackView = UIStackView()
    let titleLabel = UILabel()
    let buttonStackView = UIStackView()
    var buttons: [UIButton] = []
    var selectionChanged: ((Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.textColor = .gray
        titleLabel.font = .systemFont(ofSize: 13)
        
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 0
        buttonStackView.distribution = .fillEqually
        buttonStackView.backgroundColor = .darkGray
        buttonStackView.layer.cornerRadius = 8
        buttonStackView.clipsToBounds = true
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(buttonStackView)
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: IndentConstant + IntervalConstant),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -IndentConstant),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: IndentConstant/2),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -IndentConstant/2)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with title:String, options: [String], selectedIndex: Int?) {
        buttons.forEach { $0.removeFromSuperview() }
        buttons = []
        titleLabel.text = title
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            button.setTitleColor(.gray, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.backgroundColor = .darkGray
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
            buttons.append(button)
        }
        if let selectedIndex = selectedIndex, selectedIndex >= 0, selectedIndex < buttons.count {
            buttons[selectedIndex].isSelected = true
            updateButtonAppearance(buttons)
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        buttons.forEach { $0.isSelected = false }
        sender.isSelected = true
        updateButtonAppearance(buttons)
        selectionChanged?(sender.tag)
    }
    
    private func updateButtonAppearance(_ buttons: [UIButton]) {
        buttons.forEach { button in
            button.backgroundColor = button.isSelected ? .lightGray : .darkGray
            button.layer.cornerRadius = button.isSelected ? 8 : 0
            button.clipsToBounds = button.isSelected ? true : false
        }
    }
}
