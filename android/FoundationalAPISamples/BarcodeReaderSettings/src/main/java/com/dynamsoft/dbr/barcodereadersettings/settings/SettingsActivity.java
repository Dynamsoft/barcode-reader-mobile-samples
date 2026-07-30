package com.dynamsoft.dbr.barcodereadersettings.settings;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.dbr.barcodereadersettings.R;
import com.dynamsoft.dbr.barcodereadersettings.models.SettingsCache;
import com.google.android.material.appbar.MaterialToolbar;

public class SettingsActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        initActionBar();

        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.container, new SettingsFragment())
                    .commit();
        }
    }

    private void initActionBar() {
        MaterialToolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setNavigationOnClickListener(v -> getOnBackPressedDispatcher().onBackPressed());
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        SettingsCache.getCurrentSettings().saveToPreferences(this);
    }
}