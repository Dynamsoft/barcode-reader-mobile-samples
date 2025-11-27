/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

let maxFramesKey = "maxFrames"
let scanRegionKey = "scanRegion"
let colourModeKey = "colourMode"

class SettingsViewController: UIViewController {
    
    private let numberTextField = UITextField()
    private var scanRegionButtons: [UIButton] = []
    private var colourModeButtons: [UIButton] = []
    private var defaultValue: String = "10"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Settings"

        setupUI()
        loadSavedSettings()
        addDoneButtonToKeyboard()
    }

    private func setupUI() {
        numberTextField.backgroundColor = .black
        numberTextField.textColor = .white
        numberTextField.textAlignment = .center
        numberTextField.keyboardType = .numberPad
        numberTextField.layer.borderColor = UIColor.white.cgColor
        numberTextField.layer.borderWidth = 1.0
        numberTextField.placeholder = "1-999"
        numberTextField.text = defaultValue
        numberTextField.translatesAutoresizingMaskIntoConstraints = false
        numberTextField.addTarget(self, action: #selector(maxFramesChanged), for: .editingChanged)
        numberTextField.delegate = self

        let maxFramesLabel = createFramesLabel(text: "Max captured frames count")
        
        let frameStackView = UIStackView(arrangedSubviews: [maxFramesLabel, numberTextField])
        frameStackView.axis = .horizontal
        frameStackView.spacing = 10

        let scanRegionLabel = createLabel(text: "Scan region")
        let scanRegions = ["Full Image", "Square", "Rectangular"]
        scanRegionButtons = createRadioButtons(titles: scanRegions, action: #selector(scanRegionButtonTapped))

        let colourModeLabel = createLabel(text: "Image colour mode")
        let colourModes = ["Colour", "Grayscale", "Binary"]
        colourModeButtons = createRadioButtons(titles: colourModes, action: #selector(colourModeButtonTapped))

        let stackView = UIStackView(arrangedSubviews: [
            frameStackView,
            scanRegionLabel, createButtonStackView(scanRegionButtons),
            colourModeLabel, createButtonStackView(colourModeButtons)
        ])
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let backView = UIView()
        backView.backgroundColor = UIColor(red: 29/255.0, green: 29/255.0, blue: 29/255.0, alpha: 1.0)
        backView.addSubview(stackView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -20),
            
            backView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            backView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }

    private func loadSavedSettings() {
        if let savedFrames = UserDefaults.standard.value(forKey: maxFramesKey) as? Int {
            numberTextField.text = "\(savedFrames)"
        }

        if let savedScanRegionIndex = UserDefaults.standard.value(forKey: scanRegionKey) as? Int {
            if savedScanRegionIndex < scanRegionButtons.count {
                scanRegionButtons.forEach { $0.isSelected = false }
                scanRegionButtons[savedScanRegionIndex].isSelected = true
                updateButtonAppearance(scanRegionButtons)
            }
        } else {
            scanRegionButtons[0].isSelected = true
            updateButtonAppearance(scanRegionButtons)
        }

        if let savedColourModeIndex = UserDefaults.standard.value(forKey: colourModeKey) as? Int {
            if savedColourModeIndex < colourModeButtons.count {
                colourModeButtons.forEach { $0.isSelected = false }
                colourModeButtons[savedColourModeIndex].isSelected = true
                updateButtonAppearance(colourModeButtons)
            }
        } else {
            colourModeButtons[1].isSelected = true
            updateButtonAppearance(colourModeButtons)
        }
    }
    
    private func addDoneButtonToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        numberTextField.inputAccessoryView = toolbar
    }
}

// MARK: - PrivateFunc
extension SettingsViewController {
    
    private func createFramesLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .gray
        label.font = .systemFont(ofSize: 13)
        return label
    }

    private func createRadioButtons(titles: [String], action: Selector) -> [UIButton] {
        return titles.map { title in
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.gray, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.backgroundColor = .darkGray
            button.addTarget(self, action: action, for: .touchUpInside)
            return button
        }
    }

    private func createButtonStackView(_ buttons: [UIButton]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .darkGray
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true
        return stackView
    }

    private func updateButtonAppearance(_ buttons: [UIButton]) {
        buttons.forEach { button in
            button.backgroundColor = button.isSelected ? .lightGray : .darkGray
            button.layer.cornerRadius = button.isSelected ? 8 : 0
            button.clipsToBounds = button.isSelected ? true : false
        }
    }
}

// MARK: - Selector
extension SettingsViewController {
    
    @objc private func maxFramesChanged() {
        if let text = numberTextField.text, let value = Int(text) {
            UserDefaults.standard.set(value, forKey: maxFramesKey)
        }
    }

    @objc private func scanRegionButtonTapped(_ sender: UIButton) {
        scanRegionButtons.forEach { $0.isSelected = false }
        sender.isSelected = true
        updateButtonAppearance(scanRegionButtons)

        if let index = scanRegionButtons.firstIndex(of: sender) {
            UserDefaults.standard.set(index, forKey: scanRegionKey)
        }
    }

    @objc private func colourModeButtonTapped(_ sender: UIButton) {
        colourModeButtons.forEach { $0.isSelected = false }
        sender.isSelected = true
        updateButtonAppearance(colourModeButtons)

        if let index = colourModeButtons.firstIndex(of: sender) {
            UserDefaults.standard.set(index, forKey: colourModeKey)
        }
    }
    
    @objc private func doneButtonTapped() {
        numberTextField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text, let value = Int(text), value >= 1 && value <= 999 {
            return true
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if let intValue = Int(currentText), intValue >= 1 && intValue <= 999 {
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return string.isEmpty
    }
}
