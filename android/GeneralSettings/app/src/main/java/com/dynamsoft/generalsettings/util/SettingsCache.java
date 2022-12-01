package com.dynamsoft.generalsettings.util;

import android.util.Log;

import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dce.EnumResolution;
import com.dynamsoft.dce.RegionDefinition;
import com.dynamsoft.dce.EnumEnhancerFeatures;

public class SettingsCache {
    int barcodeFormats = EnumBarcodeFormat.BF_ALL;
    int barcodeFormats_2 = 0;
    int expectedBarcodeCount = 1;
    boolean isContinuousScan = true;

    private EnumResolution resolution = EnumResolution.RESOLUTION_1080P;
    private int enumEnhancerFeatures = 0;
    private boolean isEnhancedFocusEnabled;
    private boolean isSharpnessFilterEnabled;
    private boolean isSensorFilterEnabled;
    private boolean isAutoZoomEnabled;
    private boolean isFastModeEnabled;
    private boolean isScanRegionEnabled;
    private int[] scanRegionRect = new int[]{/*top*/0, /*bottom*/100, /*left*/0, /*right*/100};
    private int miniResultConfidence = 30;
    private boolean isResultVerificationEnabled = false;
    private boolean isDuplicateFilterEnabled = false;
    private int forgetTime = 3000;
    private int miniDecodeInterval = 0;
    private boolean isDecodeInvertedBarcodesEnabled = false;

    private RegionDefinition scanRegion = new RegionDefinition();
    {
        scanRegion.regionTop = 0;
        scanRegion.regionBottom = 100;
        scanRegion.regionLeft = 0;
        scanRegion.regionRight = 100;
        scanRegion.regionMeasuredByPercentage = 1;
    }
    private boolean isBeepEnabled = true;
    private boolean isVibrationEnabled = true;


    private boolean isOverlayVisible = true;
    private boolean isTorchBtnVisible;

    private static SettingsCache currentSettings = new SettingsCache();

    public static SettingsCache getCurrentSettings() {
        return currentSettings;
    }

    public void resetAllSettings(){
        currentSettings = new SettingsCache();
    }

    public int getBarcodeFormats() {
        return barcodeFormats;
    }

    public void setBarcodeFormats(int barcodeFormats) {
        this.barcodeFormats = barcodeFormats;
    }

    public int getBarcodeFormats_2() {
        return barcodeFormats_2;
    }

    public void setBarcodeFormats_2(int barcodeFormats_2) {
        this.barcodeFormats_2 = barcodeFormats_2;
    }

    public int getExpectedBarcodeCount() {
        return expectedBarcodeCount;
    }

    public void setExpectedBarcodeCount(int expectedBarcodeCount) {
        this.expectedBarcodeCount = expectedBarcodeCount;
    }

    public boolean isContinuousScan() {
        return isContinuousScan;
    }

    public void setContinuousScan(boolean continuousScan) {
        this.isContinuousScan = continuousScan;
    }

    public EnumResolution getResolution() {
        return resolution;
    }

    public void setResolution(EnumResolution resolution) {
        this.resolution = resolution;
    }

    public int getEnumEnhancerFeatures() {
        return enumEnhancerFeatures;
    }

    public boolean isEnhancedFocusEnabled() {
        return isEnhancedFocusEnabled;
    }

    public void setEnhancedFocusEnabled(boolean enhancedFocusEnabled) {
        isEnhancedFocusEnabled = enhancedFocusEnabled;
        if(isEnhancedFocusEnabled) {
            enumEnhancerFeatures |= EnumEnhancerFeatures.EF_ENHANCED_FOCUS;
        } else {
            enumEnhancerFeatures &= (~EnumEnhancerFeatures.EF_ENHANCED_FOCUS);
        }
    }

    public boolean isSharpnessFilterEnabled() {
        return isSharpnessFilterEnabled;
    }

    public void setSharpnessFilterEnabled(boolean sharpnessFilterEnabled) {
        isSharpnessFilterEnabled = sharpnessFilterEnabled;
        if(isSharpnessFilterEnabled) {
            enumEnhancerFeatures |= EnumEnhancerFeatures.EF_FRAME_FILTER;
        } else {
            enumEnhancerFeatures &= (~EnumEnhancerFeatures.EF_FRAME_FILTER);
        }
    }

    public boolean isSensorFilterEnabled() {
        return isSensorFilterEnabled;
    }

