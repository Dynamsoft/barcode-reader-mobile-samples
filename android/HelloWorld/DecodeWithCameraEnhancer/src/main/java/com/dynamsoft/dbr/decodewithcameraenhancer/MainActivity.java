package com.dynamsoft.dbr.decodewithcameraenhancer;

import android.app.AlertDialog;
import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.Feedback;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.license.LicenseManager;

import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private CameraEnhancer mCamera;
    private CaptureVisionRouter mRouter;

    private AlertDialog mAlertDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", this, (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                    runOnUiThread(()-> ((TextView) findViewById(R.id.tv_license_error)).setText("License initialization failed: "+error.getMessage()));
                }
            });
        }
        PermissionUtil.requestCameraPermission(this);


        CameraView cameraView = findViewById(R.id.camera_view);
        mCamera = new CameraEnhancer(cameraView, this);
        mRouter = new CaptureVisionRouter(this);
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
            public void onDecodedBarcodesReceived(DecodedBarcodesResult result) {
                runOnUiThread(() -> showResult(result));
            }
        });

    }

    @Override
    public void onResume() {
        // Start video barcode reading
        try {
            // Open the camera.
            mCamera.open();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        // Start capturing. If success, you will receive results in the CapturedResultReceiver.
        mRouter.startCapturing(EnumPresetTemplate.PT_READ_SINGLE_BARCODE, new CompletionListener() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                runOnUiThread(() -> showDialog("Error", String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", errorCode, errorString)));
            }
        });
        super.onResume();
    }

    @Override
    public void onPause() {
        // Stop video barcode reading
        try {
            mCamera.close();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        mRouter.stopCapturing();
        super.onPause();
    }

    // This is the method that access all BarcodeResultItem in the DecodedBarcodesResult and extract the content.
    private void showResult(DecodedBarcodesResult result) {
        StringBuilder strRes = new StringBuilder();

        if (result != null && result.getItems() != null && result.getItems().length > 0) {
            mRouter.stopCapturing();
            mRouter.getInput().clearBuffer();
            // Extract the barcode format and the barcode text from the BarcodeResultItem.
            for (int i = 0; i < result.getItems().length; i++) {
                BarcodeResultItem item = result.getItems()[i];
                strRes.append(item.getFormatString()).append(":").append(item.getText()).append("\n\n");
            }
            if (mAlertDialog != null && mAlertDialog.isShowing()) {
                return;
            }
            Feedback.vibrate(this);
            showDialog(getString(R.string.result_title), strRes.toString());
        }
    }


    private void showDialog(String title, String message) {
        if (mAlertDialog == null) {
            // Restart the capture when the dialog is closed
            mAlertDialog = new AlertDialog.Builder(this).setCancelable(true).setPositiveButton("OK", null)
                    .setOnDismissListener(dialog -> mRouter.startCapturing(EnumPresetTemplate.PT_READ_SINGLE_BARCODE, null))
                    .create();
        }
        mAlertDialog.setTitle(title);
        mAlertDialog.setMessage(message);
        mAlertDialog.show();
    }

}