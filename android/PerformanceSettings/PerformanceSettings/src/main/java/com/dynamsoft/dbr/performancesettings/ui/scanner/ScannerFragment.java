package com.dynamsoft.dbr.performancesettings.ui.scanner;

import android.app.AlertDialog;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.dynamsoft.core.basic_structures.CapturedResultReceiver;
import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.DSRect;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.EnumDeblurMode;
import com.dynamsoft.dbr.performancesettings.ImageUtil;
import com.dynamsoft.dbr.performancesettings.R;
import com.dynamsoft.dbr.performancesettings.databinding.FragmentScannerBinding;
import com.dynamsoft.dbr.performancesettings.ui.result.ResultFragment;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ScannerFragment extends Fragment {

    private CameraEnhancer mCamera;
    private CaptureVisionRouter mRouter;

    private final MultiFrameResultCrossFilter mFilter = new MultiFrameResultCrossFilter();

    {
        mFilter.enableResultCrossVerification(EnumCapturedResultItemType.CRIT_BARCODE, true);
    }

    private FragmentScannerBinding binding;
    private String mCurrentTemplate = EnumPresetTemplate.PT_READ_SINGLE_BARCODE;
    private final ExecutorService changeSettingsThread = Executors.newSingleThreadExecutor();

    private final ActivityResultLauncher<String> getFileImage = registerForActivityResult(new ActivityResultContracts.GetContent(), uri -> {
        try {
            InputStream inputStream;
            if (uri != null && ((inputStream = requireActivity().getContentResolver().openInputStream(uri)) != null)) {
                byte[] selectedFileBytes = ImageUtil.inputStreamToBytes(inputStream);
                requireActivity().getSupportFragmentManager()
                        .beginTransaction()
                        .replace(R.id.container, ResultFragment.newInstance(selectedFileBytes, mCurrentTemplate))
                        .addToBackStack("Scanner Fragment")
                        .commit();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    });

    public static ScannerFragment newInstance() {
        return new ScannerFragment();
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        PermissionUtil.requestCameraPermission(requireActivity());
        mRouter = new CaptureVisionRouter(requireContext());
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentScannerBinding.inflate(inflater, container, false);

        //Only resetting the cameraView can make other configurations(e.g. ScanRegion) unchanged.
        //Therefore, you need to use Activity as the lifecycleOwner of CameraEnhancer.
        //You can also create a new CameraEnhancer instance with new CameraView and Fragment.getViewLifecycleOwner()
        // every time Fragment.onCreateView() is called and reset other configurations.
        if(mCamera == null) {
            mCamera = new CameraEnhancer(binding.cameraView, requireActivity());
        } else {
            mCamera.setCameraView(binding.cameraView);
        }

        try {
            mRouter.setInput(mCamera);
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }
        mRouter.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onDecodedBarcodesReceived(DecodedBarcodesResult result) {
                if (result != null && result.getItems() != null && result.getItems().length > 0) {
                    requireActivity().runOnUiThread(() -> showResultsItems(result.getItems()));
                }
            }
        });
        initView();
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
                        .setCancelable(true).setPositiveButton("OK", null)
                        .setMessage(String.format(Locale.getDefault(), "ErrorCode:%d%nErrorMessage:%s", errorCode, errorString))
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

    private void initView() {
        binding.btnSelectfile.setOnClickListener(v -> getFileImage.launch("image/*"));

        binding.rgModes.setOnCheckedChangeListener((group, checkedId) -> {
            if (binding != null) {
                binding.btnSelectfile.setVisibility(checkedId == R.id.btn_speed_first || checkedId == R.id.btn_read_rate_first ? View.VISIBLE : View.GONE);
            }

            //Prevents repeated calls when re-enter the ScannerFragment
            if(!group.findViewById(checkedId).isPressed()) {
                return;
            }

            changeSettingsThread.submit(() -> {
                try {
                    mRouter.stopCapturing(); //time-consuming op
                    mRouter.resetSettings();
                    if (checkedId == R.id.btn_single_barcode) {
                        setSingleBarcodeMode();
                    } else if (checkedId == R.id.btn_speed_first) {
                        setVideoSpeedFirst();
                    } else if (checkedId == R.id.btn_read_rate_first) {
                        setVideoReadRateFirst();
                    } else if (checkedId == R.id.btn_accuracy_first) {
                        setVideoAccuracy();
                    }
                    mRouter.startCapturing(mCurrentTemplate, null);
                } catch (CaptureVisionRouterException | CameraEnhancerException e) {
                    e.printStackTrace();
                }
            });
        });
    }

    private void setSingleBarcodeMode() throws CameraEnhancerException {
        mCurrentTemplate = EnumPresetTemplate.PT_READ_SINGLE_BARCODE;

        mRouter.removeResultFilter(mFilter);

        // Reset the scanRegion settings.
        mCamera.setScanRegion(null);
    }

    private void setVideoSpeedFirst() throws CaptureVisionRouterException, CameraEnhancerException {
        mCurrentTemplate = EnumPresetTemplate.PT_READ_BARCODES_SPEED_FIRST;
        // You can also use the simplified settings to configure the settings. For example:
//        SimplifiedCaptureVisionSettings simplifiedSettings = mRouter.getSimplifiedSettings(mCurrentTemplate);
//        simplifiedSettings.timeout = 500;
//        SimplifiedBarcodeReaderSettings barcodeSettings = simplifiedSettings.barcodeSettings;
//        barcodeSettings.barcodeFormatIds = EnumBarcodeFormat.BF_DEFAULT;
//        barcodeSettings.expectedBarcodesCount = 0;
//        mRouter.updateSettings(mCurrentTemplate, simplifiedSettings);

        mRouter.removeResultFilter(mFilter);
        // Set a scan region to reduce the processing time consumption.
        mCamera.setScanRegion(new DSRect(0.15f, 0.3f, 0.85f, 0.7f, true));
    }

    private void setVideoReadRateFirst() throws CaptureVisionRouterException, CameraEnhancerException {
        mCurrentTemplate = EnumPresetTemplate.PT_READ_BARCODES_READ_RATE_FIRST;

        // You can also use the simplified settings to configure the settings. For example:
//        SimplifiedCaptureVisionSettings simplifiedSettings = mRouter.getSimplifiedSettings(mCurrentTemplate);
//        simplifiedSettings.timeout = 10000;
//        SimplifiedBarcodeReaderSettings barcodeSettings = simplifiedSettings.barcodeSettings;
//        barcodeSettings.barcodeFormatIds = EnumBarcodeFormat.BF_DEFAULT;
//        barcodeSettings.expectedBarcodesCount = 512;
//        barcodeSettings.grayscaleEnhancementModes = new int[]{EnumGrayscaleTransformationMode.GTM_ORIGINAL, EnumGrayscaleTransformationMode.GTM_INVERTED};
//        barcodeSettings.deblurModes = new int[]{EnumDeblurMode.DM_BASED_ON_LOC_BIN, EnumDeblurMode.DM_THRESHOLD_BINARIZATION, EnumDeblurMode.DM_DEEP_ANALYSIS,
//                EnumDeblurMode.DM_THRESHOLD_BINARIZATION, EnumDeblurMode.DM_DIRECT_BINARIZATION, EnumDeblurMode.DM_SMOOTHING, EnumDeblurMode.DM_GRAY_EQULIZATION,
//                EnumDeblurMode.DM_MORPHING, EnumDeblurMode.DM_SHARPENING, EnumDeblurMode.DM_SHARPENING_SMOOTHING};
//        mRouter.updateSettings(mCurrentTemplate, simplifiedSettings);

        mRouter.removeResultFilter(mFilter);

        mCamera.setScanRegion(null);
    }

    public void setVideoAccuracy() throws CaptureVisionRouterException, CameraEnhancerException {
        mCurrentTemplate = EnumPresetTemplate.PT_READ_BARCODES;
        // You can also use the simplified settings to configure the settings. For example:
//        SimplifiedCaptureVisionSettings simplifiedSettings = mRouter.getSimplifiedSettings(mCurrentTemplate);
//        simplifiedSettings.timeout = 10000;
//        SimplifiedBarcodeReaderSettings barcodeSettings = simplifiedSettings.barcodeSettings;
//        barcodeSettings.barcodeFormatIds = EnumBarcodeFormat.BF_DEFAULT;
//        barcodeSettings.expectedBarcodesCount = 512;
//        barcodeSettings.grayscaleEnhancementModes = new int[]{EnumGrayscaleTransformationMode.GTM_ORIGINAL, EnumGrayscaleTransformationMode.GTM_INVERTED};
//        barcodeSettings.deblurModes = new int[]{EnumDeblurMode.DM_BASED_ON_LOC_BIN, EnumDeblurMode.DM_THRESHOLD_BINARIZATION};
//        barcodeSettings.minResultConfidence = 30;
//        barcodeSettings.minBarcodeTextLength = 6;
//        barcodeSettings.barcodeTextRegExPattern = "";
//        mRouter.updateSettings(mCurrentTemplate, simplifiedSettings);

        mRouter.addResultFilter(mFilter);

        mCamera.setScanRegion(null);
    }

    private void showResultsItems(BarcodeResultItem[] items) {
        StringBuilder strResults = new StringBuilder();
        for (BarcodeResultItem item : items) {
            strResults.append("\n\n").append(getString(R.string.format)).append(item.getFormatString()).append("\n").append(getString(R.string.text)).append(item.getText());
        }
        if (binding != null) {
            String countString = String.format(getString(R.string.Total), items.length);
            binding.tvResults.setText(String.format("%s%n%s", countString, strResults));
            binding.tvResults.setVisibility(View.VISIBLE);
        }
    }
}