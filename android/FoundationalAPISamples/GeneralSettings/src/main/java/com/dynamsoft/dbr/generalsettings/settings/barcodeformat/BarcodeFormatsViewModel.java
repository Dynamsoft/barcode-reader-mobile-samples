package com.dynamsoft.dbr.generalsettings.settings.barcodeformat;

import static com.dynamsoft.dbr.generalsettings.ui.formatselection.BarcodeFormatConstants.AllBarcodeFormatOned;
import static com.dynamsoft.dbr.generalsettings.ui.formatselection.BarcodeFormatConstants.AllBarcodeFormatOthers;
import static com.dynamsoft.dbr.generalsettings.ui.formatselection.BarcodeFormatConstants.AllBarcodeFormatPharmacode;
import static com.dynamsoft.dbr.generalsettings.ui.formatselection.BarcodeFormatConstants.AllBarcodeFormatTwod;

import androidx.lifecycle.ViewModel;

import com.dynamsoft.dbr.generalsettings.models.DecodeSettings;
import com.dynamsoft.dbr.generalsettings.models.SettingsCache;

public class BarcodeFormatsViewModel extends ViewModel {
    public final SettingsCache settingsCache = SettingsCache.getCurrentSettings();

    public long bfOnedFormats = settingsCache.decodeSettings.getBarcodeFormat() & AllBarcodeFormatOned;
    public long bfTwodFormats = settingsCache.decodeSettings.getBarcodeFormat() & AllBarcodeFormatTwod;
    public long bfPharmacodeFormats = settingsCache.decodeSettings.getBarcodeFormat() & AllBarcodeFormatPharmacode;
    public long bfOthersFormats = settingsCache.decodeSettings.getBarcodeFormat() & AllBarcodeFormatOthers;

    public long getBfOned() {
        return bfOnedFormats;
    }

    public void setBfOned(long bfOned) {
        this.bfOnedFormats = bfOned;
        DecodeSettings decodeSettings = settingsCache.decodeSettings;
        decodeSettings.setBarcodeFormat(decodeSettings.getBarcodeFormat() & ~AllBarcodeFormatOned | bfOned);
    }

    public void setBfTwod(long bfTwod) {
        this.bfTwodFormats = bfTwod;
        DecodeSettings decodeSettings = settingsCache.decodeSettings;
        decodeSettings.setBarcodeFormat(decodeSettings.getBarcodeFormat() & ~AllBarcodeFormatTwod | bfTwod);
    }

    public long getBfTwod() {
        return bfTwodFormats;
    }

    public void setBfPharmacode(long bfPharmacode) {
        this.bfPharmacodeFormats = bfPharmacode;
        DecodeSettings decodeSettings = settingsCache.decodeSettings;
        decodeSettings.setBarcodeFormat(decodeSettings.getBarcodeFormat() & ~AllBarcodeFormatPharmacode | bfPharmacode);
    }

    public long getBfPharmacode() {
        return bfPharmacodeFormats;
    }

    public void setBfOthers(long bfOthers) {
        this.bfOthersFormats = bfOthers;
        DecodeSettings decodeSettings = settingsCache.decodeSettings;
        decodeSettings.setBarcodeFormat(decodeSettings.getBarcodeFormat() & ~AllBarcodeFormatOthers | bfOthers);
    }

    public long getBfOthers() {
        return bfOthersFormats;
    }

}