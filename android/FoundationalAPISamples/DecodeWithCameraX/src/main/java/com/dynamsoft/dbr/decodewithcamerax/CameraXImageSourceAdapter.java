package com.dynamsoft.dbr.decodewithcamerax;

import android.content.Context;
import android.content.res.Configuration;
import android.util.Size;

import androidx.camera.view.CameraController;
import androidx.camera.view.LifecycleCameraController;
import androidx.lifecycle.LifecycleOwner;

import com.dynamsoft.core.basic_structures.EnumImagePixelFormat;
import com.dynamsoft.core.basic_structures.ImageData;
import com.dynamsoft.core.basic_structures.ImageSourceAdapter;
import com.dynamsoft.dbr.decodewithcamerax.ui.PreviewWithDrawingQuads;

import java.util.concurrent.Executors;

public class CameraXImageSourceAdapter extends ImageSourceAdapter {
    public static final Size DEFAULT_RESOLUTION_PORTRAIT = new Size(1080, 1920);
    public static final Size DEFAULT_RESOLUTION_LANDSCAPE = new Size(1920, 1080);

    private byte[] mBytes;

    public CameraXImageSourceAdapter(Context context, LifecycleOwner lifecycleOwner, PreviewWithDrawingQuads previewWithDrawingQuads) {
        LifecycleCameraController lifecycleCameraController = new LifecycleCameraController(context);
        lifecycleCameraController.bindToLifecycle(lifecycleOwner);
        lifecycleCameraController.setTapToFocusEnabled(true);
        CameraController.OutputSize outputSize;
        if (context.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            outputSize = new CameraController.OutputSize(DEFAULT_RESOLUTION_LANDSCAPE);
        } else {
            outputSize = new CameraController.OutputSize(DEFAULT_RESOLUTION_PORTRAIT);
        }
        lifecycleCameraController.setPreviewTargetSize(outputSize);
        lifecycleCameraController.setImageAnalysisTargetSize(outputSize);

        lifecycleCameraController.setImageAnalysisAnalyzer(Executors.newSingleThreadExecutor(), image -> {
            previewWithDrawingQuads.updateBufferToSensorTransformMatrix(image.getImageInfo());
            try {
                if (mBytes == null || mBytes.length != image.getPlanes()[0].getBuffer().remaining()) {
                    mBytes = new byte[image.getPlanes()[0].getBuffer().remaining()];
                }
                image.getPlanes()[0].getBuffer().get(mBytes);
                int nRowStride = image.getPlanes()[0].getRowStride();
                int nPixelStride = image.getPlanes()[0].getPixelStride();
                ImageData imageData = new ImageData();
                imageData.bytes = mBytes;
                imageData.width = image.getWidth();
                imageData.height = image.getHeight();
                imageData.stride = nRowStride;
                imageData.format = EnumImagePixelFormat.IPF_NV21;
                addImageToBuffer(imageData);
            } finally {
                image.close();
            }
        });
        previewWithDrawingQuads.previewView.setController(lifecycleCameraController);
    }

    @Override
    public boolean hasNextImageToFetch() {
        return true;
    }
}
