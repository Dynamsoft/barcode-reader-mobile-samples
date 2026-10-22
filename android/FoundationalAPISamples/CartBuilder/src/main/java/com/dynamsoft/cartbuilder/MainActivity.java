package com.dynamsoft.cartbuilder;

import android.os.Bundle;
import android.util.Log;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.cartbuilder.ui.ResultsView;
import com.dynamsoft.cartbuilder.ui.ScanView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.license.LicenseManager;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";

    private ScanView scanView;

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
                    Log.e(TAG, "License initialization failed: " + (error != null ? error.getMessage() : "unknown error"));
                }
            });
        }

        PermissionUtil.requestCameraPermission(this);

        ResultsView resultsView = findViewById(R.id.results_view);
        scanView = findViewById(R.id.scan_view);
        scanView.setBarcodeResultReceiver(resultsView::addBarcodes);

        findViewById(R.id.btn_action).setOnClickListener(v -> {
            if (scanView.isScanning()) {
                scanView.stopScanning();
                scanView.setVisibility(View.GONE);
            } else {
                scanView.startScanning();
                scanView.setVisibility(View.VISIBLE);
            }
        });

        findViewById(R.id.tv_clear_list).setOnClickListener(v -> resultsView.clearBarcodes());
    }

    @Override
    protected void onPause() {
        super.onPause();
        scanView.stopScanning();
        scanView.setVisibility(View.GONE);
    }
}