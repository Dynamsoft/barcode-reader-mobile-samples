package com.dynamsoft.decodewithcamerax;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.os.Bundle;
import android.view.View;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;

public class MainActivity extends AppCompatActivity {
    private AlertDialog errorDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_activity);

        // Initialize license for Dynamsoft Barcode Reader.
        // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
        // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
        BarcodeReader.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", new DBRLicenseVerificationListener() {
            @Override
            public void DBRLicenseVerificationCallback(boolean isSuccessful, Exception e) {
                runOnUiThread(() -> {
                    if (!isSuccessful) {
                        e.printStackTrace();
                        showLicenseErrorDialog(e.getMessage());
                    }
                });
            }
        });

    }

    private void showLicenseErrorDialog(String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        errorDialog = builder.setTitle(R.string.error_dialog_title)
                .setPositiveButton("OK", null)
                .setMessage(message)
                .setOnDismissListener(dialog -> {
                    errorDialog = null;
                })
                .show();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (errorDialog != null) {
            errorDialog.dismiss();
        }
    }

    public void btnStartScanning(View view) {
        view.setClickable(false);
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.container, CameraFragment.newInstance())
                .addToBackStack(null)
                .commit();
        view.setClickable(true);
    }
}