package com.dynamsoft.dbr.generalsettings.ui;

import static com.dynamsoft.dbr.generalsettings.ui.ExpandLinearLayout.Type.ARROW_ONLY;
import static com.dynamsoft.dbr.generalsettings.ui.ExpandLinearLayout.Type.SWITCH_ONLY;

import android.animation.ObjectAnimator;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.widget.SwitchCompat;
import androidx.databinding.BindingAdapter;
import androidx.databinding.InverseBindingAdapter;
import androidx.databinding.InverseBindingListener;

import com.dynamsoft.dbr.generalsettings.R;

/**
 * TODO: document your custom view class.
 */
public class ExpandLinearLayout extends LinearLayout {
    public enum Type {
        ARROW_ONLY,
        SWITCH_ONLY,
        ARROW_AND_SWITCH
    }

    private float ivTargetRotaionX = 180f;
    private float animPercent = 1f;

    private TextView tvTitle;
    private View titleView;

    private boolean isOpen = false;
    public SwitchCompat switchCompat;

    //For SwitchCompat's two-way dataBinding
    public InverseBindingListener onCheckedChangeListener;

    public ExpandLinearLayout(Context context) {
        this(context, null);
    }

    public ExpandLinearLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ExpandLinearLayout(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context, attrs, defStyle);
    }

    private void init(Context context, AttributeSet attrs, int defStyle) {
        setOrientation(VERTICAL);

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.ExpandLinearLayout, defStyle, 0);
        int type = typedArray.getInt(R.styleable.ExpandLinearLayout_type, 0);

        int titleBackGround = typedArray.getColor(R.styleable.ExpandLinearLayout_android_background, getResources().getColor(R.color.settings_primary));

        titleView = inflate(context, type == ARROW_ONLY.ordinal() ? R.layout.layout_expand_arrow_only
                : type == SWITCH_ONLY.ordinal() ? R.layout.layout_expand_switch_only
                : R.layout.layout_expand_arrow_and_switch, null);
        int titleWidth = typedArray.getLayoutDimension(R.styleable.ExpandLinearLayout_titleWidth, -1);
        int titleHeight = typedArray.getLayoutDimension(R.styleable.ExpandLinearLayout_titleHeight, (int) (48 * getResources().getDisplayMetrics().density));

        String titleText = typedArray.getString(R.styleable.ExpandLinearLayout_titleText);
        float titlePaddingStart = typedArray.getDimension(R.styleable.ExpandLinearLayout_title_padding_start, 0f);
        float titlePaddingEnd = typedArray.getDimension(R.styleable.ExpandLinearLayout_title_padding_end, 0f);
        int titleTextColor = typedArray.getColor(R.styleable.ExpandLinearLayout_titleTextColor, getResources().getColor(R.color.settings_text_primary));
        String tipMessage = typedArray.getString(R.styleable.ExpandLinearLayout_tipMessage);
        isOpen = typedArray.getBoolean(R.styleable.ExpandLinearLayout_openAtFirst, false);

        typedArray.recycle();

        titleView.setBackgroundColor(titleBackGround);
        setBackgroundColor(titleBackGround);

        tvTitle = titleView.findViewById(R.id.tv_title);
        tvTitle.setText(titleText);
        tvTitle.setTextColor(titleTextColor);
        ImageView ivTip = titleView.findViewById(R.id.iv_tip);
        if (tipMessage != null && !tipMessage.isEmpty()) {
            ivTip.setVisibility(VISIBLE);
            Extension.addClickToShowDialog(ivTip, titleText, tipMessage);
        } else {
            ivTip.setVisibility(GONE);
        }

        LayoutParams titleLP = new LayoutParams(titleWidth, titleHeight);
        addView(titleView, titleLP);
        titleView.setPadding((int) titlePaddingStart, 0, (int) titlePaddingEnd, 0);

        if (type != SWITCH_ONLY.ordinal()) {
            ImageView ivArrow = titleView.findViewById(R.id.iv_arrow);
            ivArrow.setRotationX(ivTargetRotaionX);
            titleView.setOnClickListener(v -> {
                setOpen(!isOpen);
                startAnim();
                rotateView(ivArrow);
            });
        }

        if (type != ARROW_ONLY.ordinal()) {
            switchCompat = titleView.findViewById(R.id.switch_compat);
        }

        if (type == SWITCH_ONLY.ordinal()) {
            switchCompat.setOnCheckedChangeListener((buttonView, isChecked) -> {
                if (onCheckedChangeListener != null) {
                    onCheckedChangeListener.onChange();
                }
                setOpen(isChecked);
                startAnim();
            });
            titleView.setOnClickListener(v -> switchCompat.setChecked(!switchCompat.isChecked()));
        }

    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int allChildHeight = 0;
        int firstChildHeight = 0;
        if (getChildCount() > 0) {
            for (int i = 0; i < getChildCount(); i++) {
                View child = getChildAt(i);
                int childHeight = child.getMeasuredHeight()
                        + ((MarginLayoutParams) child.getLayoutParams()).topMargin
                        + ((MarginLayoutParams) child.getLayoutParams()).bottomMargin;
                if (i == 0) {
                    firstChildHeight = childHeight + getPaddingTop() + getPaddingBottom();
                }
                allChildHeight += childHeight;
                if (i == getChildCount() - 1) {
                    allChildHeight += getPaddingTop() + getPaddingBottom();
                }
            }
        }

        if (isOpen) {
            setMeasuredDimension(widthMeasureSpec, firstChildHeight + (int) ((allChildHeight - firstChildHeight) * animPercent));
        } else {
            setMeasuredDimension(widthMeasureSpec, allChildHeight - (int) ((allChildHeight - firstChildHeight) * animPercent));
        }
    }

    private void setOpen(boolean open) {
        isOpen = open;
        ivTargetRotaionX = isOpen ? 0f : 180f;
    }

    private void startAnim() {
        ObjectAnimator animator = ObjectAnimator.ofFloat(this, "animPercent", 0f, 1f);
        animator.setDuration(Math.max((getChildCount() - 1) * 100L, 200));
        animator.start();
    }

    private float getAnimPercent() {
        return animPercent;
    }

    //For ObjectAnimator
    private void setAnimPercent(float animPercent) {
        this.animPercent = animPercent;
        requestLayout();
    }

    private void rotateView(View view) {
        ObjectAnimator rotationXAnimator = ObjectAnimator.ofFloat(view, "rotationX", view.getRotationX(), ivTargetRotaionX);
        rotationXAnimator.setDuration(Math.max((getChildCount() - 1) * 100L, 200));
        rotationXAnimator.start();
    }

    private void setChecked(boolean checked) {
        if (switchCompat != null) {
            switchCompat.setChecked(checked);
        }
    }

    public static class DataBindAdapter {
        @BindingAdapter("scChecked")
        public static void setScChecked(ExpandLinearLayout view, boolean checked) {
            view.setChecked(checked);
        }

        @InverseBindingAdapter(attribute = "scChecked", event = "scCheckedAttrChanged")
        public static boolean getScChecked(ExpandLinearLayout view) {
            if (view.switchCompat != null) {
                return view.switchCompat.isChecked();
            }
            return false;
        }

        @BindingAdapter(value = {"scCheckedAttrChanged"}, requireAll = false)
        public static void setScCheckedListener(ExpandLinearLayout view, InverseBindingListener listener) {
            view.onCheckedChangeListener = listener;
        }

        @BindingAdapter("usable")
        public static void setUsable(ExpandLinearLayout view, boolean usable) {
            if (!usable && view.isOpen) {
                view.titleView.callOnClick();
            }
            for (int i = 0; i < view.getChildCount(); i++) {
                view.getChildAt(i).setClickable(usable);
            }
            view.tvTitle.setAlpha(usable ? 1f : 0.5f);

        }

    }


}