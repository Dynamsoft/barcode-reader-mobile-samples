//
//  GridBarcodeTypes.swift
//  GridBarcodeReading
//

import UIKit
import DynamsoftCaptureVisionBundle

enum GridCellStatus: String {
    case decoded = "Decoded"
    case deepDecoded = "Deep Decoded"
    case failed = "Failed"

    var color: UIColor {
        switch self {
        case .decoded:
            return .systemGreen
        case .deepDecoded:
            return .systemBlue
        case .failed:
            return .systemRed
        }
    }
}

struct GridCellResult {
    let row: Int
    let col: Int
    let status: GridCellStatus
    let text: String
}

struct GridOverlay {
    let quad: Quadrilateral
    let stroke: UIColor
    let fill: UIColor
}

struct GridProcessAlert {
    let title: String
    let message: String
}

struct GridProcessOutput {
    let overlays: [GridOverlay]
    let rows: [GridCellResult]
    let decoded: Int
    let failed: Int
    let total: Int
    let alert: GridProcessAlert?
}
