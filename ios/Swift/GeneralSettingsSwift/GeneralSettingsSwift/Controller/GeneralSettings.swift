//
//  GeneralSettings.swift
//  GeneralSettingsSwift
//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

import Foundation

class GeneralSettings:NSObject{
    var dce:DynamsoftCameraEnhancer! = nil
    var dceView:DCECameraView! = nil
    var dbr:DynamsoftBarcodeReader! = nil
    
    var runtimeSettings:iPublicRuntimeSettings!
    var cameraSettings:CameraSettings!
    var scanRegion:ScanRegionSettings!
    
    var isContinueScan:Bool = false
    
    static let instance = GeneralSettings()
    private override init() {
        cameraSettings = CameraSettings(resolution: "Auto", focus: false, sharpness: false, sensor: false, zoom: false, fastMode: false)
        scanRegion = ScanRegionSettings(isScanRegion: false, top: 0, left: 0, right: 100, bottom: 100)
    }
    
    struct CameraSettings {
        var resolution:String
        var focus:Bool
        var sharpness:Bool
        var sensor:Bool
        var zoom:Bool
        var fastMode:Bool
    }
    
    struct ScanRegionSettings {
        var isScanRegion:Bool
        var top:Int
        var left:Int
        var right:Int
        var bottom:Int
    }
}
