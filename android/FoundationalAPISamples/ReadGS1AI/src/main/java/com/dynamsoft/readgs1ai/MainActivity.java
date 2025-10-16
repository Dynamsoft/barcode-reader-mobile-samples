package com.dynamsoft.readgs1ai;

import android.app.AlertDialog;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.dcp.ParsedResult;
import com.dynamsoft.dcp.ParsedResultItem;
import com.dynamsoft.license.LicenseManager;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    private CaptureVisionRouter mRouter;
    private CameraEnhancer mCamera;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (success, e) -> {
            if (!success) e.printStackTrace();
        });

        PermissionUtil.requestCameraPermission(this);

        mRouter = new CaptureVisionRouter();
        mCamera = new CameraEnhancer(findViewById(R.id.camera_view), this);
        try {
            mRouter.initSettingsFromFile("ReadGS1AIBarcode.json"); //See file in assets/Templates.
            mRouter.setInput(mCamera);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }

        mRouter.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onParsedResultsReceived(@NonNull ParsedResult result) {
                if (result.getItems().length == 0) {
                    return;
                }
                String[] contents = getContentsFromParsedItem(result.getItems()[0]);
                if (contents.length > 0) {
                    mRouter.stopCapturing();
                    runOnUiThread(() -> new AlertDialog.Builder(MainActivity.this)
                            .setCancelable(true)
                            .setPositiveButton("OK", null)
                            .setOnDismissListener(_dialog -> mRouter.startCapturing("", null))
                            .setItems(contents, null)
                            .show());
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        mCamera.open();
        mRouter.startCapturing("", new CompletionListener() {
            @Override
            public void onSuccess() {
                //do nothing
            }

            @Override
            public void onFailure(int errorCode, String errorString) {
                runOnUiThread(() -> new AlertDialog.Builder(MainActivity.this)
                        .setCancelable(true)
                        .setPositiveButton("OK", null)
                        .setTitle("StartCapturing error")
                        .setMessage(String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", errorCode, errorString))
                        .show());
            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();
        mCamera.close();
        mRouter.stopCapturing();
    }

    private static String[] getContentsFromParsedItem(ParsedResultItem item) {
        ArrayList<String> contents = new ArrayList<>();
        for (String fieldName : item.getParsedFields().keySet()) {
            if (!isAI(fieldName)) continue;
            String aiDescription = item.getFieldValue(fieldName + "AI");
            String aiData = item.getFieldValue(fieldName + "Data");
            if (aiDescription != null && aiDescription.toLowerCase().contains("date")) {
                aiData = parseDateString(aiData);
            }
            contents.add(aiDescription + ": " + aiData);
        }
        return contents.toArray(new String[0]);
    }

    private static boolean isAI(String str) {
        return str != null && str.matches("(\\d+)|(\\d+n)");
    }

    private static String parseDateString(String dateStr) {
        if (dateStr == null) {
            return "";
        }
        int length = dateStr.length();
        //Only support yyMMdd, yyMMddHHmm, yyMMddHHmmSS.
        if (length != 6 && length != 10 && length != 12) {
            return dateStr;
        }

        int year = Integer.parseInt(dateStr.substring(0, 2)) + 2000;
        int month = Integer.parseInt(dateStr.substring(2, 4)) - 1;
        int day = Integer.parseInt(dateStr.substring(4, 6));

        Calendar calendar = Calendar.getInstance();
        calendar.clear();
        calendar.set(year, month, 1);

        // Handle day=0 -> last day of month
        int lastDay = calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
        day = (day == 0) ? lastDay : day;


        // Initialize hour, minute, and second to 0
        int hour = 0, minute = 0, second = 0;

        // Parse hour and minute if the length allows
        if (length >= 10) {
            hour = Integer.parseInt(dateStr.substring(6, 8));
            minute = Integer.parseInt(dateStr.substring(8, 10));
            // Parse second if the length is exactly 12
            if (length == 12) {
                second = Integer.parseInt(dateStr.substring(10, 12));
            }
        }

        calendar.set(year, month, day, hour, minute, second);

        String pattern;
        switch (dateStr.length()) {
            case 6:
                pattern = "yy/MM/dd";
                break;
            case 10:
                pattern = "yy/MM/dd HH:mm";
                break;
            case 12:
            default:
                pattern = "yy/MM/dd HH:mm:ss";
        }

        return new SimpleDateFormat(pattern, Locale.getDefault()).format(calendar.getTime());
    }

}