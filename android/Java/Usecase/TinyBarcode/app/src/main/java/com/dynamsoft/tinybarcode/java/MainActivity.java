//This is a HelloWorld sample that illustrates how to set up a simplest video barcode scanner with Dynamsoft Barcode Reader.

package com.dynamsoft.tinybarcode.java;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Point;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.MotionEvent;
import android.view.View;
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
import com.dynamsoft.dce.EnumEnhancerFeatures;
import com.dynamsoft.tinybarcode.R;

import java.text.DecimalFormat;
import java.text.NumberFormat;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;

/**
 * @author dynamsoft
 */
public class MainActivity extends AppCompatActivity {
	private BarcodeReader mReader;
	private CameraEnhancer mCameraEnhancer;
	private AlertDialog alertDialog;
	private ZoomSeekbarView sbManuelZoom;
	private TextView tvManuelZoom;
	private SwitchCompat scAutoZoom;

	@SuppressLint("ClickableViewAccessibility")
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
		sbManuelZoom = findViewById(R.id.sb_manuel_zoom);
		tvManuelZoom = findViewById(R.id.tv_manuel_zoom);
		scAutoZoom = findViewById(R.id.sc_auto_zoom);
		scAutoZoom.setOnCheckedChangeListener((buttonView, isChecked) -> {
			if (isChecked) {
				// When auto-zoom feature is enabled, the camera will zoom-in automatically
				// towards the un-decoded barcode zone and zoom-out after the barcode is decoded.
				// A valid license is required to enable the auto-zoom feature.

				try {
					mCameraEnhancer.enableFeatures(EnumEnhancerFeatures.EF_AUTO_ZOOM);
				} catch (CameraEnhancerException e) {
					e.printStackTrace();
				}
				sbManuelZoom.setVisibility(View.GONE);
				tvManuelZoom.setVisibility(View.GONE);
			}else{
				mCameraEnhancer.disableFeatures(EnumEnhancerFeatures.EF_AUTO_ZOOM);
				try {
					mCameraEnhancer.setZoom(1.5f);
					tvManuelZoom.setText("1.5X");
					sbManuelZoom.setStartIndex(1.5f);
					sbManuelZoom.setIndex(1.5f);
				} catch (CameraEnhancerException e) {
					e.printStackTrace();
				}
				tvManuelZoom.setVisibility(View.VISIBLE);
			}
		});

		cameraView.setOverlayVisible(true);
		// Create an instance of Dynamsoft Camera Enhancer for video streaming.
		mCameraEnhancer = new CameraEnhancer(MainActivity.this);
		mCameraEnhancer.setCameraView(cameraView);


		try {
			// Set the zoom factor of the camera.
			mCameraEnhancer.setZoom(1.5f);


			// Restrict the zoom range. Both zoom and auto-zoom will not exceed this range.
			//mCameraEnhancer.setAutoZoomRange(1.5, 5)


			// Trigger a focus at the middel of the screen and keep continuous auto-focus enabled after the focus finished
			//mCameraEnhancer.setFocus(new Point(0.5,0.5), EnumFocusMode.FM_CONTINUOUS_AUTO)
			// If you want to lock the focal length after the focus. You can use the following code instead
			// setFocus(new Point(0.5,0.5), EnumFocusMode.FM_LOCKED)


			// Create an instance of Dynamsoft Barcode Reader.
			mReader = new BarcodeReader();
		} catch (BarcodeReaderException e) {
			e.printStackTrace();
		} catch (CameraEnhancerException e) {
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

		tvManuelZoom.setText("1.5X");
		NumberFormat formatter = new DecimalFormat("0.0");
		sbManuelZoom.setVisibility(View.GONE);
		sbManuelZoom.setRange(1.5f, mCameraEnhancer.getMaxZoomFactor());
		sbManuelZoom.setStartIndex(1.5f);
		sbManuelZoom.setOnMoveActionListener(new ZoomSeekbarView.OnTouchListener() {
			@Override
			public void onMove(float x) {
				tvManuelZoom.setText(formatter.format(x).replace(".0", "") + "X");
				try {
					mCameraEnhancer.setZoom(x);
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

		tvManuelZoom.setOnTouchListener(new View.OnTouchListener() {
			float currentX = 0;
			float startPosition = 0f;
			float lastX = 0f;

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_DOWN) {
					sbManuelZoom.setVisibility(View.VISIBLE);
					float lastPosition = sbManuelZoom.getPosition();
					if (lastPosition > 0) {
						sbManuelZoom.setPosition(lastPosition);
					}
					lastX = event.getX();
					startPosition = sbManuelZoom.getPosition();
				}

				float indexStart = sbManuelZoom.getPaddingStart() + sbManuelZoom.getX();
				float indexEnd = sbManuelZoom.getWidth() - sbManuelZoom.getPaddingEnd() + sbManuelZoom.getX();
				currentX = sbManuelZoom.getPosition();
				float moveX = event.getX() - lastX;
				lastX = event.getX();
				startPosition += moveX;
				if (startPosition < 0) {
					startPosition = sbManuelZoom.getPosition();
				} else if (startPosition < indexStart) {
					startPosition = indexStart;
				} else if (startPosition > indexEnd) {
					startPosition = indexEnd;
				}
				event.setLocation(startPosition, event.getY());
				sbManuelZoom.onTouchEvent(event);
				return true;
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

	private final Runnable mHideSeekBarRunnable = () -> {
		if (sbManuelZoom != null) {
			sbManuelZoom.setVisibility(View.GONE);
		}
	};

}
