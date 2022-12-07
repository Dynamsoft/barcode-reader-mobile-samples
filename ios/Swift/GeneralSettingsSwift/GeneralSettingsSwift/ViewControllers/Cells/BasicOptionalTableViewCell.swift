//
//  BasicOptionalTableViewCell.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class BasicOptionalTableViewCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRectMake(kCellLeftMargin, 0, 0, kCellHeight))
        label.font = kFont_Regular(kCellTitleFontSize)
        label.textAlignment = .left
        return label
    }()
    
    
    lazy var optionalStateImageV: UIImageView = {
        let imageV = UIImageView.init(frame: CGRectMake(kScreenWidth - kCellRightMargin - 16, (kCellHeight - 16) / 2.0, 16, 16))
        imageV.image = UIImage(named: "checked")
        return imageV
    }()
    
    private lazy var separationLine: UIView = {
        let separationLine = UIView.init(frame: CGRectMake(0, kCellHeight - KCellSeparationLineHeight, kScreenWidth, KCellSeparationLineHeight))
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
        self.contentView.addSubview(optionalStateImageV)
        self.contentView.addSubview(separationLine)
    }
    
    func updateUI(with title: String, optionState: Bool) -> Void {
        self.titleLabel.text = title
        self.titleLabel.width = ToolsManager.shared.calculateWidth(with: title, font: self.titleLabel.font, componentHeight: self.titleLabel.height)
        self.optionalStateImageV.isHidden = !optionState
    }
}
