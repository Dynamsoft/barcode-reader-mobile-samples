package com.dynamsoft.decodefromanimagekt

import android.net.Uri
import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.MainThread
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.dynamsoft.cvr.CapturedResult
import com.dynamsoft.cvr.CaptureVisionRouter
import com.dynamsoft.cvr.EnumPresetTemplate
import com.dynamsoft.dbr.BarcodeResultItem
import com.dynamsoft.decodefromanimagekt.databinding.ActivityMainBinding
import com.dynamsoft.license.LicenseManager
import java.io.IOException
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : AppCompatActivity() {
    private var selectedImageBytes: ByteArray? = null

    private lateinit var binding: ActivityMainBinding
    private lateinit var mRouter: CaptureVisionRouter
    private lateinit var mDecodeThreadExecutor: ExecutorService
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater);
        setContentView(binding.root)

        mDecodeThreadExecutor = Executors.newSingleThreadExecutor()

        if (savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", this) { isSuccess, error ->
                if (!isSuccess) {
                    error?.printStackTrace()
                    runOnUiThread { binding.tvLicenseError.text = "License initialization failed: ${error?.message}" }
                }
            }
        }

        mRouter = CaptureVisionRouter(this)

        selectedImageBytes = FileUtil.assetsFileToBytes(applicationContext, "image-decoding-sample.png")

        binding.imageView.setImageBitmap(FileUtil.fileBytesToBitmap(selectedImageBytes))

        binding.btnDecode.setOnClickListener {
            binding.pbDecoding.visibility = View.VISIBLE
            // Decode barcodes from the file byte.
            // The method returns a CapturedResult object that contains an array of CapturedResultItems.
            // CapturedResultItem is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
            mDecodeThreadExecutor.submit {
                val capturedResult: CapturedResult =
                    mRouter.capture(selectedImageBytes, EnumPresetTemplate.PT_READ_BARCODES_READ_RATE_FIRST)
                runOnUiThread { showBarcodeResult(capturedResult) }
            }
        }

        binding.btnSelectImg.setOnClickListener { getFileImage.launch("image/*") }
    }

    private val getFileImage = registerForActivityResult<String, Uri>(
        ActivityResultContracts.GetContent()
    ) {
        if (it != null) {
            try {
                val inputStream =
                    contentResolver.openInputStream(it)
                selectedImageBytes = FileUtil.inputStreamToBytes(inputStream!!)
                binding.imageView.setImageBitmap(
                    FileUtil.fileBytesToBitmap(
                        selectedImageBytes
                    )
                )
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }
    }

    @MainThread
    // This is the method that extract the barcodes info from the CapturedResult.
    private fun showBarcodeResult(result: CapturedResult) {
        binding.pbDecoding.visibility = View.GONE
        if (result.errorCode == 0 || result.items.isNotEmpty()) {
            val results = ArrayList<String>()
            // Get each CapturedResultItem object from the array.
            for (item in result.items) {
                item as BarcodeResultItem
                // Extract the barcode format and the barcode text from the CapturedResultItem.
                results.add(String.format(getString(R.string.results_message), item.formatString, item.text))
            }
            showDialog(String.format(getString(R.string.results_title), result.items.size), *results.toTypedArray())
        } else {
            showDialog("Error","ErrorCode:${result.errorCode}\nErrorMessage:${result.errorMessage}" )
        }
    }

    private fun showDialog(title: String?, vararg messages: String) {
        android.app.AlertDialog.Builder(this).setTitle(title)
            .setItems(messages, null)
            .setCancelable(true)
            .setPositiveButton("OK", null)
            .show()
    }
}