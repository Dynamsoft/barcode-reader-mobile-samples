package com.dynamsoft.dbr.generalsettings.scanner;

import android.app.Application;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.generalsettings.models.ResultFeedbackSettings;
import com.dynamsoft.dbr.generalsettings.models.SettingsCache;
import com.dynamsoft.dce.Feedback;

import java.lang.ref.WeakReference;

public class ScannerViewModel extends AndroidViewModel implements CapturedResultReceiver, CompletionListener {
    private static final String TAG = "ScannerViewModel";
    public final SettingsCache settingsCache = SettingsCache.getCurrentSettings();
    private WeakReference<Listener> listener = new WeakReference<>(null);

    public ScannerViewModel(@NonNull Application application) {
        super(application);
    }

    @Override
    public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
        if(result.getItems().length > 0) {
            if(listener.get() != null) {
                listener.get().showResult(result);
            }

            ResultFeedbackSettings feedbackSettings = settingsCache.resultFeedbackSettings;
            if(feedbackSettings.isBeepEnabled) {
                Feedback.beep(getApplication().getApplicationContext());
            }
            if(feedbackSettings.isVibrationEnabled) {
                Feedback.vibrate(getApplication().getApplicationContext());
            }
        }
    }


    //interface CompletionListener.onSuccess
    @Override
    public void onSuccess() {
        Log.i(TAG, "onSuccess: StartCapturing success. Template is "+settingsCache.decodeSettings.getSelectedPresetTemplateName());
    }

    //interface CompletionListener.onFailure
    @Override
    public void onFailure(int errorCode, String errorString) {
        if(listener.get() != null) {
            listener.get().showError(errorCode, errorString, "StartCapturing Error");
        }
    }

    public void setListener(Listener listener) {
        this.listener = new WeakReference<>(listener);
    }

    public interface Listener {
        void showResult(DecodedBarcodesResult result);
        void showError(int errorCode, String errorString, String title);
    }
}
