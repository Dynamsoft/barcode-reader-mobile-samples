package com.dynamsoft.dbr.decodefromanimage;

import android.app.AlertDialog;
import android.os.Bundle;
import android.view.View;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.core.basic_structures.CapturedResult;
import com.dynamsoft.core.basic_structures.CapturedResultItem;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.decodefromanimage.databinding.ActivityMainBinding;
import com.dynamsoft.license.LicenseManager;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends AppCompatActivity {

    private ActivityMainBinding binding;
    private byte[] selectedImageBytes;

    private CaptureVisionRouter mRouter;
    private final ExecutorService mDecodeThreadExecutor = Executors.newSingleThreadExecutor();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        if (savedInstanceState == null) {
            // Initialize license for Dynamsoft Barcode Reader.
		    // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
		    // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", this, (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                }
            });
        }

        mRouter = new CaptureVisionRouter(this);

        selectedImageBytes = FileUtil.assetsFileToBytes(getApplicationContext(), "image-decoding-sample.png");
        binding.imageView.setImageBitmap(FileUtil.fileBytesToBitmap(selectedImageBytes));

        binding.btnDecode.setOnClickListener(v -> {
            binding.pbDecoding.setVisibility(View.VISIBLE);
            mDecodeThreadExecutor.submit(() -> {
                // Decode barcodes from the file byte.
                // The method returns a CapturedResult object that contains an array of CapturedResultItems.
                // CapturedResultItem is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
                CapturedResult capturedResult = mRouter.capture(selectedImageBytes, EnumPresetTemplate.PT_READ_BARCODES_READ_RATE_FIRST);
                runOnUiThread(() -> showBarcodeResult(capturedResult));
            });
        });

        binding.btnSelectImg.setOnClickListener(v -> getFileImage.launch("image/*"));
    }

    private final ActivityResultLauncher<String> getFileImage = registerForActivityResult(new ActivityResultContracts.GetContent(), uri -> {
        if (uri != null) {
            try {
                InputStream inputStream = getContentResolver().openInputStream(uri);
                selectedImageBytes = FileUtil.inputStreamToBytes(inputStream);
                binding.imageView.setImageBitmap(FileUtil.fileBytesToBitmap(selectedImageBytes));
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    });

    @MainThread
    // This is the method that extract the barcodes info from the CapturedResult.
    private void showBarcodeResult(@NonNull CapturedResult result) {
        binding.pbDecoding.setVisibility(View.GONE);
        if (result.getErrorCode() == 0 || result.getItems().length > 0) {
            ArrayList<String> results = new ArrayList<>();
            // Get each CapturedResultItem object from the array.
            for (CapturedResultItem item : result.getItems()) {
                // Extract the barcode format and the barcode text from the CapturedResultItem.
                results.add(String.format(getString(R.string.results_message),
                        ((BarcodeResultItem) item).getFormatString(),
                        ((BarcodeResultItem) item).getText()));
            }
            showDialog(String.format(getString(R.string.results_title), result.getItems().length), results.toArray(new String[0]));
        } else {
            showDialog("Error", String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", result.getErrorCode(), result.getErrorMessage()));
        }
    }

    private void showDialog(String title, String... messages) {
        new AlertDialog.Builder(this).setTitle(title)
                .setItems(messages, null)
                .setCancelable(true)
                .setPositiveButton("OK", null)
                .show();
    }
}