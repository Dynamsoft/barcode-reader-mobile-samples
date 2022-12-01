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
    private EditText etMinResultConfidence;
    private EditText etDuplicateForgetTime;
    private EditText etMinDecInterval;

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_barcode_settings, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.findViewById(R.id.view_barcode_formats).setOnClickListener(v -> moveToFragment(R.id.action_barcodeSettingsFragment_to_barcodeFormatsFragment));
        view.findViewById(R.id.iv_expected_count).setOnClickListener(v -> showTip(R.string.tv_expected_count, R.string.tv_expected_count_detail));
        view.findViewById(R.id.iv_result_verification).setOnClickListener(v -> showTip(R.string.result_verification, R.string.result_verification_info));
        view.findViewById(R.id.iv_duplicate_filter).setOnClickListener(v -> showTip(R.string.duplicate_filter, R.string.duplicate_filter_info));
        view.findViewById(R.id.iv_forget_time).setOnClickListener(v -> showTip(R.string.duplicate_forget_time, R.string.duplicate_forget_time_info));
        view.findViewById(R.id.iv_mini_dec_internal).setOnClickListener(v -> showTip(R.string.mini_decode_interval, R.string.mini_decode_interval_info));

        settingsCache = SettingsCache.getCurrentSettings();

        SwitchCompat scOverlay = view.findViewById(R.id.sc_continuousScan);
        SwitchCompat scResultVerification = view.findViewById(R.id.sc_result_verification);
        SwitchCompat scDuplicateFilter = view.findViewById(R.id.sc_duplicate_filter);
        SwitchCompat scDecInvertedBarcodes = view.findViewById(R.id.sc_dec_inverted_barcodes);
        etExpectedCount = view.findViewById(R.id.et_expected_barcode_count);
        etMinResultConfidence = view.findViewById(R.id.et_mini_confidence);
        etDuplicateForgetTime = view.findViewById(R.id.et_duplicate_forget_time);
        etMinDecInterval = view.findViewById(R.id.et_mini_dec_internal);

        scOverlay.setChecked(settingsCache.isContinuousScan());
        scOverlay.setOnCheckedChangeListener((compoundButton, isChecked) -> settingsCache.setContinuousScan(isChecked));

        scResultVerification.setChecked(settingsCache.isResultVerificationEnabled());
        scResultVerification.setOnCheckedChangeListener((compoundButton, isChecked) -> settingsCache.setResultVerificationEnabled(isChecked));

        scDuplicateFilter.setChecked(settingsCache.isDuplicateFilterEnabled());
        scDuplicateFilter.setOnCheckedChangeListener((compoundButton, isChecked) -> settingsCache.setDuplicateFilterEnabled(isChecked));

        scDecInvertedBarcodes.setChecked(settingsCache.isDecodeInvertedBarcodesEnabled());
        scDecInvertedBarcodes.setOnCheckedChangeListener((compoundButton, isChecked) -> settingsCache.setDecodeInvertedBarcodesEnabled(isChecked));

        etExpectedCount.setText(String.valueOf(settingsCache.getExpectedBarcodeCount()));
        etExpectedCount.setOnEditorActionListener((textView, actionId, keyEvent) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                settingsCache.setExpectedBarcodeCount(Integer.parseInt(textView.getText().toString()));
//                if (checkEtExpectedCount()) {
//                    hideKeyboard(etExpectedCount);
//                    etExpectedCount.clearFocus();
//                }
                if(checkInvalidValue("1", 0, 999, etExpectedCount)){
                    settingsCache.setExpectedBarcodeCount(Integer.parseInt(etExpectedCount.getText().toString()));
                    hideKeyboard(etExpectedCount);
                    etExpectedCount.clearFocus();
                }
                return true;
            }
            return false;
        });

        etMinResultConfidence.setText(String.valueOf(settingsCache.getMiniResultConfidence()));
        etMinResultConfidence.setOnEditorActionListener((textView, actionId, keyEvent) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                settingsCache.setMiniResultConfidence(Integer.parseInt(textView.getText().toString()));
                if(checkInvalidValue("30", 0, 100, etExpectedCount)){
                    settingsCache.setExpectedBarcodeCount(Integer.parseInt(etMinResultConfidence.getText().toString()));
                    hideKeyboard(etMinResultConfidence);
                    etMinResultConfidence.clearFocus();
                }
                return true;
            }
            return false;
        });

        etDuplicateForgetTime.setText(String.valueOf(settingsCache.getForgetTime()));
        etDuplicateForgetTime.setOnEditorActionListener((textView, actionId, keyEvent) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                settingsCache.setForgetTime(Integer.parseInt(textView.getText().toString()));
                if(checkInvalidValue("3000", 0, 600000, etDuplicateForgetTime)){
                    settingsCache.setForgetTime(Integer.parseInt(etDuplicateForgetTime.getText().toString()));
                    hideKeyboard(etDuplicateForgetTime);
                    etDuplicateForgetTime.clearFocus();
                }
                return true;
            }
            return false;
        });

        etMinDecInterval.setText(String.valueOf(settingsCache.getMiniDecodeInterval()));
        etMinDecInterval.setOnEditorActionListener((textView, actionId, keyEvent) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                settingsCache.setForgetTime(Integer.parseInt(textView.getText().toString()));
                if(checkInvalidValue("0", 0, 0x7fffffff, etMinDecInterval)){
                    settingsCache.setForgetTime(Integer.parseInt(etMinDecInterval.getText().toString()));
                    hideKeyboard(etMinDecInterval);
                    etMinDecInterval.clearFocus();
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

    public boolean checkInvalidValue(String defaultValue, int min, int max, EditText view) {
        if (view.getVisibility() == View.VISIBLE) {
            int tempValue;
            try {
                tempValue = Integer.parseInt(view.getText().toString());
                if (tempValue >= min && tempValue <= max) {
                    return true;
                } else {
                    String errorMsg = "Input Invalid! Legal value: ["+ min +"," + max +"]";
                    Toast.makeText(getContext(), errorMsg, Toast.LENGTH_LONG).show();
                    view.setText(defaultValue);
                    return false;
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                String errorMsg = "Input Invalid! Legal value: ["+ min +"," + max +"]";
                Toast.makeText(getContext(), errorMsg, Toast.LENGTH_LONG).show();
                view.setText(defaultValue);
                return false;
            }
        }
        return true;
    }

    @Override
    protected String getTitle() {
        return "Barcode Settings";
    }

//    @Override
//    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
//        if (item.getItemId() == android.R.id.home && checkEtExpectedCount()) {
//            requireActivity().onBackPressed();
//            return true;
//        }
//        return true;
//    }

    @Override
    public boolean checkEditText() {
        return true;
    }
}
