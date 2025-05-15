
import Foundation
import UIKit

let kScreenWidth = UIScreen.main.bounds.size.width

let kScreenHeight = UIScreen.main.bounds.size.height

let kNavigationBarFullHeight = UIDevice.ds_navigationFullHeight()

let kTabBarSafeAreaHeight = UIDevice.ds_safeDistanceBottom()

func kFont_Regular(_ fonts: CGFloat) -> UIFont {
    UIFont.systemFont(ofSize: fonts)
}

typealias ConfirmCompletion = () -> Void

enum DriverLicenseType: String {
    case AAMVA_DL_ID = "AAMVA_DL_ID"
    case AAMVA_DL_ID_WITH_MAG_STRIPE = "AAMVA_DL_ID_WITH_MAG_STRIPE"
    case SOUTH_AFRICA_DL = "SOUTH_AFRICA_DL"
}

let parseFailedTip = "Failed to parse the result.\n The barcode text is :\n"

let parsedContentDeficiencyTip = "Failed to parse the result. The drivers' information does not exist in the barcode!"
