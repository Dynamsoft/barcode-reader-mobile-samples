package com.dynamsoft.scanmultiplebarcodes;

import android.os.Bundle;
import android.widget.TextView;

import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbrbundle.ui.BarcodeScanResult;
import com.dynamsoft.dbrbundle.ui.BarcodeScannerActivity;
import com.dynamsoft.dbrbundle.ui.BarcodeScannerConfig;
import com.dynamsoft.dbrbundle.ui.EnumScanningMode;

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

		//optional
		BarcodeScannerConfig config = new BarcodeScannerConfig();
		config.setLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9");
		config.setTorchButtonVisible(true);
		config.setCloseButtonVisible(true);
		config.setScanLaserVisible(true);
		config.setScanningMode(EnumScanningMode.SM_MULTIPLE);
		//config.setScanRegion(new DSRect(0.15f, 0.25f, 0.85f, 0.65f, true));
		config.setAutoZoomEnabled(false);
		//optional

		//must call
		launcher = registerForActivityResult(new BarcodeScannerActivity.ResultContract(), result -> {
			if (result.getResultStatus() == BarcodeScanResult.EnumResultStatus.RS_FINISHED && result.getBarcodes() != null) {
				StringBuilder content = new StringBuilder();
				content.append("Count: ").append(result.getBarcodes().length).append("\n\n");
				for (BarcodeResultItem barcode : result.getBarcodes()) {
					content.append("format: ").append(barcode.getFormatString()).append("\n").append("content: ").append(barcode.getText()).append("\n\n");
				}
				textView.setText(content.toString());
			} else if(result.getResultStatus() == BarcodeScanResult.EnumResultStatus.RS_CANCELED ){
				textView.setText("Scan canceled.");
			}
			if (result.getErrorString() != null && !result.getErrorString().isEmpty()) {
				textView.setText(result.getErrorString());
			}
		});

		findViewById(R.id.btn_navigate).setOnClickListener(v -> launcher.launch(config));
	}
}
