package com.dynamsoft.dbr.barcodereadersettings.settings.simplifiedsettings;

import androidx.lifecycle.ViewModel;

import com.dynamsoft.dbr.barcodereadersettings.models.SettingsCache;
import com.dynamsoft.dbr.barcodereadersettings.settings.OnItemClickListener;

import java.lang.ref.WeakReference;

public class SimplifiedSettingsViewModel extends ViewModel {
    public final SettingsCache settingsCache = SettingsCache.getCurrentSettings();
    private WeakReference<OnItemClickListener> onItemClickListener = new WeakReference<>(null);

    public void setOnItemClickListener(OnItemClickListener listener) {
        onItemClickListener = new WeakReference<>(listener);
    }


    public void itemClick(String item) {
        if (onItemClickListener.get() != null) {
            onItemClickListener.get().onItemClick(item);
        }
    }
}