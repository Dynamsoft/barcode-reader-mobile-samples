package com.dynamsoft.dbr.generalsettings.scanner;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.ViewModelProvider;

import com.dynamsoft.core.basic_structures.DSRect;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.SimplifiedCaptureVisionSettings;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.SimplifiedBarcodeReaderSettings;
import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.models.CameraSettings;
import com.dynamsoft.dbr.generalsettings.models.DecodeSettings;
import com.dynamsoft.dbr.generalsettings.models.MultiFrameCrossFilterSettings;
import com.dynamsoft.dbr.generalsettings.models.SettingsCache;
import com.dynamsoft.dbr.generalsettings.settings.SettingsActivity;
import com.dynamsoft.dbr.generalsettings.ui.CustomResultDisplayView;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.EnumEnhancerFeatures;
import com.dynamsoft.dce.EnumResolution;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;
import com.google.android.material.appbar.MaterialToolbar;

import java.util.Objects;

public class ScannerActivity extends AppCompatActivity implements ScannerViewModel.Listener {
    private CaptureVisionRouter router;
    private CameraEnhancer camera;
    private final MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
    private ScannerViewModel viewModel;
    private SettingsCache settingsCache;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        PermissionUtil.requestCameraPermission(this);

        viewModel = new ViewModelProvider(this).get(ScannerViewModel.class);
        settingsCache = viewModel.settingsCache;

        viewModel.setListener(this);

