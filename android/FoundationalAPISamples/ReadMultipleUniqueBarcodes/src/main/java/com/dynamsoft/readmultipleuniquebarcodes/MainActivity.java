package com.dynamsoft.readmultipleuniquebarcodes;

import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.DrawingItem;
import com.dynamsoft.dce.DrawingLayer;
import com.dynamsoft.dce.DrawingStyleManager;
import com.dynamsoft.dce.EnumCoordinateBase;
import com.dynamsoft.dce.QuadDrawingItem;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    public static final String EXTRA_RESULTS = "EXTRA_RESULTS";
    private static final String SPLITTER = "___";
    // To store unique scanned barcodes("${formatString}___${text}")
    private final HashSet<String> cachedBarcode = new HashSet<>();
    private CameraEnhancer mCamera;
    private CaptureVisionRouter mRouter;
    private boolean isCaptureClicked = false;
    private int cachedBarcodesStyleId;
    private int notCachedBarcodesStyleId;

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
        PermissionUtil.requestCameraPermission(this);

        Button btnCapture = findViewById(R.id.btn_capture);
        btnCapture.setOnClickListener(v -> isCaptureClicked = true);

        Button btnShowResults = findViewById(R.id.btn_show_results);
        btnShowResults.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, ResultsActivity.class);
            intent.putStringArrayListExtra(EXTRA_RESULTS, new ArrayList<>(cachedBarcode));
            startActivity(intent);
        });

        TextView tvBadgeCount = findViewById(R.id.tv_badge);

        CameraView cameraView = findViewById(R.id.camera_view);
        mCamera = new CameraEnhancer(cameraView, this);

        mRouter = new CaptureVisionRouter();
        try {
            // Set the camera enhancer as the input.
            mRouter.setInput(mCamera);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }

        MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
        filter.enableLatestOverlapping(EnumCapturedResultItemType.CRIT_BARCODE, true);
        mRouter.addResultFilter(filter);

        // Customize drawing items in this sample, we hide the DBR drawing layer.
        cameraView.getDrawingLayer(DrawingLayer.DBR_LAYER_ID).setVisible(false);
        DrawingLayer cachedBarcodesLayer = cameraView.createDrawingLayer();
        DrawingLayer notCachedBarcodesLayer = cameraView.createDrawingLayer();
        cachedBarcodesStyleId = DrawingStyleManager.createDrawingStyle(0xFF49F549, 2, 0, 0);
        notCachedBarcodesStyleId = DrawingStyleManager.createDrawingStyle(0xFFF59A49, 2, 0, 0);
        cachedBarcodesLayer.setDefaultStyle(cachedBarcodesStyleId);
        notCachedBarcodesLayer.setDefaultStyle(notCachedBarcodesStyleId);

        mRouter.addResultReceiver(new CapturedResultReceiver() {
            @Override
            // Implement the callback method to receive DecodedBarcodesResult.
            // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
            // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
            public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
                if (isCaptureClicked && result.getItems().length > 0) {
                    isCaptureClicked = false;

                    for (BarcodeResultItem item : result.getItems()) {
                        cachedBarcode.add(item.getFormatString() + SPLITTER + item.getText());
                    }
                    runOnUiThread(() -> {
                        tvBadgeCount.setVisibility(View.VISIBLE);
                        tvBadgeCount.setText(String.valueOf(cachedBarcode.size()));
                    });
                }

                // Drawing cached and not cached barcodes with different styles
                ArrayList<DrawingItem> cachedDrawingItems = new ArrayList<>();
                ArrayList<DrawingItem> notCachedDrawingItems = new ArrayList<>();
                for (BarcodeResultItem item : result.getItems()) {
                    String key = item.getFormatString() + SPLITTER + item.getText();
                    if (cachedBarcode.contains(key)) {
                        cachedDrawingItems.add(new QuadDrawingItem(item.getLocation(), EnumCoordinateBase.CB_IMAGE));
                    } else {
                        notCachedDrawingItems.add(new QuadDrawingItem(item.getLocation(), EnumCoordinateBase.CB_IMAGE));
                    }
                }
                cachedBarcodesLayer.setDrawingItems(cachedDrawingItems);
                notCachedBarcodesLayer.setDrawingItems(notCachedDrawingItems);
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();
        // Start video barcode reading
        // Open the camera.
        mCamera.open();
        // Start capturing. If success, you will receive results in the CapturedResultReceiver.
        mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, new CompletionListener() {
            @Override
            public void onSuccess() {
                //noop
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
    public void onPause() {
        super.onPause();
        // Stop video barcode reading
        mCamera.close();
        mRouter.stopCapturing();
    }
}