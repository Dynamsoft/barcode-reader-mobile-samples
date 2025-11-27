package com.dynamsoft.dbr.decodewithcameraenhancer;

import android.app.AlertDialog;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.decodewithcameraenhancer.ui.resultsview.CustomizedResultsDisplayView;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.license.LicenseManager;

import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private CameraEnhancer mCamera;
    private CaptureVisionRouter mRouter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                }
            });
        }
        PermissionUtil.requestCameraPermission(this);

        CameraView cameraView = findViewById(R.id.camera_view);
        mCamera = new CameraEnhancer(cameraView, this);
        mRouter = new CaptureVisionRouter();
        try {
            // Set the camera enhancer as the input.
            mRouter.setInput(mCamera);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        mRouter.addResultReceiver(new CapturedResultReceiver() {
            @Override
            // Implement the callback method to receive DecodedBarcodesResult.
            // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
            // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
            public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
                runOnUiThread(() -> showResult(result));
            }
        });

    }

    @Override
    public void onResume() {
        // Start video barcode reading
        // Open the camera.
        mCamera.open();
        // Start capturing. If success, you will receive results in the CapturedResultReceiver.
        mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, new CompletionListener() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                runOnUiThread(() -> new AlertDialog.Builder(MainActivity.this)
                        .setCancelable(true)
                        .setPositiveButton("OK", null)
                        .setTitle("StartCapturing error")
                        .setMessage(String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", errorCode, errorString))
                        .show());
            }
        });
        super.onResume();
    }

    @Override
    public void onPause() {
        // Stop video barcode reading
        mCamera.close();
        mRouter.stopCapturing();
        super.onPause();
    }

    // This is the method that access all BarcodeResultItem in the DecodedBarcodesResult and extract the content.
    @MainThread
    private void showResult(DecodedBarcodesResult result) {
        if (result != null && result.getItems().length > 0) {
            CustomizedResultsDisplayView resultView = findViewById(R.id.results_view);
            resultView.setVisibility(View.VISIBLE);
            resultView.updateResults(result.getItems());
        }
    }

}