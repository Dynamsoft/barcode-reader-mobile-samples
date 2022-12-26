package com.dynamsoft.imagedecoding;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.Intent;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.EnumPresetTemplate;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.imagedecoding.databinding.ActivityMainBinding;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class MainActivity extends AppCompatActivity {
    private ActivityMainBinding binding;
    private BarcodeReader mReader;
    private byte[] mImgBytes;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize license for Dynamsoft Barcode Reader.
        // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
        // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
        BarcodeReader.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", new DBRLicenseVerificationListener() {
            @Override
            public void DBRLicenseVerificationCallback(boolean isSuccessful, Exception e) {
                runOnUiThread(() -> {
                    if (!isSuccessful) {
                        e.printStackTrace();
                        showErrorDialog(e.getMessage());
                    }
                });
            }
        });

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        try {
            mReader = new BarcodeReader();
            mReader.updateRuntimeSettings(EnumPresetTemplate.IMAGE_READ_RATE_FIRST);
        } catch (BarcodeReaderException e) {
            throw new RuntimeException(e);
        }

        binding.btnSelectImg.setOnClickListener(v-> choicePhotoWrapper());
        binding.btnDecode.setOnClickListener(v->{
            TextResult[] results = null;
            try {
                if(mImgBytes != null) {
                    results = mReader.decodeFileInMemory(mImgBytes);
                } else {
                    InputStream inputStream = getAssets().open("image-decoding-sample.png");
                    results = mReader.decodeFileInMemory(inputStream);
                }
                if(results != null && results.length > 0) {
                    showResultsDialog(results);
                }
            } catch (BarcodeReaderException | IOException e) {
                e.printStackTrace();
            }
        });

        try {
            InputStream inputStream = getAssets().open("image-decoding-sample.png");
            Bitmap sampleBitmap = BitmapFactory.decodeStream(inputStream);
            inputStream.close();
            binding.imageView.setImageBitmap(sampleBitmap);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public void choicePhotoWrapper() {
        Intent intent = new Intent("android.intent.action.GET_CONTENT");
        intent.setType("image/*");
        startActivityForResult(intent, 1024);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(requestCode == 1024 && data != null) {
            byte[] content = null;
            Uri originalUri = data.getData();
            ContentResolver resolver = getContentResolver();
            try {
                content = readStream(resolver.openInputStream(originalUri));
            } catch (Exception e) {
                e.printStackTrace();
            }

            if(content == null ) {
                return;
            }
            mImgBytes = content;
            BitmapFactory.Options opts = new BitmapFactory.Options();
            opts.inJustDecodeBounds = true;
            BitmapFactory.decodeByteArray(content, 0, content.length, opts);

            if (opts.outHeight * opts.outWidth > 1920 * 1080) {
                float scale = (float) Math.sqrt((double) (opts.outHeight * opts.outWidth) / (4000 * 2250));
                opts.inTargetDensity = getResources().getDisplayMetrics().densityDpi;
                opts.inDensity = (int) (opts.inTargetDensity * scale);
            }
            opts.inJustDecodeBounds = false;
            binding.imageView.setImageBitmap(BitmapFactory.decodeByteArray(content, 0, content.length, opts));
        }
    }

    public static byte[] readStream(InputStream inStream) throws Exception {
        byte[] buffer = new byte[1024];
        int len = -1;
        ByteArrayOutputStream outStream = new ByteArrayOutputStream();
        while ((len = inStream.read(buffer)) != -1) {
            outStream.write(buffer, 0, len);
        }
        byte[] data = outStream.toByteArray();
        outStream.close();
        inStream.close();
        return data;
    }

    private void showResultsDialog(TextResult[] results) {
        StringBuilder strResults = new StringBuilder();
        for (TextResult result : results) {
            strResults.append("\n\n").append(getString(R.string.format)).append(result.barcodeFormatString).append("\n").append(getString(R.string.text)).append(result.barcodeText);
        }
        AlertDialog.Builder dialog = new AlertDialog.Builder(this);
        dialog.setTitle(R.string.results_title)
                .setPositiveButton("OK", null)
                .setMessage(strResults)
                .show();
    }

    private void showErrorDialog(String message) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(this);
        dialog.setTitle(R.string.error_dialog_title)
                .setPositiveButton("OK", null)
                .setMessage(message)
                .show();

    }

}