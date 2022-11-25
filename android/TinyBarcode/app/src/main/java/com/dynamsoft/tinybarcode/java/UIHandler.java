package com.dynamsoft.tinybarcode.java;

import android.os.Handler;
import android.os.Looper;

public class UIHandler {
    public static Handler getInstance() {
        return UIHandlerHolder.UIHandler;
    }

    private static class UIHandlerHolder {
        private static final Handler UIHandler = new Handler(Looper.getMainLooper());
    }
}