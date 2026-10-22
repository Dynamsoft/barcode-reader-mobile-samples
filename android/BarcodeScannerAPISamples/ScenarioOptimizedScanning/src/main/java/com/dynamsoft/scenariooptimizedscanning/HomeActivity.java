package com.dynamsoft.scenariooptimizedscanning;

import android.content.Intent;
import android.os.Bundle;

import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.core.basic_structures.DSRect;
import com.dynamsoft.dbrbundle.ui.BarcodeScanResult;
import com.dynamsoft.dbrbundle.ui.BarcodeScannerActivity;
import com.dynamsoft.dbrbundle.ui.BarcodeScannerConfig;
import com.dynamsoft.dce.EnumResolution;
import com.dynamsoft.scenariooptimizedscanning.ui.HomeItemAdapter;
import com.dynamsoft.scenariooptimizedscanning.ui.HomeItemsRecyclerView;
import com.dynamsoft.scenariooptimizedscanning.ui.ModeInfo;

public class HomeActivity extends AppCompatActivity implements HomeItemAdapter.OnHomeItemClickListener {
    private ActivityResultLauncher<BarcodeScannerConfig> launcher;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        HomeItemsRecyclerView rvByFormats = findViewById(R.id.rv_by_formats);
        rvByFormats.setOnHomeItemClickListener(this);
        HomeItemsRecyclerView rvByScenario = findViewById(R.id.rv_by_scenario);
        rvByScenario.setOnHomeItemClickListener(this);

        launcher = registerForActivityResult(new BarcodeScannerActivity.ResultContract(), result -> {
            String content = "";
            if (result.getResultStatus() == BarcodeScanResult.EnumResultStatus.RS_FINISHED && result.getBarcodes() != null) {
                content = "Result\n" +
                        "\n" +
                        "\n" +
                        "format: " + result.getBarcodes()[0].getFormatString()  + "\n" +
                        "\n" +
                        "content: " + result.getBarcodes()[0].getText();
            } else if (result.getResultStatus() == BarcodeScanResult.EnumResultStatus.RS_CANCELED) {
                content = "Scan canceled.";
            }
            if (result.getErrorString() != null && !result.getErrorString().isEmpty()) {
                content = result.getErrorString();
            }
            Intent intent = new Intent(HomeActivity.this, ResultActivity.class);
            intent.putExtra("result", content);
            startActivity(intent);
        });
    }

    @Override
    public void onHomeItemClick(@NonNull ModeInfo modeInfo) {
        BarcodeScannerConfig config = new BarcodeScannerConfig();
        /*
        Initialize the license.
        The license string here is a trial license. Note that network connection is required for this license to work.
        You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
        */
        config.setLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9");

        // Pick the template that matches the scenario the user selected.
        config.setTemplateFile(modeInfo.templateFileInAsset); //modeInfo.templateFileInAsset is one of template file in asset/Templates, null for default template.
        if (modeInfo.titleInHome == R.string.home_title_dot_code) {
            config.setZoomFactor(2.0f);
            config.setScanRegion(new DSRect(0.15f, 0.35f, 0.85f, 0.48f, true));
        }
        if(modeInfo.titleInHome == R.string.home_title_pdf_417) {
            config.setResolution(EnumResolution.RESOLUTION_4K);
        }
        launcher.launch(config);
    }
}
