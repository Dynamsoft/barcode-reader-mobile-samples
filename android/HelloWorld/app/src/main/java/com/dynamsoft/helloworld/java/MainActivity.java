//This is a HelloWorld sample that illustrates how to set up a simplest video barcode scanner with Dynamsoft Barcode Reader.

package com.dynamsoft.helloworld.java;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.widget.TextView;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.ImageData;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.dbr.TextResultListener;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.DCECameraView;
import com.dynamsoft.dce.DCEFeedback;
import com.dynamsoft.helloworld.R;

import androidx.appcompat.app.AppCompatActivity;

/**
 * @author dynamsoft
 */
public class MainActivity extends AppCompatActivity {
	private BarcodeReader mReader;
	private CameraEnhancer mCameraEnhancer;
	private AlertDialog alertDialog;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		// Initialize license for Dynamsoft Barcode Reader.
		// The license string here is a time-limited trial license. Note that network connection is required for this license to work.
		// You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
		BarcodeReader.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", new DBRLicenseVerificationListener() {
			@Override
			public void DBRLicenseVerificationCallback(boolean isSuccessful, Exception e) {
				runOnUiThread(() -> {
					if (!isSuccessful) {
						e.printStackTrace();
						showDialog(getString(R.string.error_dialog_title), e.getMessage(), null);
					}
				});
			}
		});

		// Add camera view for previewing video.
		DCECameraView cameraView = findViewById(R.id.cameraView);
		cameraView.setOverlayVisible(true);
		// Create an instance of Dynamsoft Camera Enhancer for video streaming.
		mCameraEnhancer = new CameraEnhancer(MainActivity.this);
		mCameraEnhancer.setCameraView(cameraView);

		try {
			// Create an instance of Dynamsoft Barcode Reader.
			mReader = new BarcodeReader();
		} catch (BarcodeReaderException e) {
			e.printStackTrace();
		}

		// Bind the Camera Enhancer instance to the Barcode Reader instance to get frames from camera.
		mReader.setCameraEnhancer(mCameraEnhancer);

//		try {
//			PublicRuntimeSettings settings = mReader.getRuntimeSettings();
//			settings.barcodeFormatIds = EnumBarcodeFormat.BF_ONED |
//					EnumBarcodeFormat.BF_QR_CODE |
//					EnumBarcodeFormat.BF_PDF417 |
//					EnumBarcodeFormat.BF_DATAMATRIX;
//		} catch (BarcodeReaderException e) {
//			e.printStackTrace();
//		}

		// Register a listener to obtain the recognized barcode results.
		mReader.setTextResultListener(new TextResultListener() {
			// Obtain the recognized barcode results and display.
			@Override
			public void textResultCallback(int id, ImageData imageData, TextResult[] textResults) {
				runOnUiThread(() -> showResult(textResults));
			}
		});
	}

	@Override
	public void onResume() {
		// Start video barcode reading
		try {
			mCameraEnhancer.open();
		} catch (CameraEnhancerException e) {
			e.printStackTrace();
		}
		mReader.startScanning();
		super.onResume();
	}

	@Override
	public void onPause() {
		// Stop video barcode reading
		try {
			mCameraEnhancer.close();
		} catch (CameraEnhancerException e) {
			e.printStackTrace();
		}
		mReader.stopScanning();
		super.onPause();
	}

	@Override
	protected void onStop() {
		super.onStop();
		if (alertDialog != null) {
			alertDialog.dismiss();
		}
	}

	private void showResult(TextResult[] results) {
		String strRes = "";

		if (results != null && results.length > 0) {

			DCEFeedback.vibrate(this);
			mReader.stopScanning();

			for (int i = 0; i < results.length; i++)
				strRes += results[i].barcodeText + "\n\n";
			if (alertDialog != null && alertDialog.isShowing()) {
				return;
			}
			showDialog("Result", strRes, new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					mReader.startScanning();
				}
			});
		}
	}

	private void showDialog(String title, String message, DialogInterface.OnClickListener listener) {
		AlertDialog.Builder dialog = new AlertDialog.Builder(this);
		alertDialog = dialog.setTitle(title)
				.setPositiveButton("OK", listener)
				.setMessage(message)
				.setCancelable(false)
				.show();
	}

}
