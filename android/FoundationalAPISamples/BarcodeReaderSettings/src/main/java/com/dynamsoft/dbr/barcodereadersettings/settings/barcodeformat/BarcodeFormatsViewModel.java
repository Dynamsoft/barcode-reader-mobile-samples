package com.dynamsoft.dbr.barcodereadersettings.settings.barcodeformat;

import static com.dynamsoft.dbr.barcodereadersettings.ui.formatselection.BarcodeFormatConstants.ALL_BARCODE_FORMAT_ONED;
import static com.dynamsoft.dbr.barcodereadersettings.ui.formatselection.BarcodeFormatConstants.ALL_BARCODE_FORMAT_OTHERS;
import static com.dynamsoft.dbr.barcodereadersettings.ui.formatselection.BarcodeFormatConstants.ALL_BARCODE_FORMAT_PHARMACODE;
import static com.dynamsoft.dbr.barcodereadersettings.ui.formatselection.BarcodeFormatConstants.ALL_BARCODE_FORMAT_TWOD;

import androidx.lifecycle.ViewModel;

import com.dynamsoft.dbr.barcodereadersettings.models.DecodeSettings;
import com.dynamsoft.dbr.barcodereadersettings.models.SettingsCache;

public class BarcodeFormatsViewModel extends ViewModel {
    public final SettingsCache settingsCache = SettingsCache.getCurrentSettings();

    public long bfOnedFormats = settingsCache.decodeSettings.getBarcodeFormat() & ALL_BARCODE_FORMAT_ONED;
    public long bfTwodFormats = settingsCache.decodeSettings.getBarcodeFormat() & ALL_BARCODE_FORMAT_TWOD;
    public long bfPharmacodeFormats = settingsCache.decodeSettings.getBarcodeFormat() & ALL_BARCODE_FORMAT_PHARMACODE;
    public long bfOthersFormats = settingsCache.decodeSettings.getBarcodeFormat() & ALL_BARCODE_FORMAT_OTHERS;

    public long getBfOned() {
        return bfOnedFormats;
    }

    public void setBfOned(long bfOned) {
        this.bfOnedFormats = bfOned;
        DecodeSettings decodeSettings = settingsCache.decodeSettings;
        decodeSettings.setBarcodeFormat(decodeSettings.getBarcodeFormat() & ~ALL_BARCODE_FORMAT_ONED | bfOned);
    }

    public void setBfTwod(long bfTwod) {
        this.bfTwodFormats = bfTwod;
        DecodeSettings decodeSettings = settingsCache.decodeSettings;
        decodeSettings.setBarcodeFormat(decodeSettings.getBarcodeFormat() & ~ALL_BARCODE_FORMAT_TWOD | bfTwod);
    }

    public long getBfTwod() {
        return bfTwodFormats;
    }

    public void setBfPharmacode(long bfPharmacode) {
        this.bfPharmacodeFormats = bfPharmacode;
        DecodeSettings decodeSettings = settingsCache.decodeSettings;
        decodeSettings.setBarcodeFormat(decodeSettings.getBarcodeFormat() & ~ALL_BARCODE_FORMAT_PHARMACODE | bfPharmacode);
    }

    public long getBfPharmacode() {
        return bfPharmacodeFormats;
    }

    public void setBfOthers(long bfOthers) {
        this.bfOthersFormats = bfOthers;
        DecodeSettings decodeSettings = settingsCache.decodeSettings;
        decodeSettings.setBarcodeFormat(decodeSettings.getBarcodeFormat() & ~ALL_BARCODE_FORMAT_OTHERS | bfOthers);
    }

    public long getBfOthers() {
        return bfOthersFormats;
    }

}