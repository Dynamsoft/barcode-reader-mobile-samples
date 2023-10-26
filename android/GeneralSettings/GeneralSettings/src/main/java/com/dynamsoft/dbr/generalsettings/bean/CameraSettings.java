package com.dynamsoft.dbr.generalsettings.bean;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.dynamsoft.core.basic_structures.DSRect;
import com.dynamsoft.dbr.generalsettings.BR;
import com.dynamsoft.dce.EnumEnhancerFeatures;
import com.dynamsoft.dce.EnumResolution;

public class CameraSettings extends BaseObservable {
    @EnumResolution
    private int resolution = EnumResolution.RESOLUTION_1080P;

    @EnumEnhancerFeatures
    private int enhancedFeatures = 0;

    private boolean isScanRegionEnabled = false;

    private DSRect scanRegion = new DSRect(0, 0, 1, 1, true);

    private int regionLeft = 0, regionRight = 100, regionTop = 0, regionBottom = 100;
    private String regionLeftText = "0", regionRightText = "100", regionTopText = "0", regionBottomText = "100";

    private boolean isBeepEnabled = true;

    private boolean isVibrationEnabled = true;

    @Bindable
    public int getResolution() {
        return resolution;
    }

    public void setResolution(int resolution) {
        this.resolution = resolution;
        notifyPropertyChanged(BR.resolution);
    }

    @Bindable
    public int getEnhancedFeatures() {
        return enhancedFeatures;
    }

    public void setEnhancedFeatures(int enhancedFeatures) {
        this.enhancedFeatures = enhancedFeatures;
        notifyPropertyChanged(BR.enhancedFeatures);
    }

    @Bindable
    public boolean isEnhancedFocusEnabled() {
        return (enhancedFeatures & EnumEnhancerFeatures.EF_ENHANCED_FOCUS) != 0;
    }

    public void setEnhancedFocusEnabled(boolean enhancedFocusEnabled) {
        if (enhancedFocusEnabled) {
            enhancedFeatures |= EnumEnhancerFeatures.EF_ENHANCED_FOCUS;
        } else {
            enhancedFeatures &= (~EnumEnhancerFeatures.EF_ENHANCED_FOCUS);
        }
        notifyPropertyChanged(BR.enhancedFeatures);
    }

    @Bindable
    public boolean isSharpnessFilterEnabled() {
        return (enhancedFeatures & EnumEnhancerFeatures.EF_FRAME_FILTER) != 0;
    }

    public void setSharpnessFilterEnabled(boolean sharpnessFilterEnabled) {
        if (sharpnessFilterEnabled) {
            enhancedFeatures |= EnumEnhancerFeatures.EF_FRAME_FILTER;
        } else {
            enhancedFeatures &= (~EnumEnhancerFeatures.EF_FRAME_FILTER);
        }
        notifyPropertyChanged(BR.enhancedFeatures);
    }

    @Bindable
    public boolean isSensorFilterEnabled() {
        return (enhancedFeatures & EnumEnhancerFeatures.EF_SENSOR_CONTROL) != 0;
    }

    public void setSensorFilterEnabled(boolean sensorFilterEnabled) {
        if (sensorFilterEnabled) {
            enhancedFeatures |= EnumEnhancerFeatures.EF_SENSOR_CONTROL;
        } else {
            enhancedFeatures &= (~EnumEnhancerFeatures.EF_SENSOR_CONTROL);
        }
        notifyPropertyChanged(BR.enhancedFeatures);
    }

    @Bindable
    public boolean isAutoZoomEnabled() {
        return (enhancedFeatures & EnumEnhancerFeatures.EF_AUTO_ZOOM) != 0;
    }

    public void setAutoZoomEnabled(boolean autoZoomEnabled) {
        if (autoZoomEnabled) {
            enhancedFeatures |= EnumEnhancerFeatures.EF_AUTO_ZOOM;
        } else {
            enhancedFeatures &= (~EnumEnhancerFeatures.EF_AUTO_ZOOM);
        }
        notifyPropertyChanged(BR.enhancedFeatures);
    }

    @Bindable
    public boolean isSmartTorchEnabled() {
        return (enhancedFeatures & EnumEnhancerFeatures.EF_SMART_TORCH) != 0;
    }

