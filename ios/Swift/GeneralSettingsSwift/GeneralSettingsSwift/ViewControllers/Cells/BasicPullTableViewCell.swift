//
//  BasicPullTableViewCell.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class BasicPullTableViewCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRectMake(kCellLeftMargin, 0, 0, kCellHeight))
        label.font = kFont_Regular(kCellTitleFontSize)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var pullImageV: UIImageView = {
        let image = UIImageView.init(frame: CGRectMake(kScreenWidth - kCellRightMargin - 16, (kCellHeight - 16) / 2.0, 16, 16))
        image.image = UIImage(named: "select_down")
        return image
    }()
    
    private lazy var pullTextLabel: UILabel = {
        let label = UILabel.init(frame: CGRectMake(self.pullImageV.left - 150, (kCellHeight - 20) / 2.0, 150, 20))
        label.font = kFont_Regular(kCellPullTextFontSize)
        label.textAlignment = .right
        return label
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
        self.contentView.addSubview(pullImageV)
        self.contentView.addSubview(pullTextLabel)
        self.contentView.addSubview(separationLine)
    }
    
    /// Update UI.
    func updateUI(with title: String, content: String) -> Void {
        self.titleLabel.text = title
        self.titleLabel.width = ToolsManager.shared.calculateWidth(with: title, font: self.titleLabel.font, componentHeight: self.titleLabel.height)
        self.pullTextLabel.text = content
    }
}
