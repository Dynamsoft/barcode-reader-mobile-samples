package com.dynamsoft.dbr.tinybarcodedecoding;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;

import androidx.annotation.MainThread;
import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.tinybarcodedecoding.databinding.ActivityMainBinding;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.EnumEnhancerFeatures;
import com.dynamsoft.dce.Feedback;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.license.LicenseManager;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    private CameraEnhancer mCamera;
    private CaptureVisionRouter mRouter;
    private AlertDialog mAlertDialog;
    private ActivityMainBinding binding;
    private final float DEFAULT_ZOOM_RATE = 1.5f;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (savedInstanceState == null) {
            // Initialize license for Dynamsoft Barcode Reader.
            // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
            // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", this, (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                }
            });
        }
        PermissionUtil.requestCameraPermission(this);

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        mCamera = new CameraEnhancer(binding.cameraView, this);
        mRouter = new CaptureVisionRouter(this);
        try {
            // Set the camera enhancer as the input.
            mRouter.setInput(mCamera);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        mRouter.addResultReceiver(new CapturedResultReceiver() {
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
    public void onResume() {
        super.onResume();
        // Start video barcode reading
        try {
            // Open the camera.
            mCamera.open();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, /*@Nullable CompletionListener completionHandler = */new CompletionListener() {
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
    public void onPause() {
        super.onPause();
        // Stop video barcode reading
        try {
            mCamera.close();
        } catch (CameraEnhancerException e) {
            e.printStackTrace();
        }
        mRouter.stopCapturing();
    }

    private final Runnable mHideSeekBarRunnable = () -> {
        if (binding != null) {
            binding.sbManuelZoom.setVisibility(View.GONE);
        }
    };

    @SuppressLint("ClickableViewAccessibility")
    private void initView() {
        NumberFormat formatter = new DecimalFormat("0.0");

        binding.scAutoZoom.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                // When auto-zoom feature is enabled, the camera will zoom-in automatically
                // towards the un-decoded barcode zone and zoom-out after the barcode is decoded.
                // A valid license is required to enable the auto-zoom feature.
                try {
                    mCamera.enableEnhancedFeatures(EnumEnhancerFeatures.EF_AUTO_ZOOM);
                } catch (CameraEnhancerException e) {
                    e.printStackTrace();
                }
                binding.sbManuelZoom.setVisibility(View.GONE);
                binding.tvManuelZoom.setVisibility(View.GONE);
            } else {
                mCamera.disableEnhancedFeatures(EnumEnhancerFeatures.EF_AUTO_ZOOM);
                try {
                    mCamera.setZoomFactor(DEFAULT_ZOOM_RATE);
                    binding.tvManuelZoom.setText(formatter.format(DEFAULT_ZOOM_RATE));
                    binding.sbManuelZoom.setIndex(DEFAULT_ZOOM_RATE);
                } catch (CameraEnhancerException e) {
                    e.printStackTrace();
                }
                binding.tvManuelZoom.setVisibility(View.VISIBLE);
            }
        });

        binding.tvManuelZoom.setText(formatter.format(DEFAULT_ZOOM_RATE));
        binding.sbManuelZoom.setVisibility(View.GONE);
        binding.sbManuelZoom.setRange(1f, mCamera.getCapabilities().maxZoomFactor);
        binding.sbManuelZoom.setStartIndex(DEFAULT_ZOOM_RATE);
        binding.sbManuelZoom.setOnMoveActionListener(new ZoomSeekbarView.OnTouchListener() {
            @Override
            public void onMove(float x) {
                binding.tvManuelZoom.setText(formatter.format(x).replace(".0", "") + "X");
                try {
                    // Use the setZoomFactor method to set the zoom factor.
                    mCamera.setZoomFactor(x);
                } catch (CameraEnhancerException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onTouchStart() {
                UIHandler.getInstance().removeCallbacks(mHideSeekBarRunnable);
            }

            @Override
            public void onTouchEnd() {
                UIHandler.getInstance().postDelayed(mHideSeekBarRunnable, 2000);
            }
        });

        binding.tvManuelZoom.setOnTouchListener(new View.OnTouchListener() {
            float currentX = 0;
            float startPosition = 0f;
            float lastX = 0f;

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    binding.sbManuelZoom.setVisibility(View.VISIBLE);
                    float lastPosition = binding.sbManuelZoom.getPosition();
                    if (lastPosition > 0) {
                        binding.sbManuelZoom.setPosition(lastPosition);
                    }
                    lastX = event.getX();
                    startPosition = binding.sbManuelZoom.getPosition();
                }

                float indexStart = binding.sbManuelZoom.getPaddingStart() + binding.sbManuelZoom.getX();
                float indexEnd = binding.sbManuelZoom.getWidth() - binding.sbManuelZoom.getPaddingEnd() + binding.sbManuelZoom.getX();
                currentX = binding.sbManuelZoom.getPosition();
                float moveX = event.getX() - lastX;
                lastX = event.getX();
                startPosition += moveX;
                if (startPosition < 0) {
                    startPosition = binding.sbManuelZoom.getPosition();
                } else if (startPosition < indexStart) {
                    startPosition = indexStart;
                } else if (startPosition > indexEnd) {
                    startPosition = indexEnd;
                }
                event.setLocation(startPosition, event.getY());
                binding.sbManuelZoom.onTouchEvent(event);
                return true;
            }
        });
    }

    private void showResult(DecodedBarcodesResult result) {
        StringBuilder strRes = new StringBuilder();

        if (result != null && result.getItems() != null && result.getItems().length > 0) {
            mRouter.stopCapturing();
            mRouter.getInput().clearBuffer();
            for (int i = 0; i < result.getItems().length; i++) {
                // Extract the barcode format and the barcode text from the BarcodeResultItem.
                BarcodeResultItem item = result.getItems()[i];
                strRes.append(item.getFormatString()).append(":").append(item.getText()).append("\n\n");
            }
            if (mAlertDialog != null && mAlertDialog.isShowing()) {
                return;
            }
            Feedback.vibrate(this);
            showDialog(getString(R.string.result_title), strRes.toString());
        }
    }

    @MainThread
    private void showDialog(String title, String message) {
        if (mAlertDialog == null) {
            // Restart capture when the dialog is closed.
            mAlertDialog = new AlertDialog.Builder(this).setCancelable(true).setPositiveButton("OK", null)
                    .setOnDismissListener(dialog -> mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, null))
                    .create();
        }
        mAlertDialog.setTitle(title);
        mAlertDialog.setMessage(message);
        mAlertDialog.show();
    }

}