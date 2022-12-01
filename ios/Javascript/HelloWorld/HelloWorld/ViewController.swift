//
//  ViewController.swift
//
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var dce:DynamsoftCameraEnhancer! = nil
    var dceView:DCECameraView! = nil
    var barcodeReader:DynamsoftBarcodeReader! = nil
    
    var wkWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wkWebView = WKWebView(frame: self.view.frame)
        // pollute your WKUserContentController
        MainScanner().pollute(wkWebView!)
        self.view.addSubview(wkWebView!)
        
        let fileURL =  Bundle.main.url(forResource: "index", withExtension: "html" )
        wkWebView?.loadFileURL(fileURL!,allowingReadAccessTo:Bundle.main.bundleURL);
        
        // let url = URL(string: "https://example.com")
        // let request = URLRequest(url: url!)
        // wkWebView!.load(request)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

extension UIViewController {
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
}
