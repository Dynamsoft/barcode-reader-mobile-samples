//
//  GridBarcodeProcessor.swift
//  GridBarcodeReading
//

import UIKit
import DynamsoftCaptureVisionBundle

final class GridBarcodeProcessor {
    private let cvr: CaptureVisionRouter
    private let fastTemplateName: String
    private let deepTemplateName: String

    init(cvr: CaptureVisionRouter, fastTemplateName: String, deepTemplateName: String) {
        self.cvr = cvr
        self.fastTemplateName = fastTemplateName
        self.deepTemplateName = deepTemplateName
    }

    func process(image: UIImage) -> GridProcessOutput {
        let firstPassResult = cvr.captureFromImage(image, templateName: fastTemplateName)
        if let message = firstPassResult.errorMessage, firstPassResult.errorCode != 0 {
            return GridProcessOutput(
                overlays: [],
                rows: [],
                decoded: 0,
                failed: 0,
                total: 0,
                alert: GridProcessAlert(title: "Decoding Failed", message: message)
            )
        }

        guard let items = firstPassResult.decodedBarcodesResult?.items, !items.isEmpty else {
            return GridProcessOutput(
                overlays: [],
                rows: [],
                decoded: 0,
                failed: 0,
                total: 0,
                alert: GridProcessAlert(title: "No Barcode Detected", message: "No barcode was detected.")
            )
        }

        let firstPassEntries: [(text: String, quad: Quadrilateral)] = items.map { item in
            let quad = item.location
            quad.quadId = quad.hash
            return (text: item.text, quad: quad)
        }
        var firstPassTextByQuadId: [Int: String] = [:]
        for entry in firstPassEntries {
            firstPassTextByQuadId[entry.quad.quadId] = entry.text
        }

        let locations = firstPassEntries.map(\.quad)
        guard let rowcolArray = LayoutAnalyzer.analyze(locations)?.elements else {
            return GridProcessOutput(
                overlays: [],
                rows: [],
                decoded: 0,
                failed: 0,
                total: 0,
                alert: GridProcessAlert(title: "Layout Analysis Failed", message: "Unable to analyze the barcode grid layout.")
            )
        }

        guard let deepSettings = try? cvr.getSimplifiedSettings(deepTemplateName) else {
            return GridProcessOutput(
                overlays: [],
                rows: [],
                decoded: 0,
                failed: 0,
                total: 0,
                alert: GridProcessAlert(title: "Settings Unavailable", message: "Unable to load GridDeepDecode settings.")
            )
        }

        var overlays: [GridOverlay] = []
        var cellResults: [GridCellResult] = []
        var decodedCount = 0
        var failedCount = 0
        let totalCells = rowcolArray.reduce(0) { $0 + $1.count }

        for (rowIndex, colArray) in rowcolArray.enumerated() {
            for (colIndex, element) in colArray.enumerated() {
                let row = rowIndex + 1
                let col = colIndex + 1

                let quad = element.quad

                if element.source == .inferred {
                    deepSettings.roiMeasuredInPercentage = false
                    deepSettings.roi = enlargedQuadrilateral(from: quad, scale: 2.0, image: image)
                    guard (try? cvr.updateSettings(deepTemplateName, settings: deepSettings)) != nil else {
                        overlays.append(GridOverlay(
                            quad: quad,
                            stroke: .systemRed,
                            fill: UIColor.systemRed.withAlphaComponent(0.18)
                        ))
                        failedCount += 1
                        cellResults.append(GridCellResult(row: row, col: col, status: .failed, text: "-"))
                        continue
                    }
                    autoreleasepool {
                        let secondPassResult = cvr.captureFromImage(image, templateName: deepTemplateName)
                        if let inferredItem = secondPassResult.decodedBarcodesResult?.items?.first {
                            overlays.append(GridOverlay(
                                quad: inferredItem.location,
                                stroke: .systemBlue,
                                fill: UIColor.systemBlue.withAlphaComponent(0.18)
                            ))
                            decodedCount += 1
                            cellResults.append(GridCellResult(row: row, col: col, status: .deepDecoded, text: inferredItem.text))
                        } else {
                            overlays.append(GridOverlay(
                                quad: quad,
                                stroke: .systemRed,
                                fill: UIColor.systemRed.withAlphaComponent(0.18)
                            ))
                            failedCount += 1
                            cellResults.append(GridCellResult(row: row, col: col, status: .failed, text: "-"))
                        }
                    }
                } else {
                    overlays.append(GridOverlay(
                        quad: quad,
                        stroke: .systemGreen,
                        fill: UIColor.systemGreen.withAlphaComponent(0.18)
                    ))

                    if let matchedText = firstPassTextByQuadId[quad.quadId] {
                        decodedCount += 1
                        cellResults.append(GridCellResult(row: row, col: col, status: .decoded, text: matchedText))
                    } else {
                        failedCount += 1
                        cellResults.append(GridCellResult(row: row, col: col, status: .failed, text: "-"))
                    }
                }
            }
        }

        return GridProcessOutput(
            overlays: overlays,
            rows: cellResults,
            decoded: decodedCount,
            failed: failedCount,
            total: totalCells,
            alert: nil
        )
    }

    private func enlargedQuadrilateral(from quad: Quadrilateral, scale: CGFloat, image: UIImage) -> Quadrilateral {
        let center = quad.centrePoint
        let imageSize = imageCoordinateSize(for: image)

        let enlargedPoints: [NSValue] = quad.points.map { pointValue in
            let point = pointValue.cgPointValue
            let scaledPoint = CGPoint(
                x: center.x + (point.x - center.x) * scale,
                y: center.y + (point.y - center.y) * scale
            )

            let clampedPoint = CGPoint(
                x: min(max(scaledPoint.x, 0), imageSize.width),
                y: min(max(scaledPoint.y, 0), imageSize.height)
            )
            return NSValue(cgPoint: clampedPoint)
        }

        return Quadrilateral(pointArray: enlargedPoints, quadId: quad.quadId)
    }

    private func imageCoordinateSize(for image: UIImage) -> CGSize {
        let pixelSize = imagePixelSize(for: image)
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            return CGSize(width: pixelSize.height, height: pixelSize.width)
        default:
            return pixelSize
        }
    }

    private func imagePixelSize(for image: UIImage) -> CGSize {
        if let cgImage = image.cgImage {
            return CGSize(width: cgImage.width, height: cgImage.height)
        }
        return image.size
    }
}
