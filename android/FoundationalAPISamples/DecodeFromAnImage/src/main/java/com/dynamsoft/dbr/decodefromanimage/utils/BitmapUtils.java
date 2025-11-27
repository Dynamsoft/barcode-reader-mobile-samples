package com.dynamsoft.dbr.decodefromanimage.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Point;
import android.graphics.Typeface;
import android.text.TextPaint;

import androidx.core.content.res.ResourcesCompat;

import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.decodefromanimage.R;

public class BitmapUtils {
    public static void drawResultsOnBitmap(Context context, Bitmap bm, DecodedBarcodesResult result, float scale) {
        if (bm == null || result == null || result.getItems().length == 0) {
            return;
        }

        Path path = new Path();
        Canvas canvas = new Canvas(bm);

        Paint quadPaint = new Paint();
        quadPaint.setStyle(Paint.Style.STROKE);
        quadPaint.setStrokeWidth(5f);
        quadPaint.setColor(ResourcesCompat.getColor(context.getResources(), R.color.dy_orange, null));
        quadPaint.setAntiAlias(true);

        float r = Math.max(Math.min(bm.getWidth(), bm.getHeight()) / 80f, 10f);

        TextPaint textPaint = new TextPaint(Paint.ANTI_ALIAS_FLAG | Paint.DEV_KERN_TEXT_FLAG);
        textPaint.setTextSize(2.5f * r);
        textPaint.setTypeface(Typeface.DEFAULT_BOLD);
        textPaint.setColor(Color.WHITE);
        textPaint.setTypeface(Typeface.SANS_SERIF);
        textPaint.setAntiAlias(true);

        Paint roundPaint = new Paint();
        roundPaint.setStyle(Paint.Style.STROKE);
        roundPaint.setStrokeWidth(2 * r);
        roundPaint.setColor(ResourcesCompat.getColor(context.getResources(), R.color.dy_orange, null));
        roundPaint.setAntiAlias(true);

        for (int index = 0; index < result.getItems().length; index++) {
            BarcodeResultItem item = result.getItems()[index];
            float centerX = 0f;
            float centerY = 0f;
            path.reset();

            Point[] points = item.getLocation().points;
            for (int i = 0; i < 4; i++) {
                float x = points[i].x / scale;
                float y = points[i].y / scale;
                centerX += x / 4;
                centerY += y / 4;
                if (i == 0) {
                    path.moveTo(x, y);
                } else {
                    path.lineTo(x, y);
                }
            }

            path.close();
            canvas.drawPath(path, quadPaint);
            canvas.drawCircle(centerX, centerY, r, roundPaint);
            canvas.drawText(String.valueOf(index + 1), centerX - (index < 9 ? 0.63f : 1.53f) * r, centerY + 0.92f * r, textPaint);
        }
    }
}
