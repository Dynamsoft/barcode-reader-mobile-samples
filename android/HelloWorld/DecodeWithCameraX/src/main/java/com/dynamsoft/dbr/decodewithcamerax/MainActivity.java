package com.dynamsoft.dbr.decodewithcamerax;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.pm.PackageManager;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.dynamsoft.core.basic_structures.CapturedResultReceiver;
import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.license.LicenseManager;

import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private CaptureVisionRouter mRouter;
    private AlertDialog mAlertDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (savedInstanceState == null) {
            // Initialize license for Dynamsoft Barcode Reader.
		    // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
		    // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", this, (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                }
            });
        }
        requestCameraPermission(this);

        CameraXImageSourceAdapter cameraXImageSourceAdapter = new CameraXImageSourceAdapter(this, this, findViewById(R.id.previewView));

        mRouter = new CaptureVisionRouter(this);
        try {
            mRouter.setInput(cameraXImageSourceAdapter);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }
        mRouter.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onDecodedBarcodesReceived(DecodedBarcodesResult result) {
                runOnUiThread(() -> showResult(result));
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, new CompletionListener() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                runOnUiThread(() -> showDialog("Error", String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", errorCode, errorString)));
            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();
        mRouter.stopCapturing();
    }


    private void showResult(DecodedBarcodesResult result) {
        StringBuilder strRes = new StringBuilder();

        if (result != null && result.getItems() != null && result.getItems().length > 0) {
            mRouter.stopCapturing();
            for (int i = 0; i < result.getItems().length; i++) {
                BarcodeResultItem item = result.getItems()[i];
                strRes.append(item.getFormatString()).append(":").append(item.getText()).append("\n\n");
            }
            if (mAlertDialog != null && mAlertDialog.isShowing()) {
                return;
            }
            showDialog(getString(R.string.result_title), strRes.toString());
        }
    }


    private void showDialog(String title, String message) {
        if(mAlertDialog == null) {
            mAlertDialog = new AlertDialog.Builder(this).setCancelable(true).setPositiveButton("OK", null)
                    .setOnDismissListener(dialog -> mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, null))
                    .create();
        }
        mAlertDialog.setTitle(title);
        mAlertDialog.setMessage(message);
        mAlertDialog.show();
    }

    public static void requestCameraPermission(Activity activity) {
        try {
            if (ContextCompat.checkSelfPermission(activity, android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.CAMERA}, 1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}