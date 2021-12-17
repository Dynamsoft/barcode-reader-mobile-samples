package com.dynamsoft.generalsettings.util;

import android.util.TypedValue;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.appcompat.widget.SwitchCompat;
import androidx.recyclerview.widget.RecyclerView;

public class TextAndSwitchViewHolder extends RecyclerView.ViewHolder {

    private TextView textView;
    private SwitchCompat switchCompat;

    public TextAndSwitchViewHolder(@NonNull View itemView, @IdRes int textViewId, @IdRes int switchCompatId) {
        super(itemView);
        textView = itemView.findViewById(textViewId);
        switchCompat = itemView.findViewById(switchCompatId);
    }

    public void setTextView(String text) {
        textView.setText(text);
    }

    public void setTextSize(float spSize) {
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, spSize);
    }

    public void setTextView(@StringRes int textId) {
        textView.setText(textId);
    }
}
