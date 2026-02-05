package com.dynamsoft.debug;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.license.LicenseManager;

public class HomeActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        if(savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccess, error) -> {
                if (!isSuccess) error.printStackTrace();
            });
        }

        findViewById(R.id.btn_start_capturing).setOnClickListener(v->{
            Intent intent = new Intent(this, CaptureActivity.class);
            startActivity(intent);
        });
    }
}