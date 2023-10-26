/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import Foundation


enum BarcodePattern: String {
    case singleBarcodePattern = "Single Barcode"
    case speedFirstPattern = "Speed First"
    case readRateFirstPattern = "Read Rate First"
    case accuracyFirstPattern = "Accuracy First"
}

let singleBarcodePatternExplain = "You can optimize the performance of single barcode reading by selecting single barcode template. "

let speedFirstPatternExplain = "You can simply optimize the barcode reading speed by selecting speed first template. You can still add your personalized settings to further improve the performance."

let readRateFirstPatternExplain = "You can simply optimize the barcode read rate by selecting read rate first template. You can still add your personalized settings to further improve the performance."

let accuracyFirstPatternExplain = "In addition to the general accuracy settings, you can add your personalized configurations to further improve the accuracy."
