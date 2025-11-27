/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import SwiftUI
import DynamsoftBarcodeReaderBundle

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var isShowingScanner: Bool
    @Binding var scanResult: String

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let vc = BarcodeScannerViewController()
        let config = BarcodeScannerConfig()
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        config.license = "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9"
        // You can use the following code to specify the barcode format. If you are using a template file, the "BarcodeFormat" can also be specified via the template file.
        /* config.barcodeFormats = [.oneD, .qrCode] */
        // If you have a customized template file, please put it under "DynamsoftResources.bundle\Templates\" and call the following code.
        /* config.templateFilePath = "ReadSingleBarcode.json" */
        // The following settings will display a scan region on the view. Only the barcode in the scan region can be decoded.
        /*
         let region = Rect()
         region.left = 0.15
         region.top = 0.3
         region.right = 0.85
         region.bottom = 0.7
         config.scanRegion = region
         */
        // Uncomment the following line to enable the beep sound when a barcode is scanned.
        /* config.isBeepEnabled = true */
        // Uncomment the following line if you don't want to display the torch button.
        /* config.isTorchButtonVisible = false */
        // Uncomment the following line if you don't want to display the close button.
        /* config.isCloseButtonVisible = false */
        // Uncomment the following line if you want to hide the scan laser.
        /* config.isScanLaserVisible = false */
        // Uncomment the following line if you want the camera to auto-zoom when the barcode is far away.
        /* config.isAutoZoomEnabled = true */
        vc.config = config
        vc.onScannedResult = { result in
            switch result.resultStatus {
            case .finished:
                let format = result.barcodes?.first?.formatString ?? ""
                let text = result.barcodes?.first?.text ?? ""
                scanResult = "Result:\nFormat: \(format)\nText: \(text)"
            case .canceled:
                scanResult = "Scan canceled"
            case .exception:
                scanResult = result.errorString ?? "An exception occurred"
            @unknown default:
                break
            }
            isShowingScanner = false
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        
    }
}
