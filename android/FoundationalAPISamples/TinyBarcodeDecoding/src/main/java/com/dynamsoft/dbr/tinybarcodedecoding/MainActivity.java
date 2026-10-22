package com.dynamsoft.dbr.tinybarcodedecoding;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.MainThread;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.EnumEnhancerFeatures;
import com.dynamsoft.dce.Feedback;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    private static final float DEFAULT_ZOOM_RATE = 1.5f;

    private CameraView cameraView;
    private ZoomSeekbarView sbManuelZoom;
    private TextView tvManuelZoom;
    private SwitchCompat scAutoZoom;
    private CameraEnhancer camera;
    private CaptureVisionRouter router;
    private AlertDialog alertDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                }
            });
        }
        PermissionUtil.requestCameraPermission(this);

        setContentView(R.layout.activity_main);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        cameraView = findViewById(R.id.cameraView);
        sbManuelZoom = findViewById(R.id.sb_manuel_zoom);
        tvManuelZoom = findViewById(R.id.tv_manuel_zoom);
        scAutoZoom = findViewById(R.id.sc_auto_zoom);

        camera = new CameraEnhancer(cameraView, this);
        camera.setZoomFactor(DEFAULT_ZOOM_RATE);

        router = new CaptureVisionRouter();

        MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
        filter.enableResultCrossVerification(EnumCapturedResultItemType.CRIT_BARCODE, true);
        router.addResultFilter(filter);

        try {
            // Set the camera enhancer as the input.
            router.setInput(camera);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        router.addResultReceiver(new CapturedResultReceiver() {
            @Override
            // Implement the callback method to receive DecodedBarcodesResult.
            // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
            // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
            public void onDecodedBarcodesReceived(DecodedBarcodesResult result) {
                runOnUiThread(() -> showResult(result));
            }
        });
        initView();

    }

    @Override
    protected void onResume() {
        super.onResume();

        // Open the camera.
        camera.open();

        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        router.startCapturing(EnumPresetTemplate.PT_READ_SINGLE_BARCODE, /*@Nullable CompletionListener completionHandler = */new CompletionListener() {
            @Override
            public void onSuccess() {
            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                runOnUiThread(() -> showDialog("Error", String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", errorCode, errorString)));
            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();
        camera.close();
        router.stopCapturing();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Cancel the pending callback and unregister the receivers and filters so they do not outlive this Activity.
        UIHandler.getInstance().removeCallbacks(hideSeekBarRunnable);
        router.removeAllResultReceivers();
        router.removeAllResultFilters();
    }

    private final Runnable hideSeekBarRunnable = () -> {
        sbManuelZoom.setVisibility(View.GONE);
    };

    @SuppressLint("ClickableViewAccessibility")
    private void initView() {
        NumberFormat formatter = new DecimalFormat("0.0");

        camera.setZoomFactorChangeListener(zoom -> {
            runOnUiThread(()->{
                sbManuelZoom.setIndex(zoom);
                tvManuelZoom.setText(formatter.format(zoom)+"x");
            });
        });

        scAutoZoom.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                // When auto-zoom feature is enabled, the camera will zoom-in automatically
                // towards the un-decoded barcode zone and zoom-out after the barcode is decoded.
                // A valid license is required to enable the auto-zoom feature.
                try {
                    camera.enableEnhancedFeatures(EnumEnhancerFeatures.EF_AUTO_ZOOM);
                } catch (CameraEnhancerException e) {
                    e.printStackTrace();
                }
                sbManuelZoom.setVisibility(View.GONE);
                tvManuelZoom.setVisibility(View.GONE);
            } else {
                camera.disableEnhancedFeatures(EnumEnhancerFeatures.EF_AUTO_ZOOM);
                camera.setZoomFactor(DEFAULT_ZOOM_RATE);
                tvManuelZoom.setText(formatter.format(DEFAULT_ZOOM_RATE));
                sbManuelZoom.setIndex(DEFAULT_ZOOM_RATE);
                tvManuelZoom.setVisibility(View.VISIBLE);
            }
        });

        tvManuelZoom.setText(formatter.format(DEFAULT_ZOOM_RATE));
        sbManuelZoom.setVisibility(View.GONE);
        sbManuelZoom.setRange(1f, camera.getCapabilities().maxZoomFactor);
        sbManuelZoom.setStartIndex(DEFAULT_ZOOM_RATE);
        sbManuelZoom.setOnMoveActionListener(new ZoomSeekbarView.OnTouchListener() {
            @Override
            public void onMove(float x) {
                tvManuelZoom.setText(formatter.format(x).replace(".0", "") + "x");
                camera.setZoomFactor(x);
            }

            @Override
            public void onTouchStart() {
                UIHandler.getInstance().removeCallbacks(hideSeekBarRunnable);
            }

            @Override
            public void onTouchEnd() {
                UIHandler.getInstance().postDelayed(hideSeekBarRunnable, 2000);
            }
        });

        tvManuelZoom.setOnTouchListener(new View.OnTouchListener() {
            float currentX = 0;
            float startPosition = 0f;
            float lastX = 0f;

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    sbManuelZoom.setVisibility(View.VISIBLE);
                    float lastPosition = sbManuelZoom.getPosition();
                    if (lastPosition > 0) {
                        sbManuelZoom.setPosition(lastPosition);
                    }
                    lastX = event.getX();
                    startPosition = sbManuelZoom.getPosition();
                }

                float indexStart = sbManuelZoom.getPaddingStart() + sbManuelZoom.getX();
                float indexEnd = sbManuelZoom.getWidth() - sbManuelZoom.getPaddingEnd() + sbManuelZoom.getX();
                currentX = sbManuelZoom.getPosition();
                float moveX = event.getX() - lastX;
                lastX = event.getX();
                startPosition += moveX;
                if (startPosition < 0) {
                    startPosition = sbManuelZoom.getPosition();
                } else if (startPosition < indexStart) {
                    startPosition = indexStart;
                } else if (startPosition > indexEnd) {
                    startPosition = indexEnd;
                }
                event.setLocation(startPosition, event.getY());
                sbManuelZoom.onTouchEvent(event);
                return true;
            }
        });
    }

    private void showResult(DecodedBarcodesResult result) {
        StringBuilder strRes = new StringBuilder();

        if (result != null && result.getItems().length > 0) {
            router.stopCapturing();
            router.getInput().clearBuffer();
            for (int i = 0; i < result.getItems().length; i++) {
                // Extract the barcode format and the barcode text from the BarcodeResultItem.
                BarcodeResultItem item = result.getItems()[i];
                strRes.append(item.getFormatString()).append(":").append(item.getText()).append("\n\n");
            }
            if (alertDialog != null && alertDialog.isShowing()) {
                return;
            }
            Feedback.vibrate();
            showDialog(getString(R.string.result_title), strRes.toString());
        }
    }

    @MainThread
    private void showDialog(String title, String message) {
        if (alertDialog == null) {
            // Restart capture when the dialog is closed.
            alertDialog = new AlertDialog.Builder(this).setCancelable(true).setPositiveButton("OK", null)
                    .setOnDismissListener(dialog -> router.startCapturing(EnumPresetTemplate.PT_READ_SINGLE_BARCODE, null))
                    .create();
        }
        alertDialog.setTitle(title);
        alertDialog.setMessage(message);
        alertDialog.show();
    }

}