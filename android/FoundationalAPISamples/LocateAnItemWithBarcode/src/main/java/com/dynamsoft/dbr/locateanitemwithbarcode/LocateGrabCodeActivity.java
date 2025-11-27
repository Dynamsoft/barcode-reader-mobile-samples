package com.dynamsoft.dbr.locateanitemwithbarcode;

import static com.dynamsoft.dbr.locateanitemwithbarcode.LocateStartActivity.KEY_CRABBED_CODE;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.utils.PermissionUtil;

public class LocateGrabCodeActivity extends AppCompatActivity implements CapturedResultReceiver {
    private static final String TAG = "LocateGrabCodeActivity";

    private CaptureVisionRouter router;
    private CameraEnhancer camera;
    private final String templateName = EnumPresetTemplate.PT_READ_SINGLE_BARCODE;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_grab_code);

        PermissionUtil.requestCameraPermission(this);

        router = new CaptureVisionRouter();
        router.addResultReceiver(this);
        camera = new CameraEnhancer(findViewById(R.id.camera_view), this);
        try {
            router.setInput(camera);
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        router.startCapturing(templateName, new CompletionListener() {
            @Override
            public void onSuccess() {
                //no-op
                Log.i(TAG, "Start capturing success. Template: " + templateName);
            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                runOnUiThread(() -> ((TextView) findViewById(R.id.tv_start_capturing_error))
                        .setText("StartCapturing failed: errorCode=" + errorCode + ", errorString=" + errorString));
            }
        });

        camera.open();

    }

    @Override
    protected void onPause() {
        super.onPause();
        router.stopCapturing();
        camera.close();

    }

    @Override //CapturedResultReceiver
    public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
        runOnUiThread(() -> {
            if (result.getItems().length > 0) {
                String text = result.getItems()[0].getText();
                Intent backIntent = new Intent();
                backIntent.putExtra(KEY_CRABBED_CODE, text);
                setResult(RESULT_OK, backIntent);
                finish();
            }
        });
    }
}