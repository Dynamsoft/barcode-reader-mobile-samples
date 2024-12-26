/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class BasicSwitchTableViewCell: UITableViewCell {

    var questionCompletion: QuestionCompletion?
    var switchChangedCompletion: SwitchChangedCompletion?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: kCellLeftMargin, y: 0, width: 0, height: kCellHeight))
        label.font = kFont_Regular(kCellTitleFontSize)
        label.textAlignment = .left
        return label
    }()
    
    lazy var questionButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: 100, y: (kCellHeight - 16) / 2.0, width: 16, height: 16))
        button.setImage(UIImage(named: "icon_question"), for: .normal)
        button.addTarget(self, action: #selector(clickQuestionButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var controlSwitch: UISwitch = {
        let controlSwitch = UISwitch.init()
        controlSwitch.left = kScreenWidth - kCellRightMargin - controlSwitch.width
        controlSwitch.top = (kCellHeight - controlSwitch.height) / 2.0
        controlSwitch.addTarget(self, action: #selector(controlSwitchChanged(_:)), for: .valueChanged)
        return controlSwitch
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
    
    private func setupUI() -> Void {
        self.selectionStyle = .none
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(questionButton)
        self.contentView.addSubview(controlSwitch)
        self.contentView.addSubview(separationLine)
    }

    @objc private func clickQuestionButton(_ button: UIButton) -> Void {
        self.questionCompletion?()
    }
    
    @objc private func controlSwitchChanged(_ controlSwitch: UISwitch) -> Void {
        self.switchChangedCompletion?(controlSwitch.isOn)
    }
    
    /// Update UI.
    func updateUI(with title: String, isOn: Bool) -> Void {
        self.titleLabel.text = title
        self.titleLabel.width = ToolsManager.shared.calculateWidth(with: title, font: self.titleLabel.font, componentHeight: self.titleLabel.height)
        self.questionButton.left = self.titleLabel.right + kCellMarginBetweenTextAndQuestion
        
        self.controlSwitch.isOn = isOn
    }
    
}
