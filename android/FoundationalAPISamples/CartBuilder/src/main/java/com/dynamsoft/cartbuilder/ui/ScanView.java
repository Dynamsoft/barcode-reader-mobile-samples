package com.dynamsoft.cartbuilder.ui;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Outline;
import android.graphics.Point;
import android.graphics.drawable.GradientDrawable;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.ViewOutlineProvider;
import android.view.ViewParent;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.dynamsoft.cartbuilder.R;
import com.dynamsoft.core.basic_structures.CompletionListener;
import com.dynamsoft.core.basic_structures.EnumCapturedResultItemType;
import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.core.basic_structures.VideoFrameTag;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResultReceiver;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.CameraEnhancer;
import com.dynamsoft.dce.CameraEnhancerException;
import com.dynamsoft.dce.CameraView;
import com.dynamsoft.dce.DrawingItem;
import com.dynamsoft.dce.DrawingLayer;
import com.dynamsoft.dce.EnumCoordinateBase;
import com.dynamsoft.dce.Feedback;
import com.dynamsoft.dce.QuadDrawingItem;
import com.dynamsoft.utility.MultiFrameResultCrossFilter;

import java.util.ArrayList;
import java.util.List;

public class ScanView extends FrameLayout {
    // Used to distinguish a click from a drag. This prevents tiny finger jitter from starting a drag.
    private final int touchSlop;
    private CameraView cameraView;
    private DrawingLayer customLayer;
    private ImageView ivTarget;
    private CameraEnhancer camera;
    private CaptureVisionRouter router;
    private boolean isScanning = false;
    private TextView tvError = null;
    private BarcodeResultReceiver receiver;
    private float downRawX;
    private float downRawY;
    private float startX;
    private float startY;
    private boolean dragging;

    public ScanView(@NonNull Context context) {
        this(context, null);
    }

