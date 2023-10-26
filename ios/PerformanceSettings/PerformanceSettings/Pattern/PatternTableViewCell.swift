/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class PatternTableViewCell: UITableViewCell {

    var questionCompletion: QuestionCompletion?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: kCellLeftMargin, y: 0, width: self.width, height: kCellHeight))
        label.font = kFont_Regular(kCellTitleFontSize)
        label.textAlignment = .left
        return label
    }()
    
    lazy var questionButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: kCellWidth - 16 - kCellRightMargin, y: (kCellHeight - 16) / 2.0, width: 16, height: 16))
        button.setImage(UIImage(named: "icon_question"), for: .normal)
        button.addTarget(self, action: #selector(questionSelectedAction(_:)), for: .touchUpInside)
        return button
    }()
    
    static func cellHeight() -> CGFloat {
        return kCellHeight
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() -> Void {
        self.backgroundColor = .clear
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(questionButton)
    }
    
    
    @objc private func questionSelectedAction(_ button: UIButton) -> Void {
        self.questionCompletion?()
    }
    
    func updateUI(with title: String, isSelected: Bool) -> Void {
        self.titleLabel.text = title
        self.contentView.backgroundColor = isSelected == true ? kPatternSelectedColor : kPatternUnselectedColor
    }

}
