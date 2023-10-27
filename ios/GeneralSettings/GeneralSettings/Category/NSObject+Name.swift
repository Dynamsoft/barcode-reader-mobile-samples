
import Foundation

extension NSObject {
    static var className: String {
        get {
            return NSStringFromClass(self).components(separatedBy: CharacterSet(charactersIn: ".")).first ?? ""
        }
        
    }
}
