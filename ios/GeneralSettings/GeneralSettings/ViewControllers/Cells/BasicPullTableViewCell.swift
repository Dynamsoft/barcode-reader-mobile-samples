/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit

class BasicPullTableViewCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame:  CGRect(x: kCellLeftMargin, y: 0, width: 0, height: kCellHeight))
        label.font = kFont_Regular(kCellTitleFontSize)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var pullImageV: UIImageView = {
        let image = UIImageView.init(frame: CGRect(x: kScreenWidth - kCellRightMargin - 16, y: (kCellHeight - 16) / 2.0, width: 16, height: 16))
        image.image = UIImage(named: "select_down")
        return image
    }()
    
    private lazy var pullTextLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: self.pullImageV.left - 150, y: (kCellHeight - 20) / 2.0, width: 150, height: 20))
        label.font = kFont_Regular(kCellPullTextFontSize)
        label.textAlignment = .right
        return label
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
