package com.dynamsoft.readmultiplebarcodes;

import android.app.AlertDialog;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

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
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.util.HashMap;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    public static final String EXTRA_RESULTS = "EXTRA_RESULTS";
    private static final String SPLITTER = "___";
    private CameraEnhancer mCamera;
    private CaptureVisionRouter mRouter;
    private boolean isConfirmClicked = false;

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


        Button btnConfirm = findViewById(R.id.btn_confirm);
        btnConfirm.setOnClickListener(v -> isConfirmClicked = true);

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


        mRouter.addResultReceiver(new CapturedResultReceiver() {
            @Override
            // Implement the callback method to receive DecodedBarcodesResult.
            // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
            // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
            public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
                if (isConfirmClicked && result.getItems().length > 0) {
                    isConfirmClicked = false;
                    final HashMap<String, Integer> barcodes = new HashMap<>();

                    for (BarcodeResultItem item : result.getItems()) {
                        String key = item.getFormatString() + SPLITTER + item.getText();
                        Integer count = barcodes.get(key);
                        if (count == null) {
                            count = 0;
                        }
                        barcodes.put(key, count + 1);
                    }


                    // Stop capturing to avoid repeated calls to onDecodedBarcodesReceived and showResults.
                    mRouter.stopCapturing();
                    mCamera.close();

                    runOnUiThread(() -> showResults(barcodes));
                }
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

    private void showResults(HashMap<String, Integer> barcodes) {
        findViewById(R.id.results_container).setVisibility(View.VISIBLE);
        Button btnClose = findViewById(R.id.btn_close_results);
        btnClose.setOnClickListener(v -> {
            findViewById(R.id.results_container).setVisibility(View.GONE);

            //Resume scanning after closing the results view.
            mCamera.open();
            mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, null);
        });


        int totalCount = 0;
        for (int count : barcodes.values()) {
            totalCount += count;
        }
        TextView tvResultsTitle = findViewById(R.id.tv_results_title);
        tvResultsTitle.setText(getString(R.string.result_title, totalCount));

        RecyclerView rvResults = findViewById(R.id.rv_results);
        rvResults.setLayoutManager(new LinearLayoutManager(this));
        rvResults.setAdapter(new ResultsAdapter(barcodes));
    }
}