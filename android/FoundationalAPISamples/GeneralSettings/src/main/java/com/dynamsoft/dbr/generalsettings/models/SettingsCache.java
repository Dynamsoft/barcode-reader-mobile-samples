package com.dynamsoft.dbr.generalsettings.models;

import android.content.Context;
import android.content.SharedPreferences;

import com.google.gson.Gson;

public class SettingsCache {
    private static final SettingsCache CURRENT = new SettingsCache();
    private static final String PREF_NAME = "SettingsCache";
    private static final String KEY_SETTINGS = "settings";
    private static final Gson GSON = new Gson();

    public DecodeSettings decodeSettings = new DecodeSettings();
    public CameraSettings cameraSettings = new CameraSettings();
    public MultiFrameCrossFilterSettings multiFrameCrossFilterSettings = new MultiFrameCrossFilterSettings();
    public ResultFeedbackSettings resultFeedbackSettings = new ResultFeedbackSettings();

    public static SettingsCache getCurrentSettings() {
        return CURRENT;
    }

    public void reset() {
        cameraSettings.reset();
        decodeSettings.reset();
        multiFrameCrossFilterSettings.reset();
        resultFeedbackSettings.reset();
    }

    public void saveToPreferences(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString(KEY_SETTINGS, GSON.toJson(this));
        editor.apply();
    }

    public void loadFromPreferences(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        String json = prefs.getString(KEY_SETTINGS, null);
        if (json != null) {
            SettingsCache loadedSettings = GSON.fromJson(json, SettingsCache.class);
            this.decodeSettings = loadedSettings.decodeSettings;
            this.cameraSettings = loadedSettings.cameraSettings;
            this.multiFrameCrossFilterSettings = loadedSettings.multiFrameCrossFilterSettings;
            this.resultFeedbackSettings = loadedSettings.resultFeedbackSettings;
        }
    }

}
