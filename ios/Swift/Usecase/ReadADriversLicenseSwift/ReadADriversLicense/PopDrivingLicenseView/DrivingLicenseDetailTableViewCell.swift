//
//  DrivingLicenseTableViewCell.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2021/09/18.
//  Copyright © 2021 Dynamsoft. All rights reserved.
//

import UIKit

class DrivingLicenseDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var abbreviationLb: UILabel!
    @IBOutlet weak var descriptionLb: UILabel!
    
    static let identifier = String(describing: DrivingLicenseDetailTableViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state

    }
    
}
