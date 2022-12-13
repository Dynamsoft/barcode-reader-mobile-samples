package com.dynamsoft.decodewithcamerax;

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
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import android.util.Size;
import android.view.LayoutInflater;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.EnumImagePixelFormat;
import com.dynamsoft.dbr.EnumPresetTemplate;
import com.dynamsoft.dbr.ImageData;
import com.dynamsoft.dbr.ImageSource;
import com.dynamsoft.dbr.TextResult;
import com.dynamsoft.dbr.TextResultListener;
import com.google.common.util.concurrent.ListenableFuture;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;

import static androidx.camera.core.CameraSelector.LENS_FACING_BACK;

public class CameraFragment extends Fragment {

    private PreviewView mPreviewView;
    private AlertDialog errorDialog, resDialog;

    private int mImagePixelFormat = EnumImagePixelFormat.IPF_NV21; //default

    private BarcodeReader mReader;
    private ImageData mImageData;

    private boolean isShowingDialog;
    private Size resolution = new Size(1920, 1080);


    public static CameraFragment newInstance() {
        return new CameraFragment();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.camera_fragment, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mPreviewView = view.findViewById(R.id.preview_view);
        requestPermissions();
        initBarcodeReader();
        initCamera();
    }

    @Override
    public void onResume() {
        super.onResume();
        mReader.startScanning();
    }

    @Override
    public void onPause() {
        super.onPause();
        mReader.stopScanning();
    }

    private void requestPermissions() {
        try {
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(requireActivity(), new String[]{Manifest.permission.CAMERA}, 1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initBarcodeReader() {

        try {
            // Create an instance of Dynamsoft Barcode Reader.
            mReader = new BarcodeReader();
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        mReader.updateRuntimeSettings(EnumPresetTemplate.VIDEO_SPEED_FIRST);

        mReader.setImageSource(new ImageSource() {
            @Override
            public ImageData getImage() {
                return mImageData;
            }
        });

        mReader.setTextResultListener(new TextResultListener() {
            @Override
            public void textResultCallback(int i, ImageData imageData, TextResult[] textResults) {
                if (textResults != null && textResults.length > 0) {
                    requireActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (!isShowingDialog) {
                                showResult(textResults);
                            }
                        }
                    });
                }
            }
        });
    }

    private void initCamera() {
        ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(requireContext());

        cameraProviderFuture.addListener(() -> {
            try {
                // Camera provider is now guaranteed to be available
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();

                int rotation = ((WindowManager)requireContext().getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getRotation();
                if(rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) {
                    resolution = new Size(1080, 1920);
                } else {
                    resolution = new Size(1920, 1080);
                }

                // Set up the view finder use case to display camera preview
                Preview preview = new Preview.Builder()
                        .setTargetResolution(resolution)
                        .setTargetRotation(rotation)
                        .build();

                // Choose the camera by requiring a lens facing
                CameraSelector cameraSelector = new CameraSelector.Builder()
                        .requireLensFacing(LENS_FACING_BACK)
                        .build();

                ImageAnalysis imageAnalysis =
                        new ImageAnalysis.Builder()
                                // enable the following line if RGBA output is needed.
//                                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                                .setTargetResolution(resolution)
                                .setTargetRotation(rotation)
                                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                .build();

                if (imageAnalysis.getOutputImageFormat() == ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888) {
                    mImagePixelFormat = EnumImagePixelFormat.IPF_ABGR_8888;
                } else if (imageAnalysis.getOutputImageFormat() == ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888) {
                    mImagePixelFormat = EnumImagePixelFormat.IPF_NV21;
                }

                imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor(), mBarcodeAnalyzer);

                // Unbind use cases before re-bind use cases
                cameraProvider.unbindAll();
                // Attach use cases to the camera with the same lifecycle owner
                Camera camera = cameraProvider.bindToLifecycle(
                        this,
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
        }, ContextCompat.getMainExecutor(requireContext()));
    }


    private final ImageAnalysis.Analyzer mBarcodeAnalyzer = new ImageAnalysis.Analyzer() {
        @Override
        public void analyze(@NonNull ImageProxy imageProxy) {
            try {
                // insert your code here.
                // after done, release the ImageProxy object
                if (isShowingDialog) {
                    mImageData = null;
                    return;
                }
                byte[] data = new byte[imageProxy.getPlanes()[0].getBuffer().remaining()];
                imageProxy.getPlanes()[0].getBuffer().get(data);
                int nRowStride = imageProxy.getPlanes()[0].getRowStride();
                int nPixelStride = imageProxy.getPlanes()[0].getPixelStride();

                ImageData imageData = new ImageData();
                imageData.bytes = data;
                imageData.width = imageProxy.getWidth();
                imageData.height = imageProxy.getHeight();
                imageData.stride = nRowStride;
                imageData.format = EnumImagePixelFormat.IPF_NV21;
                imageData.orientation = imageProxy.getImageInfo().getRotationDegrees();
                mImageData = imageData;
            } finally {
                imageProxy.close();
            }
        }
    };

    private void showResult(TextResult[] results) {
        StringBuilder strRes = new StringBuilder();
        if (results != null && results.length > 0) {
            for (TextResult result : results) {
                strRes.append("Format: ").append(result.barcodeFormatString).append("\n").append("Text: ").append(result.barcodeText).append("\n\n");
            }
        } else {
            return;
        }
        isShowingDialog = true;
        AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());

        resDialog = builder.setTitle("Total: " + results.length)
                .setPositiveButton("OK", null)
                .setMessage(strRes.toString())
                .setOnDismissListener(dialog -> {
                    isShowingDialog = false;
                    resDialog = null;
                })
                .show();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (resDialog != null) {
            resDialog.dismiss();
        }
    }
}