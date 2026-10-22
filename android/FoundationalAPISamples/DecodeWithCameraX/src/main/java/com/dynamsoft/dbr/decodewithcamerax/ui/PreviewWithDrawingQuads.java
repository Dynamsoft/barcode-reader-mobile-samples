package com.dynamsoft.dbr.decodewithcamerax.ui;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.ImageInfo;
import androidx.camera.view.PreviewView;
import androidx.core.content.ContextCompat;

import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.dbr.decodewithcamerax.R;

import java.util.ArrayList;
import java.util.List;

public class PreviewWithDrawingQuads extends FrameLayout {
    private final Path path = new Path();
    private final Paint quadsPaint = new Paint();
    private final List<Quadrilateral> quadsOnBuffer = new ArrayList<>();
    private final Matrix bufferToSensorTransformMatrix = new Matrix();

    public PreviewView previewView;

    public PreviewWithDrawingQuads(@NonNull Context context) {
        this(context, null);
    }

    public PreviewWithDrawingQuads(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public PreviewWithDrawingQuads(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        this(context, attrs, defStyleAttr, 0);
    }

    public PreviewWithDrawingQuads(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);

        quadsPaint.setStyle(Paint.Style.STROKE);
        quadsPaint.setStrokeWidth(5);
        quadsPaint.setColor(ContextCompat.getColor(context, R.color.dy_orange));
        quadsPaint.setAntiAlias(true);

        previewView = new PreviewView(context);
        addView(previewView, new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT));
    }

    @SuppressLint("RestrictedApi")
    @Override
    protected void dispatchDraw(@NonNull Canvas canvas) {
        super.dispatchDraw(canvas);

        Matrix sensorToViewTransform = previewView.getSensorToViewTransform();
        if(sensorToViewTransform == null) {
            return;
        }
        Matrix bufferToPreviewTransformMatrix = new Matrix(bufferToSensorTransformMatrix);
        bufferToPreviewTransformMatrix.postConcat(sensorToViewTransform);


        for (Quadrilateral quadOnBuffer : quadsOnBuffer) {
            path.reset();
            Quadrilateral quadOnPreview = quadOnBuffer.transformByMatrix(bufferToPreviewTransformMatrix);
            for (int i = 0; i < quadOnPreview.points.length; i++) {
                if(i == 0) {
                    path.moveTo(quadOnPreview.points[i].x, quadOnPreview.points[i].y);
                } else {
                    path.lineTo(quadOnPreview.points[i].x, quadOnPreview.points[i].y);
                }
            }
            path.close();
            canvas.drawPath(path, quadsPaint);
        }
    }

    public void updateQuadsOnBuffer(List<Quadrilateral> quads) {
        quadsOnBuffer.clear();
        quadsOnBuffer.addAll(quads);
        invalidate();
    }

    public void updateBufferToSensorTransformMatrix(ImageInfo imageInfo) {
        Matrix sensorToBufferTransformMatrix = imageInfo.getSensorToBufferTransformMatrix();
        sensorToBufferTransformMatrix.invert(bufferToSensorTransformMatrix);
    }
}
