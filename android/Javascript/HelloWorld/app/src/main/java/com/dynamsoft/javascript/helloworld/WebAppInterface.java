package com.dynamsoft.javascript.helloworld;

import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.JavascriptInterface;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.PublicRuntimeSettings;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.DCECameraView;
import com.google.gson.Gson;

public class WebAppInterface {
    CameraEnhancer mCameraEnhancer;
    BarcodeReader mReader;
    DCECameraView mCameraView;
    MainActivity mainActivity;

    WebAppInterface(CameraEnhancer cameraEnhancer, BarcodeReader reader, DCECameraView cameraView, MainActivity activity) {
        mCameraEnhancer = cameraEnhancer;
        mReader = reader;
        mCameraView = cameraView;
        mainActivity = activity;
    }

    // encapsulate the code you want to execute into a method here, which can be called in JS code
    // set the position of the CameraView
    @JavascriptInterface
    public void setCameraUI(int[] params) {
        DisplayMetrics dm = new DisplayMetrics();
        mainActivity.getWindowManager().getDefaultDisplay().getMetrics(dm);
        float density = dm.density;
        ViewGroup.LayoutParams lP = mCameraView.getLayoutParams();
        int width = Double.valueOf(params[2] * density).intValue();
        int height = Double.valueOf(params[3] * density).intValue();
        int marginLeft = Double.valueOf(params[0] * density).intValue();
        int marginTop = Double.valueOf(params[1] * density).intValue();
        lP.width = width;
        Log.i("width", String.valueOf(width));
        lP.height = height;
        ViewGroup.MarginLayoutParams mlp = (ViewGroup.MarginLayoutParams) mCameraView.getLayoutParams();
        mlp.setMargins(marginLeft, marginTop, 0, 0);
        Log.i("setUI", "OK");
    }

    // get barcodeReader's runtimeSettings
    @JavascriptInterface
    public String getRuntimeSettings() throws BarcodeReaderException {
        Log.i("settings", "get");
        PublicRuntimeSettings settings = mReader.getRuntimeSettings();
        Gson gson = new Gson();
        return gson.toJson(settings);
    }

    // get barcodeReader's EnumBarcodeFormat
    @JavascriptInterface
    public String getEnumBarcodeFormat() throws BarcodeReaderException {
        Log.i("foramt", "get");
        Gson gson = new Gson();
        return gson.toJson(MainScanner.initFormatsMap());
    }

    @JavascriptInterface
    public void updateRuntimeSettings(String settings) throws BarcodeReaderException {
        Log.i("settings", "set");
        Gson gson = new Gson();
        PublicRuntimeSettings _settings = gson.fromJson(settings, PublicRuntimeSettings.class);
        mReader.updateRuntimeSettings(_settings);
    }

    @JavascriptInterface
    public void startScanning() {
        try {
//            scanCallbackName = cbName;
            mCameraEnhancer.open();
            mainActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mCameraView.setVisibility(View.VISIBLE);
                }
            });
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        mReader.startScanning();
        Log.i("start", "OK");
    }

    @JavascriptInterface
    public void stopScanning() {
        // Stop video barcode reading
//            cameraView.setOverlayVisible(false);
        mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mCameraView.setVisibility(View.INVISIBLE);
            }
        });
        mReader.stopScanning();
        try {
            mCameraEnhancer.close();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        Log.i("stop", "OK");
    }

}
