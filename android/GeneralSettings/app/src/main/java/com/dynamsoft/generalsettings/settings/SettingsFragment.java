package com.dynamsoft.generalsettings.settings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.dynamsoft.generalsettings.R;
import com.dynamsoft.generalsettings.BaseFragment;
import com.dynamsoft.generalsettings.util.SettingsCache;

public class SettingsFragment extends BaseFragment {
    SettingsCache settingsCache = SettingsCache.getCurrentSettings();

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_settings, container, false);
    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        view.findViewById(R.id.rl_settings_barcode).setOnClickListener(v -> moveToFragment(R.id.action_settingsFragment_to_barcodeSettingsFragment));
        view.findViewById(R.id.rl_settings_camera).setOnClickListener(v -> moveToFragment(R.id.action_settingsFragment_to_cameraSettingsFragment));
        view.findViewById(R.id.rl_settings_view).setOnClickListener(v -> moveToFragment(R.id.action_settingsFragment_to_viewSettingsFragment));
        view.findViewById(R.id.rl_reset_settings).setOnClickListener(v -> {
            settingsCache.resetAllSettings();
            Toast.makeText(getContext(), getText(R.string.reset_settings_tips), Toast.LENGTH_LONG).show();
        });
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    protected String getTitle() {
        return "Settings";
    }

}