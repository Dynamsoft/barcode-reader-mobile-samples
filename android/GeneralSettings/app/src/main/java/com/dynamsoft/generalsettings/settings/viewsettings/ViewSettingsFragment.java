package com.dynamsoft.generalsettings.settings.viewsettings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;

import com.dynamsoft.generalsettings.BaseFragment;
import com.dynamsoft.generalsettings.R;
import com.dynamsoft.generalsettings.util.SettingsCache;

public class ViewSettingsFragment extends BaseFragment {
    SettingsCache settingsCache = SettingsCache.getCurrentSettings();

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_view_settings, container, false);
    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.findViewById(R.id.iv_overlay).setOnClickListener(v -> showTip(R.string.tv_overlay,R.string.tv_overlay_detail));

        SwitchCompat scOverlay = view.findViewById(R.id.sc_overlay);
        scOverlay.setChecked(settingsCache.isOverlayVisible());
        scOverlay.setOnCheckedChangeListener((compoundButton, isChecked) -> settingsCache.setOverlayVisible(isChecked));

        SwitchCompat scTorchBtn = view.findViewById(R.id.sc_torch_button);
        scTorchBtn.setChecked(settingsCache.isTorchBtnVisible());
        scTorchBtn.setOnCheckedChangeListener((compoundButton, isChecked) -> settingsCache.setTorchBtnVisible(isChecked));
    }

    @Override
    protected String getTitle() {
        return "View Settings";
    }

}