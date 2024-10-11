package com.dynamsoft.locateanitemwithbarcode;

import android.content.Intent;
import android.os.Bundle;
import android.widget.EditText;

import com.dynamsoft.license.LicenseManager;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

/**
 * @author: dynamsoft
 * Time: 2024/8/5
 * Description:
 */
public class MainActivity extends AppCompatActivity {
	private EditText mEditText;
	@Override
	protected void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		mEditText = findViewById(R.id.et_text);
		findViewById(R.id.btn_to).setOnClickListener(v -> {
			Intent intent = new Intent(MainActivity.this, ScanActivity.class);
			String goalQr = mEditText.getText().toString();
			intent.putExtra("barcode", goalQr);
			startActivity(intent);
		});
		findViewById(R.id.btn_scan).setOnClickListener(v -> {
			Intent intent = new Intent(MainActivity.this, CrabCodeActivity.class);
			startActivityForResult(intent, 0);
		});

		LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", this, (isSuccess, error) -> {
			if (!isSuccess) {
				error.printStackTrace();
			}
		});
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == 0 && resultCode == RESULT_OK) {
			if(data != null) {
				mEditText.setText(data.getStringExtra("crabCode"));
			}
		}
	}
}
