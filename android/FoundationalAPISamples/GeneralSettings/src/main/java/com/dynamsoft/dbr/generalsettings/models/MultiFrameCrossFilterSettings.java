package com.dynamsoft.dbr.generalsettings.models;


import android.util.Range;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;


public class MultiFrameCrossFilterSettings extends BaseObservable {
    @Bindable
    public boolean isMultiFrameVerificationEnabled = true;
    @Bindable
    public boolean isResultDeduplicationEnabled;
    @Bindable
    public int duplicationForgetTime = 3000;
    public static final Range<Integer> duplicationForgetTimeRange = new Range<>(0, Integer.MAX_VALUE);
    @Bindable
    public boolean isLatestOverlappingEnabled;

    @Bindable
    public int maxOverlappingFramesCount = 5;
    public static final Range<Integer> maxOverlappingFramesCountRange = new Range<>(0, Integer.MAX_VALUE);


    public int getDuplicationForgetTime() {
        return duplicationForgetTime;
    }

    public void setDuplicationForgetTime(int duplicationForgetTime) {
        this.duplicationForgetTime = duplicationForgetTime;
    }

    public int getMaxOverlappingFramesCount() {
        return maxOverlappingFramesCount;
    }

    public void setMaxOverlappingFramesCount(int maxOverlappingFramesCount) {
        this.maxOverlappingFramesCount = maxOverlappingFramesCount;
    }

    public void reset() {
        MultiFrameCrossFilterSettings newSettings = new MultiFrameCrossFilterSettings();
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
