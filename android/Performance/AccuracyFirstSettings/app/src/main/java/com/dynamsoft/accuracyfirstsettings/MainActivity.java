//This sample shows how to reach the best barcode decoding accuracy when using Dynamsoft Barcode Reader.

package com.dynamsoft.accuracyfirstsettings;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRDLSLicenseVerificationListener;
import com.dynamsoft.dbr.DCESettingParameters;
import com.dynamsoft.dbr.DMDLSConnectionParameters;
import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.PublicRuntimeSettings;
import com.dynamsoft.dbr.TextResultCallback;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.DCECameraView;
import com.dynamsoft.dce.DCELicenseVerificationListener;
import com.dynamsoft.dce.EnumEnhancerFeatures;

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

        try {
            // Create an instance of Dynamsoft Barcode Reader.
            reader = new BarcodeReader();

            // Initialize license for Dynamsoft Barcode Reader.
            // The organization id 200001 here will grant you a public trial license good for 7 days. Note that network connection is required for this license to work.
            // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
            // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
            DMDLSConnectionParameters dbrParameters = new com.dynamsoft.dbr.DMDLSConnectionParameters();
            dbrParameters.organizationID = "200001";
            reader.initLicenseFromDLS(dbrParameters, new DBRDLSLicenseVerificationListener() {
                @Override
                public void DLSLicenseVerificationCallback(boolean isSuccessful, Exception e) {
                    if (!isSuccessful) {
                        e.printStackTrace();
                    }
                }
            });

        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        // Create a listener to obtain the recognized barcode results.
        TextResultCallback mTextResultCallback = new TextResultCallback() {
            // Obtain the recognized barcode results and display.
            @Override
            public void textResultCallback(int i, TextResult[] textResults, Object userData) {
                (MainActivity.this).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        showResult(textResults);
                    }
                });
            }
        };

        // Initialize license for Dynamsoft Camera Enhancer.
        // The string "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" here is a 7-day free license. Note that network connection is required for this license to work.
        // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dce&utm_source=installer&package=android
        CameraEnhancer.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", new DCELicenseVerificationListener() {
            @Override
            public void DCELicenseVerificationCallback(boolean isSuccess, Exception e) {
                if (!isSuccess) {
                    e.printStackTrace();
                }
            }
        });

        // Create an instance of Dynamsoft Camera Enhancer for video streaming.
        mCameraEnhancer = new CameraEnhancer(MainActivity.this);
        mCameraEnhancer.setCameraView(cameraView);
        
        // Enable overlay visibility to highlight the recognized barcode results.
        cameraView.setOverlayVisible(true);

        // Accuracy first settings for barcode scanning.
        this.configAccuracyFirst();

        // Create settings of video barcode reading.
        DCESettingParameters dceSettingParameters = new DCESettingParameters();

        // This cameraInstance is the instance of the Camera Enhancer.
        // The Barcode Reader will use this instance to take control of the camera and acquire frames from the camera to start the barcode decoding process.
        dceSettingParameters.cameraInstance = mCameraEnhancer;

        // Make this setting to get the result. The result will be an object that contains text result and other barcode information.
        dceSettingParameters.textResultCallback = mTextResultCallback;

        // Bind the Camera Enhancer instance to the Barcode Reader instance.
        reader.SetCameraEnhancerParam(dceSettingParameters);
    }

    private void configAccuracyFirst() {

        try {
            // Obtain current runtime settings of instance.
            PublicRuntimeSettings s = reader.getRuntimeSettings();

            // Here we set expected barcode count to 1.
            s.expectedBarcodesCount = 1;

            // Parameter 1. Set expected barcode format
            // The more precise the barcode format is set, the higher the accuracy.
            // Mostly, misreading only occurs on reading oneD barcode. So here we use OneD barcode format to demonstrate.
            s.barcodeFormatIds = EnumBarcodeFormat.BF_ONED;
            s.barcodeFormatIds_2 = 0;

            // Parameter 2. Set the minimal result confidence.
            // The greater the confidence, the higher the accuracy.
            // Filter by minimal confidence of the decoded barcode. We recommend using 30 as the default minimal confidence value
            s.minResultConfidence = 30;

            // Parameter 3. Sets the minimum length of barcode text for filtering.
            // The more precise the barcode text length is set, the higher the accuracy.
            s.minBarcodeTextLength = 6;

            // Apply the new settings to the instance
            reader.updateRuntimeSettings(s);

        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        // Parameter 4. Enable result verification for video barcode reading.
        // After the result verification is turned on, the SDK will verify the result among multiple video frames.
        reader.enableResultVerification(true);

        // Parameter 5. Enable frame filter to filter out low quality frames
        // Frame filter is the feature of Dynamsoft Camera Enhancer. If the feature is turned on, Camera Enhancer will only deliver the high quality frame to barcode reader for decoding.
        try {
            mCameraEnhancer.enableFeatures(EnumEnhancerFeatures.EF_FRAME_FILTER);
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onResume() {
        // Start video barcode reading
        reader.StartCameraEnhancer();
        super.onResume();
    }

    @Override
    public void onPause() {
        // Stop video barcode reading
        reader.StopCameraEnhancer();
        super.onPause();
    }

    // The barcoding result will be an object. Please view more in the online document.
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
}
