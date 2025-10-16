package com.dynamsoft.dbr.decodewithcamerax;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.decodewithcamerax.ui.resultsview.CustomizedResultsDisplayView;
import com.dynamsoft.dbr.decodewithcamerax.ui.PreviewWithDrawingQuads;
import com.dynamsoft.license.LicenseManager;

import java.util.ArrayList;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    private CaptureVisionRouter mRouter;
    private PreviewWithDrawingQuads mPreviewWithDrawingQuads;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

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
        requestCameraPermission(this);
        mPreviewWithDrawingQuads = findViewById(R.id.previewView);
        CameraXImageSourceAdapter cameraXImageSourceAdapter = new CameraXImageSourceAdapter(this, this, mPreviewWithDrawingQuads);

        mRouter = new CaptureVisionRouter();
        try {
            // Set the camera enhancer as the input.
            mRouter.setInput(cameraXImageSourceAdapter);
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
                ArrayList<Quadrilateral> list = new ArrayList<>();
                for (BarcodeResultItem item : result.getItems()) {
                    list.add(item.getLocation());
                }
                mPreviewWithDrawingQuads.updateQuadsOnBuffer(list);
                runOnUiThread(() -> showResult(result));
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
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
    }

    @Override
    protected void onPause() {
        super.onPause();
        mRouter.stopCapturing();
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