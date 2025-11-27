package com.dynamsoft.scansinglebarcode;

import android.os.Bundle;
import android.widget.TextView;

import com.dynamsoft.dbrbundle.ui.BarcodeScanResult;
import com.dynamsoft.dbrbundle.ui.BarcodeScannerActivity;
import com.dynamsoft.dbrbundle.ui.BarcodeScannerConfig;
import com.dynamsoft.core.basic_structures.DSRect;

import androidx.activity.EdgeToEdge;
import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class MainActivity extends AppCompatActivity {
	private ActivityResultLauncher<BarcodeScannerConfig> launcher;

	@Override
	protected void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		EdgeToEdge.enable(this);
		ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
			Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
			v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
			return insets;
		});

		TextView textView = findViewById(R.id.tv_result);
		BarcodeScannerConfig config = new BarcodeScannerConfig();

		/*
        Initialize the license.
        The license string here is a trial license. Note that network connection is required for this license to work.
        You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
		*/
		config.setLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9");

		// You can use the following code to specify the barcode format. If you are using a template file, the "BarcodeFormat" can also be specified via the template file.
		//config.setBarcodeFormats(EnumBarcodeFormat.BF_ONED | EnumBarcodeFormat.BF_QR_CODE);
		// If you have a customized template file, please put it under "src\main\assets\Templates\" and call the following code.
		//config.setTemplateFile("ReadSingleBarcode.json");
		// The following settings will display a scan region on the view. Only the barcode in the scan region can be decoded.
		//config.setScanRegion(new DSRect(0.15f, 0.3f, 0.85f, 0.7f, true));
		// Uncomment the following line to disable the beep sound.
		//config.setBeepEnabled(false);
		// Uncomment the following line if you don't want to display the torch button.
		// config.setTorchButtonVisible(false);
		// Uncomment the following line if you don't want to display the close button.
		// config.setCloseButtonVisible(false);
		// Uncomment the following line if you want to hide the scan laser.
		// config.setScanLaserVisible(false);
		// Uncomment the following line if you want the camera to auto-zoom when the barcode is far away.
		// config.setAutoZoomEnabled(false);

		launcher = registerForActivityResult(new BarcodeScannerActivity.ResultContract(), result -> {
			if (result.getResultStatus() == BarcodeScanResult.EnumResultStatus.RS_FINISHED && result.getBarcodes() != null) {
				String content = "Result: format: " + result.getBarcodes()[0].getFormatString() + "\n" + "content: "
						+ result.getBarcodes()[0].getText();
				textView.setText(content);
			} else if (result.getResultStatus() == BarcodeScanResult.EnumResultStatus.RS_CANCELED) {
				textView.setText("Scan canceled.");
			}
			if (result.getErrorString() != null && !result.getErrorString().isEmpty()) {
				textView.setText(result.getErrorString());
			}
		});

		findViewById(R.id.btn_navigate).setOnClickListener(v -> launcher.launch(config));
	}
}
