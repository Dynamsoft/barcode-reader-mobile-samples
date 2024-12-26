package com.dynamsoft.dbr.decodefromanimage;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class FileUtil {
    public static Bitmap fileBytesToBitmap(byte[] fileBytes) {
        if (fileBytes != null) {
            BitmapFactory.Options opts = new BitmapFactory.Options();
            opts.inJustDecodeBounds = true;
            BitmapFactory.decodeByteArray(fileBytes, 0, fileBytes.length, opts);
            if (opts.outHeight * opts.outWidth > 1920 * 1080) {
                float scale = (float) Math.sqrt((double) (opts.outHeight * opts.outWidth) / (1920 * 1080));
                opts.inTargetDensity = 1;
                opts.inDensity = (int) Math.ceil(scale);
            }
            opts.inJustDecodeBounds = false;
            return BitmapFactory.decodeByteArray(fileBytes, 0, fileBytes.length, opts);
        } else {
            return null;
        }
    }

    public static byte[] inputStreamToBytes(InputStream is) {
        try {
            ByteArrayOutputStream os = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int len;
            while ((len = is.read(buffer)) != -1) {
                os.write(buffer, 0, len);
            }
            os.close();
            is.close();
            return os.toByteArray();
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static byte[] assetsFileToBytes(Context context, String fileName) {
        try {
            InputStream inputStream = context.getAssets().open(fileName);
            return inputStreamToBytes(inputStream);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}
