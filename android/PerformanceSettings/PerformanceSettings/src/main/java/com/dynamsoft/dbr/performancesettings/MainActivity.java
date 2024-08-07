package com.dynamsoft.dbr.performancesettings;

import android.os.Bundle;
import android.view.KeyEvent;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.dynamsoft.dbr.performancesettings.ui.result.ResultFragment;
import com.dynamsoft.dbr.performancesettings.ui.scanner.ScannerFragment;
import com.dynamsoft.license.LicenseManager;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.container, ScannerFragment.newInstance())
                    .commit();
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", this, (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                    runOnUiThread(()-> ((TextView) findViewById(R.id.tv_license_error)).setText("License initialization failed: "+error.getMessage()));
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