package com.dynamsoft.decodewithcamerax;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.util.Size;
import android.widget.TextView;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.EnumImagePixelFormat;
import com.dynamsoft.dbr.EnumPresetTemplate;
import com.dynamsoft.dbr.TextResult;
import com.google.common.util.concurrent.ListenableFuture;

import java.lang.invoke.ConstantCallSite;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;

import static androidx.camera.core.CameraSelector.LENS_FACING_BACK;

public class MainActivity extends AppCompatActivity {
    PreviewView mPreviewView;
    TextView tvRes;

    BarcodeReader mReader;

    boolean isShowingResult;

    Size resolution = new Size(1920, 1080);
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mPreviewView = findViewById(R.id.preview_view);
        tvRes = findViewById(R.id.tv_res);
        requestPermissions();
        initBarcodeReader();

        ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(this);

        cameraProviderFuture.addListener(()->{
            try {
                // Camera provider is now guaranteed to be available
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();

                // Set up the view finder use case to display camera preview
                Preview preview = new Preview.Builder().build();

                // Choose the camera by requiring a lens facing
                CameraSelector cameraSelector = new CameraSelector.Builder()
                        .requireLensFacing(LENS_FACING_BACK)
                        .build();

                ImageAnalysis imageAnalysis =
                        new ImageAnalysis.Builder()
                                // enable the following line if RGBA output is needed.
                                //.setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                                .setTargetResolution(new Size(resolution.getWidth(), resolution.getHeight()))
                                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                .build();

                imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor(), mBarcodeAnalyzer);

                // Attach use cases to the camera with the same lifecycle owner
                Camera camera = cameraProvider.bindToLifecycle(
                        ((LifecycleOwner) this),
                        cameraSelector,
                        preview,
                        imageAnalysis);

                // Connect the preview use case to the previewView
                preview.setSurfaceProvider(
                        mPreviewView.getSurfaceProvider());
            } catch (InterruptedException | ExecutionException e) {
                // Currently no exceptions thrown. cameraProviderFuture.get()
                // shouldn't block since the listener is being called, so no need to
                // handle InterruptedException.
            }
        }, ContextCompat.getMainExecutor(this));
    }

    private void initBarcodeReader() {
        // Initialize license for Dynamsoft Barcode Reader.
        // The license key "DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" here will grant you a time-limited public trial license. Note that network connection is required for this license to work.
        // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
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

        try {
            // Create an instance of Dynamsoft Barcode Reader.
            mReader = new BarcodeReader();
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        mReader.updateRuntimeSettings(EnumPresetTemplate.VIDEO_SPEED_FIRST);
    }

    private ImageAnalysis.Analyzer mBarcodeAnalyzer = new ImageAnalysis.Analyzer() {
        @Override
        public void analyze(@NonNull ImageProxy imageProxy) {
            try {
                // insert your code here.
                // after done, release the ImageProxy object
                if(isShowingResult) {
                    return;
                }
                byte[] data = new byte[imageProxy.getPlanes()[0].getBuffer().remaining()];
                imageProxy.getPlanes()[0].getBuffer().get(data);
                int nRowStride = imageProxy.getPlanes()[0].getRowStride();
                int nPixelStride = imageProxy.getPlanes()[0].getPixelStride();
                try {
                    TextResult[] results = mReader.decodeBuffer(data,imageProxy.getWidth(), imageProxy.getHeight(), nRowStride*nPixelStride, EnumImagePixelFormat.IPF_NV21);
                    runOnUiThread(() -> showResult(results));
                } catch (BarcodeReaderException e) {
                    e.printStackTrace();
                }
            } finally {
                imageProxy.close();
            }
        }
    };

    private void requestPermissions() {
        try {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, 1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void showResult(TextResult[] results) {
        StringBuilder strRes = new StringBuilder();
        if (results != null && results.length > 0) {
            for (TextResult result : results) {
                if(result.barcodeFormat_2 != 0) {
                    strRes.append("Format: ").append(result.barcodeFormatString_2).append("\n").append("Text: ").append(result.barcodeText).append("\n\n");
                } else {
                    strRes.append("Format: ").append(result.barcodeFormatString).append("\n").append("Text: ").append(result.barcodeText).append("\n\n");
                }
            }
        } else {
            return;
        }
        isShowingResult = true;
        AlertDialog.Builder resDialog = new AlertDialog.Builder(this);

        resDialog.setTitle("Total: "+results.length)
                .setPositiveButton("OK",null)
                .setMessage(strRes.toString())
                .setOnDismissListener(dialog -> {
                    isShowingResult = false;
                })
                .show();
    }

    private void showErrorDialog(String message) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(this);
        dialog.setTitle(R.string.error_dialog_title)
                .setPositiveButton("OK",null)
                .setMessage(message)
                .show();

    }
}