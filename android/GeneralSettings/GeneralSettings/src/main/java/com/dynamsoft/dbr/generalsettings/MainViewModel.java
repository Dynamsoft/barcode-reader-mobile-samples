package com.dynamsoft.dbr.generalsettings;

import androidx.lifecycle.ViewModel;

import com.dynamsoft.dbr.generalsettings.bean.BarcodeSettings;
import com.dynamsoft.dbr.generalsettings.bean.CameraSettings;
import com.dynamsoft.dbr.generalsettings.bean.ViewSettings;

public class MainViewModel extends ViewModel {
    public BarcodeSettings barcodeSettings = new BarcodeSettings();
    public CameraSettings cameraSettings = new CameraSettings();
    public ViewSettings viewSettings = new ViewSettings();

    private void updateBarcodeSettings(BarcodeSettings barcodeSettings) {
        this.barcodeSettings = barcodeSettings;
    }
    private void updateCameraSettings(CameraSettings cameraSettings) {
        this.cameraSettings = cameraSettings;
    }
    private void updateViewSettings(ViewSettings viewSettings) {
        this.viewSettings = viewSettings;
    }

    public void resetAllSettings() {
        updateBarcodeSettings(new BarcodeSettings());
        updateCameraSettings(new CameraSettings());
        updateViewSettings(new ViewSettings());
    }


}
