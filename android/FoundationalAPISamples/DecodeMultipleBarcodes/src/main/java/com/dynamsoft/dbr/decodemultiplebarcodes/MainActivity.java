package com.dynamsoft.dbr.decodemultiplebarcodes;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.View;

import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.CoreException;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.core.basic_structures.ImageData;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.intermediate_results.IntermediateResultManager;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.utils.PermissionUtil;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.utility.ImageManager;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

/**
 * @author: dynamsoft
 * Time: 2024/8/1
 * Description:
 */
public class MainActivity extends AppCompatActivity {
	private CameraEnhancer mCamera;
	private CaptureVisionRouter mRouter;
	private AlertDialog mAlertDialog;
	private DecodedBarcodesResult results;
	private volatile boolean passed = false;
	public static WeakReference<DecodedBarcodesResult> weakResults;

	@Override
	protected void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", this, (isSuccess, error) -> {
			if (!isSuccess) {
				error.printStackTrace();
			}
		});
		PermissionUtil.requestCameraPermission(this);

		CameraView cameraView = findViewById(R.id.camera_view);
		findViewById(R.id.btn_decode).setOnClickListener(v -> {
			if (results != null) {
				passed = true;
			}
		});
		mCamera = new CameraEnhancer(cameraView, this);
		mRouter = new CaptureVisionRouter(this);

		MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
		filter.enableLatestOverlapping(EnumCapturedResultItemType.CRIT_BARCODE, true);
		mRouter.addResultFilter(filter);
		try {
			mRouter.initSettingsFromFile("ReadMultipleBarcodes.json");
			mRouter.setInput(mCamera);
		} catch (CaptureVisionRouterException e) {
			throw new RuntimeException(e);
		}

		mRouter.addResultReceiver(new CapturedResultReceiver() {
			@Override
			// Implement the callback method to receive DecodedBarcodesResult.
			// The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
			// BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
			public void onDecodedBarcodesReceived(DecodedBarcodesResult result) {
				results = result;
				if(passed){
					passed = false;
					weakResults = new WeakReference<>(results);
					saveImageDataToFile(results.getOriginalImageHashId());
					runOnUiThread(()->{
						Intent intent = new Intent(MainActivity.this, ResultActivity.class);
						startActivity(intent);
					});
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


	private @NonNull ArrayList<String> assembleResult() {
		BarcodeResultItem[] items = results.getItems();
		ArrayList<String> list = new ArrayList<String>();
		for (BarcodeResultItem item : items) {
			list.add(item.getFormatString());
			list.add(item.getText());
		}
		return list;
	}

	private void saveImageDataToFile(String hashId) {
		IntermediateResultManager manager = mRouter.getIntermediateResultManager();
		ImageData originalImage = manager.getOriginalImage(hashId);
		File cacheFile = new File(getCacheDir(), "original_image.jpg");
		try {
			FileOutputStream fos = new FileOutputStream(cacheFile);
			Bitmap bitmap = originalImage.toBitmap();
			bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
			fos.close();
			//return cacheFile.getAbsolutePath();
		} catch (CoreException | IOException e) {
			e.printStackTrace();
		}
	}
}
