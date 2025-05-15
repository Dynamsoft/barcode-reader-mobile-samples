package com.dynamsoft.dbr.generalsettings.ui;

import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.TypedArray;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.Range;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatButton;
import androidx.appcompat.widget.SwitchCompat;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.databinding.BindingAdapter;
import androidx.databinding.InverseBindingAdapter;
import androidx.databinding.InverseBindingListener;

import com.dynamsoft.dbr.generalsettings.R;

public class SingleLineLayout extends ConstraintLayout {
    public static final int MODE_ARROW_NEXT = 0x1;
    public static final int MODE_BUTTON = 0x2;
    public static final int MODE_EDIT_TEXT = 0x4;
    //    public static final int MODE_SPINNER = 0x08; //not use for now
    public static final int MODE_SWITCH_COMPAT = 0x10;
    public static final int MODE_CHECK_BOX = 0x20;

    private int endId = LayoutParams.PARENT_ID;

    private String titleText;
    private Range<Integer> etRange;

    public ViewGroup titleView;
    public TextView tvTitle;
    public ImageView ivArrow;
    public AppCompatButton button;
    public EditText etText;
    public SwitchCompat switchCompat; //For MODE_SWITCH_COMPAT or MODE_CHECK_BOX

    //For SwitchCompat's two-way dataBinding
    public InverseBindingListener onScCheckedChangeListener;
    public InverseBindingListener onTextEditChangeListener;

    public SingleLineLayout(@NonNull Context context) {
        this(context, null);
    }

