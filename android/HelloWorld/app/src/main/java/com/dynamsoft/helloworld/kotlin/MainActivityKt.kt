package com.dynamsoft.helloworld.kotlin

import android.content.DialogInterface
import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.dynamsoft.dbr.BarcodeReader
import com.dynamsoft.dbr.BarcodeReaderException
import com.dynamsoft.dbr.TextResult
import com.dynamsoft.dce.CameraEnhancer
import com.dynamsoft.dce.CameraEnhancerException
import com.dynamsoft.dce.DCECameraView
import com.dynamsoft.dce.DCEFeedback
import com.dynamsoft.helloworld.R

class MainActivityKt : AppCompatActivity() {
    private lateinit var mReader: BarcodeReader
    private lateinit var mCameraEnhancer: CameraEnhancer
    private var alertDialog: AlertDialog? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_kt)
        BarcodeReader.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9") { isSuccessful, e ->
            runOnUiThread {
                if (!isSuccessful) {
                    e.printStackTrace()
                    showDialog(getString(R.string.error_dialog_title), e.message?:"", null)
                }
            }
        }
        // Add camera view for previewing video.
        val cameraView = findViewById<DCECameraView>(R.id.cameraView)
        cameraView.overlayVisible = true
        // Create an instance of Dynamsoft Camera Enhancer for video streaming.
        mCameraEnhancer = CameraEnhancer(this@MainActivityKt)
        mCameraEnhancer.cameraView = cameraView
        try {
            // Create an instance of Dynamsoft Barcode Reader.
            mReader = BarcodeReader()
        } catch (e: BarcodeReaderException) {
            e.printStackTrace()
        }

        // Bind the Camera Enhancer instance to the Barcode Reader instance to get frames from camera.
        mReader.setCameraEnhancer(mCameraEnhancer)

//        try {
//            val settings = mReader.runtimeSettings
//            settings.barcodeFormatIds =
//                EnumBarcodeFormat.BF_ONED or EnumBarcodeFormat.BF_QR_CODE or EnumBarcodeFormat.BF_PDF417 or EnumBarcodeFormat.BF_DATAMATRIX
//        } catch (e: BarcodeReaderException) {
//            e.printStackTrace();
//        }

        mReader.setTextResultListener { id, imageData, textResult ->
            runOnUiThread {
                showResult(textResult)
            }
        }
    }

    public override fun onResume() {
        // Start video barcode reading
        try {
            mCameraEnhancer.open()
        } catch (e: CameraEnhancerException) {
            e.printStackTrace()
        }
        mReader.startScanning()
        super.onResume()
    }

    public override fun onPause() {
        // Stop video barcode reading
        try {
            mCameraEnhancer.close()
        } catch (e: CameraEnhancerException) {
            e.printStackTrace()
        }
        mReader.stopScanning()
        super.onPause()
    }

    public override fun onStop() {
        if (alertDialog != null) {
            alertDialog!!.dismiss()
        }
        super.onStop()
    }

    private fun showDialog(
        title: String,
        message: String,
        listener: DialogInterface.OnClickListener?
    ) {
        val dialog = AlertDialog.Builder(this)
        alertDialog = dialog.setTitle(title).setPositiveButton("OK", listener)
            .setMessage(message)
            .setCancelable(false)
            .show()
    }

    private fun showResult(results: Array<TextResult>?){
        var strRes = "";
        if(results != null && results.isNotEmpty()){
            DCEFeedback.vibrate(this)
            mReader.stopScanning()
            for(i in results.indices){
                strRes += results[i].barcodeText
            }
            if (alertDialog != null && alertDialog!!.isShowing) {
                return
            }
            showDialog("Result", strRes){ _, _ -> mReader.startScanning()}
        }
    }
}