//
//  SettingsCommon.swift
//  PerformanceSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

class SettingsCommon: NSObject {

    //align:true-left,false-right
    static func GetFrameInCell(cell:UITableViewCell, isAlignLeft:Bool, margin:CGFloat,size:CGSize)->CGRect
    {
        if(isAlignLeft)
        {//left
            return CGRect(x: margin, y: cell.contentView.center.y - size.height / 2, width: size.width, height: size.height)
        }
        else
        {//right
            return CGRect(x: cell.contentView.bounds.width - margin - size.width, y: cell.contentView.center.y - size.height / 2, width: size.width, height: size.height)
        }
    }
    
    static func getQuestionBtn(cell:UITableViewCell,leftMargin:CGFloat) -> UIButton
    {
        let btn = UIButton(frame: SettingsCommon.GetFrameInCell(cell: cell, isAlignLeft: true, margin: leftMargin, size: CGSize(width: 32, height: 32)))
        btn.backgroundColor = UIColor.clear
        let img = UIImage(named: "icon_question")
        btn.setImage(img, for: .normal)
        cell.contentView.addSubview(btn)
        return btn
    }
}
