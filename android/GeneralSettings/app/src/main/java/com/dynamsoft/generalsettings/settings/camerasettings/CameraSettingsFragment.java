package com.dynamsoft.generalsettings.settings.camerasettings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;

import com.dynamsoft.dce.EnumResolution;
import com.dynamsoft.generalsettings.BaseFragment;
import com.dynamsoft.generalsettings.MainActivity;
import com.dynamsoft.generalsettings.R;
import com.dynamsoft.generalsettings.util.SettingsCache;

import java.util.ArrayList;

public class CameraSettingsFragment extends BaseFragment {
    SettingsCache settingsCache = SettingsCache.getCurrentSettings();
    EditText etRegionTop, etRegionBottom, etRegionLeft, etRegionRight;
    EditText[] etRegionValues;
    ArrayList<String> resolutionList = new ArrayList<>();
    {
        resolutionList.add("480P");
        resolutionList.add("720P");
        resolutionList.add("1080P");
        resolutionList.add("2K");
        resolutionList.add("4K");
    }

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_camera_settings, container, false);
    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.findViewById(R.id.iv_enhanced_focus).setOnClickListener(v -> showTip(R.string.tv_enhanced_focus, R.string.tv_enhanced_focus_detail));
        view.findViewById(R.id.iv_sharpness_filter).setOnClickListener(v -> showTip(R.string.tv_sharpness_filter, R.string.tv_sharpness_filter_detail));
        view.findViewById(R.id.iv_sensor_filter).setOnClickListener(v -> showTip(R.string.tv_sensor_filter, R.string.tv_sensor_filter_detail));
        view.findViewById(R.id.iv_auto_zoom).setOnClickListener(v -> showTip(R.string.tv_auto_zoom, R.string.tv_auto_zoom_detail));
        view.findViewById(R.id.iv_fast_mode).setOnClickListener(v -> showTip(R.string.tv_fast_mode, R.string.tv_fast_mode_detail));
        view.findViewById(R.id.iv_scan_region).setOnClickListener(v -> showTip(R.string.tv_scan_region, R.string.tv_scan_region_detail));

        Spinner spResolution = view.findViewById(R.id.sp_resolution);
        ArrayAdapter<String> resolutionsAdapter = new ArrayAdapter<>(getContext(),R.layout.simple_spinner_item, resolutionList);
        resolutionsAdapter.setDropDownViewResource(R.layout.simple_spinner_item);
        spResolution.setAdapter(resolutionsAdapter);
        spResolution.setSelection(settingsCache.getResolution().ordinal() - 1);
        spResolution.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int position, long id) {
                settingsCache.setResolution(EnumResolution.fromValue(position+1));
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        SwitchCompat scEnhancedFocus = view.findViewById(R.id.sc_enhanced_focus);
        scEnhancedFocus.setChecked(settingsCache.isEnhancedFocusEnabled());
        scEnhancedFocus.setOnCheckedChangeListener((buttonView, isChecked) -> settingsCache.setEnhancedFocusEnabled(isChecked));

        SwitchCompat scSharpnessFilter = view.findViewById(R.id.sc_sharpness_filter);
        scSharpnessFilter.setChecked(settingsCache.isSharpnessFilterEnabled());
        scSharpnessFilter.setOnCheckedChangeListener((buttonView, isChecked) -> settingsCache.setSharpnessFilterEnabled(isChecked));

        SwitchCompat scSensorFilter = view.findViewById(R.id.sc_sensor_filter);
        scSensorFilter.setChecked(settingsCache.isSensorFilterEnabled());
        scSensorFilter.setOnCheckedChangeListener((buttonView, isChecked) -> settingsCache.setSensorFilterEnabled(isChecked));

        SwitchCompat scAutoZoom = view.findViewById(R.id.sc_auto_zoom);
        scAutoZoom.setChecked(settingsCache.isAutoZoomEnabled());
        scAutoZoom.setOnCheckedChangeListener((buttonView, isChecked) -> settingsCache.setAutoZoomEnabled(isChecked));

        SwitchCompat scFastMode = view.findViewById(R.id.sc_fast_mode);
        scFastMode.setChecked(settingsCache.isFastModeEnabled());
        scFastMode.setOnCheckedChangeListener((buttonView, isChecked) -> settingsCache.setFastModeEnabled(isChecked));

        LinearLayout viewScanRegionSettings = view.findViewById(R.id.view_region_settings);
        SwitchCompat scScanRegion = view.findViewById(R.id.sc_scan_region);
        if (settingsCache.isScanRegionEnabled()) {
            viewScanRegionSettings.setVisibility(View.VISIBLE);
        } else {
            viewScanRegionSettings.setVisibility(View.GONE);
        }
        scScanRegion.setChecked(settingsCache.isScanRegionEnabled());
        scScanRegion.setOnCheckedChangeListener((buttonView, isChecked) -> {
            settingsCache.setScanRegionEnabled(isChecked);
            if (settingsCache.isScanRegionEnabled()) {
                viewScanRegionSettings.setVisibility(View.VISIBLE);
            } else {
                viewScanRegionSettings.setVisibility(View.GONE);
            }
        });

        etRegionTop = view.findViewById(R.id.et_scan_region_top);
        etRegionBottom = view.findViewById(R.id.et_scan_region_bottom);
        etRegionLeft = view.findViewById(R.id.et_scan_region_left);
        etRegionRight = view.findViewById(R.id.et_scan_region_right);
        etRegionValues = new EditText[]{etRegionTop, etRegionBottom, etRegionLeft, etRegionRight};
        for (int i = 0; i < 4; i++) {
            etRegionValues[i].setText(String.valueOf(settingsCache.getScanRegionRect()[i]));
            int finalI = i;
            etRegionValues[i].setOnEditorActionListener((textView, actionId, keyEvent) -> {
                if (actionId == EditorInfo.IME_ACTION_DONE || actionId == EditorInfo.IME_ACTION_NEXT) {
                    if(textView.getText().toString().equals("")){
                        textView.setText(String.valueOf(settingsCache.getScanRegionRect()[finalI]));
                    }
                    settingsCache.getScanRegionRect()[finalI] = Integer.parseInt(textView.getText().toString());
                    if (actionId == EditorInfo.IME_ACTION_DONE && checkEtRegionValues()) {
                        hideKeyboard(etRegionValues[finalI]);
                        etRegionValues[finalI].clearFocus();
                    }
                }
                return false;
            });
        }
    }

    @Override
    public void onResume() {
        ((MainActivity) getActivity()).setCurrentFragment(this);
        super.onResume();
    }

    @Override
    public void onPause() {
        ((MainActivity) getActivity()).setCurrentFragment(null);
        super.onPause();
    }

    @Override
    protected String getTitle() {
        return "Camera Settings";
    }

    public boolean checkEtRegionValues() {
        int tempValue;
        boolean inputValid = true;
        int[] values = new int[4];//{top, bottom, left, right}
        for (int i = 0; i < 4; i++) {
            if(etRegionValues[i].getText().toString().equals("")){
                etRegionValues[i].setText(String.valueOf(settingsCache.getScanRegionRect()[i]));
            }
            tempValue = Integer.parseInt(etRegionValues[i].getText().toString());
            if (tempValue >= 0 && tempValue <= 100) {
                settingsCache.getScanRegionRect()[i] = tempValue;
            } else if (tempValue > 100) {
                settingsCache.getScanRegionRect()[i] = 100;
                etRegionValues[i].setText("100");
                inputValid = true;
            }
            values[i] = Integer.parseInt(etRegionValues[i].getText().toString());
        }
        //if top>bottom || left>right, show the error tip and correct the wrong values
        if (values[0] > values[1]) {
            Toast.makeText(getContext(), getText(R.string.scan_region_settings_error), Toast.LENGTH_LONG).show();
//            values[1] = values[0];
//            etRegionValues[1].setText(String.valueOf(values[1]));
            inputValid = false;
        }
        if (values[2] > values[3]) {
            Toast.makeText(getContext(), getText(R.string.scan_region_settings_error), Toast.LENGTH_LONG).show();
//            values[3] = values[2];
//            etRegionValues[3].setText(String.valueOf(values[3]));
            inputValid = false;
        }
        settingsCache.uptedeScanRegionValues(inputValid);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home && checkEtRegionValues()) {
            requireActivity().onBackPressed();
            return true;
        }
        return true;
    }

    @Override
    public boolean checkEditText() {
        return checkEtRegionValues();
    }

}