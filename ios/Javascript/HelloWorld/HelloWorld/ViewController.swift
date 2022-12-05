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
        self.view.sendSubviewToBack(wkWebView!)
        
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
    static var current:UIViewController? {
        let delegate  = UIApplication.shared.delegate as? AppDelegate
        var current = delegate?.window?.rootViewController
        
        while (current?.presentedViewController != nil)  {
            current = current?.presentedViewController
        }
        
        if let tabbar = current as? UITabBarController , tabbar.selectedViewController != nil {
            current = tabbar.selectedViewController
        }
        
        while let navi = current as? UINavigationController , navi.topViewController != nil  {
            current = navi.topViewController
        }
        return current
    }

}
