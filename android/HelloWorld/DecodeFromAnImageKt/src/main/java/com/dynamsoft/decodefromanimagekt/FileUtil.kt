package com.dynamsoft.decodefromanimagekt

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream
import kotlin.math.ceil

/**
 * @author: dynamsoft
 * Time: 2023/8/25
 * Description:
 */

object FileUtil {
    fun fileBytesToBitmap(fileBytes: ByteArray?): Bitmap? {
        return if (fileBytes != null) {
            val opts = BitmapFactory.Options()
            opts.inJustDecodeBounds = true
            BitmapFactory.decodeByteArray(fileBytes, 0, fileBytes.size, opts)
            if (opts.outHeight * opts.outWidth > 1920 * 1080) {
                val scale =
                    Math.sqrt((opts.outHeight * opts.outWidth).toDouble() / (1920 * 1080)).toFloat()
                opts.inTargetDensity = 1
                opts.inDensity = ceil(scale).toInt()
            }
            opts.inJustDecodeBounds = false
            BitmapFactory.decodeByteArray(fileBytes, 0, fileBytes.size, opts)
        } else {
            null
        }
    }

    fun inputStreamToBytes(`is`: InputStream): ByteArray? {
        return try {
            val os = ByteArrayOutputStream()
            val buffer = ByteArray(1024)
            var len: Int
            while (`is`.read(buffer).also { len = it } != -1) {
                os.write(buffer, 0, len)
            }
            os.close()
            `is`.close()
            os.toByteArray()
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }

    fun assetsFileToBytes(context: Context, fileName: String?): ByteArray? {
        return try {
            val inputStream = context.assets.open(fileName!!)
            inputStreamToBytes(inputStream)
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }
}
