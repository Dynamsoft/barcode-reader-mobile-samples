package com.dynamsoft.javascript.helloworld;

import android.app.AlertDialog;
import android.util.Log;
import android.webkit.ValueCallback;
import android.webkit.WebView;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.ImageData;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.dbr.TextResultListener;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.DCECameraView;
import com.google.gson.Gson;

import java.util.HashMap;
import java.util.Map;

public class MainScanner {
    WebView mWebView;
    CameraEnhancer mCameraEnhancer;
    BarcodeReader mReader;
    DCECameraView cameraView;
    MainActivity mainActivity;
    WebAppInterface webAppInterface;

    // Initialize license for Dynamsoft Barcode Reader.
    // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
    // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
    MainScanner(MainActivity activity, WebView webview) {
        mWebView = webview;
        mainActivity = activity;
        BarcodeReader.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", new DBRLicenseVerificationListener() {
            @Override
            public void DBRLicenseVerificationCallback(boolean isSuccessful, Exception error) {
                mainActivity.runOnUiThread(() -> {
                    if (!isSuccessful) {
                        error.printStackTrace();
                        showErrorDialog(error.getMessage());
                    }
                });
            }
        });

        // Add camera view for previewing video.
        cameraView = mainActivity.findViewById(R.id.myCameraView);
        cameraView.setOverlayVisible(true);

        mCameraEnhancer = new CameraEnhancer(mainActivity);
        mCameraEnhancer.setCameraView(cameraView);

        // Initialize barcode reader
        try {
            mReader = new BarcodeReader();
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }
        mReader.setCameraEnhancer(mCameraEnhancer);

        webAppInterface = new WebAppInterface(mCameraEnhancer, mReader, cameraView, mainActivity);

        // Create a barcode result listener and register
        mReader.setTextResultListener(new TextResultListener() {
            // Obtain the recognized barcode results and display.
            @Override
            public void textResultCallback(int id, ImageData imageData, TextResult[] textResults) {
                mainActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (textResults.length > 0) {
                            Gson gson = new Gson();
                            evaluateJavascript("webviewBridge.onBarcodeRead", gson.toJson(textResults));
                        }
                    }
                });
            }
        });

    }

    public void evaluateJavascript(String funcName, String parameter) {
        mWebView.post(new Runnable() {
            @Override
            public void run() {
                mWebView.evaluateJavascript(funcName + "('" + parameter + "')", new ValueCallback<String>() {
                    @Override
                    // if there is a callback, you can handle it there
                    public void onReceiveValue(String s) { }
                });
            }
        });
    }

    private void showErrorDialog(String message) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(mainActivity);
        dialog.setTitle("License Verification Failed").setPositiveButton("OK", null).setMessage(message).show();
    }

    public static Map<String, Integer> initFormatsMap() {
        Map<String, Integer> mapFormats = new HashMap<>();

        mapFormats.put("BF_ALL", EnumBarcodeFormat.BF_ALL);
        mapFormats.put("BF_ONED", EnumBarcodeFormat.BF_ONED);
        mapFormats.put("BF_GS1_DATABAR", EnumBarcodeFormat.BF_GS1_DATABAR);
        mapFormats.put("BF_NULL", EnumBarcodeFormat.BF_NULL);
        mapFormats.put("BF_CODE_39", EnumBarcodeFormat.BF_CODE_39);
        mapFormats.put("BF_CODE_128", EnumBarcodeFormat.BF_CODE_128);
        mapFormats.put("BF_CODE_93", EnumBarcodeFormat.BF_CODE_93);
        mapFormats.put("BF_CODABAR", EnumBarcodeFormat.BF_CODABAR);
        mapFormats.put("BF_ITF", EnumBarcodeFormat.BF_ITF);
        mapFormats.put("BF_EAN_13", EnumBarcodeFormat.BF_EAN_13);
        mapFormats.put("BF_EAN_8", EnumBarcodeFormat.BF_EAN_8);
        mapFormats.put("BF_UPC_A", EnumBarcodeFormat.BF_UPC_A);
        mapFormats.put("BF_UPC_E", EnumBarcodeFormat.BF_UPC_E);
        mapFormats.put("BF_INDUSTRIAL_25", EnumBarcodeFormat.BF_INDUSTRIAL_25);
        mapFormats.put("BF_CODE_39_EXTENDED", EnumBarcodeFormat.BF_CODE_39_EXTENDED);
        mapFormats.put("BF_GS1_DATABAR_OMNIDIRECTIONAL", EnumBarcodeFormat.BF_GS1_DATABAR_OMNIDIRECTIONAL);
        mapFormats.put("BF_GS1_DATABAR_TRUNCATED", EnumBarcodeFormat.BF_GS1_DATABAR_TRUNCATED);
        mapFormats.put("BF_GS1_DATABAR_STACKED", EnumBarcodeFormat.BF_GS1_DATABAR_STACKED);
        mapFormats.put("BF_GS1_DATABAR_STACKED_OMNIDIRECTIONAL", EnumBarcodeFormat.BF_GS1_DATABAR_STACKED_OMNIDIRECTIONAL);
        mapFormats.put("BF_GS1_DATABAR_EXPANDED", EnumBarcodeFormat.BF_GS1_DATABAR_EXPANDED);
        mapFormats.put("BF_GS1_DATABAR_EXPANDED_STACKED", EnumBarcodeFormat.BF_GS1_DATABAR_EXPANDED_STACKED);
        mapFormats.put("BF_GS1_DATABAR_LIMITED", EnumBarcodeFormat.BF_GS1_DATABAR_LIMITED);
        mapFormats.put("BF_PATCHCODE", EnumBarcodeFormat.BF_PATCHCODE);
        mapFormats.put("BF_PDF417", EnumBarcodeFormat.BF_PDF417);
        mapFormats.put("BF_QR_CODE", EnumBarcodeFormat.BF_QR_CODE);
        mapFormats.put("BF_DATAMATRIX", EnumBarcodeFormat.BF_DATAMATRIX);
        mapFormats.put("BF_AZTEC", EnumBarcodeFormat.BF_AZTEC);
        mapFormats.put("BF_MAXICODE", EnumBarcodeFormat.BF_MAXICODE);
        mapFormats.put("BF_MICRO_QR", EnumBarcodeFormat.BF_MICRO_QR);
        mapFormats.put("BF_MICRO_PDF417", EnumBarcodeFormat.BF_MICRO_PDF417);
        mapFormats.put("BF_GS1_COMPOSITE", EnumBarcodeFormat.BF_GS1_COMPOSITE);
        mapFormats.put("BF_MSI_CODE", EnumBarcodeFormat.BF_MSI_CODE);
        mapFormats.put("BF_CODE_11", EnumBarcodeFormat.BF_CODE_11);

        return mapFormats;
    }

}
