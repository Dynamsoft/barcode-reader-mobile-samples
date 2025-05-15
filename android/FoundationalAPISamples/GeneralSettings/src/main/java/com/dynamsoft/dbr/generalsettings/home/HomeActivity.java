package com.dynamsoft.dbr.generalsettings.home;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.models.SettingsCache;
import com.dynamsoft.dbr.generalsettings.scanner.ScannerActivity;
import com.dynamsoft.license.LicenseManager;

public class HomeActivity extends AppCompatActivity {

    private static final String TAG = "HomeActivity";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

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

        findViewById(R.id.btn_start).setOnClickListener(v -> startActivity(new Intent(this, ScannerActivity.class)));

        SettingsCache.getCurrentSettings().loadFromPreferences(this);
    }

}