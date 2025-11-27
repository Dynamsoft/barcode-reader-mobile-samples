package com.dynamsoft.debug;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.util.Size;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.IntDef;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.preference.PreferenceManager;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.DSRect;
import com.dynamsoft.core.basic_structures.EnumColourChannelUsageType;
import com.dynamsoft.core.basic_structures.ImageData;
import com.dynamsoft.core.intermediate_results.BinaryImageUnit;
import com.dynamsoft.core.intermediate_results.ColourImageUnit;
import com.dynamsoft.core.intermediate_results.GrayscaleImageUnit;
import com.dynamsoft.core.intermediate_results.IntermediateResultExtraInfo;
import com.dynamsoft.core.intermediate_results.IntermediateResultUnit;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.cvr.intermediate_results.IntermediateResultReceiver;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.debug.settings.PreferencesConstants;
import com.dynamsoft.debug.settings.SettingsActivity;
import com.dynamsoft.utility.ImageIO;
import com.dynamsoft.utility.UtilityException;
import com.google.android.material.appbar.MaterialToolbar;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Locale;

public class CaptureActivity extends AppCompatActivity {

    @IntDef({ColorMode.COLOUR, ColorMode.GRAYSCALE, ColorMode.BINARY})
    private @interface ColorMode {
        int COLOUR = 0;
        int GRAYSCALE = 1;
        int BINARY = 2;
    }

    private static final String TAG = "CaptureActivity";

    private int maxCapturedFramesCount;

    @ColorMode
    private int captureImageColourMode = ColorMode.COLOUR;
    private String scanRegion;

    private final ImageIO imageIO = new ImageIO();
    private CaptureVisionRouter router;
    private CameraEnhancer camera;

    private String savedDir;

