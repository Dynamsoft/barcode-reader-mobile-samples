package com.dynamsoft.decodewithcameraxkt

import android.content.Context
import android.content.res.Configuration
import android.util.Size
import androidx.camera.core.ImageProxy
import androidx.camera.view.CameraController.OutputSize
import androidx.camera.view.LifecycleCameraController
import androidx.camera.view.PreviewView
import androidx.lifecycle.LifecycleOwner
import com.dynamsoft.core.basic_structures.EnumImagePixelFormat
import com.dynamsoft.core.basic_structures.ImageData
import com.dynamsoft.core.basic_structures.ImageSourceAdapter
import java.util.concurrent.Executors

/**
 * @author: dynamsoft
 * Time: 2023/8/25
 * Description:
 */
class CameraXImageSourceAdapter(
    context: Context,
    lifecycleOwner: LifecycleOwner?,
    previewView: PreviewView
) : ImageSourceAdapter() {
    private var mBytes: ByteArray? = null

    init {
        val lifecycleCameraController = LifecycleCameraController(context)
        lifecycleCameraController.bindToLifecycle(lifecycleOwner!!)
        lifecycleCameraController.isTapToFocusEnabled = true
        val outputSize: OutputSize = if (context.resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE) {
                OutputSize(DEFAULT_RESOLUTION_LANDSCAPE)
            } else {
                OutputSize(DEFAULT_RESOLUTION_PORTRAIT)
            }
        lifecycleCameraController.previewTargetSize = outputSize
        lifecycleCameraController.imageAnalysisTargetSize = outputSize
        lifecycleCameraController.setImageAnalysisAnalyzer(
            Executors.newSingleThreadExecutor()
        ) { image: ImageProxy ->
            try {
                if (mBytes == null || mBytes!!.size != image.planes[0].buffer
                        .remaining()
                ) {
                    mBytes = ByteArray(image.planes[0].buffer.remaining())
                }
                image.planes[0].buffer[mBytes!!]
                val nRowStride = image.planes[0].rowStride
                val nPixelStride = image.planes[0].pixelStride
                val imageData = ImageData()
                imageData.bytes = mBytes
                imageData.width = image.width
                imageData.height = image.height
                imageData.stride = nRowStride
                imageData.format = EnumImagePixelFormat.IPF_NV21
                imageData.orientation = image.imageInfo.rotationDegrees
                addImageToBuffer(imageData)
            } finally {
                image.close()
            }
        }
        previewView.controller = lifecycleCameraController
    }

    override fun hasNextImageToFetch(): Boolean {
        return true
    }

    companion object {
        val DEFAULT_RESOLUTION_PORTRAIT = Size(1080, 1920)
        val DEFAULT_RESOLUTION_LANDSCAPE = Size(1920, 1080)
    }
}
