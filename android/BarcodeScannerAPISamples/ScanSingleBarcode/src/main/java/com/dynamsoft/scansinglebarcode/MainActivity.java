package com.dynamsoft.scansinglebarcode;

import android.os.Bundle;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.dbrbundle.ui.BarcodeScanResult;
import com.dynamsoft.dbrbundle.ui.BarcodeScannerActivity;
import com.dynamsoft.dbrbundle.ui.BarcodeScannerConfig;

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

        // BarcodeScannerConfig also lets you set the barcode formats, the scan region, the scanning mode and the
        // visibility of the torch/close/laser buttons. See the API reference for the full list of options.
        // To use a customized template, put the JSON file under "src\main\assets\Templates\" and call
        // config.setTemplateFile("YourTemplate.json").
        // Note that this sample ships no template: it uses the default settings of the scanner.

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
