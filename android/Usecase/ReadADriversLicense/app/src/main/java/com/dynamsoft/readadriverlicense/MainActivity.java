package com.dynamsoft.readadriverlicense;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.TextView;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRDLSLicenseVerificationListener;
import com.dynamsoft.dbr.DMDLSConnectionParameters;
import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.EnumBarcodeFormat_2;
import com.dynamsoft.dbr.EnumConflictMode;
import com.dynamsoft.dbr.EnumIntermediateResultType;
import com.dynamsoft.dbr.PublicRuntimeSettings;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.dbr.TextResultCallback;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.DCECameraView;

import java.util.HashMap;

public class MainActivity extends AppCompatActivity {
    DCECameraView cameraView;
    private TextView mFlash;
    BarcodeReader reader;
    CameraEnhancer mCameraEnhancer;
    private boolean isFinished = false;

    @SuppressLint("HandlerLeak")
    private final Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            TextResult[] results = (TextResult[]) msg.obj;
            if (isFinished)
                return;
            for (TextResult result : results) {
                if (DBRDriverLicenseUtil.ifDriverLicense(result.barcodeText)) {
                    isFinished = true;
                    HashMap<String, String> resultMaps = DBRDriverLicenseUtil.readUSDriverLicense(result.barcodeText);
                    Intent intent = new Intent(MainActivity.this, ResultActivity.class);
                    DriverLicense driverLicense = new DriverLicense();
                    driverLicense.documentType = "DL";
                    driverLicense.firstName = resultMaps.get(DBRDriverLicenseUtil.FIRST_NAME);
                    driverLicense.middleName = resultMaps.get(DBRDriverLicenseUtil.MIDDLE_NAME);
                    driverLicense.lastName = resultMaps.get(DBRDriverLicenseUtil.LAST_NAME);
                    driverLicense.gender = resultMaps.get(DBRDriverLicenseUtil.GENDER);
                    driverLicense.addressStreet = resultMaps.get(DBRDriverLicenseUtil.STREET);
                    driverLicense.addressCity = resultMaps.get(DBRDriverLicenseUtil.CITY);
                    driverLicense.addressState = resultMaps.get(DBRDriverLicenseUtil.STATE);
                    driverLicense.addressZip = resultMaps.get(DBRDriverLicenseUtil.ZIP);
                    driverLicense.licenseNumber = resultMaps.get(DBRDriverLicenseUtil.LICENSE_NUMBER);
                    driverLicense.issueDate = resultMaps.get(DBRDriverLicenseUtil.ISSUE_DATE);
                    driverLicense.expiryDate = resultMaps.get(DBRDriverLicenseUtil.EXPIRY_DATE);
                    driverLicense.birthDate = resultMaps.get(DBRDriverLicenseUtil.BIRTH_DATE);
                    driverLicense.issuingCountry = resultMaps.get(DBRDriverLicenseUtil.ISSUING_COUNTRY);

                    intent.putExtra("DriverLicense", driverLicense);
                    startActivity(intent);
                }
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        cameraView = findViewById(R.id.cameraView);
        mFlash = findViewById(R.id.tv_flash);

        try {
            reader = new BarcodeReader();

            DMDLSConnectionParameters dbrParameters = new DMDLSConnectionParameters();
            // The organization id 200001 here will grant you a time-limited public trial license.
            // After that, please visit: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
            // to request for an extension.
            dbrParameters.organizationID = "200001";
            reader.initLicenseFromDLS(dbrParameters, new DBRDLSLicenseVerificationListener() {
                @Override
                public void DLSLicenseVerificationCallback(boolean isSuccessful, Exception e) {
                    runOnUiThread(() -> {
                        if (!isSuccessful) {
                            e.printStackTrace();
                            showErrorDialog(e.getMessage());
                        }
                    });
                }
            });
            initBarcodeReader();

            // Get the TestResult object from the callback
            TextResultCallback mTextResultCallback = new TextResultCallback() {
                @Override
                public void textResultCallback(int i, TextResult[] textResults, Object userData) {
                    if (textResults == null || textResults.length == 0)
                        return;
                    Message message = handler.obtainMessage();
                    message.obj = textResults;
                    handler.sendMessage(message);
                }
            };


            //Create a camera module for video barcode scanning.
            mCameraEnhancer = new CameraEnhancer(MainActivity.this);
            mCameraEnhancer.setCameraView(cameraView);

            // Bind the Camera Enhancer instance to the Barcode Reader instance.
            reader.setCameraEnhancer(mCameraEnhancer);

            // Make this setting to get the result. The result will be an object that contains text result and other barcode information.
            reader.setTextResultCallback(mTextResultCallback, null);

        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onResume() {
        isFinished = false;
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
        try {
            mCameraEnhancer.close();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        reader.stopScanning();
        super.onPause();
    }

    private boolean mIsFlashOn = false;

    public void onFlashClick(View v) {
        if (mCameraEnhancer == null)
            return;
        try {
            if (!mIsFlashOn) {
                mCameraEnhancer.turnOnTorch();
                mIsFlashOn = true;
                mFlash.setText("Flash OFF");
            } else {
                mCameraEnhancer.turnOffTorch();
                mIsFlashOn = false;
                mFlash.setText("Flash ON");
            }
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
    }

    void initBarcodeReader() throws BarcodeReaderException {
        PublicRuntimeSettings runtimeSettings = reader.getRuntimeSettings();
        runtimeSettings.barcodeFormatIds = EnumBarcodeFormat.BF_ALL;
        runtimeSettings.barcodeFormatIds_2 = EnumBarcodeFormat_2.BF2_NULL;
        runtimeSettings.timeout = 3000;
        runtimeSettings.intermediateResultTypes = EnumIntermediateResultType.IRT_TYPED_BARCODE_ZONE;
        if (reader != null) {
            reader.initRuntimeSettingsWithString("{\"ImageParameter\":{\"Name\":\"Balance\",\"DeblurLevel\":5,\"ExpectedBarcodesCount\":512,\"LocalizationModes\":[{\"Mode\":\"LM_CONNECTED_BLOCKS\"},{\"Mode\":\"LM_SCAN_DIRECTLY\"}]}}", EnumConflictMode.CM_OVERWRITE);
            reader.updateRuntimeSettings(runtimeSettings);
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