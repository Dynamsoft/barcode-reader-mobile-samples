//
//  BasicTextTableViewCell.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class BasicTextTableViewCell: UITableViewCell, UITextFieldDelegate {

    var questionCompletion: QuestionCompletion?
    var inputTFValueChangedCompletion: InputTFValueChangedCompletion?
    
    var titleOffset: CGFloat {
        get {self.titleLabel.left}
        set {
            self.titleLabel.left = kCellLeftMargin + newValue
        }
    }
    
    var defaultValue: Int = 0
    
    var questionButtonIsHidden: Bool {
        get{self.questionButton.isHidden}
        set {
            self.questionButton.isHidden = newValue
        }
    }
    
    var saveMaxNum = 0
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: kCellLeftMargin, y: 0, width: 0, height: kCellHeight))
        label.font = kFont_Regular(kCellTitleFontSize)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var questionButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: 100, y: (kCellHeight - 16) / 2.0, width: 16, height: 16))
        button.setImage(UIImage(named: "icon_question"), for: .normal)
        button.addTarget(self, action: #selector(clickQuestionButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var inputCountTF: UITextField = {
        let textField = UITextField.init(frame: CGRect(x: kScreenWidth - kCellRightMargin - 70, y: (kCellHeight - 20) / 2.0, width: 70, height: 20))
        textField.tintColor = kCellInputTFTextColor
        textField.textColor = kCellInputTFTextColor
        textField.font = kFont_Regular(kCellInputCountFontSize)
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.clearsOnBeginEditing = true
        textField.inputAccessoryView = self.inputCountTFAccessoryView
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var inputCountTFAccessoryView: UIView = {
        let accessoryView = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        accessoryView.backgroundColor = UIColor.init(red: 216.0 / 255.0, green: 216.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0)
        let btn = UIButton.init(frame: CGRect(x: kScreenWidth - 55, y: 5, width: 40, height: 28))
        btn.setTitle("Done", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = kFont_Regular(16)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(doneButtonClicked(_:)), for: .touchUpInside)
        accessoryView.addSubview(btn)
        return accessoryView
    }()
    
    private lazy var separationLine: UIView = {
        let separationLine = UIView.init(frame: CGRect(x: 0, y: kCellHeight - KCellSeparationLineHeight, width: kScreenWidth, height: KCellSeparationLineHeight))
        separationLine.backgroundColor = kCellSeparationLineBackgroundColor
        return separationLine
    }()
    
    static func cellHeight() -> CGFloat {
        return kCellHeight
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() -> Void {
        self.selectionStyle = .none
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(questionButton)
        self.contentView.addSubview(inputCountTF)
        self.contentView.addSubview(separationLine)
    }
    
    @objc private func clickQuestionButton(_ button: UIButton) -> Void {
        self.questionCompletion?()
    }
    
    @objc private func doneButtonClicked(_ button: UIButton) -> Void {
        self.inputCountTF.resignFirstResponder()
        if self.inputCountTF.text?.count == 0 {
            self.inputCountTF.text = String(format: "%ld", self.defaultValue)
        }

        self.inputTFValueChangedCompletion?(Int(self.inputCountTF.text!)!)
    }
    
    /// Update UI.
    func updateUI(with title: String, valueNum: Int) -> Void {
        self.titleLabel.text = title
        self.titleLabel.width = ToolsManager.shared.calculateWidth(with: title, font: self.titleLabel.font, componentHeight: self.titleLabel.height)
        self.questionButton.left = self.titleLabel.right + kCellMarginBetweenTextAndQuestion
        self.inputCountTF.text = String(format: "%ld", valueNum)
    }
    
    /// Setting the maxvalue of the inputCountTF.
    func setInputCountTFMaxValue(with maxValue: Int) -> Void {
        self.titleOffset = 0.0
        self.questionButtonIsHidden = false
        self.saveMaxNum = maxValue
    }

    // MARK: - UITextFieldDeleagte
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.inputCountTF.text?.count == 0 {
            self.inputCountTF.text = String(format: "%ld", self.defaultValue)
        }

        self.inputTFValueChangedCompletion?(Int(self.inputCountTF.text!)!)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) -> Void {
        let numValue = Int(textField.text!) ?? 0
        if numValue > self.saveMaxNum {
            guard let textStr = textField.text else {
                return
            }
            textField.text = String(textStr.dropLast(1))
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    
}
