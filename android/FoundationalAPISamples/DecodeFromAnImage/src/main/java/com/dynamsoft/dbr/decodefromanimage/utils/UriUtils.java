package com.dynamsoft.dbr.decodefromanimage.utils;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Build;
import android.util.Size;

import androidx.core.content.FileProvider;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class UriUtils {
    public static List<Uri> getImageUrisFromAssetsDir(Context context, String dirName) {
        ArrayList<Uri> uris = new ArrayList<>();
        try {
            String[] list = context.getAssets().list(dirName);
            assert list != null;
            for (String file : list) {
                if (file.endsWith(".png") || file.endsWith(".jpg") || file.endsWith(".jpeg") || file.endsWith(".gif")) {
                    uris.add(Uri.parse("file:///android_asset/" + dirName + "/" + file));
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return uris;
    }

    public static Uri getUriFromFile(Context context, String path) {
        File file = new File(path);
        if (file.getParentFile() != null && !file.getParentFile().exists()) {
            file.getParentFile().mkdirs(); // Create parent directories if needed
        }
        return FileProvider.getUriForFile(context, context.getPackageName(), file);
    }

    public static InputStream toInputStream(Context context, Uri uri) {
        String prefix = "/android_asset/";
        if (uri.getEncodedPath() != null && uri.getEncodedPath().startsWith(prefix)) {
            try {
                return context.getAssets().open(uri.getEncodedPath().substring(prefix.length()));
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            try {
                return context.getContentResolver().openInputStream(uri);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public static byte[] toBytes(Context context, Uri uri) {
        try (InputStream inputStream = toInputStream(context, uri)) {
            if (inputStream != null) {
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                byte[] buffer = new byte[1024];
                int length;
                while ((length = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, length);
                }
                return outputStream.toByteArray();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return new byte[0]; // Empty byte array
    }

    public static Size getRotatedSize(Context context, Uri uri) {
        try (InputStream inputStream = toInputStream(context, uri)) {
            if (inputStream != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                //Call ExifInterface API required level 24
                ExifInterface exifInterface = new ExifInterface(inputStream);
                int orientation = exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
                int width = exifInterface.getAttributeInt(ExifInterface.TAG_IMAGE_WIDTH, 0);
                int height = exifInterface.getAttributeInt(ExifInterface.TAG_IMAGE_LENGTH, 0);

                if (width != 0 && height != 0 && orientation != ExifInterface.ORIENTATION_UNDEFINED) {
                    if (orientation == ExifInterface.ORIENTATION_ROTATE_90 || orientation == ExifInterface.ORIENTATION_ROTATE_270) {
                        return new Size(height, width);
                    } else {
                        return new Size(width, height);
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace(); // Or handle the exception appropriately
        }

        // EXIF information is incomplete.
        // In this sample, this happens mainly to the URIs obtained from assets.
        try (InputStream inputStream = toInputStream(context, uri)) {
            if (inputStream != null) {
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inJustDecodeBounds = true;
                BitmapFactory.decodeStream(inputStream, null, options);
                return new Size(options.outWidth, options.outHeight);
            }
        } catch (IOException e) {
            e.printStackTrace(); // Or handle the exception appropriately
        }

        return new Size(0, 0);
    }

}
