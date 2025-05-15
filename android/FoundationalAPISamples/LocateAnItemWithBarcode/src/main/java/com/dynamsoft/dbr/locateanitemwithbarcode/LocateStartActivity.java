package com.dynamsoft.dbr.locateanitemwithbarcode;

import android.content.Intent;
import android.os.Bundle;
import android.widget.EditText;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.license.LicenseManager;

public class LocateStartActivity extends AppCompatActivity {
    public static final String KEY_CRABBED_CODE = "Crabbed code";
    public static final String KEY_SEARCHING_ITEM = "Searching item";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_locate_start);

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

        EditText editText = findViewById(R.id.et_text);
        ActivityResultLauncher<Intent> launcher = registerForActivityResult(new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    if (result.getResultCode() == RESULT_OK) {
                        String crabCode = result.getData().getStringExtra(KEY_CRABBED_CODE);
                        editText.setText(crabCode);
                    }
                });
        findViewById(R.id.btn_scan).setOnClickListener(v -> {
            Intent intent = new Intent(LocateStartActivity.this, LocateGrabCodeActivity.class);
            launcher.launch(intent);
        });

        findViewById(R.id.btn_start_searching).setOnClickListener(v -> {
            Intent intent = new Intent(LocateStartActivity.this, LocateScanActivity.class);
            intent.putExtra(KEY_SEARCHING_ITEM, editText.getText().toString());
            startActivity(intent);
        });

    }
}