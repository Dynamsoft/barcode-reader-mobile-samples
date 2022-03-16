//This is a HelloWorld sample that illustrates how to set up a simplest video barcode scanner with Dynamsoft Barcode Reader.

package com.dynamsoft.helloworld;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.os.Bundle;
import android.widget.TextView;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.EnumPresetTemplate;
import com.dynamsoft.dbr.ImageData;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.dbr.TextResultListener;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.DCECameraView;

public class MainActivity extends AppCompatActivity {
    BarcodeReader reader;
    CameraEnhancer mCameraEnhancer;
    TextView tvRes;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Add camera view for previewing video.
        DCECameraView cameraView = findViewById(R.id.cameraView);

        // Add TextView to display recognized barcode results.
        tvRes = findViewById(R.id.tv_res);

        // Initialize license for Dynamsoft Barcode Reader.
        // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
        // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
        BarcodeReader.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", new DBRLicenseVerificationListener() {
            @Override
            public void DBRLicenseVerificationCallback(boolean isSuccessful, Exception e) {
                runOnUiThread(() -> {
                    if (!isSuccessful) {
                        e.printStackTrace();
                        showErrorDialog(e.getMessage());
                    }
                });
            }
        });

        try {
            // Create an instance of Dynamsoft Barcode Reader.
            reader = new BarcodeReader();
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        // Create a listener to obtain the recognized barcode results.
        TextResultListener mTextResultListener = new TextResultListener() {
            // Obtain the recognized barcode results and display.
            @Override
            public void textResultCallback(int id, ImageData imageData, TextResult[] textResults) {
                runOnUiThread(() -> showResult(textResults));
            }
        };

        // Create an instance of Dynamsoft Camera Enhancer for video streaming.
        mCameraEnhancer = new CameraEnhancer(MainActivity.this);
        mCameraEnhancer.setCameraView(cameraView);

        // Bind the Camera Enhancer instance to the Barcode Reader instance.
        reader.setCameraEnhancer(mCameraEnhancer);

        // Make this setting to get the result. The result will be an object that contains text result and other barcode information.
        reader.setTextResultListener(mTextResultListener);

        // Optimized template for scanning one single barcode from a video input
        reader.updateRuntimeSettings(EnumPresetTemplate.VIDEO_SINGLE_BARCODE);
    }

    @Override
    public void onResume() {
        // Start video barcode reading
        try {
            mCameraEnhancer.open();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        reader.startScanning();
        super.onResume();
    }

    @Override
    public void onPause() {
        // Stop video barcode reading
        try {
            mCameraEnhancer.close();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        reader.stopScanning();
        super.onPause();
    }


    private void showResult(TextResult[] results) {
        if (results != null && results.length > 0) {
            String strRes = "";
            for (int i = 0; i < results.length; i++)
                strRes += results[i].barcodeText + "\n\n";
            tvRes.setText(strRes);
        } else {
            tvRes.setText("");
        }
    }

    private void showErrorDialog(String message) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(this);
        dialog.setTitle(R.string.error_dialog_title)
                .setPositiveButton("OK",null)
                .setMessage(message)
                .show();

    }

}
