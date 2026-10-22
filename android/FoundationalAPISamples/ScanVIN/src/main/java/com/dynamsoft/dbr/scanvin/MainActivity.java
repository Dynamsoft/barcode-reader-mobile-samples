package com.dynamsoft.dbr.scanvin;

import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.dcp.ParsedResult;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    private CaptureVisionRouter router;
    private CameraEnhancer camera;
    private String parsedText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        EdgeToEdge.enable(this);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        if (savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=cvs&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccessful, error) -> {
                if (!isSuccessful) {
                    error.printStackTrace();
                }
            });
        }

        //Request camera permission
        PermissionUtil.requestCameraPermission(this);

        CameraView cameraView = findViewById(R.id.camera_view);
        camera = new CameraEnhancer(cameraView, this);
        router = new CaptureVisionRouter();

        try {
            router.setInput(camera);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }

        MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
        filter.enableResultCrossVerification(EnumCapturedResultItemType.CRIT_BARCODE, true);
        router.addResultFilter(filter);

        router.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
                if (result.getItems().length > 0) {
                    parsedText = result.getItems()[0].getText();
                }
            }

            @Override
            public void onParsedResultsReceived(@NonNull ParsedResult result) {
                if (result.getItems().length > 0) {
                    VINData vinData = VINData.fromParsedItem(result.getItems()[0]);
                    if (vinData == null) {
                        showParsedText();
                    } else {
                        goToResultActivity(vinData);
                        router.stopCapturing();
                    }
                } else {
                    showParsedText();
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        //Reset tip text.
        ((TextView) findViewById(R.id.tv_parsed)).setText("");
        parsedText = "";

        camera.open();
        router.startCapturing("ReadVINBarcode", new CompletionListener() {
            @Override
            public void onSuccess() {
            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                runOnUiThread(() -> {
                    TextView tvError = findViewById(R.id.tv_error);
                    tvError.setText(String.format(Locale.getDefault(), "ErrorCode: %d\nErrorString: %s", errorCode, errorString));
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

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Unregister the receivers and filters so they do not outlive this Activity.
        router.removeAllResultReceivers();
        router.removeAllResultFilters();
    }

    private void showParsedText() {
        if (parsedText != null && !parsedText.isEmpty()) {
            runOnUiThread(() -> {
                TextView tvParsedText = findViewById(R.id.tv_parsed);
                tvParsedText.setText(String.format("Failed to parse the result. The text is:%n%s", parsedText));
            });
        }
    }

    private void goToResultActivity(@NonNull VINData vinData) {
        Intent intent = new Intent(this, ResultActivity.class);
        intent.putExtra("vinData", vinData);
        startActivity(intent);
    }
}