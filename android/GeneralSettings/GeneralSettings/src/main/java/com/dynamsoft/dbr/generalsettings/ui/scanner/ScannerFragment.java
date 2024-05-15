package com.dynamsoft.dbr.generalsettings.ui.scanner;

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
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.core.basic_structures.EnumGrayscaleTransformationMode;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.cvr.SimplifiedCaptureVisionSettings;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.SimplifiedBarcodeReaderSettings;
import com.dynamsoft.dbr.generalsettings.MainViewModel;
import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.bean.BarcodeSettings;
import com.dynamsoft.dbr.generalsettings.bean.CameraSettings;
import com.dynamsoft.dbr.generalsettings.bean.ViewSettings;
import com.dynamsoft.dbr.generalsettings.databinding.FragmentScannerBinding;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.DrawingLayer;
import com.dynamsoft.dce.Feedback;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class ScannerFragment extends Fragment {
    private CameraEnhancer mCamera;
    private CaptureVisionRouter mRouter;

    private FragmentScannerBinding binding;

    private boolean isResultsShowing;
    private boolean ifContinuousScan;

    private boolean isBeepEnabled;
    private boolean isVibrationEnabled;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        PermissionUtil.requestCameraPermission(requireActivity());
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentScannerBinding.inflate(inflater, container, false);
        MainViewModel viewModel = new ViewModelProvider(requireActivity()).get(MainViewModel.class);
        mCamera = new CameraEnhancer(binding.cameraView, getViewLifecycleOwner());
        mRouter = new CaptureVisionRouter(requireContext());
        try {
            mRouter.setInput(mCamera);
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }

        mRouter.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onDecodedBarcodesReceived(DecodedBarcodesResult result) {
                if (result != null && result.getItems() != null && result.getItems().length > 0 && (!isResultsShowing || ifContinuousScan)) {

                    // Stop the barcode decoding when the scan mode is not continuous scan.
                    if (!ifContinuousScan) {
                        mRouter.stopCapturing();
                        mRouter.getInput().clearBuffer();
                    }
                    if (isVibrationEnabled) {
                        Feedback.vibrate(requireContext());
                    }
                    if (isBeepEnabled) {
                        Feedback.beep(requireContext());
                    }
                    requireActivity().runOnUiThread(() -> showResultItems(result.getItems()));
                }
            }
        });

        initSettings(mRouter, mCamera, viewModel);
        return binding.getRoot();
    }

    @Override
    public void onResume() {
        super.onResume();
        try {
            mCamera.open();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, /*@Nullable CompletionListener completionHandler = */new CompletionListener() {
            @Override
            public void onSuccess() {
            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                requireActivity().runOnUiThread(() -> new AlertDialog.Builder(requireContext())
                        .setTitle("Error")
                        .setMessage(String.format(Locale.getDefault(), "ErrorCode:%d%nErrorMessage:%s",errorCode, errorString))
                        .setCancelable(true)
                        .setPositiveButton("OK", null)
                        .show());
            }
        });
    }

    @Override
    public void onPause() {
        super.onPause();
        try {
            mCamera.close();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        mRouter.stopCapturing();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

    @Override
    public void onPrepareOptionsMenu(@NonNull Menu menu) {
        menu.findItem(R.id.action_settings).setVisible(true);
        super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == R.id.action_settings) {
            NavHostFragment.findNavController(this).navigate(R.id.action_scannerFragment_to_settingsFragment);
        }
        return super.onOptionsItemSelected(item);
    }

    private void initSettings(CaptureVisionRouter cvr, CameraEnhancer dce, MainViewModel viewModel) {
        initBarcodeSettings(cvr, viewModel.barcodeSettings);
        initCameraSettings(dce, viewModel.cameraSettings);
        initViewSettings(dce.getCameraView(), viewModel.viewSettings);
    }

    private void initBarcodeSettings(CaptureVisionRouter cvr, BarcodeSettings newSettings) {
        try {
            // Get the simplified settings of the current template.
            SimplifiedCaptureVisionSettings simplifiedSettings = cvr.getSimplifiedSettings(EnumPresetTemplate.PT_READ_BARCODES);
            // Get the simplified barcode reader settings.
            SimplifiedBarcodeReaderSettings barcodeSettings = simplifiedSettings.barcodeSettings;
            // Modify the barcode formats, expected count, min result confidence, etc.
            barcodeSettings.barcodeFormatIds = newSettings.getBarcodeFormat();
            barcodeSettings.expectedBarcodesCount = newSettings.getExpectedCount();
            barcodeSettings.minResultConfidence = newSettings.getMinResultConfidence();
            barcodeSettings.barcodeTextRegExPattern = newSettings.getBarcodeTextRegExPattern();
            barcodeSettings.grayscaleTransformationModes = new int[]{EnumGrayscaleTransformationMode.GTM_ORIGINAL,
                    newSettings.isDecodeInvertedBarcodesEnabled() ? EnumGrayscaleTransformationMode.GTM_INVERTED : 0};
            cvr.updateSettings(EnumPresetTemplate.PT_READ_BARCODES, simplifiedSettings);
            
            // Enable multi-frame cross filter. It includes deduplication and the result cross verification features. 
            MultiFrameResultCrossFilter resultCrossFilter = new MultiFrameResultCrossFilter();
            resultCrossFilter.enableResultCrossVerification(EnumCapturedResultItemType.CRIT_BARCODE, newSettings.isResultCrossVerificationEnabled());
            resultCrossFilter.enableResultDeduplication(EnumCapturedResultItemType.CRIT_BARCODE, newSettings.isResultDeduplicationEnabled());
            resultCrossFilter.setDuplicateForgetTime(EnumCapturedResultItemType.CRIT_BARCODE, newSettings.getDuplicationForgetTime());
            // Add the result filter so that the above settings are set to CVR.
            cvr.addResultFilter(resultCrossFilter);

            ifContinuousScan = newSettings.isContinuousScan();
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }
    }

    private void initCameraSettings(CameraEnhancer dce, CameraSettings newSettings) {
        try {
            // Set the resolution.
            dce.setResolution(newSettings.getResolution());
            // Enable the advanced features. The advanced features include auto-zoom, enhanced focus, frame filter, etc.
            dce.enableEnhancedFeatures(newSettings.getEnhancedFeatures());
            dce.disableEnhancedFeatures(~newSettings.getEnhancedFeatures());
            if (newSettings.isScanRegionEnabled()) {
                // Set a scan region to speed up processing.
                dce.setScanRegion(newSettings.getScanRegion());
            } else {
                dce.setScanRegion(null);
            }
            isBeepEnabled = newSettings.isBeepEnabled();
            isVibrationEnabled = newSettings.isVibrationEnabled();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
    }

    private void initViewSettings(CameraView cameraView, ViewSettings newSettings) {
        cameraView.getDrawingLayer(DrawingLayer.DBR_LAYER_ID).setVisible(newSettings.isHighlightBarcode());
        cameraView.setTorchButtonVisible(newSettings.isTorchButtonVisible());
    }

    private void showResultItems(BarcodeResultItem[] resultItems) {
        isResultsShowing = true;
        StringBuilder continueRes = new StringBuilder();
        View dialogView = LayoutInflater.from(getContext()).inflate(R.layout.result_dialog, null);
        TextView resultCount = dialogView.findViewById(R.id.tv_result_count);
        resultCount.setText(String.format(getString(R.string.Total), resultItems.length));
        final ArrayList<Map<String, String>> resultMapList = new ArrayList<>();
        for (int i = 0; i < resultItems.length; i++) {
            Map<String, String> temp = new HashMap<>();
            temp.put("Index", String.valueOf(i + 1));
            temp.put("Format", resultItems[i].getFormatString());
            continueRes.append("\n\n").append(getString(R.string.format)).append(resultItems[i].getFormatString()).append("\n").append(getString(R.string.text)).append(resultItems[i].getText());
            temp.put("Text", resultItems[i].getText());
            resultMapList.add(temp);
        }
        if (binding == null) {
            return;
        }
        if (ifContinuousScan) {
            isResultsShowing = false;
            binding.tvContinueScanRes.setText(String.format(getString(R.string.Show_Result_Text), resultItems.length, continueRes));
            binding.tvContinueScanRes.setVisibility(View.VISIBLE);
        } else {
            binding.tvContinueScanRes.setVisibility(View.GONE);
            ResultAdapter resultAdapter = new ResultAdapter(resultMapList);
            RecyclerView resultsRecyclerView = dialogView.findViewById(R.id.rv_result_list);
            resultsRecyclerView.setLayoutManager(new LinearLayoutManager(dialogView.getContext()));
            resultsRecyclerView.setAdapter(resultAdapter);
            AlertDialog resultDialog = new AlertDialog.Builder(getContext()).create();
            resultDialog.setOnCancelListener(dialog -> {
                isResultsShowing = false;
                mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, null);
            });
            resultDialog.setView(dialogView);
            resultDialog.show();
        }
    }
}