    public void setSmartTorchEnabled(boolean smartTorchEnabled) {
        if (smartTorchEnabled) {
            enhancedFeatures |= EnumEnhancerFeatures.EF_SMART_TORCH;
        } else {
            enhancedFeatures &= (~EnumEnhancerFeatures.EF_SMART_TORCH);
        }
        notifyPropertyChanged(BR.enhancedFeatures);
    }

    @Bindable
    public boolean isScanRegionEnabled() {
        return isScanRegionEnabled;
    }

    public void setScanRegionEnabled(boolean scanRegionEnabled) {
        isScanRegionEnabled = scanRegionEnabled;
        notifyPropertyChanged(BR.scanRegionEnabled);
    }

    public DSRect getOldRegion() {
        return scanRegion;
    }

    public DSRect getScanRegion() {
        scanRegion.right = (float) regionRight / 100;
        scanRegion.left = (float) regionLeft / 100;
        scanRegion.top = (float) regionTop / 100;
        scanRegion.bottom = (float) regionBottom / 100;
        return scanRegion;
    }

    public void setScanRegion(DSRect scanRegion) {
        this.scanRegion = scanRegion;
    }

    @Bindable
    public int getRegionLeft() {
        return regionLeft;
    }

    public void setRegionLeft(int regionLeft) {
        this.regionLeft = Math.min(regionLeft, 100);
        notifyPropertyChanged(BR.regionLeft);
    }

    @Bindable
    public String getRegionLeftText() {
        return regionLeftText;
    }

    public void setRegionLeftText(String regionLeftText) {
        if(regionLeftText.isEmpty()) {
            this.regionLeftText = "0";
            this.regionLeft = 0;
        } else {
            this.regionLeft = Math.min(Integer.parseInt(regionLeftText), 100);
            this.regionLeftText = Integer.toString(this.regionLeft);
        }
        notifyPropertyChanged(BR.regionLeftText);
    }

    @Bindable
    public int getRegionRight() {
        return regionRight;
    }

    public void setRegionRight(int regionRight) {
        this.regionRight = Math.min(regionRight, 100);
        notifyPropertyChanged(BR.regionRight);
    }

    @Bindable
    public String getRegionRightText() {
        return regionRightText;
    }

    public void setRegionRightText(String regionRightText) {
        if(regionRightText.isEmpty()) {
            this.regionRightText = "0";
            this.regionRight = 0;
        } else {
            this.regionRight = Math.min(Integer.parseInt(regionRightText), 100);
            this.regionRightText = Integer.toString(this.regionRight);
        }
        notifyPropertyChanged(BR.regionRightText);
    }

    @Bindable
    public int getRegionTop() {
        return regionTop;
    }

    public void setRegionTop(int regionTop) {
        this.regionTop = Math.min(regionTop, 100);
        notifyPropertyChanged(BR.regionTop);
    }

    @Bindable
    public String getRegionTopText() {
        return regionTopText;
    }

    public void setRegionTopText(String regionTopText) {
        if(regionTopText.isEmpty()) {
            this.regionTopText = "0";
            this.regionTop = 0;
        } else {
            this.regionTop = Math.min(Integer.parseInt(regionTopText), 100);
            this.regionTopText = Integer.toString(this.regionTop);
        }
        notifyPropertyChanged(BR.regionTopText);
    }

    @Bindable
    public int getRegionBottom() {
        return regionBottom;
    }

    public void setRegionBottom(int regionBottom) {
        this.regionBottom = Math.min(regionBottom, 100);
        notifyPropertyChanged(BR.regionBottom);
    }

    @Bindable
    public String getRegionBottomText() {
        return regionBottomText;
    }

    public void setRegionBottomText(String regionBottomText) {
        if(regionBottomText.isEmpty()) {
            this.regionBottomText = "0";
            this.regionBottom = 0;
        } else {
            this.regionBottom = Math.min(Integer.parseInt(regionBottomText), 100);
            this.regionBottomText = Integer.toString(this.regionBottom);
        }
        notifyPropertyChanged(BR.regionBottomText);
    }

    @Bindable
    public boolean isBeepEnabled() {
        return isBeepEnabled;
    }

    public void setBeepEnabled(boolean beepEnabled) {
        isBeepEnabled = beepEnabled;
        notifyPropertyChanged(BR.beepEnabled);
    }

    @Bindable
    public boolean isVibrationEnabled() {
        return isVibrationEnabled;
    }

    public void setVibrationEnabled(boolean vibrationEnabled) {
        isVibrationEnabled = vibrationEnabled;
        notifyPropertyChanged(BR.vibrationEnabled);
    }
}
