package com.dynamsoft.dbr.locateanitemwithbarcode;

import static com.dynamsoft.dbr.locateanitemwithbarcode.LocateStartActivity.KEY_SEARCHING_ITEM;

import android.graphics.Color;
import android.graphics.Point;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.ArcDrawingItem;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.DrawingItem;
import com.dynamsoft.dce.DrawingLayer;
import com.dynamsoft.dce.DrawingStyleManager;
import com.dynamsoft.dce.EnumCoordinateBase;
import com.dynamsoft.dce.TextDrawingItem;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.util.ArrayList;

public class LocateScanActivity extends AppCompatActivity implements CapturedResultReceiver {
    private static final String TAG = "LocateScanActivity";
    private CaptureVisionRouter router;
    private CameraEnhancer camera;
    private CameraView cameraView;
    private final String templateName = "ReadMultipleBarcodes";

    private String searchingItem;
    private DrawingLayer locatedItemLayer;

    // The style for highlighting located barcode that exactly matches your input.
    int matchedStyle;
    // The style for highlighting located barcodes that are not matching your input.
    int notMatchedStyle;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scanner);

        searchingItem = getIntent().getStringExtra(KEY_SEARCHING_ITEM);

        PermissionUtil.requestCameraPermission(this);

        cameraView = findViewById(R.id.camera_view);
        camera = new CameraEnhancer(cameraView, this);

        findViewById(R.id.btn_locate_another_item).setOnClickListener(v->{
            finish();
        });

        router = new CaptureVisionRouter();
        router.addResultReceiver(this);
        try {
            //In src/assets/Templates
            router.initSettingsFromFile("ReadMultipleBarcodes.json");
            router.setInput(camera);
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }

        MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
        filter.enableLatestOverlapping(EnumCapturedResultItemType.CRIT_BARCODE, true);
        // You can set the max overlapping frame count. Default value is 5. If your phone is not moving or just moving slowly and stably, you can set it higher.
        filter.setMaxOverlappingFrames(EnumCapturedResultItemType.CRIT_BARCODE, 10);
        router.addResultFilter(filter);

        initDrawingLayers();
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
        ArrayList<DrawingItem> drawingItemArrayList = new ArrayList<>();
        for (BarcodeResultItem item : result.getItems()) {
            int arcCenterX = (item.getLocation().points[0].x + item.getLocation().points[1].x + item.getLocation().points[2].x + item.getLocation().points[3].x) / 4;
            int arcCenterY = (item.getLocation().points[0].y + item.getLocation().points[1].y + item.getLocation().points[2].y + item.getLocation().points[3].y) / 4;
            Point arcCenter = new Point(arcCenterX, arcCenterY);
            ArcDrawingItem arcDrawingItem = new ArcDrawingItem(arcCenter, 40, EnumCoordinateBase.CB_IMAGE);

            if (item.getText().equals(searchingItem)) {
                arcDrawingItem.setDrawingStyleId(matchedStyle);
                TextDrawingItem locatedBarcodeItemText = new TextDrawingItem(item.getText(), new Point(arcCenterX - 60, arcCenterY - 120), 700, 200, EnumCoordinateBase.CB_IMAGE);
                locatedBarcodeItemText.setDrawingStyleId(matchedStyle);
                TextDrawingItem symbolMatchedItem = new TextDrawingItem("+", new Point(arcCenterX - 18, arcCenterY - 32), 100, 100, EnumCoordinateBase.CB_IMAGE);
                symbolMatchedItem.setDrawingStyleId(matchedStyle);

                drawingItemArrayList.add(arcDrawingItem);
                drawingItemArrayList.add(locatedBarcodeItemText);
                drawingItemArrayList.add(symbolMatchedItem);
            } else {
                arcDrawingItem.setDrawingStyleId(notMatchedStyle);
                TextDrawingItem symbolNotMatchedItem = new TextDrawingItem("x", new Point(arcCenterX - 18, arcCenterY - 32), 100, 100, EnumCoordinateBase.CB_IMAGE);
                symbolNotMatchedItem.setDrawingStyleId(notMatchedStyle);
                drawingItemArrayList.add(arcDrawingItem);
                drawingItemArrayList.add(symbolNotMatchedItem);
            }
        }
        locatedItemLayer.setDrawingItems(drawingItemArrayList);
    }

    private void initDrawingLayers() {
        // The default layer have default UI elements. Here we set it invisible.
        DrawingLayer layer = cameraView.getDrawingLayer(DrawingLayer.DBR_LAYER_ID);
        layer.setVisible(false);


        // The style for highlighting located barcode that exactly matches your input.
        matchedStyle = DrawingStyleManager.createDrawingStyle(Color.TRANSPARENT, 0, Color.GREEN, Color.WHITE);
        // The style for highlighting located barcodes that are not matching your input.
        notMatchedStyle = DrawingStyleManager.createDrawingStyle(Color.TRANSPARENT, 0, Color.RED, Color.WHITE);

        // Get a new layer to draw UI element for highlighting barcodes.
        locatedItemLayer = cameraView.createDrawingLayer();
        locatedItemLayer.setDefaultStyle(matchedStyle);
        locatedItemLayer.setVisible(true);
    }


}