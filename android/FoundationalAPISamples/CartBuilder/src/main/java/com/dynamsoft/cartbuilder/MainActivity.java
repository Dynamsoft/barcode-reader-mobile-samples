package com.dynamsoft.cartbuilder;

import android.os.Bundle;
import android.util.Log;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.cartbuilder.ui.ResultsView;
import com.dynamsoft.cartbuilder.ui.ScanView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.license.LicenseVerificationListener;

public class MainActivity extends AppCompatActivity {
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

        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", new LicenseVerificationListener() {
            @Override
            public void onLicenseVerified(boolean isSuccess, @Nullable Exception e) {
                if (!isSuccess) {
                    Log.e("MainActivity", "onLicenseVerified: " + e.getMessage());
                }
            }
        });

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