        initActionBar();
        initCameraAndCaptureVisionRouter();
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == R.id.action_settings) {
            findViewById(R.id.results_view).setVisibility(View.GONE);
            startActivity(new Intent(this, SettingsActivity.class));
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void initCameraAndCaptureVisionRouter() {
        CameraView cameraView = findViewById(R.id.camera_view);
        camera = new CameraEnhancer(cameraView, this);

        router = new CaptureVisionRouter();
        try {
            router.setInput(camera);
            router.addResultReceiver(viewModel);
        } catch (CaptureVisionRouterException e) {
            //no-op
        }
        router.addResultFilter(filter);
    }

    @Override
    protected void onResume() {
        super.onResume();

        //ResultFeedbackSettings take effect in CapturedResultReceiver callback. See ScannerViewModel.onDecodedBarcodesReceived
        setupDecodeSettings();
        setupMultiFrameResultCrossFilterSettings();
        setupCameraSettings();

        camera.open();

        router.startCapturing(settingsCache.decodeSettings.getSelectedPresetTemplateName(), viewModel);
    }

    @Override
    protected void onPause() {
        super.onPause();
        camera.close();

        router.stopCapturing();
    }

    //interface ScannerViewModel.Listener
    @Override
    public void showResult(@NonNull DecodedBarcodesResult result) {
        runOnUiThread(() -> {
            if (result.getItems().length > 0) {
                CustomResultDisplayView resultView = findViewById(R.id.results_view);
                resultView.setVisibility(View.VISIBLE);
                resultView.updateResults(result.getItems());
            }
        });
    }

    //interface ScannerViewModel.Listener
    @Override
    public void showError(int errorCode, String errorString, String title) {
        runOnUiThread(() -> ((TextView) findViewById(R.id.tv_start_capturing_error))
                .setText("StartCapturing failed: errorCode=" + errorCode + ", errorString=" + errorString));
    }

    private void initActionBar() {
        MaterialToolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setNavigationOnClickListener(v -> getOnBackPressedDispatcher().onBackPressed());
    }

    private void setupDecodeSettings() {
        DecodeSettings decodeSettings = settingsCache.decodeSettings;

        try {
            if (decodeSettings.ifUseImportedTemplate) {
                router.initSettings(decodeSettings.getImportedTemplateContent());
            } else {
                router.resetSettings();
            }
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }

        if (decodeSettings.ifUseImportedTemplate && decodeSettings.ifImportedTemplateIsComplex) {
            return;
        }

        String selectedTemplateName = decodeSettings.getSelectedPresetTemplateName();
        try {
            SimplifiedCaptureVisionSettings simplifiedCaptureVisionSettings = router.getSimplifiedSettings(selectedTemplateName);
            simplifiedCaptureVisionSettings.timeout = decodeSettings.getTimeout();
            simplifiedCaptureVisionSettings.minImageCaptureInterval = decodeSettings.getMinDecodeInterval();

            SimplifiedBarcodeReaderSettings barcodeSettings = simplifiedCaptureVisionSettings.barcodeSettings;
            assert barcodeSettings != null;
            barcodeSettings.barcodeFormatIds = decodeSettings.getBarcodeFormat();
            barcodeSettings.expectedBarcodesCount = decodeSettings.getExpectedBarcodesCount();
            barcodeSettings.localizationModes = decodeSettings.getLocalizationModes();
            barcodeSettings.deblurModes = decodeSettings.getDeblurModes();
            barcodeSettings.grayscaleEnhancementModes = decodeSettings.getGrayscaleEnhancementModes();
            barcodeSettings.grayscaleTransformationModes = decodeSettings.getGrayscaleTransformationModes();
            barcodeSettings.minResultConfidence = decodeSettings.getMinResultConfidence();
            barcodeSettings.scaleDownThreshold = decodeSettings.getScaleDownThreshold();
            barcodeSettings.barcodeTextRegExPattern = decodeSettings.getBarcodeTextRegExPattern();
            barcodeSettings.minBarcodeTextLength = decodeSettings.getMinBarcodeTextLength();

            router.updateSettings(selectedTemplateName, simplifiedCaptureVisionSettings);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }
    }

    private void setupMultiFrameResultCrossFilterSettings() {
        //Filter should be added to the router via CaptureVisionRouter.addFilter() in advance,
        // so setting the filter will take effect.
        MultiFrameCrossFilterSettings filterSettings = settingsCache.multiFrameCrossFilterSettings;
        filter.enableResultCrossVerification(EnumCapturedResultItemType.CRIT_BARCODE, filterSettings.isMultiFrameVerificationEnabled);
        filter.enableResultDeduplication(EnumCapturedResultItemType.CRIT_BARCODE, filterSettings.isResultDeduplicationEnabled);
        filter.setDuplicateForgetTime(EnumCapturedResultItemType.CRIT_BARCODE, filterSettings.duplicationForgetTime);
        filter.enableLatestOverlapping(EnumCapturedResultItemType.CRIT_BARCODE, filterSettings.isLatestOverlappingEnabled);
        filter.setMaxOverlappingFrames(EnumCapturedResultItemType.CRIT_BARCODE, filterSettings.maxOverlappingFramesCount);
    }

    private void setupCameraSettings() {
        CameraSettings cameraSettings = settingsCache.cameraSettings;

        try {
            if (cameraSettings.autoZoomEnabled) {
                camera.enableEnhancedFeatures(EnumEnhancerFeatures.EF_AUTO_ZOOM);
            } else {
                camera.disableEnhancedFeatures(EnumEnhancerFeatures.EF_AUTO_ZOOM);
            }

            if (Objects.equals(cameraSettings.resolution, CameraSettings.Resolution.FULL_HD)) {
                camera.setResolution(EnumResolution.RESOLUTION_1080P);
            } else { //cameraSettings.resolution.equals(CameraSettings.Resolution.HD)
                camera.setResolution(EnumResolution.RESOLUTION_720P);
            }


            switch (cameraSettings.scanRegion) {
                case CameraSettings.ScanRegion.FULL_IMAGE:
                    camera.setScanRegion(null);
                    break;
                case CameraSettings.ScanRegion.SQUARE:
                    camera.setScanRegion(new DSRect(.15f, .3f, .85f, .7f, true));
                    break;
                case CameraSettings.ScanRegion.RECTANGLE:
                    camera.setScanRegion(new DSRect(.05f, .3f, .95f, .55f, true));
                    break;
            }
        } catch (CameraEnhancerException e) {
            throw new RuntimeException(e);
        }
    }
}