package com.dynamsoft.dbr.generalsettings.ui;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.databinding.BindingAdapter;
import androidx.databinding.InverseBindingAdapter;
import androidx.databinding.InverseBindingListener;

import com.dynamsoft.dbr.generalsettings.R;

public class RadioGroupWithTitle extends FrameLayout {
    private static final String TAG = "RadioGroupWithTitle";

    private RadioGroup radioGroup;

    private CharSequence[] optionTextArray;

    private InverseBindingListener onSelectionChangeListener;

    public RadioGroupWithTitle(@NonNull Context context) {
        this(context, null);
    }

    public RadioGroupWithTitle(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public RadioGroupWithTitle(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context, attrs, defStyleAttr);
    }

    private void initView(Context context, AttributeSet attrs, int defStyleAttr) {
        LayoutInflater.from(context).inflate(R.layout.layout_radio_group_with_title, this);

        radioGroup = findViewById(R.id.radio_group);

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.RadioGroupWithTitle, defStyleAttr, 0);
        String titleText = typedArray.getString(R.styleable.RadioGroupWithTitle_titleText);
        String tipMessage = typedArray.getString(R.styleable.RadioGroupWithTitle_tipMessage);
        CharSequence[] textArray = typedArray.getTextArray(R.styleable.RadioGroupWithTitle_optionTextArray);
        typedArray.recycle();

        if (titleText != null) {
            ((TextView) findViewById(R.id.tv_title)).setText(titleText);
        }
        if (tipMessage != null && !tipMessage.isEmpty()) {
            ImageView ivTip = findViewById(R.id.iv_tip);
            ivTip.setVisibility(VISIBLE);
            Extension.addClickToShowDialog(ivTip, titleText, tipMessage);
        }

        initOptionTextArray(textArray);
    }

    private void initOptionTextArray(CharSequence[] optionTextArray) {
        if(optionTextArray == null || optionTextArray.length == 0) {
            return;
        }
        this.optionTextArray = optionTextArray;
        LinearLayout.LayoutParams btnParams = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT);
        btnParams.weight = 1;
        btnParams.gravity = Gravity.CENTER;
        @SuppressLint("ResourceType")
        ColorStateList colorStateList = ContextCompat.getColorStateList(getContext(), R.drawable.selector_radiobutton_textcolor);
        for (int i = 0; i < optionTextArray.length; i++) {
            RadioButton button = new RadioButton(getContext());
            button.setBackgroundResource(R.drawable.selector_radiobutton_selected);
            button.setId(getIdFromIndex(i));
            button.setButtonDrawable(null);
            button.setChecked(i==0);
            button.setText(optionTextArray[i]);
            button.setTextSize(14f);
            button.setGravity(Gravity.CENTER);
            button.setTextColor(colorStateList);
            radioGroup.addView(button, btnParams);
        }
        setOnCheckedChangeListener((group, button, checkedId, selectedText) -> {
            if(onSelectionChangeListener != null) {
                onSelectionChangeListener.onChange();
            }
        });
    }

    private int getIdFromIndex(int index) {
        return index+ hashCode();
    }

    private int getIndexFromId(int id) {
        return id - hashCode();
    }

    private void check(String text) {
        for (int i = 0; i < optionTextArray.length; i++) {
            if(optionTextArray[i].equals(text)) {
                radioGroup.check(getIdFromIndex(i));
            }
        }
    }

    private void setOnCheckedChangeListener(@NonNull OnCheckedChangeListener listener) {
        radioGroup.setOnCheckedChangeListener((group, checkedId) -> {
            RadioButton button = group.findViewById(checkedId);
            listener.onCheckedChanged(radioGroup, button, checkedId, button.getText().toString());
        });
    }

    private interface OnCheckedChangeListener {
        void onCheckedChanged(RadioGroup group, RadioButton button, int checkedId, String selectedText);
    }

    public static class DataBindAdapter {
        @BindingAdapter("rgString")
        public static void setRgString(RadioGroupWithTitle view, String rgString) {
            view.check(rgString);
        }

        @InverseBindingAdapter(attribute = "rgString", event = "rgStringAttrChanged")
        public static String getRgString(RadioGroupWithTitle view) {
            int index = view.getIndexFromId(view.radioGroup.getCheckedRadioButtonId());
            return view.optionTextArray[index].toString();
        }

        @BindingAdapter(value = {"rgStringAttrChanged"}, requireAll = false)
        public static void setSelectionChangeListener(RadioGroupWithTitle view, InverseBindingListener listener) {
            view.onSelectionChangeListener = listener;
        }

    }
}
