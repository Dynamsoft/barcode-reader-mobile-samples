package com.dynamsoft.dbr.generalsettings.ui;

import android.app.AlertDialog;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.annotation.IdRes;
import androidx.appcompat.view.ContextThemeWrapper;
import androidx.navigation.Navigation;

import com.dynamsoft.dbr.generalsettings.R;

public class BindingAdapter {
    @androidx.databinding.BindingAdapter("TipMessage")
    public static void setImageTipMessage(ImageView imageView, String tips) {
        if(tips != null) {
            imageView.setOnClickListener(v-> showTip(v.getContext(), tips));
        }
    }

    private static void showTip(Context context, String message) {
        AlertDialog dialog = new AlertDialog
                .Builder(new ContextThemeWrapper(context, R.style.CustomDialogTheme))
                .setMessage(message)
                .create();
        dialog.show();
    }

    @androidx.databinding.BindingAdapter("NavigationId")
    public static void setNavigationActionId(View view, @IdRes int actionId) {
        view.setOnClickListener(v->Navigation.findNavController(v).navigate(actionId));
    }
}
