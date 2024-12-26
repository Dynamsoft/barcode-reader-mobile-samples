package com.dynamsoft.scansinglebarcodekt

import android.graphics.RectF
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.activity.result.ActivityResultLauncher
import androidx.appcompat.app.AppCompatActivity
import com.dynamsoft.core.basic_structures.DSRect
import com.dynamsoft.dbr.EnumBarcodeFormat
import com.dynamsoft.dbrbundle.ui.BarcodeScanResult
import com.dynamsoft.dbrbundle.ui.BarcodeScannerActivity
import com.dynamsoft.dbrbundle.ui.BarcodeScannerConfig

/**
 * @author: dynamsoft
 * Time: 2024/9/29
 * Description:
 */
class MainActivity : AppCompatActivity() {
    private lateinit var launcher: ActivityResultLauncher<BarcodeScannerConfig>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val textView = findViewById<TextView>(R.id.tv_result)

        val config = BarcodeScannerConfig().apply {
            /*
            Initialize the license.
            The license string here is a trial license. Note that network connection is required for this license to work.
            You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            */
            license = "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9";

            // You can use the following code to specify the barcode format. If you are using a template file, the "BarcodeFormat" can also be specified via the template file.
            //barcodeFormats = EnumBarcodeFormat.BF_ONED or EnumBarcodeFormat.BF_QR_CODE
            // If you have a customized template file, please put it under "src\main\assets\Templates\" and call the following code.
            //templateFilePath = "ReadSingleBarcode.json"
            // The following settings will display a scan region on the view. Only the barcode in the scan region can be decoded.
            //scanRegion = DSRect(0.15f, 0.3f, 0.85f, 0.7f, true)
            // Uncomment the following line to disable the beep sound.
            //isBeepEnabled = false
            // Uncomment the following line if you don't want to display the torch button.
            //isTorchButtonVisible = false
            // Uncomment the following line if you don't want to display the close button.
            //isCloseButtonVisible = false
            // Uncomment the following line if you want to hide the scan laser.
            //isScanLaserVisible = false
            // Uncomment the following line if you want the camera to auto-zoom when the barcode is far away.
            //isAutoZoomEnabled = true
        }

        launcher = registerForActivityResult(BarcodeScannerActivity.ResultContract()) { result ->
            if (result.resultStatus == BarcodeScanResult.EnumResultStatus.RS_FINISHED && result.barcodes != null) {
                val content = """
     Result: format: ${result.barcodes[0].formatString}
     content: ${result.barcodes[0].text}
     """.trimIndent()
                textView.text = content
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
