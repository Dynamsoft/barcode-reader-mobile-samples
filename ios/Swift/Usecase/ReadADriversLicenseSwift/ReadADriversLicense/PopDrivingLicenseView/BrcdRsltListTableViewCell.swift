//
//  BrcdRsltListTableViewCell.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2021/09/18.
//  Copyright © 2021 Dynamsoft. All rights reserved.
//

import UIKit

class BrcdRsltListTableViewCell: UITableViewCell {

    //public:
    @IBOutlet weak var cellNum: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    
    
    static let identifier = String(describing: BrcdRsltListTableViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .default
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFormatLabel(text:String)
    {
        let priceString = NSMutableAttributedString.init(string: text)
        self.formatLabel.text = ""
        priceString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSNumber.init(value: 1), range: NSRange(location: 0, length: priceString.length))
        self.formatLabel.attributedText = priceString
    }
}
