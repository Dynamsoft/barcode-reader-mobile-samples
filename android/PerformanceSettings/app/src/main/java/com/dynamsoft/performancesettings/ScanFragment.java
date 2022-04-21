package com.dynamsoft.performancesettings;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.text.method.ScrollingMovementMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.EnumBarcodeFormat_2;
import com.dynamsoft.dbr.EnumDeblurMode;
import com.dynamsoft.dbr.EnumPresetTemplate;
import com.dynamsoft.dbr.ImageData;
import com.dynamsoft.dbr.PublicRuntimeSettings;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.dbr.TextResultListener;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.DCECameraView;
import com.dynamsoft.dce.EnumEnhancerFeatures;
import com.dynamsoft.dce.RegionDefinition;
import com.dynamsoft.dce.DCELicenseVerificationListener;


public class ScanFragment extends Fragment {
    CameraEnhancer cameraEnhancer;
    DCECameraView cameraView;
    BarcodeReader reader;
    TextView tvResults;
    EnumPresetTemplate template = EnumPresetTemplate.VIDEO_SINGLE_BARCODE;

    public static ScanFragment newInstance() {
        return new ScanFragment();
    }

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
                requireActivity().runOnUiThread(() -> {
                    if (!b && e != null) {
                        e.printStackTrace();
                        showErrorDialog(e.getMessage());
                    }
                });
            }
        });
        
        try {
            reader = new BarcodeReader();
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        // Create an instance of Dynamsoft Camera Enhancer for video streaming.
        cameraEnhancer = new CameraEnhancer(requireContext());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_scan, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        tvResults = view.findViewById(R.id.tv_results);
        reader.setTextResultListener(mTextResultListener);
        reader.updateRuntimeSettings(template);
        //accuracy first selected
        if (template == EnumPresetTemplate.DEFAULT) {
            reader.enableDuplicateFilter(true);
            reader.enableResultVerification(true);
        } else {
            reader.enableDuplicateFilter(false);
            reader.enableResultVerification(false);
        }
        cameraView = view.findViewById(R.id.camera_view);
        cameraView.setOverlayVisible(true);
        cameraEnhancer.setCameraView(cameraView);
        reader.setCameraEnhancer(cameraEnhancer);
    }

    @Override
    public void onResume() {
        ((MainActivity) requireActivity()).setScanFragment(this);
        ((MainActivity) requireActivity()).showViewInScanFg();
        try {
            cameraEnhancer.open();
            reader.startScanning();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        super.onResume();
    }

    @Override
    public void onPause() {
        try {
            cameraEnhancer.close();
            reader.stopScanning();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        super.onPause();
    }

    // Set the barcode scanning mode to single barcode scanning.
    public void setSingleBarcodeMode() {
        if (reader != null) {
            // Select video single barcode template
            reader.updateRuntimeSettings(EnumPresetTemplate.VIDEO_SINGLE_BARCODE);
        }

        // Reset the scanRegion settings.
        // The scanRegion will be reset to the whole screen when you trigger the setScanRegion with a null value.
        try {
            if (cameraEnhancer != null)
                cameraEnhancer.setScanRegion(null);
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
    }

    // Set the barcode decoding mode to image speed first.
    public void setImageSpeedFirst() {
        if (reader != null) {
            // Select Image speed first template.
            // The template includes settings that benefits the processing speed for general image barcode decoding scenarios.
            reader.updateRuntimeSettings(EnumPresetTemplate.IMAGE_SPEED_FIRST);
            try {
                // You can also optimize the settings via PublicRuntimeSettings struct.
                PublicRuntimeSettings settings = reader.getRuntimeSettings();

                // Specifiy the barcode formats to match your usage scenarios will help you further improve the barcode processing speed.
                settings.barcodeFormatIds = EnumBarcodeFormat.BF_ALL;
                settings.barcodeFormatIds_2 = EnumBarcodeFormat_2.BF2_NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                settings.expectedBarcodesCount = 0;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                settings.scaleDownThreshold = 2300;

                // Add or update the above settings.
                reader.updateRuntimeSettings(settings);
            } catch (BarcodeReaderException e) {
                e.printStackTrace();
            }
        }
    }

    // Set the barcode decoding mode to video speed first.
    public void setVideoSpeedFirst() {
        if (reader != null) {
            // Select the video speed first template.
            // The template includes settings that benefits the processing speed for general video barcode scanning scenarios.
            reader.updateRuntimeSettings(EnumPresetTemplate.VIDEO_SPEED_FIRST);
            try {
                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                PublicRuntimeSettings settings = reader.getRuntimeSettings();

                // Specifiy the barcode formats to match your usage scenarios will help you further improve the barcode processing speed.
                settings.barcodeFormatIds = EnumBarcodeFormat.BF_ALL;
                settings.barcodeFormatIds_2 = EnumBarcodeFormat_2.BF2_NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                settings.expectedBarcodesCount = 0;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                settings.scaleDownThreshold = 2300;

                // The unit of timeout is millisecond, it will force the Barcode Reader to stop processing the current image.
                // Set a smaller timeout value will help the Barcode Reader to quickly quit the video frames without a barcode when decoding on video streaming.
                settings.timeout = 500;

                // Add or update the above settings.
                reader.updateRuntimeSettings(settings);
            } catch (BarcodeReaderException e) {
                e.printStackTrace();
            }
        }

        if (cameraEnhancer != null) {
            // Specify the scanRegion via Camera Enhancer will help you improve the barcode processing speed.
            // The video frames will be cropped based on the scanRegion so that the Barcode Reader will focus on the scanRegion only.
            // Configure a RegionDefinition value for the scanRegion.
            RegionDefinition scanRegion = new RegionDefinition();

            // The int value 30 means the top border of the scanRegion is 30% margin from the top border of the video frame.
            scanRegion.regionTop = 30;

            // The int value 70 means the bottom border of the scanRegion is 70% margin from the top border of the video frame.
            scanRegion.regionBottom = 70;

            // The int value 15 means the left border of the scanRegion is 15% margin from the left border of the video frame.
            scanRegion.regionLeft = 15;

            // The int value 85 means the right border of the scanRegion is 85% margin from the left border of the video frame.
            scanRegion.regionRight = 85;

            // Set the regionMeasuredByPercentage to 1, so that the above values will stands for percentage. Otherwise, they will stands for pixel length.
            scanRegion.regionMeasuredByPercentage = 1;
            try {
                // Trigger the scanRegion setting, the scanRegion will be displayed on the UI at the same time.
                // Trigger setScanRegionVisible = false will hide the scanRegion on the UI but the scanRegion still exist.
                // Set the scanRegion to a null value can disable the scanRegion setting.
                cameraEnhancer.setScanRegion(scanRegion);
            } catch (CameraEnhancerException e) {
                e.printStackTrace();
            }
        }
    }

    // Set the barcode decoding mode to image read rate first.
    public void setImageReadRateFirst() {
        if (reader != null) {
            // Select the image read rate first template.
            // A higher Read Rate means the Barcode Reader has higher possibility to decode the target barcode.
            // The template includes settings that benefits the read rate for general image barcode decoding scenarios.
            reader.updateRuntimeSettings(EnumPresetTemplate.IMAGE_READ_RATE_FIRST);
            try {
                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                PublicRuntimeSettings settings = reader.getRuntimeSettings();

                // Specifiy more barcode formats will help you to improve the read rate of the Barcode Reader
                settings.barcodeFormatIds = EnumBarcodeFormat.BF_ALL;
                settings.barcodeFormatIds_2 = EnumBarcodeFormat_2.BF2_NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                settings.expectedBarcodesCount = 512;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                settings.scaleDownThreshold = 10000;

                // Add or update the above settings.
                reader.updateRuntimeSettings(settings);
            } catch (BarcodeReaderException e) {
                e.printStackTrace();
            }
        }
    }

    public void setVideoReadRateFirst() {
        if (reader != null) {
            // Select the video read rate first template.
            // A higher Read Rate means the Barcode Reader has higher possibility to decode the target barcode.
            // The template includes settings that benefits the read rate for general video barcode scanning scenarios.
            reader.updateRuntimeSettings(EnumPresetTemplate.VIDEO_READ_RATE_FIRST);
            try {
                // Get the current settings via method getRuntimeSettings so that you can add your personalized settings via PublicRuntimeSettings struct.
                PublicRuntimeSettings settings = reader.getRuntimeSettings();

                // Specifiy more barcode formats will help you to improve the read rate of the Barcode Reader
                settings.barcodeFormatIds = EnumBarcodeFormat.BF_ALL;
                settings.barcodeFormatIds_2 = EnumBarcodeFormat_2.BF2_NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                settings.expectedBarcodesCount = 512;

                // The Barcode Reader will try to scale down the image continuously until the image is smaller than the scaleDownThreshold.
                // A smaller image benefits the decoding speed but reduce the read rate and accuracy at the same time.
                settings.scaleDownThreshold = 2300;

                // The unit of timeout is millisecond, it will force the Barcode Reader to stop processing the current image.
                // Set a smaller timeout value will help the Barcode Reader to quickly quit the video frames without a barcode when decoding on video streaming.
                settings.timeout = 5000;

                // Add or update the above settings.
                reader.updateRuntimeSettings(settings);
            } catch (BarcodeReaderException e) {
                e.printStackTrace();
            }
        }

        // Reset the scanRegion settings.
        // The scanRegion will be reset to the whole screen when you trigger the setScanRegion with a null value.
        try {
            if (cameraEnhancer != null)
                cameraEnhancer.setScanRegion(null);
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
    }

    // Set the barcode scanning mode to accuracy first.
    // There is no preset template for accuracy first.
    public void setAccuracyMode() {
        if (reader != null) {
            try {
                // Reset all of the runtime settings.
                reader.resetRuntimeSettings();
                PublicRuntimeSettings settings = reader.getRuntimeSettings();

                // Specifiy the barcode formats to match your usage scenarios will help you further improve the barcode processing accuracy.
                settings.barcodeFormatIds = EnumBarcodeFormat.BF_ALL;
                settings.barcodeFormatIds_2 = EnumBarcodeFormat_2.BF2_NULL;

                // The Barcode Reader will try to decode as many barcodes as the expected count.
                // When the expected barcodes count is set to 0, the Barcode Reader will try to decode at least 1 barcode.
                settings.expectedBarcodesCount = 512;

                // Simplify the DeblurModes so that the severely blurred images will be skipped.
                settings.deblurModes = new int[]{EnumDeblurMode.DM_BASED_ON_LOC_BIN, EnumDeblurMode.DM_THRESHOLD_BINARIZATION};

                // Add confidence filter for the barcode results.
                // A higher confidence for the barcode result means the higher possibility to be correct.
                // The default value of the confidence is 30, which can filter the majority of misreading barcode results.
                settings.minResultConfidence = 30;

                // Add filter condition for the barcode results.
                settings.minBarcodeTextLength = 6;

                // Add or update the above settings.
                reader.updateRuntimeSettings(settings);
            } catch (BarcodeReaderException e) {
                e.printStackTrace();
            }

            // The correctness of barcode results will be double checked before output.
            reader.enableResultVerification(true);

            // Reset the scanRegion settings.
            // The scanRegion will be reset to the whole screen when you trigger the setScanRegion with a null value.
            try {
                if (cameraEnhancer != null)
                    cameraEnhancer.setScanRegion(null);
            } catch (CameraEnhancerException e) {
                e.printStackTrace();
            }
        }

        if (cameraEnhancer != null) {
            try {
                // The frame filter feature of Camera Enhancer will help you to skip blurry frame when decoding on video streaming.
                // This feature requires a valid license of Dynamsoft Camera Enhancer
                cameraEnhancer.enableFeatures(EnumEnhancerFeatures.EF_FRAME_FILTER);
            } catch (CameraEnhancerException e) {
                e.printStackTrace();
            }
        }
    }

    public void choicePhotoWrapper(int mode) {
        String[] perms = {Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE};
        int permission = ActivityCompat.checkSelfPermission(requireContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE);
        int apiVersion = Build.VERSION.SDK_INT;
        if (apiVersion >= Build.VERSION_CODES.R && !Environment.isExternalStorageManager()) {
            startActivityForResult(new Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION), 1);
        } else if (apiVersion >= Build.VERSION_CODES.M && apiVersion < Build.VERSION_CODES.R && permission != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(requireActivity(), perms, 1);
        } else {
            Intent intent = new Intent("android.intent.action.GET_CONTENT");
            intent.setType("image/*");
            startActivityForResult(intent, mode);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        String path = "";
        if (data != null) {
            path = FileUtil.getFilePathFromUri(getContext(), data.getData());
        } else {
            return;
        }
        ResultsFragment resultsFragment = ResultsFragment.newInstance();
        requireActivity().getSupportFragmentManager().beginTransaction()
                .replace(R.id.container, resultsFragment)
                .addToBackStack(null)
                .commit();
        if (requestCode == 1) { // 1->speed first mode, 2->read rate first mode
            setImageSpeedFirst();
        } else {
            setImageReadRateFirst();
        }
        TextResult[] results = null;
        try {
            results = reader.decodeFile(path);
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }
        resultsFragment.setPathAndTextResults(path, results);
        ((MainActivity) requireActivity()).hideViewInResultsFg();

        //After finishing decoding image, return to video mode.
        if (requestCode == 1) { // 1->speed first mode, 2->read rate first mode
            reader.updateRuntimeSettings(EnumPresetTemplate.VIDEO_SPEED_FIRST);
        } else {
            reader.updateRuntimeSettings(EnumPresetTemplate.VIDEO_READ_RATE_FIRST);
        }
    }

    private final TextResultListener mTextResultListener = new TextResultListener() {
        @Override
        public void textResultCallback(int i, ImageData imageData, TextResult[] textResults) {
            if (textResults != null && textResults.length > 0) {
                requireActivity().runOnUiThread(() -> showResults(textResults));
            }
        }
    };

    @SuppressLint("SetTextI18n")
    private void showResults(TextResult[] results) {
        StringBuilder strResults = new StringBuilder();
        for (TextResult result : results) {
            if (result.barcodeFormat_2 != 0) {
                strResults.append("\n\n").append(getString(R.string.format)).append(result.barcodeFormatString_2).append("\n").append(getString(R.string.text)).append(result.barcodeText);
            } else {
                strResults.append("\n\n").append(getString(R.string.format)).append(result.barcodeFormatString).append("\n").append(getString(R.string.text)).append(result.barcodeText);
            }
        }
        tvResults.setText("" + getText(R.string.Total) + results.length + "\n" + strResults);
        tvResults.setVisibility(View.VISIBLE);
        tvResults.setMovementMethod(ScrollingMovementMethod.getInstance());
    }

    private void showErrorDialog(String message) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(requireContext());
        dialog.setTitle(R.string.error_dialog_title)
                .setPositiveButton("OK", null)
                .setMessage(message)
                .show();

    }

}