    public ScanView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ScanView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        // Initialize touch slop for filtering out small movements
        touchSlop = ViewConfiguration.get(context).getScaledTouchSlop();
        init();
    }

    private static float clamp(float v, float min, float max) {
        if (min > max) {
            float t = min;
            min = max;
            max = t;
        }
        return Math.max(min, Math.min(v, max));
    }

    private void init() {
        initViewFromXml();

        // Set rounded corners and elevation
        final float cornerRadiusPx = dp(15f);
        GradientDrawable backgroundDrawable = new GradientDrawable();
        backgroundDrawable.setShape(GradientDrawable.RECTANGLE);
        backgroundDrawable.setCornerRadius(cornerRadiusPx);
        setBackground(backgroundDrawable);

        //Make sure the content is clipped to the rounded corners
        setClipToOutline(true);
        setOutlineProvider(new ViewOutlineProvider() {
            @Override
            public void getOutline(View view, Outline outline) {
                outline.setRoundRect(0, 0, view.getWidth(), view.getHeight(), cornerRadiusPx);
            }
        });

        // Set elevation for shadow effect
        setElevation(dp(8));

        initCamera();
        initRouter();
    }

    private void initViewFromXml() {
        LayoutInflater.from(getContext()).inflate(R.layout.view_scan, this, true);
        cameraView = findViewById(R.id.camera_view);
        ivTarget = findViewById(R.id.iv_target);

        //Don't show DBR layer, use custom drawingLayer instead.
        DrawingLayer dbrLayer = cameraView.getDrawingLayer(DrawingLayer.DBR_LAYER_ID);
        dbrLayer.setVisible(false);
        customLayer = cameraView.createDrawingLayer();

        tvError = findViewById(R.id.tv_error);

        ImageView ivClose = findViewById(R.id.iv_close);
        ivClose.setOnClickListener(v -> {
            stopScanning();
            setVisibility(View.GONE);
        });

        ImageView ivTorch = findViewById(R.id.iv_torch);
        final boolean[] isTorchOn = {false};
        ivTorch.setOnClickListener(v -> {
            if (!isTorchOn[0]) {
                camera.turnOnTorch();
                ivTorch.setImageResource(com.dynamsoft.R.drawable.icon_flash_on);
            } else {
                camera.turnOffTorch();
                ivTorch.setImageResource(com.dynamsoft.R.drawable.icon_flash_off);
            }
            isTorchOn[0] = !isTorchOn[0];
        });

        TextView tvZoom = findViewById(R.id.tv_zoom);
        tvZoom.setOnClickListener(v -> {
            if (tvZoom.getText().equals("1x")) {
                camera.setZoomFactor(2.0f);
                tvZoom.setText("2x");
            } else {
                camera.setZoomFactor(1.0f);
                tvZoom.setText("1x");
            }
        });


    }

    private void initCamera() {
        if (camera != null) return;
        if (cameraView == null) {
            throw new IllegalStateException("cameraView is null. Did you inflate view_scan.xml?");
        }
        camera = new CameraEnhancer(cameraView, null);
    }

    private void initRouter() {
        if (router != null) return;
        router = new CaptureVisionRouter();
        MultiFrameResultCrossFilter filter = new MultiFrameResultCrossFilter();
        filter.enableLatestOverlapping(EnumCapturedResultItemType.CRIT_BARCODE, true);
        router.addResultFilter(filter);
        try {
            router.setInput(camera);
        } catch (CaptureVisionRouterException e) {
            throw new RuntimeException(e);
        }
        router.addResultReceiver(new CapturedResultReceiver() {
            @Override
            public void onDecodedBarcodesReceived(@NonNull DecodedBarcodesResult result) {
                if (result.getItems().length == 0) return;

                if (result.getItems().length > 1 && ivTarget.getVisibility() != View.VISIBLE) {
                    //If the first time the result contains multiple barcodes, show the alignment icon and wait for the next frame and subsequent results
                    post(() -> ivTarget.setVisibility(View.VISIBLE));
                    return;
                }

                List<DrawingItem> drawingItems = new ArrayList<>();

                if (result.getItems().length == 1 && ivTarget.getVisibility() != View.VISIBLE) {
                    //If the first time a result is obtained and only one barcode is decoded, return the result directly
                    processAfterObtainingBarcode(result.getItems()[0]);
                }

                if (ivTarget.getVisibility() == View.VISIBLE) {
                    //When the alignment icon is displayed, return the barcode whose area contains the center point
                    for (BarcodeResultItem item : result.getItems()) {
                        Quadrilateral location = item.getLocation();

                        Point centerOfVisibleRegion = getCenterOfVisibleRegion(result);

                        if (location.isPointInQuadrilateral(centerOfVisibleRegion)) {
                            processAfterObtainingBarcode(item);
                            break;
                        }
                    }
                }
            }
        });
    }


    @NonNull
    private Point getCenterOfVisibleRegion(@NonNull DecodedBarcodesResult result) {
        VideoFrameTag imageTag = (VideoFrameTag) result.getOriginalImageTag();
        Point centerOfVisibleRegion = new Point(imageTag.getOriginalWidth() / 2, imageTag.getOriginalHeight() / 2);
        centerOfVisibleRegion.offset(-imageTag.getCropRegion().left, -imageTag.getCropRegion().top);
        if (getContext().getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            centerOfVisibleRegion.set(centerOfVisibleRegion.y, centerOfVisibleRegion.x);
        }
        return centerOfVisibleRegion;
    }

    private void processAfterObtainingBarcode(BarcodeResultItem item) {
        // Provide feedback when barcode(s) is/are detected
        Feedback.beep();
        Feedback.vibrate();

        // Draw the barcode on custom layer
        List<DrawingItem> drawingItems = new ArrayList<>();
        drawingItems.add(new QuadDrawingItem(item.getLocation(), EnumCoordinateBase.CB_IMAGE));
        customLayer.setDrawingItems(drawingItems);

        stopScanning();

        // Fade out
        post(() -> fadeOutAndHide());
        post(() -> ivTarget.setVisibility(View.GONE));

        // Notify the receiver
        if (receiver != null) {
            receiver.onBarcodesReceive(item);
        }
    }


    @MainThread
    public void fadeOutAndHide() {
        // Cancel any running animations to avoid stacking.
        animate().cancel();

        // If already hidden, do nothing.
        if (getVisibility() != View.VISIBLE) {
            setVisibility(View.GONE);
            setAlpha(1f);
            return;
        }

        // Animate alpha to 0, then mark GONE and reset alpha for the next time it becomes visible.
        animate().alpha(0f)
                .setDuration(1000)
                .withEndAction(() -> {
                    customLayer.clearDrawingItems();
                    setVisibility(View.GONE);
                    setAlpha(1f);
                })
                .start();
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        try {
            camera.setScanRegion(cameraView.getVisibleRegionOfVideo());
            cameraView.setScanRegionMaskVisible(false);
        } catch (CameraEnhancerException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);

        if (visibility != View.VISIBLE) {
            // Resetting cameraView here clears the ghost image left on the preview from the previous session.
            // It prevents the old frame from briefly appearing when reopening.
            // The app still works without this call.
            camera.setCameraView(cameraView);
        }
    }

    public void startScanning() {
        isScanning = true;
        camera.open();
        router.startCapturing(EnumPresetTemplate.PT_READ_BARCODES, new CompletionListener() {
            @Override
            public void onSuccess() {
                Log.i("ScanView", "onSuccess: startCapturing success.");
            }

            @Override
            public void onFailure(int errorCode, String errorMessage) {
                post(() -> {
                    tvError.setText("ErrorCode: " + errorCode + "\n" + "ErrorMessage: " + errorMessage);
                    tvError.setVisibility(View.VISIBLE);
                });
            }
        });
    }

    public void stopScanning() {
        isScanning = false;
        camera.close();
        router.stopCapturing();
    }

    public boolean isScanning() {
        return isScanning;
    }

    @Nullable
    public CameraView getCameraView() {
        return cameraView;
    }

    public void setBarcodeResultReceiver(@Nullable BarcodeResultReceiver receiver) {
        this.receiver = receiver;
    }

    public void updateSizePx(int widthPx, int heightPx) {
        ViewGroup.LayoutParams lp = getLayoutParams();
        if (lp == null) {
            lp = new ViewGroup.LayoutParams(widthPx, heightPx);
        } else {
            lp.width = widthPx;
            lp.height = heightPx;
        }
        ViewGroup.LayoutParams finalLp = lp;
        animate().setDuration(300)
                .scaleX((float) widthPx / getWidth())
                .scaleY((float) heightPx / getHeight())
                .withEndAction(() -> {
                    setLayoutParams(finalLp);
                    setScaleX(1f);
                    setScaleY(1f);
                    post(this::clampToParentBounds);
                })
                .start();
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        switch (ev.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                dragging = false;
                downRawX = ev.getRawX();
                downRawY = ev.getRawY();
                startX = getTranslationX();
                startY = getTranslationY();
                ViewParentCompat.requestDisallowInterceptTouchEvent(this, true);
                return false;

            case MotionEvent.ACTION_MOVE:
                float dx = Math.abs(ev.getRawX() - downRawX);
                float dy = Math.abs(ev.getRawY() - downRawY);
                if (!dragging && (dx > touchSlop || dy > touchSlop)) {
                    dragging = true;
                    return true;
                }
                return false;

            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                dragging = false;
                ViewParentCompat.requestDisallowInterceptTouchEvent(this, false);
                return false;
        }
        return super.onInterceptTouchEvent(ev);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        View parent = (View) getParent();
        if (parent == null) return super.onTouchEvent(event);

        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                dragging = false;
                downRawX = event.getRawX();
                downRawY = event.getRawY();
                startX = getTranslationX();
                startY = getTranslationY();
                ViewParentCompat.requestDisallowInterceptTouchEvent(this, true);
                return true;

            case MotionEvent.ACTION_MOVE:
                float moveDxAbs = Math.abs(event.getRawX() - downRawX);
                float moveDyAbs = Math.abs(event.getRawY() - downRawY);
                if (!dragging && (moveDxAbs > touchSlop || moveDyAbs > touchSlop)) {
                    dragging = true;
                }

                if (dragging) {
                    float dx = event.getRawX() - downRawX;
                    float dy = event.getRawY() - downRawY;

                    float targetX = startX + dx;
                    float targetY = startY + dy;

                    float[] clamped = clampTranslationToParent(parent, targetX, targetY);
                    setTranslationX(clamped[0]);
                    setTranslationY(clamped[1]);
                }
                return true;

            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                ViewParentCompat.requestDisallowInterceptTouchEvent(this, false);
                if (!dragging) {
                    performClick();
                }
                dragging = false;
                return true;
        }
        return super.onTouchEvent(event);
    }

    private void clampToParentBounds() {
        View parent = (View) getParent();
        if (parent == null) return;
        float[] clamped = clampTranslationToParent(parent, getTranslationX(), getTranslationY());
        setTranslationX(clamped[0]);
        setTranslationY(clamped[1]);
    }

    private float[] clampTranslationToParent(@NonNull View parent, float targetTx, float targetTy) {
        int leftBound = parent.getPaddingLeft();
        int topBound = parent.getPaddingTop();
        int rightBound = parent.getWidth() - parent.getPaddingRight();
        int bottomBound = parent.getHeight() - parent.getPaddingBottom();

        if (rightBound <= leftBound || bottomBound <= topBound) {
            return new float[]{targetTx, targetTy};
        }

        float baseLeft = getLeft();
        float baseTop = getTop();

        float minTx = leftBound - baseLeft;
        float minTy = topBound - baseTop;
        float maxTx = rightBound - (baseLeft + getWidth());
        float maxTy = bottomBound - (baseTop + getHeight());

        float clampedX = clamp(targetTx, minTx, maxTx);
        float clampedY = clamp(targetTy, minTy, maxTy);
        return new float[]{clampedX, clampedY};
    }

    private float dp(float dp) {
        return TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP,
                dp,
                getResources().getDisplayMetrics()
        );
    }

    public interface BarcodeResultReceiver {
        void onBarcodesReceive(@NonNull BarcodeResultItem... barcodes);
    }

    private static final class ViewParentCompat {
        private ViewParentCompat() {
        }

        static void requestDisallowInterceptTouchEvent(@NonNull View child, boolean disallow) {
            ViewParent parent = child.getParent();
            if (parent != null) {
                parent.requestDisallowInterceptTouchEvent(disallow);
            }
        }
    }
}
