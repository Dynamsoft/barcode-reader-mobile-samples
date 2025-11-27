package com.dynamsoft.dcv.driverslicensescanner;

import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.dcp.ParsedResult;
import com.dynamsoft.license.LicenseManager;

public class MainActivity extends AppCompatActivity {

    private CaptureVisionRouter router;
    private CameraEnhancer camera;
    private String textBeforeParsing;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

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

        router.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
                if (result.getItems().length > 0) {
                    textBeforeParsing = result.getItems()[0].getText();
                }
            }

            @Override
            public void onParsedResultsReceived(@NonNull ParsedResult result) {
                if (result.getItems().length > 0) {
                    String[] displayStrings = ParseUtil.parsedItemToDisplayStrings(result.getItems()[0]);
                    if (displayStrings == null || displayStrings.length <= 1/*Only have Document Type content*/) {
                        showParsedText();
                    } else {
                        textBeforeParsing = null;
                        runOnUiThread(() -> ((TextView)(findViewById(R.id.tv_parsed))).setText(""));
                        goToResultActivity(displayStrings);
                        router.stopCapturing();
                    }
                } else {
                    showParsedText();
                }
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();
        camera.open();
        router.startCapturing("ReadDriversLicense", new CompletionListener() {
            @Override
            public void onSuccess() {
                //Do nothing
            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                runOnUiThread(() -> {
                    TextView tvError = findViewById(R.id.tv_error);
                    tvError.setText("ErrorCode: " + errorCode + "\nErrorString: " + errorString);
                });
            }
        });
    }

    @Override
    public void onPause() {
        super.onPause();
        camera.close();
        router.stopCapturing();
    }

    private void showParsedText() {
        if (textBeforeParsing != null && !textBeforeParsing.isEmpty()) {
            runOnUiThread(() -> {
                TextView tvParsedText = findViewById(R.id.tv_parsed);
                tvParsedText.setText("Failed to parse the result. The drivers' information does not exist in the barcode! ");
            });
        }
    }

    private void goToResultActivity(String[] displayStrings) {
        Intent intent = new Intent(this, ResultActivity.class);
        intent.putExtra("displayStrings", displayStrings);
        startActivity(intent);
    }
}