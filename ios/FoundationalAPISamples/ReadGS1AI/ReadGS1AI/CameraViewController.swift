/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import Foundation
import UIKit
import DynamsoftCaptureVisionBundle

class CameraViewController: UIViewController {

    var cameraView = CameraView()
    let dce = CameraEnhancer()
    let cvr = CaptureVisionRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Barcode Scanning"
        setLicense()
        setupDCV()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dce.open()
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        cvr.startCapturing("ReadGS1AI") { isSuccess, error in
            if (!isSuccess) {
                if let error = error {
                    self.showResult("Error", error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dce.close()
        cvr.stopCapturing()
        dce.clearBuffer()
    }

    func setupDCV() {
        view.insertSubview(cameraView, at: 0)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        dce.cameraView = cameraView
        // Set the camera enhancer as the input.
        try! cvr.setInput(dce)
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        cvr.addResultReceiver(self)
        try! cvr.initSettingsFromFile("ReadGS1AI.json")
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CameraViewController: CapturedResultReceiver {
    
    func onParsedResultsReceived(_ result: ParsedResult) {
        guard let item = result.items?.first else {
            return
        }

        cvr.stopCapturing()
        let message = buildGS1Message(from: item)
        showResult("GS1 Result", message) {
            self.cvr.startCapturing("ReadGS1AI")
        }
    }

    private func buildGS1Message(from item: ParsedResultItem) -> String {
        return getContentsFromParsedItem(item).joined(separator: "\n")
    }

    /// Extracts "AI description: data" strings from a parsed GS1 item.
    private func getContentsFromParsedItem(_ item: ParsedResultItem) -> [String] {
        var contents: [String] = []
        let fields = item.parsedFields

        for fieldName in fields.keys where isAI(fieldName) {
            let aiDescription = fields["\(fieldName)AI"] ?? "unspecified"
            var aiData = fields["\(fieldName)Data"]

            if aiDescription.lowercased().contains("date") {
                aiData = parseDateAndTimeString(aiData)
            }

            if let aiData = aiData {
                contents.append("\(aiDescription): \(aiData)")
            }
        }

        return contents
    }

    private func isAI(_ str: String?) -> Bool {
        guard let str = str else {
            return false
        }
        return str.range(of: "^\\d{2,4}$", options: .regularExpression) != nil
    }

    /// Supported input formats: yyMMdd, yyMMddHHmm, yyMMddHHmmSS.
    private func parseDateAndTimeString(_ dateStr: String?) -> String? {
        guard let dateStr = dateStr,
              dateStr.range(of: "^(\\d{6}|\\d{10}|\\d{12})$", options: .regularExpression) != nil else {
            return nil
        }

        let length = dateStr.count

        guard let yearSuffix = Int(String(dateStr.prefix(2))),
              let month = Int(String(dateStr.dropFirst(2).prefix(2))),
              let dayValue = Int(String(dateStr.dropFirst(4).prefix(2))),
              (1...12).contains(month) else {
            return nil
        }

        let year = yearSuffix + 2000
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        guard let firstDayDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let lastDay = calendar.range(of: .day, in: .month, for: firstDayDate)?.count else {
            return nil
        }

        let day = dayValue == 0 ? lastDay : dayValue

        var hour = 0
        var minute = 0
        var second = 0
        if length >= 10 {
            guard let hourValue = Int(String(dateStr.dropFirst(6).prefix(2))),
                  let minuteValue = Int(String(dateStr.dropFirst(8).prefix(2))) else {
                return nil
            }
            hour = hourValue
            minute = minuteValue

            if length == 12 {
                guard let secondValue = Int(String(dateStr.dropFirst(10).prefix(2))) else {
                    return nil
                }
                second = secondValue
            }
        }

        let components = DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )

        guard let date = calendar.date(from: components) else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = calendar.timeZone
        switch length {
        case 6:
            formatter.dateFormat = "yy/MM/dd"
        case 10:
            formatter.dateFormat = "yy/MM/dd HH:mm"
        default:
            formatter.dateFormat = "yy/MM/dd HH:mm:ss"
        }

        return formatter.string(from: date)
    }
}

// MARK: LicenseVerificationListener
extension CameraViewController: LicenseVerificationListener {
    func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if !isSuccess {
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
}
