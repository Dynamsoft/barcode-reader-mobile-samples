package com.dynamsoft.decodewithcameraxkt

import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.dynamsoft.core.basic_structures.CapturedResultReceiver
import com.dynamsoft.core.basic_structures.CompletionListener
import com.dynamsoft.cvr.CaptureVisionRouter
import com.dynamsoft.cvr.CaptureVisionRouterException
import com.dynamsoft.cvr.EnumPresetTemplate
import com.dynamsoft.dbr.DecodedBarcodesResult
import com.dynamsoft.license.LicenseManager


class MainActivity : AppCompatActivity() {
    private lateinit var mRouter: CaptureVisionRouter
    private var mAlertDialog: AlertDialog? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        if (savedInstanceState == null) {
            // Initialize license for Dynamsoft Barcode Reader.
            // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
            // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
            LicenseManager.initLicense(
                "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", this
            ) { isSuccess, error ->
                if (!isSuccess) {
                    error.printStackTrace()
                }
            }
        }
        requestCameraPermission(this)
        val cameraXImageSourceAdapter =
            CameraXImageSourceAdapter(this, this, findViewById(R.id.previewView))
        mRouter = CaptureVisionRouter(this)
        try {
            // Set the ImageSourceAdapter you created as the input.
            mRouter.input = cameraXImageSourceAdapter
        } catch (e: CaptureVisionRouterException) {
            throw RuntimeException(e)
        }
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        mRouter.addResultReceiver(object : CapturedResultReceiver {
            // Implement the callback method to receive DecodedBarcodesResult.
            // The method returns a DecodedBarcodesResult object that contains an array of BarcodeResultItems.
            // BarcodeResultItems is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
            override fun onDecodedBarcodesReceived(result: DecodedBarcodesResult) {
                runOnUiThread { showResult(result) }
            }
        })
    }

    override fun onResume() {
        super.onResume()
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, object : CompletionListener {
            override fun onSuccess() {}

            override fun onFailure(errorCode: Int, errorString: String?) =
                runOnUiThread { showDialog("Error", "ErrorCode: $errorCode ErrorMessage: $errorString") }
        })
    }

    override fun onPause() {
        super.onPause()
        mRouter.stopCapturing()
    }

    // This is the method that access all BarcodeResultItem in the DecodedBarcodesResult and extract the content.
    private fun showResult(result: DecodedBarcodesResult?) {
        val strRes = StringBuilder()
        if (result != null && result.items != null && result.items.isNotEmpty()) {
            mRouter.stopCapturing()
            for (i in result.items.indices) {
                // Extract the barcode format and the barcode text from the BarcodeResultItem.
                val item = result.items[i]
                strRes.append(item.formatString).append(":").append(item.text).append("\n\n")
            }
            if (mAlertDialog != null && mAlertDialog!!.isShowing) {
                return
            }
            showDialog(getString(R.string.result_title), strRes.toString())
        }
    }

    private fun showDialog(title: String, message: String?) {
        if (mAlertDialog == null) {
            // Restart the capture when the dialog is closed
            mAlertDialog = AlertDialog.Builder(this).setCancelable(true).setPositiveButton("OK", null)
                .setOnDismissListener {
                    mRouter.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, null)
                }
                .create()
        }
        mAlertDialog?.apply {
            setTitle(title)
            setMessage(message)
            show()
        }
    }

    companion object {
        fun requestCameraPermission(activity: Activity?) {
            try {
                if (ContextCompat.checkSelfPermission(
                        activity!!,
                        Manifest.permission.CAMERA
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    ActivityCompat.requestPermissions(
                        activity,
                        arrayOf(Manifest.permission.CAMERA),
                        1
                    )
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}