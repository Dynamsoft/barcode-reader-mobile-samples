//This is a HelloWorld sample that illustrates how to set up a simplest video barcode scanner with Dynamsoft Barcode Reader.

package com.dynamsoft.helloworld;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRDLSLicenseVerificationListener;
import com.dynamsoft.dbr.DCESettingParameters;
import com.dynamsoft.dbr.DMDLSConnectionParameters;
import com.dynamsoft.dbr.TextResultCallback;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.DCECameraView;
import com.dynamsoft.dce.DCELicenseVerificationListener;

public class MainActivity extends AppCompatActivity {
    BarcodeReader reader;
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
            public void DCELicenseVerificationCallback(boolean b, Exception e) {
                if (!b) {
                    e.printStackTrace();
                }
            }
        });

        // Create an instance of Dynamsoft Camera Enhancer for video streaming.
        CameraEnhancer mCameraEnhancer = new CameraEnhancer(MainActivity.this);
        mCameraEnhancer.setCameraView(cameraView);

		// Create settings of video barcode reading.
        DCESettingParameters dceSettingParameters = new DCESettingParameters();

        // This cameraInstance is the instance of the Dynamsoft Camera Enhancer.
        // The Barcode Reader will use this instance to take control of the camera and acquire frames from the camera to start the barcode decoding process.
        dceSettingParameters.cameraInstance = mCameraEnhancer;

        // Make this setting to get the result. The result will be an object that contains text result and other barcode information.
        dceSettingParameters.textResultCallback = mTextResultCallback;

		// Bind the Camera Enhancer instance to the Barcode Reader instance.
        reader.SetCameraEnhancerParam(dceSettingParameters);
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
