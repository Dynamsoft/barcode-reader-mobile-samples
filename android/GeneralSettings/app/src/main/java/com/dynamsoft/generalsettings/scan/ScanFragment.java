package com.dynamsoft.generalsettings.scan;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.DMDLSConnectionParameters;
import com.dynamsoft.dbr.ImageData;
import com.dynamsoft.dbr.PublicRuntimeSettings;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.dbr.TextResultCallback;
import com.dynamsoft.dbr.TextResultListener;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.DCECameraView;
import com.dynamsoft.dce.RegionDefinition;
import com.dynamsoft.generalsettings.R;
import com.dynamsoft.generalsettings.BaseFragment;
import com.dynamsoft.generalsettings.util.SettingsCache;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class ScanFragment extends BaseFragment {

    DCECameraView cameraView;
    CameraEnhancer cameraEnhancer;
    BarcodeReader reader;
    private boolean isFragmentOnFocus;
    private boolean ifContinuousScan;
    private boolean isResultsShowing;

    private TextView tvContinueScanRes;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize license for Dynamsoft Barcode Reader.
        // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
        // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
        BarcodeReader.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", new DBRLicenseVerificationListener() {
            @Override
            public void DBRLicenseVerificationCallback(boolean isSuccessful, Exception e) {
                requireActivity().runOnUiThread(() -> {
                    if (!isSuccessful) {
                        e.printStackTrace();
                        showErrorDialog(e.getMessage());
                    }
                });
            }
        });
        // Initialize license for Dynamsoft Camera Enhancer.
        CameraEnhancer.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", new DCELicenseVerificationListener() {
            @Override
            public void DCELicenseVerificationCallback(boolean b, Exception e) {
                runOnUiThread(() -> {
                    if (!b && e != null) {
                        e.printStackTrace();
                        showErrorDialog(e.getMessage());
                    }
                });
            }
        });

        try {
            // Create an instance of Dynamsoft Barcode Reader.
            reader = new BarcodeReader();
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        // Create an instance of Dynamsoft Camera Enhancer for video streaming.
        cameraEnhancer = new CameraEnhancer(requireContext());
    }

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_scan, container, false);
    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        tvContinueScanRes = view.findViewById(R.id.tv_continueScanRes);

        // Bind the CameraView instance to the Camera Enhancer
        // The CameraView controls the UI elements including the video streaming
        cameraView = view.findViewById(R.id.camera_view);
        cameraEnhancer.setCameraView(cameraView);

        // Bind the Camera Enhancer instance to the Barcode Reader
        reader.setCameraEnhancer(cameraEnhancer);

        // Set the text result callback.
        reader.setTextResultListener(mTextResultListener);
    }

    @Override
    public void onResume() {
        isFragmentOnFocus = true;
        SettingsCache settingsCache = SettingsCache.getCurrentSettings();
        initSettings(settingsCache);

        // Open the camera via the Camera Enhancer.
        try {
            cameraEnhancer.open();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }

        // Start the barcode decoding thread.
        reader.startScanning();
        super.onResume();
    }

    @Override
    public void onPause() {
        isFragmentOnFocus = false;

        // Close the camera via the Camera Enhancer.
        try {
            cameraEnhancer.close();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }

        // Stop the barcode decoding thread.
        reader.stopScanning();
        super.onPause();
    }

    @Override
    public void onPrepareOptionsMenu(@NonNull Menu menu) {
        menu.findItem(R.id.action_settings).setVisible(true);
        super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == R.id.action_settings) {
            moveToFragment(R.id.action_scanFragment_to_settingsFragment);
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected String getTitle() {
        return "General Settings";
    }

    public void initSettings(SettingsCache settingsCache) {
        isResultsShowing = false;
        ifContinuousScan = settingsCache.isContinuousScan();
        try {
            // Get the current runtime settings and add additional settings.
            PublicRuntimeSettings dbrSettings = reader.getRuntimeSettings();

            // Set the barcode formats to the selected formats
            dbrSettings.barcodeFormatIds = settingsCache.getBarcodeFormats();
            dbrSettings.barcodeFormatIds_2 = settingsCache.getBarcodeFormats_2();

            // Set the expected barcode count, the less expected barcode count, the higher processing speed.
            dbrSettings.expectedBarcodesCount = settingsCache.getExpectedBarcodeCount();
            reader.updateRuntimeSettings(dbrSettings);
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        try {
            if (settingsCache.isScanRegionEnabled()) {
                // Configure the scanregion via DCE.
                // Scan region determines the size of frame that DBR will works on.
                // The regionDefinition data contains the position of the top, bottom, left and right border of the specified region.
                // The position of border can be defined by a percentage value or pixel value, which depends on the setting of ByPercentage
                RegionDefinition regionDefinition = settingsCache.getScanRegion();

                // Use the regionDefinition data to set the scanRegion
                cameraEnhancer.setScanRegion(regionDefinition);
            } else {
                cameraEnhancer.setScanRegion(null);
            }

            // Set the overlays visible to create highlighted overlays on the decoded barcodes.
            cameraView.setOverlayVisible(settingsCache.isOverlayVisible());

            // Set the torch button visible to display a torch button on the UI.
            cameraView.setTorchButtonVisible(settingsCache.isTorchBtnVisible());

            // Change the resolution of the video streaming.
            // The input parameter should be one of the preset resolution in EnumResolution.
            cameraEnhancer.setResolution(settingsCache.getResolution());

            // Enable DCE features by inputting the combined value of EnumEnhancerFeatures.
            cameraEnhancer.enableFeatures(settingsCache.getEnumEnhancerFeatures());
            cameraEnhancer.disableFeatures(~settingsCache.getEnumEnhancerFeatures());
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
    }

    // Configurations of the textResultCallback.
    // Each time when result is output, the result text will be displayed.
    TextResultListener mTextResultListener = new TextResultListener() {
        @Override
        public void textResultCallback(int i, ImageData imageData, TextResult[] textResults) {
            if (textResults != null && textResults.length > 0 && (!isResultsShowing || ifContinuousScan)) {

                // Stop the barcode decoding thread when the scan mode is not continuous scan.
                if (!ifContinuousScan) {
                    reader.stopScanning();
                }
                requireActivity().runOnUiThread(() -> showResults(textResults));
            }
        }
    };

    @SuppressLint("SetTextI18n")
    private void showResults(TextResult[] results) {
        isResultsShowing = true;
        StringBuilder continueRes = new StringBuilder();
        View dialogView = LayoutInflater.from(getContext()).inflate(R.layout.result_dialog, null);
        TextView resultCount = dialogView.findViewById(R.id.tv_result_count);
        resultCount.setText(getText(R.string.Total) + String.valueOf(results.length));
        final ArrayList<Map<String, String>> resultMapList = new ArrayList<>();
        for (int i = 0; i < results.length; i++) {
            Map<String, String> temp = new HashMap<>();
            temp.put("Index", String.valueOf(i + 1));
            if (results[i].barcodeFormat_2 != 0) {
                temp.put("Format", results[i].barcodeFormatString_2);
                continueRes.append("\n\n").append(getString(R.string.format)).append(results[i].barcodeFormatString_2).append("\n").append(getString(R.string.text)).append(results[i].barcodeText);
            } else {
                temp.put("Format", results[i].barcodeFormatString);
                continueRes.append("\n\n").append(getString(R.string.format)).append(results[i].barcodeFormatString).append("\n").append(getString(R.string.text)).append(results[i].barcodeText);
            }
            temp.put("Text", results[i].barcodeText);
            resultMapList.add(temp);
        }
        if (ifContinuousScan) {
            isResultsShowing = false;
            tvContinueScanRes.setText("" + getText(R.string.Total) + results.length + "\n" + continueRes);
            tvContinueScanRes.setVisibility(View.VISIBLE);
        } else {
            tvContinueScanRes.setVisibility(View.GONE);
            ResultAdapter resultAdapter = new ResultAdapter(resultMapList);
            RecyclerView resultsRecyclerView = dialogView.findViewById(R.id.rv_result_list);
            resultsRecyclerView.setLayoutManager(new LinearLayoutManager(dialogView.getContext()));
            resultsRecyclerView.setAdapter(resultAdapter);
            final AlertDialog resultBuilder = new AlertDialog.Builder(getContext()).create();
            resultBuilder.setOnCancelListener(dialog -> {
                isResultsShowing = false;
                if (isFragmentOnFocus) {
                    reader.startScanning();
                }
            });
            resultBuilder.setView(dialogView);
            if (isFragmentOnFocus)
                resultBuilder.show();
        }
    }

    private void showErrorDialog(String message) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(requireContext());
        dialog.setTitle(R.string.error_dialog_title)
                .setPositiveButton("OK", null)
                .setMessage(message)
                .show();

    }
}