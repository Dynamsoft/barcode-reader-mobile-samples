package com.dynamsoft.locateanitemwithbarcode;

import android.content.Intent;
import android.os.Bundle;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.util.Locale;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

/**
 * @author: dynamsoft
 * Time: 2024/8/28
 * Description:
 */
public class CrabCodeActivity extends AppCompatActivity {
	private CameraEnhancer mCamera;
	private CaptureVisionRouter mRouter;
	private AlertDialog mAlertDialog;

	@Override
	protected void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_crab_code);
		PermissionUtil.requestCameraPermission(this);

		CameraView cameraView = findViewById(R.id.camera_view);
		mCamera = new CameraEnhancer(cameraView, this);
		mRouter = new CaptureVisionRouter(this);
		MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
		filter.enableLatestOverlapping(EnumCapturedResultItemType.CRIT_BARCODE, true);
		mRouter.addResultFilter(filter);
		try {
			mRouter.resetSettings();
			mRouter.setInput(mCamera);
		} catch (CaptureVisionRouterException e) {
			throw new RuntimeException(e);
		}

		mRouter.addResultReceiver(new CapturedResultReceiver() {
			@Override
			// Implement the callback method to receive DecodedBarcodesResult.
			// The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
			// BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
			public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
				if (result.getItems().length > 0) {
					String text = result.getItems()[0].getText();
					Intent backIntent = new Intent();
					backIntent.putExtra("crabCode", text);
					setResult(RESULT_OK, backIntent);
					finish();
				}
			}
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

		mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, new CompletionListener() {
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
