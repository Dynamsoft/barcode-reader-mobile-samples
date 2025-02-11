package com.dynamsoft.scenarioorientedsamples;

import android.os.Bundle;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

/**
 * @author: dynamsoft
 * Time: 2025/1/6
 * Description:
 */
public class ResultActivity extends AppCompatActivity {
	@Override
	protected void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_result);

		String result = getIntent().getStringExtra("result");
		((TextView) findViewById(R.id.tv_result)).setText(result);
	}
}
