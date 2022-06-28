//
//  SettingsCommon.swift
//  GeneralSettingsSwift
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
    
    static func getTextField(cell:UITableViewCell, rightMargin: CGFloat, delegate:UITextFieldDelegate) -> UITextField
    {
        let textField = UITextField(frame: SettingsCommon.GetFrameInCell(cell: cell, isAlignLeft: false, margin: rightMargin, size: CGSize(width: 120, height: 40)))
        textField.backgroundColor = UIColor.clear
        textField.textColor = UIColor(red: 153.003/255.0, green: 153.003/255.0, blue: 153.003/255.0, alpha: 1)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textAlignment = .right
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.delegate = delegate
        cell.contentView.addSubview(textField)
        return textField
    }
    
    static func getCheckBox(cell:UITableViewCell,rightMargin: CGFloat) ->UIButton
    {
        let bx = UIButton(frame: SettingsCommon.GetFrameInCell(cell: cell, isAlignLeft: false, margin: rightMargin, size: CGSize(width: 16, height: 16)))
        bx.backgroundColor = UIColor.clear
        let img = UIImage(named: "check")
        bx.setImage(img, for: .selected)
        bx.isUserInteractionEnabled = false
        cell.contentView.addSubview(bx)
        return bx
    }
    
    static func addSelectDownImageView(cell:UITableViewCell, rightMargin:CGFloat)
    {
        let imageview = UIImageView(frame: SettingsCommon.GetFrameInCell(cell: cell, isAlignLeft: false, margin: rightMargin, size: CGSize(width: 18, height: 18)))
        imageview.backgroundColor = UIColor.clear
        imageview.image = UIImage(named: "select_down")
        cell.contentView.addSubview(imageview)
    }
    
    static func getSwitch(cell:UITableViewCell, rightMargin:CGFloat) -> UISwitch
    {
        let swtch = UISwitch(frame: SettingsCommon.GetFrameInCell(cell: cell, isAlignLeft: false, margin: rightMargin, size: CGSize(width: 52, height: 32)))
        cell.contentView.addSubview(swtch)
        return swtch
    }
}
