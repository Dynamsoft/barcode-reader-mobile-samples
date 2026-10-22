package com.dynamsoft.scansinglebarcodekt

import android.os.Bundle
import android.view.View
import android.widget.TextView

import androidx.activity.enableEdgeToEdge
import androidx.activity.result.ActivityResultLauncher
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

import com.dynamsoft.dbrbundle.ui.BarcodeScanResult
import com.dynamsoft.dbrbundle.ui.BarcodeScannerActivity
import com.dynamsoft.dbrbundle.ui.BarcodeScannerConfig

class MainActivity : AppCompatActivity() {
    private lateinit var launcher: ActivityResultLauncher<BarcodeScannerConfig>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        enableEdgeToEdge()
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v: View, insets: WindowInsetsCompat ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        val textView = findViewById<TextView>(R.id.tv_result)
        val config = BarcodeScannerConfig().apply {
            /*
            Initialize the license.
            The license string here is a trial license. Note that network connection is required for this license to work.
            You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            */
            license = "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9"

            // BarcodeScannerConfig also lets you set the barcode formats, the scan region, the scanning mode and the
            // visibility of the torch/close/laser buttons. See the API reference for the full list of options.
            // To use a customized template, put the JSON file under "src\main\assets\Templates\" and call
            // templateFile = "YourTemplate.json".
            // Note that this sample ships no template: it uses the default settings of the scanner.
        }

        launcher = registerForActivityResult(BarcodeScannerActivity.ResultContract()) { result ->
            if (result.resultStatus == BarcodeScanResult.EnumResultStatus.RS_FINISHED && result.barcodes != null) {
                textView.text = "Result:\nformat: ${result.barcodes[0].formatString}\ncontent: ${result.barcodes[0].text}"
            } else if (result.resultStatus == BarcodeScanResult.EnumResultStatus.RS_CANCELED) {
                textView.text = "Scan canceled."
            }
            if (result.errorString != null && result.errorString.isNotEmpty()) {
                textView.text = result.errorString
            }
        }

        findViewById<View>(R.id.btn_navigate).setOnClickListener {
            launcher.launch(
                config
            )
        }
    }
}
