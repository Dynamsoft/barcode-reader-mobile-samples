//
//  UIView+Frame.swift
//  SakuraPanoramaDemo
//
//  Copyright © Dynamsoft. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var width : CGFloat {
        get {self.frame.size.width}
        set {
            var newFrame = self.frame
            newFrame.size.width = newValue
            self.frame = newFrame
        }
    }
    
    var height : CGFloat {
        get {self.frame.size.height}
        set {
            var newFrame = self.frame
            newFrame.size.height = newValue
            self.frame = newFrame
        }
    }
    
    var top : CGFloat {
        get {self.frame.origin.y}
        set {
            var newFrame = self.frame
            newFrame.origin.y = newValue
            self.frame = newFrame
        }
    }
    
    var left : CGFloat {
        get {self.frame.origin.x}
        set {
            var newFrame = self.frame
            newFrame.origin.x = newValue
            self.frame = newFrame
        }
    }
    
    var bottom : CGFloat {
        get {self.frame.origin.y + self.frame.size.height}
        set {
            var newFrame = self.frame
            newFrame.origin.y = newValue - self.frame.size.height
            self.frame = newFrame
        }
    }
    
    var right : CGFloat {
        get {self.frame.origin.x + self.frame.size.width}
        set {
            var newFrame = self.frame
            newFrame.origin.x = newValue - self.frame.size.width
            self.frame = newFrame
        }
    }
    
}
