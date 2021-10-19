//This sample shows how to make settings to reach the best barcode scanning speed when using Dynamsoft Barcode Reader.

package com.dynamsoft.speedfirstsettings;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRDLSLicenseVerificationListener;
import com.dynamsoft.dbr.DCESettingParameters;
import com.dynamsoft.dbr.DMDLSConnectionParameters;
import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.EnumBinarizationMode;
import com.dynamsoft.dbr.EnumDeblurMode;
import com.dynamsoft.dbr.EnumLocalizationMode;
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
    private long mStartTime;
    private long mProcessedFrames;

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
            DMDLSConnectionParameters dbrParameters = new DMDLSConnectionParameters();
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
                // Drop the first frame for accurate timing
                if (mProcessedFrames == -1){
                    mStartTime = System.currentTimeMillis();
                    mProcessedFrames++;
                    return;
                }

                mProcessedFrames++;
                long avgDuration = (System.currentTimeMillis() - mStartTime)/mProcessedFrames;

                (MainActivity.this).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        showResult(textResults, mProcessedFrames, avgDuration);
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

        // Speed first settings for barcode scanning.
        this.configSpeedFirst();

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

    private void configSpeedFirst() {
        try {
            PublicRuntimeSettings settings = reader.getRuntimeSettings();

            // Parameter 1. Set expected barcode formats
            // The simpler barcode format, the faster decoding speed.
            // Here we use OneD barcode format to demonstrate.
            settings.barcodeFormatIds = EnumBarcodeFormat.BF_ONED;

            // Parameter 2. Set expected barcode count
            // The less barcode count, the faster decoding speed.
            settings.expectedBarcodesCount = 1;

            // Parameter 3. Set the threshold for the image shrinking for localization.
            // The smaller the threshold, the smaller the image shrinks.  The default value is 2300.
            settings.scaleDownThreshold = 1200;

            // Parameter 4. Set the binarization mode for convert grayscale image to binary image.
            // Mostly, the less binarization modes set, the faster decoding speed.
            settings.binarizationModes = new int[]{EnumBinarizationMode.BM_LOCAL_BLOCK,0,0,0,0,0,0,0};

            // Parameter 5. Set localization mode.
            // LM_ONED_FAST_SCAN: Localizing barcodes quickly. However, it is only for OneD barcodes. It is also recommended in interactive scenario.
            settings.localizationModes = new int[]{EnumLocalizationMode.LM_ONED_FAST_SCAN, 0,0,0,0,0,0,0};

            // LM_SCAN_DIRECTLY: Localizes barcodes quickly. It is both for OneD and TweD barcodes. This mode is recommended in interactive scenario.
            // settings.localizationModes = new int[]{EnumLocalizationMode.LM_SCAN_DIRECTLY,0,0,0,0,0,0,0};


            // Parameter 6. Reduce deblurModes setting
            // DeblurModes will improve the readability and accuracy but decrease the reading speed.
            // Please update your settings here if you want to enable different Deblurmodes.
            settings.deblurModes = new int[]{EnumDeblurMode.DM_BASED_ON_LOC_BIN,EnumDeblurMode.DM_THRESHOLD_BINARIZATION,0,0,0,0,0,0,0,0};

            // Parameter 7. Set timeout(ms) if the application is very time sensitive.
            // If timeout, the decoding thread will exit at the next check point.
            settings.timeout = 500;

            reader.updateRuntimeSettings(settings);

            // Other potentially accelerated arguments of various modes.

            // Argument 4.a Disable the EnableFillBinaryVacancy argument.
            // Local block binarization process might cause vacant area in barcode. The barcode reader will fill the vacant black by default (default value 1). Set the value 0 to disable this process.
            reader.setModeArgument("BinarizationModes", 0, "EnableFillBinaryVacancy", "0");

            // Argument 5.a Sets the scan direction when searching barcode.
            // It is valid only when the type of LocalizationMode is LM_ONED_FAST_SCAN or LM_SCAN_DIRECTLY.
            // 0: Both vertical and horizontal direction.
            // 1: Vertical direction.
            // 2: Horizontal direction.
            // Read more about localization mode members: https://www.dynamsoft.com/barcode-reader/parameters/enum/parameter-mode-enums.html?ver=latest#localizationmode
            reader.setModeArgument("LocalizationModes",0,"ScanDirection","0");

        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        // Parameter 8. Enable fast mode to generate cropped frame for speeding decoding.
        // Fast mode is the feature of Dynamsoft Camera Enhancer. If the feature is turned on, Camera Enhancer will crop the frame to transmit the small size frame to the barcode reader for decoding.
        // Read more about Dynamsoft Camera Enhancer.
        try {
            mCameraEnhancer.enableFeatures(EnumEnhancerFeatures.EF_FAST_MODE);
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onResume() {
        // Start video barcode reading
        reader.StartCameraEnhancer();
        mProcessedFrames = -1;
        super.onResume();
    }

    @Override
    public void onPause() {
        // Stop video barcode reading
        reader.StopCameraEnhancer();
        super.onPause();
    }

    // The barcoding result will be an object. Please view more in the online document.
    private void showResult(TextResult[] results, long frames, long duration) {
        if (results != null && results.length > 0) {
            String strRes = "Total processed frames: " + frames + "\n\nAverage frame cost: " + duration + "ms.\n\n";
            for (int i = 0; i < results.length; i++)
                strRes += results[i].barcodeText + "\n\n";
            tvRes.setText(strRes);
        } else {
            tvRes.setText("");
        }
    }
}
