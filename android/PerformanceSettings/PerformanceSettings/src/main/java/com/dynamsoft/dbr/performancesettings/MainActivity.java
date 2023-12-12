package com.dynamsoft.dbr.performancesettings;

import android.app.AlertDialog;
import android.os.Bundle;
import android.os.Handler;
import android.view.KeyEvent;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.dynamsoft.dbr.performancesettings.ui.result.ResultFragment;
import com.dynamsoft.dbr.performancesettings.ui.scanner.ScannerFragment;
import com.dynamsoft.license.LicenseManager;

public class MainActivity extends AppCompatActivity {

    private static final String LICENSE = "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.container, ScannerFragment.newInstance())
                    .commit();
            // Initialize license for Dynamsoft Barcode Reader.
            // The LICENSE string is defined above. It is a time-limited trial license. Note that network connection is required for this license to work.
            // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
            LicenseManager.initLicense(LICENSE, this, (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                }
            });
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            Fragment fragment = getCurrentFragment();
            if (fragment instanceof ResultFragment && (((ResultFragment) fragment).isCapturing())) {
                ((ResultFragment) fragment).showTip();
                return false;
            }
        }
        return super.onKeyDown(keyCode, event);
    }

    private Fragment getCurrentFragment() {
        return getSupportFragmentManager().getFragments().get(0);
    }
}