    public void setSensorFilterEnabled(boolean sensorFilterEnabled) {
        isSensorFilterEnabled = sensorFilterEnabled;
        if(isSensorFilterEnabled) {
            enumEnhancerFeatures |= EnumEnhancerFeatures.EF_SENSOR_CONTROL;
        } else {
            enumEnhancerFeatures &= (~EnumEnhancerFeatures.EF_SENSOR_CONTROL);
        }
    }

    public boolean isAutoZoomEnabled() {
        return isAutoZoomEnabled;
    }

    public void setAutoZoomEnabled(boolean autoZoomEnabled) {
        isAutoZoomEnabled = autoZoomEnabled;
        if(isAutoZoomEnabled) {
            enumEnhancerFeatures |= EnumEnhancerFeatures.EF_AUTO_ZOOM;
        } else {
            enumEnhancerFeatures &= (~EnumEnhancerFeatures.EF_AUTO_ZOOM);
        }
    }

    public boolean isFastModeEnabled() {
        return isFastModeEnabled;
    }

    public void setFastModeEnabled(boolean fastModeEnabled) {
        isFastModeEnabled = fastModeEnabled;
        if(isFastModeEnabled) {
            enumEnhancerFeatures |= EnumEnhancerFeatures.EF_FAST_MODE;
        } else {
            enumEnhancerFeatures &= (~EnumEnhancerFeatures.EF_FAST_MODE);
        }
    }

    public boolean isBeepEnabled() {
        return isBeepEnabled;
    }

    public void setBeepEnabled(boolean beepEnabled) {
        isBeepEnabled = beepEnabled;
    }

    public boolean isVibrationEnabled() {
        return isVibrationEnabled;
    }

    public void setVibrationEnabled(boolean vibrationEnabled) {
        isVibrationEnabled = vibrationEnabled;
    }

    public boolean isScanRegionEnabled() {
        return isScanRegionEnabled;
    }

    public void setScanRegionEnabled(boolean scanRegionEnabled) {
        this.isScanRegionEnabled = scanRegionEnabled;
    }

    public int[] getScanRegionRect() {
        return scanRegionRect;
    }

    public void uptedeScanRegionValues(boolean inputValid) {
        if(inputValid){
            scanRegion.regionTop = scanRegionRect[0];
            scanRegion.regionBottom = scanRegionRect[1];
            scanRegion.regionLeft = scanRegionRect[2];
            scanRegion.regionRight = scanRegionRect[3];
            scanRegion.regionMeasuredByPercentage = 1;
        } else {
            scanRegionRect[0] = scanRegion.regionTop;
            scanRegionRect[1] = scanRegion.regionBottom;
            scanRegionRect[2] = scanRegion.regionLeft;
            scanRegionRect[3] = scanRegion.regionRight;
        }
    }

    public RegionDefinition getScanRegion() {
        return scanRegion;
    }

    public boolean isOverlayVisible() {
        return isOverlayVisible;
    }

    public void setOverlayVisible(boolean overlayVisible) {
        isOverlayVisible = overlayVisible;
    }

    public boolean isTorchBtnVisible() {
        return isTorchBtnVisible;
    }

    public void setTorchBtnVisible(boolean torchBtnVisible) {
        isTorchBtnVisible = torchBtnVisible;
    }

    public void setMiniResultConfidence(int value){
        this.miniResultConfidence = value;
    }

    public int getMiniResultConfidence(){
        return this.miniResultConfidence;
    }

    public boolean isResultVerificationEnabled() {
        return isResultVerificationEnabled;
    }

    public void setResultVerificationEnabled(boolean resultVerificationEnabled) {
        isResultVerificationEnabled = resultVerificationEnabled;
    }

    public boolean isDuplicateFilterEnabled() {
        return isDuplicateFilterEnabled;
    }

    public void setDuplicateFilterEnabled(boolean duplicateFilterEnabled) {
        isDuplicateFilterEnabled = duplicateFilterEnabled;
    }

    public int getForgetTime() {
        return forgetTime;
    }

    public void setForgetTime(int forgetTime) {
        this.forgetTime = forgetTime;
    }

    public int getMiniDecodeInterval() {
        return miniDecodeInterval;
    }

    public void setMiniDecodeInterval(int miniDecodeInterval) {
        this.miniDecodeInterval = miniDecodeInterval;
    }

    public boolean isDecodeInvertedBarcodesEnabled() {
        return isDecodeInvertedBarcodesEnabled;
    }

    public void setDecodeInvertedBarcodesEnabled(boolean decodeInvertedBarcodesEnabled) {
        isDecodeInvertedBarcodesEnabled = decodeInvertedBarcodesEnabled;
    }
}
