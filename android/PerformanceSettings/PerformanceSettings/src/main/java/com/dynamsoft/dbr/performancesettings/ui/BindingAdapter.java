package com.dynamsoft.dbr.performancesettings.ui;

import android.app.AlertDialog;
import android.content.Context;
import android.widget.ImageView;

import androidx.appcompat.view.ContextThemeWrapper;

import com.dynamsoft.dbr.performancesettings.R;

public class BindingAdapter {
    @androidx.databinding.BindingAdapter("HasTipMessage")
    public static void setImageTipMessage(ImageView imageView, boolean canShow) {
        if(canShow) {
            imageView.setOnClickListener(v-> showTip(v.getContext(), v.getContentDescription().toString()));
        }
    }

    public static void showTip(Context context, String message) {
        AlertDialog dialog = new AlertDialog
                .Builder(new ContextThemeWrapper(context, R.style.CustomDialogTheme))
                .setMessage(message)
                .create();
        dialog.show();
    }
}
