//
//  ToolsManager.swift
//  GeneralSettingsSwift
//
//  Copyright © Dynamsoft. All rights reserved.
//

import UIKit

typealias AlertCompletion = () -> Void

class ToolsManager: NSObject {
    static let shared = ToolsManager()
    
    func calculateWidth(with text: String, font: UIFont, componentHeight: CGFloat) -> CGFloat {
        guard text.count != 0 else {
            return 0.0
        }
        let dic = [NSAttributedString.Key.font: font]
        let frame = (text as NSString).boundingRect(with:  CGSize(width: 10000, height: componentHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: dic, context: nil)
        return frame.size.width
    }
    
    func calculateHeight(with text: String, font: UIFont, componentWidth: CGFloat) -> CGFloat {
        guard text.count != 0 else {
            return 0.0
        }
        let dic = [NSAttributedString.Key.font: font]
        let frame = (text as NSString).boundingRect(with: CGSize(width: componentWidth, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: dic, context: nil)
        return frame.size.height
    }
    
    /// Add alert.
    func addAlertView(to target: UIViewController,
                      title: String = "",
                      content: String,
                      actionTitle: String = "OK",
                      completion: AlertCompletion?) -> Void {
        let alertVC = UIAlertController.init(title: title, message: content, preferredStyle: .alert)
        let action = UIAlertAction.init(title: actionTitle, style: .default) { action in
            completion?()
        }
        alertVC.addAction(action)
        target.present(alertVC, animated: true)
    }
}
