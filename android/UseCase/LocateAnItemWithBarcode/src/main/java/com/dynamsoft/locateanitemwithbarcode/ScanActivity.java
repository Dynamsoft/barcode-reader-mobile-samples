package com.dynamsoft.locateanitemwithbarcode;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.CoreException;
import com.dynamsoft.core.basic_structures.DSRect;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.core.basic_structures.OriginalImageResultItem;
import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.ArcDrawingItem;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.DrawingItem;
import com.dynamsoft.dce.DrawingLayer;
import com.dynamsoft.dce.DrawingStyle;
import com.dynamsoft.dce.DrawingStyleManager;
import com.dynamsoft.dce.EnumCoordinateBase;
import com.dynamsoft.dce.QuadDrawingItem;
import com.dynamsoft.dce.TextDrawingItem;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.utility.ImageManager;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;
import com.dynamsoft.utility.UtilityException;

import java.io.File;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Locale;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

/**
 * {@code @author:} dynamsoft
 * Time: 2024/8/5
 * Description:
 */
public class ScanActivity extends AppCompatActivity {
	private CameraEnhancer mCamera;
	private CaptureVisionRouter mRouter;
	private AlertDialog mAlertDialog;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_scan);
		PermissionUtil.requestCameraPermission(this);

		CameraView cameraView = findViewById(R.id.camera_view);
		String barcode = getIntent().getStringExtra("barcode");
		mCamera = new CameraEnhancer(cameraView, this);
		mRouter = new CaptureVisionRouter(this);

		// Enable the to-the-latest-overlapping feature to improve the performance of multiple barcode decoding.
		MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
		filter.enableLatestOverlapping(EnumCapturedResultItemType.CRIT_BARCODE, true);
		// You can set the max overlapping frame count. Default value is 5. If your phone is not moving or just moving slowly and stably, you can set it higher.
		filter.setMaxOverlappingFrames(EnumCapturedResultItemType.CRIT_BARCODE, 10);
		mRouter.addResultFilter(filter);
		try {
			mRouter.initSettingsFromFile("ReadMultipleBarcodes.json");
			mRouter.setInput(mCamera);
		} catch (CaptureVisionRouterException e) {
			throw new RuntimeException(e);
		}

		// The default layer have default UI elements. Here we set it invisible.
		DrawingLayer layer = cameraView.getDrawingLayer(DrawingLayer.DBR_LAYER_ID);
		layer.setVisible(false);

		// The style for highlighting located barcode that exactly matches your input.
		int matchedStyle = DrawingStyleManager.createDrawingStyle(Color.TRANSPARENT, 0, Color.GREEN, Color.WHITE);

		// The style for highlighting located barcodes that are not matching your input.
		int notMatchedStyle = DrawingStyleManager.createDrawingStyle(Color.TRANSPARENT, 0, Color.RED, Color.WHITE);

		// Get a new layer to draw UI element for highlighting barcodes.
		DrawingLayer locatItemLayer = cameraView.getDrawingLayer(DrawingLayer.DDN_LAYER_ID);
		locatItemLayer.setDefaultStyle(matchedStyle);
		locatItemLayer.setVisible(true);

		mRouter.addResultReceiver(new CapturedResultReceiver() {
			@Override
			// Implement the callback method to receive DecodedBarcodesResult.
			// The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
			// BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format
			public void onDecodedBarcodesReceived(DecodedBarcodesResult result) {
				ArrayList<DrawingItem> drawingItemArrayList = new ArrayList<>();
				for (BarcodeResultItem item : result.getItems()) {
					int arcCenterX = (item.getLocation().points[0].x + item.getLocation().points[1].x + item.getLocation().points[2].x + item.getLocation().points[3].x)/4;
					int arcCenterY = (item.getLocation().points[0].y + item.getLocation().points[1].y + item.getLocation().points[2].y + item.getLocation().points[3].y)/4;
					Point arcCenter = new Point(arcCenterX, arcCenterY);
					ArcDrawingItem arcDrawingItem = new ArcDrawingItem(arcCenter, 40, EnumCoordinateBase.CB_IMAGE);

					if (item.getText().equals(barcode)) {
						arcDrawingItem.setDrawingStyleId(matchedStyle);
						TextDrawingItem locatedBarcodeItemText = new TextDrawingItem(item.getText(), new Point(arcCenterX - 60, arcCenterY - 120), 500, 100, EnumCoordinateBase.CB_IMAGE);
						locatedBarcodeItemText.setDrawingStyleId(matchedStyle);
						TextDrawingItem symbolMatchedItem = new TextDrawingItem("+", new Point(arcCenterX - 20, arcCenterY -32), 500, 100, EnumCoordinateBase.CB_IMAGE);
						symbolMatchedItem.setDrawingStyleId(matchedStyle);

						drawingItemArrayList.add(arcDrawingItem);
						drawingItemArrayList.add(locatedBarcodeItemText);
						drawingItemArrayList.add(symbolMatchedItem);
					} else {
						arcDrawingItem.setDrawingStyleId(notMatchedStyle);
						TextDrawingItem symbolNotMatchedItem = new TextDrawingItem("x", new Point(arcCenterX - 18, arcCenterY -35), 500, 100, EnumCoordinateBase.CB_IMAGE);
						symbolNotMatchedItem.setDrawingStyleId(notMatchedStyle);
						drawingItemArrayList.add(arcDrawingItem);
						drawingItemArrayList.add(symbolNotMatchedItem);
					}
				}

				locatItemLayer.setDrawingItems(drawingItemArrayList);
			}
		});
		findViewById(R.id.btn_back).setOnClickListener(v -> {
			finish();
		});
	}

	@Override
	protected void onResume() {
		super.onResume();
		try {
			mCamera.open();
		} catch (CameraEnhancerException e) {
			e.printStackTrace();
		}

		mRouter.startCapturing("ReadMultipleBarcodes", new CompletionListener() {
			@Override
			public void onSuccess() {
			}

			@Override
			public void onFailure(int errorCode, String errorString) {
				runOnUiThread(() -> showDialog("Error", String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", errorCode, errorString)));
			}
		});
	}

	public void onPause() {
		// Stop video barcode reading
		try {
			mCamera.close();
		} catch (CameraEnhancerException e) {
			e.printStackTrace();
		}
		mRouter.stopCapturing();
		super.onPause();
	}

	private void showDialog(String title, String message) {
		if (mAlertDialog == null) {
			mAlertDialog = new AlertDialog.Builder(this).setCancelable(true).setPositiveButton("OK", null).create();
		}
		mAlertDialog.setTitle(title);
		mAlertDialog.setMessage(message);
		mAlertDialog.show();
	}
}
