package com.dynamsoft.dbr.performancesettings;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Typeface;
import android.media.ExifInterface;
import android.text.TextPaint;

import com.dynamsoft.core.basic_structures.CapturedResultItem;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.dbr.BarcodeResultItem;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class ImageUtil {

    public static int getScaleFromJpegBytes(byte[] jpegBytes) {
        int scale = 1;
        if (jpegBytes != null && jpegBytes.length != 0) {
            BitmapFactory.Options opts = new BitmapFactory.Options();
            opts.inJustDecodeBounds = true;
            BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.length, opts);
            scale = (int) Math.ceil(Math.sqrt((double) (opts.outHeight * opts.outWidth) / (1920 * 1080)));
        }
        return scale;
    }

    public static Bitmap jpegBytesToBitmap(byte[] jpegBytes) {
        if (jpegBytes != null && jpegBytes.length != 0) {
            BitmapFactory.Options opts = new BitmapFactory.Options();
            opts.inTargetDensity = 1;
            opts.inDensity = getScaleFromJpegBytes(jpegBytes);
            opts.inMutable = true;
            Bitmap bitmap = BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.length, opts);
            int degree = getJpegBytesDegree(jpegBytes);
            if (degree != 0) {
                Matrix matrix = new Matrix();
                matrix.postRotate(degree);
                bitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
            }
            return bitmap;
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
            return new byte[0];
        }
    }

    public static int getJpegBytesDegree(byte[] jpegBytes) {
        int degree = 0;
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                InputStream inputStream = new ByteArrayInputStream(jpegBytes);
                ExifInterface exifInterface = new ExifInterface(inputStream);
                int orientation = exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
                switch (orientation) {
                    case ExifInterface.ORIENTATION_ROTATE_90:
                        degree = 90;
                        break;
                    case ExifInterface.ORIENTATION_ROTATE_180:
                        degree = 180;
                        break;
                    case ExifInterface.ORIENTATION_ROTATE_270:
                        degree = 270;
                        break;
                    default:
                        break;
                }
                inputStream.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return degree;
    }

    public static void drawResultsOnBitmap(Bitmap bitmap, CapturedResultItem[] items, float scale) {
        if (items == null || items.length == 0 || bitmap == null) {
            return;
        }
        Path path = new Path();
        Canvas canvas = new Canvas(bitmap);
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(5f);
        paint.setColor(Color.GREEN);
        int width = Math.min(bitmap.getWidth(), bitmap.getHeight());
        float r = (float) width / 70;
        TextPaint textPaint = new TextPaint(Paint.ANTI_ALIAS_FLAG | Paint.DEV_KERN_TEXT_FLAG);
        textPaint.setTextSize(2.5f * r);
        textPaint.setTypeface(Typeface.DEFAULT_BOLD);
        textPaint.setColor(Color.WHITE);
        textPaint.setTypeface(Typeface.SANS_SERIF);
        textPaint.setAntiAlias(true);
        Paint roundPaint = new Paint();
        roundPaint.setStyle(Paint.Style.STROKE);
        roundPaint.setStrokeWidth(2 * r);
        roundPaint.setColor(Color.GREEN);
        roundPaint.setAntiAlias(true);

        for (int i = 0; i < items.length; i++) {
            if (items[i].getType() != EnumCapturedResultItemType.CRIT_BARCODE) {
                continue;
            }
            BarcodeResultItem item = (BarcodeResultItem) items[i];
            path.reset();
            path.moveTo(item.getLocation().points[0].x / scale, item.getLocation().points[0].y / scale);
            path.lineTo(item.getLocation().points[1].x / scale, item.getLocation().points[1].y / scale);
            path.lineTo(item.getLocation().points[2].x / scale, item.getLocation().points[2].y / scale);
            path.lineTo(item.getLocation().points[3].x / scale, item.getLocation().points[3].y / scale);
            path.close();
            canvas.drawPath(path, paint);
            float x = (item.getLocation().points[0].x / scale + item.getLocation().points[1].x / scale +
                    item.getLocation().points[2].x / scale + item.getLocation().points[3].x / scale) / 4;
            float y = (item.getLocation().points[0].y / scale + item.getLocation().points[1].y / scale +
                    item.getLocation().points[2].y / scale + item.getLocation().points[3].y / scale) / 4;
            canvas.drawCircle(x, y, r, roundPaint);
            if ((i + 1) < 10) {
                canvas.drawText(String.valueOf(i + 1), x - 0.63f * r, y + 0.92f * r, textPaint);
            } else {
                canvas.drawText(String.valueOf(i + 1), x - 1.53f * r, y + 0.92f * r, textPaint);
            }
        }
    }

}
