package com.dynamsoft.dbr.tinybarcodedecoding;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

import java.text.DecimalFormat;
import java.text.NumberFormat;

public class ZoomSeekbarView extends View {
    boolean ifSelected = false;
    private OnTouchListener mMoveListener = null;
    private Paint mLinePaint;
    private Paint mIndexPaint;
    private float position = -1f;
    private int max = -1;
    private int min = -1;
    private float interval = -1f;
    private float startIndex = 1f;
    private final NumberFormat formatter = new DecimalFormat("0.0");

    public ZoomSeekbarView(Context context) {
        super(context);
        init();
    }

    public ZoomSeekbarView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ZoomSeekbarView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setRange(float min, float max) {
        this.min = (int) (min * 10);
        this.max = (int) (max * 10);
    }

    private void init() {
        mLinePaint = new Paint();
        mLinePaint.setColor(getResources().getColor(R.color.white));
        mLinePaint.setAlpha(128);
        mLinePaint.setAntiAlias(true);
        mLinePaint.setStyle(Paint.Style.STROKE);
        mLinePaint.setStrokeWidth(1);

        mIndexPaint = new Paint();
        mIndexPaint.setAntiAlias(true);
        mIndexPaint.setStyle(Paint.Style.FILL_AND_STROKE);
        mIndexPaint.setColor(getResources().getColor(R.color.dy_orange));
        mIndexPaint.setStrokeWidth(4);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        interval = (float) (getWidth() - getPaddingStart() - getPaddingEnd()) / (max - min);
        if (position < 0) {
            setIndex(startIndex);
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        canvas.save();
        canvas.translate(getPaddingStart(), 0);

        float external = 0;
        if (ifSelected) {
            external = 5f;
        } else {
            external = 0;
        }

        for (int i = min; i <= max; i++) {
            if (i % 10 == 0) {
//                mLinePaint.setColor(getResources().getColor(R.color.white));
                mLinePaint.setAlpha(255);
                canvas.drawLine(0, getPaddingTop() - external, 0, getHeight() - getPaddingBottom() + external, mLinePaint);
                mLinePaint.setAlpha(128);
//                mLinePaint.setColor(getResources().getColor(R.color.gray));

//                String text = i / 10 + "X";
//                Rect rect = new Rect();
//                float txtWidth = mTextPaint.measureText(text);
//                mTextPaint.getTextBounds(text, 0, text.length(), rect);
//                if (i / 10 % 2 == 1 && i / 10 != max - 1) {
//                    canvas.drawText(text, 0 - txtWidth / 2, rect.height()+ getHeight() - 24, mTextPaint);
//                }
//                if (i / 10 == max) {
//                    canvas.drawText(text, 0 - txtWidth / 2, rect.height()+ getHeight() - 24, mTextPaint);
//                }
            } else if (i % 5 == 0) {
                canvas.drawLine(0, getPaddingTop() - external, 0, getHeight() - getPaddingBottom() + external, mLinePaint);
            } else {
                canvas.drawLine(0, getPaddingTop() - external, 0, getHeight() - getPaddingBottom() + external, mLinePaint);
            }
            Log.e("TAG", "onDraw: " + max + " " + min);
            if (interval < 0) {
                interval = (float) (getWidth() - getPaddingStart() - getPaddingEnd()) / (max - min);
            }
            canvas.translate(interval, 0);
        }
        canvas.restore();
        canvas.drawLine(position, 0, position, getHeight(), mIndexPaint);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if (mMoveListener != null) {
                    mMoveListener.onTouchStart();
                }
                setIndex(getCurrentIndex());
                break;
            case MotionEvent.ACTION_UP:
                if (mMoveListener != null) {
                    mMoveListener.onTouchEnd();
                }
                ifSelected = false;
                setIndex(getCurrentIndex());
                break;
            case MotionEvent.ACTION_MOVE:
                ifSelected = true;
                float x = event.getX();
                if (x < getPaddingStart()) {
                    setPosition(getPaddingStart());
                } else if (x > getWidth() - getPaddingEnd()) {
                    setPosition(getWidth() - getPaddingEnd());
                } else {
                    setPosition(x);
                }
                if (mMoveListener != null) {
                    mMoveListener.onMove(getCurrentIndex());
                }
            case MotionEvent.ACTION_CANCEL:
                setIndex(getCurrentIndex());
                break;
            default:
                break;
        }
        return true;
    }

    public float getPosition() {
        return position;
    }

    public void setPosition(float i) {
        position = i;
        invalidate();
    }

    public void setStartIndex(float index) {
        startIndex = index;
    }

    public void setIndex(float index) {
        int temp = (int) ((index - (float) min / 10) * interval * 10) + getPaddingStart();
        setPosition(temp);
    }

    public float getCurrentIndex() {
        float value = ((position - getPaddingStart()) / interval / 10 + (float) min / 10);
        String valueStr = formatter.format(value);
        return Float.parseFloat(valueStr);
    }


    public void setOnMoveActionListener(OnTouchListener move) {
        mMoveListener = move;
    }

    public interface OnTouchListener {
        void onMove(float x);

        void onTouchStart();

        void onTouchEnd();
    }

}
