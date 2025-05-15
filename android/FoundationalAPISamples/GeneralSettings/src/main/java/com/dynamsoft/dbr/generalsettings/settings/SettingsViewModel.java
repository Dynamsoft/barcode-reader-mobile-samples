package com.dynamsoft.dbr.generalsettings.settings;

import android.app.Application;

import androidx.lifecycle.AndroidViewModel;

import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.dbr.generalsettings.models.SettingsCache;

import java.lang.ref.WeakReference;

public class SettingsViewModel extends AndroidViewModel {
    public final SettingsCache settingsCache = SettingsCache.getCurrentSettings();

    private WeakReference<OnItemClickListener> onItemClickListener = new WeakReference<>(null);

    public SettingsViewModel(Application application) {
        super(application);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        onItemClickListener = new WeakReference<>(listener);
    }

    public void resetSettings() {
        settingsCache.reset();
    }

    public void setSelectedPresetTemplateName(String templateName) {
        settingsCache.decodeSettings.setSelectedPresetTemplateName(templateName);
    }

    public void updateImportedTemplate(String importedTemplates) throws CaptureVisionRouterException {
        CaptureVisionRouter router = new CaptureVisionRouter();

        //Throw exception if imported template is invalid
        router.initSettings(importedTemplates);
        settingsCache.decodeSettings.setImportedTemplateContent(importedTemplates);
        settingsCache.decodeSettings.setSelectedPresetTemplateName("");
        settingsCache.decodeSettings.init();
    }

    public void itemClick(String item) {
        if (onItemClickListener.get() != null) {
            onItemClickListener.get().onItemClick(item);
        }
    }
}