    private int currentCapturedFramesCount = -1;
    private Button btnCaptureVideoFrames;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_capture);

        initActionBar();
        initBtnCaptureVideoFrames();
        initCamera();
        initCaptureVisionRouter();

        PermissionUtil.requestCameraPermission(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        setupPreferences();
        setupCameraScanRegion();

        camera.open();
        router.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, new CompletionListener() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "onSuccess.");
            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                Log.e(TAG, "onFailure: " + errorString + " " + errorCode);
                runOnUiThread(() -> {
                    TextView tvError = findViewById(R.id.tv_start_capturing_error);
                    tvError.setText(String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", errorCode, errorString));
                    findViewById(R.id.btn_capture).setEnabled(false);
                });
            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();
        camera.close();
        router.stopCapturing();
    }

    private void initCamera() {
        CameraView cameraView = findViewById(R.id.camera_view);
        camera = new CameraEnhancer(cameraView, this);
        camera.setColourChannelUsageType(EnumColourChannelUsageType.CCUT_FULL_CHANNEL);
    }

    private void setupCameraScanRegion() {
        try {
            switch (scanRegion) {
                case PreferencesConstants.SCAN_REGION_FULL_IMAGE:
                    camera.setScanRegion(null);
                    break;
                case PreferencesConstants.SCAN_REGION_SQUARE:
                    Size resolution = camera.getResolution();
                    float side = Math.min(resolution.getWidth(), resolution.getHeight()) * 0.7f;
                    Log.e(TAG, "setupCameraScanRegion: "+resolution+" "+side);
                    camera.setScanRegion(new DSRect(
                            (resolution.getWidth() - side) / 2,
                            (resolution.getHeight() - side) / 2,
                            (resolution.getWidth() + side) / 2,
                            (resolution.getHeight() + side) / 2,
                            false));
                    break;
                case PreferencesConstants.SCAN_REGION_RECTANGLE:
                    camera.setScanRegion(new DSRect(.05f, .3f, .95f, .55f, true));
                    break;
            }
        } catch (CameraEnhancerException e) {
            throw new RuntimeException(e);
        }
    }

    private void initCaptureVisionRouter() {
        router = new CaptureVisionRouter();
        try {
            router.setInput(camera);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }
        router.getIntermediateResultManager().addResultReceiver(new IntermediateResultReceiver() {
            @Override
            public void onColourImageUnitReceived(@NonNull ColourImageUnit unit, IntermediateResultExtraInfo info) {
                saveIntermediateResult(unit);
            }

            @Override
            public void onGrayscaleImageUnitReceived(@NonNull GrayscaleImageUnit unit, IntermediateResultExtraInfo info) {
                saveIntermediateResult(unit);
            }

            @Override
            public void onBinaryImageUnitReceived(@NonNull BinaryImageUnit unit, IntermediateResultExtraInfo info) {
                saveIntermediateResult(unit);
            }
        });
    }

    private void saveIntermediateResult(IntermediateResultUnit unit) {
        if (currentCapturedFramesCount >= 0 && currentCapturedFramesCount < maxCapturedFramesCount) {
            ImageData imageData = null;
            if (captureImageColourMode == ColorMode.COLOUR && unit instanceof ColourImageUnit) {
                imageData = ((ColourImageUnit) unit).getImageData();
            } else if (captureImageColourMode == ColorMode.GRAYSCALE && unit instanceof GrayscaleImageUnit) {
                imageData = ((GrayscaleImageUnit) unit).getImageData();
            } else if (captureImageColourMode == ColorMode.BINARY && unit instanceof BinaryImageUnit) {
                imageData = ((BinaryImageUnit) unit).getImageData();
            }
            if (imageData != null) {
                try {
                    imageIO.saveToFile(imageData, savedDir + "/" + currentCapturedFramesCount + ".jpg", true);
                } catch (UtilityException e) {
                    e.printStackTrace();
                }
                currentCapturedFramesCount++;
                if (currentCapturedFramesCount >= maxCapturedFramesCount) {
                    finishCaptureVideoFrames();
                }
            }
        }
    }

    private void finishCaptureVideoFrames() {
        runOnUiThread(() -> {
            btnCaptureVideoFrames.setEnabled(true);
            currentCapturedFramesCount = -1;
            findViewById(R.id.progress_bar).setVisibility(View.GONE);
            new AlertDialog.Builder(CaptureActivity.this)
                    .setPositiveButton("OK", null)
                    .setTitle("Capture finished")
                    .setMessage(String.format(Locale.getDefault(), "Capture finished!\nYou can find the captured images under: %s", savedDir))
                    .show();
        });
    }

    private void initActionBar() {
        MaterialToolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setNavigationOnClickListener(v -> getOnBackPressedDispatcher().onBackPressed());
    }

    private void initBtnCaptureVideoFrames() {
        btnCaptureVideoFrames = findViewById(R.id.btn_capture);
        btnCaptureVideoFrames.setOnClickListener(v -> {
            Log.e(TAG, "initBtnCaptureVideoFrames: "+camera.getResolution());
            SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault());
            savedDir = String.format(Locale.getDefault(), "%s/%s_%s_%s",
                    getExternalCacheDir(),
                    captureImageColourMode == ColorMode.COLOUR ? "colour" : captureImageColourMode == ColorMode.GRAYSCALE ? "grayscale" : "binary",
                    scanRegion.replaceAll("\\s+", ""),
                    format.format(System.currentTimeMillis()));
            new File(savedDir).mkdirs();
            btnCaptureVideoFrames.setEnabled(false);
            currentCapturedFramesCount = 0;
            findViewById(R.id.progress_bar).setVisibility(View.VISIBLE);
        });
    }

    private void setupPreferences() {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        maxCapturedFramesCount = Integer.parseInt(sharedPreferences.getString(PreferencesConstants.MAX_CAPTURED_FRAMES_COUNT, "10"));
        captureImageColourMode = Integer.parseInt(sharedPreferences.getString(PreferencesConstants.CAPTURED_IMAGE_COLOUR, ColorMode.COLOUR + ""));
        scanRegion = sharedPreferences.getString(PreferencesConstants.SCAN_REGION, PreferencesConstants.SCAN_REGION_FULL_IMAGE);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == R.id.menu_settings) {
            startActivity(new Intent(this, SettingsActivity.class));
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}