/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftLicense

@main
class AppDelegate: UIResponder, UIApplicationDelegate, LicenseVerificationListener {
   
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 15.0,*) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 59.003 / 255.0, green: 61.9991 / 255.0, blue: 69.0028 / 255.0, alpha: 1)
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Initialize license.
        // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
        // You can also request a 30-day trial license via the Request a Trial License link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=github&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate:self)
        return true
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if(error != nil)
        {
            if let msg = error?.localizedDescription {
                print("Server license verify failed, error:\(msg)")
            }
        }
    }

}

