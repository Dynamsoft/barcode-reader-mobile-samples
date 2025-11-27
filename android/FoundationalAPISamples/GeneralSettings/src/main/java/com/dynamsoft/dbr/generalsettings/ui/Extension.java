package com.dynamsoft.dbr.generalsettings.ui;

import android.app.AlertDialog;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.dynamsoft.dbr.generalsettings.R;

public class Extension {

    public static void addClickToShowDialog(@NonNull View view, @Nullable String title, @Nullable String message) {
        view.setOnClickListener(v -> {
            AlertDialog.Builder builder = new AlertDialog.Builder(view.getContext());
            if (title != null) {
                builder.setTitle(title);
            }
            if (message != null) {
                builder.setMessage(message);
            }
            AlertDialog dialog = builder.create();
            dialog.getWindow().setBackgroundDrawableResource(R.drawable.shape_circle_conner_dialog);
            dialog.show();
        });
    }
}
