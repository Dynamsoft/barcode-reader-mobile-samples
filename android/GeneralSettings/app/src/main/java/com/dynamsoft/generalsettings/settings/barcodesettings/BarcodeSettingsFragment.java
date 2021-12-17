package com.dynamsoft.generalsettings.settings.barcodesettings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;

import com.dynamsoft.generalsettings.BaseFragment;
import com.dynamsoft.generalsettings.MainActivity;
import com.dynamsoft.generalsettings.R;
import com.dynamsoft.generalsettings.util.SettingsCache;

import java.util.Objects;

public class BarcodeSettingsFragment extends BaseFragment {
    private SettingsCache settingsCache = SettingsCache.getCurrentSettings();
    private EditText etExpectedCount;

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_barcode_settings, container, false);
    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.findViewById(R.id.view_barcode_formats).setOnClickListener(v -> moveToFragment(R.id.action_barcodeSettingsFragment_to_barcodeFormatsFragment));
        view.findViewById(R.id.iv_expected_count).setOnClickListener(v -> showTip(R.string.tv_expected_count, R.string.tv_expected_count_detail));

        settingsCache = SettingsCache.getCurrentSettings();
        SwitchCompat scOverlay = view.findViewById(R.id.sc_continuousScan);
        scOverlay.setChecked(settingsCache.isContinuousScan());
        scOverlay.setOnCheckedChangeListener((compoundButton, isChecked) -> settingsCache.setContinuousScan(isChecked));

        etExpectedCount = view.findViewById(R.id.et_expected_barcode_count);
        etExpectedCount.setText(String.valueOf(settingsCache.getExpectedBarcodeCount()));
        etExpectedCount.setOnEditorActionListener((textView, actionId, keyEvent) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                settingsCache.setExpectedBarcodeCount(Integer.parseInt(textView.getText().toString()));
                if (checkEtExpectedCount()) {
                    hideKeyboard(etExpectedCount);
                    etExpectedCount.clearFocus();
                }
                return true;
            }
            return false;
        });
    }

    @Override
    public void onResume() {
        ((MainActivity) requireActivity()).setCurrentFragment(this);
        super.onResume();
    }

    @Override
    public void onPause() {
        ((MainActivity) requireActivity()).setCurrentFragment(null);
        super.onPause();
    }

    public boolean checkEtExpectedCount() {
        if (etExpectedCount.getVisibility() == View.VISIBLE) {
            int tempValue;
            try {
                tempValue = Integer.parseInt(etExpectedCount.getText().toString());
                if (tempValue >= 0 && tempValue <= 999) {
                    settingsCache.setExpectedBarcodeCount(tempValue);
                } else {
                    Toast.makeText(getContext(), "Input Invalid! Legal value: [0, 999]", Toast.LENGTH_LONG).show();
                    etExpectedCount.setText("1");
                    return false;
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                Toast.makeText(getContext(), "Input Invalid! Legal value: [0, 999]", Toast.LENGTH_LONG).show();
                etExpectedCount.setText("1");
                return false;
            }
        }
        return true;
    }

    @Override
    protected String getTitle() {
        return "Barcode Settings";
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home && checkEtExpectedCount()) {
            requireActivity().onBackPressed();
            return true;
        }
        return true;
    }

    @Override
    public boolean checkEditText() {
        return checkEtExpectedCount();
    }
}