    public SingleLineLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SingleLineLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context, attrs, defStyleAttr);
    }

    private void initView(Context context, AttributeSet attrs, int defStyleAttr) {
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.SingleLineLayout, defStyleAttr, 0);
        int titleWidth = typedArray.getLayoutDimension(R.styleable.SingleLineLayout_titleWidth, -1);
        int titleHeight = typedArray.getLayoutDimension(R.styleable.SingleLineLayout_titleHeight, (int) (48 * getResources().getDisplayMetrics().density));

        titleText = typedArray.getString(R.styleable.SingleLineLayout_titleText);
        int titleTextColor = typedArray.getColor(R.styleable.SingleLineLayout_titleTextColor, getResources().getColor(R.color.settings_text_primary));
        String tipMessage = typedArray.getString(R.styleable.SingleLineLayout_tipMessage);
        float titlePaddingStart = typedArray.getDimension(R.styleable.SingleLineLayout_title_padding_start, 0f);
        float titlePaddingEnd = typedArray.getDimension(R.styleable.SingleLineLayout_title_padding_end, 0f);
        int mode = typedArray.getInt(R.styleable.SingleLineLayout_singleLineMode, 0);
        String buttonText = typedArray.getString(R.styleable.SingleLineLayout_buttonText);
        int inputType = typedArray.getInt(R.styleable.SingleLineLayout_android_inputType, InputType.TYPE_CLASS_NUMBER);
        int titleBackGround = typedArray.getColor(R.styleable.SingleLineLayout_android_background, getResources().getColor(R.color.settings_primary));
        typedArray.recycle();

        titleView = (ViewGroup) inflate(context, R.layout.layout_single_line, null);
        titleView.setBackgroundColor(titleBackGround);
        setBackgroundColor(titleBackGround);

        tvTitle = titleView.findViewById(R.id.tv_title);
        tvTitle.setText(titleText);
        tvTitle.setTextColor(titleTextColor);
        if (tipMessage != null && !tipMessage.isEmpty()) {
            ImageView ivTip = titleView.findViewById(R.id.iv_tip);
            ivTip.setVisibility(VISIBLE);
            Extension.addClickToShowDialog(ivTip, titleText, tipMessage);
        }

        LayoutParams titleLP = new LayoutParams(titleWidth, titleHeight);
        addView(titleView, titleLP);
        titleView.setPadding((int) titlePaddingStart, 0, (int) titlePaddingEnd, 0);


        initMode(mode);

        if (button != null) {
            button.setText(buttonText);
        }

        if (etText != null) {
            etText.setInputType(inputType);
        }
    }

    public void initMode(int mode) {
        if ((mode & MODE_ARROW_NEXT) != 0) {
            initIvArrow();
        }
        if ((mode & MODE_BUTTON) != 0) {
            initButton();
        }
        if ((mode & MODE_EDIT_TEXT) != 0) {
            initEditText();
        }

        //Doesn't support show switchCompat and checkBox at the same time
        if ((mode & MODE_SWITCH_COMPAT) != 0 || (mode & MODE_CHECK_BOX) != 0) {
            initSwitchCompat();
            if ((mode & MODE_SWITCH_COMPAT) != 0) {
                switchCompat.setTrackResource(R.drawable.selector_switch_track);
                switchCompat.setThumbTintList(ColorStateList.valueOf(getResources().getColor(R.color.thumb_default)));
            } else if ((mode & MODE_CHECK_BOX) != 0) {
                switchCompat.setThumbResource(R.drawable.selector_checkbox);
                switchCompat.setTrackDrawable(null);
            }
        }
    }

    private void initIvArrow() {
        ivArrow = new ImageView(getContext());
        ivArrow.setImageResource(R.drawable.arrow_orange_right);
        ivArrow.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
        LayoutParams lp = new LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT);
        lp.dimensionRatio = "1:1";
        if (endId == LayoutParams.PARENT_ID) {
            lp.endToEnd = LayoutParams.PARENT_ID;
        } else {
            lp.endToStart = endId;
        }
        ivArrow.setId(++endId);
        addViewToTitleView(ivArrow, lp);
    }

    private void initButton() {
        button = new AppCompatButton(getContext());
        LayoutParams lp = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
        if (endId == LayoutParams.PARENT_ID) {
            lp.endToEnd = LayoutParams.PARENT_ID;
        } else {
            lp.endToStart = endId;
        }
        button.setId(++endId);
        addViewToTitleView(button, lp);
    }

    private void initEditText() {
        etText = new EditText(getContext());
        float dpx100 = getResources().getDimension(R.dimen.base_dp_x100);
        LayoutParams lp = new LayoutParams((int) dpx100, ViewGroup.LayoutParams.MATCH_PARENT);
        if (endId == LayoutParams.PARENT_ID) {
            lp.endToEnd = LayoutParams.PARENT_ID;
        } else {
            lp.endToStart = endId;
        }
        etText.setId(++endId);
        addViewToTitleView(etText, lp);
        etText.setGravity(Gravity.CENTER);

        etText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (onTextEditChangeListener != null) {
                    onTextEditChangeListener.onChange();
                }
            }
        });
    }

    private void initSwitchCompat() {
        switchCompat = new SwitchCompat(getContext());
        LayoutParams lp = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
        if (endId == LayoutParams.PARENT_ID) {
            lp.endToEnd = LayoutParams.PARENT_ID;
        } else {
            lp.endToStart = endId;
        }
        switchCompat.setId(++endId);
        addViewToTitleView(switchCompat, lp);
        switchCompat.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (onScCheckedChangeListener != null) {
                onScCheckedChangeListener.onChange();
            }
        });
        titleView.setOnClickListener(v -> switchCompat.setChecked(!switchCompat.isChecked()));
    }

    private void addViewToTitleView(View view, ViewGroup.LayoutParams lp) {
        titleView.addView(view, lp);
    }

    public static class DataBindingAdapter {
        @BindingAdapter("scChecked")
        public static void setScChecked(SingleLineLayout view, boolean checked) {
            view.switchCompat.setChecked(checked);
        }

        @InverseBindingAdapter(attribute = "scChecked", event = "scCheckedAttrChanged")
        public static boolean getScChecked(SingleLineLayout view) {
            if (view.switchCompat != null) {
                return view.switchCompat.isChecked();
            }
            return false;
        }

        @BindingAdapter("etString")
        public static void setEtString(SingleLineLayout view, String text) {
            view.etText.setText(text);
        }

        @InverseBindingAdapter(attribute = "etString", event = "etTextAttrChanged")
        public static String getEtString(SingleLineLayout view) {
            String s = view.etText.getText().toString();
            if(s.isBlank() && view.etText.getInputType() == InputType.TYPE_CLASS_NUMBER) {
                return "0";
            } else {
                return s;
            }
        }

        @BindingAdapter("etRange")
        public static void setEtRange(SingleLineLayout view, Range<Integer> range) {
            view.etRange = range;
            if (view.etText != null) {
                DataBindingAdapter.setIntRangeVerification(view.etText, range, correctedString -> {
                    view.etText.setText(correctedString);
                    String toastTextTitle = view.titleText;
                    if (toastTextTitle.length() > 16) {
                        toastTextTitle = toastTextTitle.substring(0, 13) + "...";
                    }
                    Toast.makeText(view.getContext(), "\"" + toastTextTitle + "\" should be in " + range, Toast.LENGTH_LONG).show();
                });
            }
        }

        @BindingAdapter(value = {"scCheckedAttrChanged", "etTextAttrChanged"}, requireAll = false)
        public static void addListeners(SingleLineLayout view, @Nullable InverseBindingListener scChanged, @Nullable InverseBindingListener etChanged) {
            view.onScCheckedChangeListener = scChanged;
            view.onTextEditChangeListener = etChanged;
        }

        @BindingAdapter("usable")
        public static void setUsable(SingleLineLayout view, boolean usable) {
            view.setEnabled(usable);
            view.tvTitle.setAlpha(usable ? 1f : 0.5f);
        }

        public static void setIntRangeVerification(EditText editText, Range<Integer> range, CorrectStringCallback callback) {
            editText.setOnFocusChangeListener((v, hasFocus) -> {
                if (hasFocus) {
                    return;
                }

                int inputType = editText.getInputType();
                if (inputType == InputType.TYPE_CLASS_NUMBER ||
                        inputType == InputType.TYPE_NUMBER_FLAG_DECIMAL ||
                        inputType == InputType.TYPE_NUMBER_FLAG_SIGNED) {

                    try {
                        String inputText = editText.getText().toString();
                        int number = inputText.isEmpty() ? 0 : Integer.parseInt(inputText);
                        int inRangeNumber = range.clamp(number);

                        if (inRangeNumber != number) {
                            callback.onCorrectString(inRangeNumber + "");
                        }
                    } catch (NumberFormatException e) {
                        callback.onCorrectString(String.valueOf(range.getUpper()));
                    }
                }
            });
        }
    }

    public interface CorrectStringCallback {
        void onCorrectString(String correctedString);
    }
}
