package com.dynamsoft.dbr.generalsettings.models;


import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

public class CameraSettings extends BaseObservable {
    @Bindable
    public String scanRegion = "Full Image";

    @Bindable
    public String resolution = "Full HD";

    @Bindable
    public boolean autoZoomEnabled;

    public static class ScanRegion {
        public static final String FULL_IMAGE = "Full Image";
        public static final String SQUARE = "Square";
        public static final String RECTANGLE = "Rectangle";
    }

    public static class Resolution {
        public static String FULL_HD = "Full HD";
        public static String HD = "HD";
    }

    public void reset() {
        CameraSettings newSettings = new CameraSettings();
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
