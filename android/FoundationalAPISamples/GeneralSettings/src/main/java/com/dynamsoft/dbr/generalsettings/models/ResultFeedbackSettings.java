package com.dynamsoft.dbr.generalsettings.models;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

public class ResultFeedbackSettings extends BaseObservable {
    @Bindable
    public boolean isBeepEnabled = true;

    @Bindable
    public boolean isVibrationEnabled = true;


    public void reset() {
        ResultFeedbackSettings newSettings = new ResultFeedbackSettings();
        for (Field declaredField : getClass().getDeclaredFields()) {
            try {
                if(!Modifier.isFinal(declaredField.getModifiers())) {
                    Object newValue = declaredField.get(newSettings);
                    declaredField.set(this, newValue);
                }
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }
        notifyChange();
    }
}
