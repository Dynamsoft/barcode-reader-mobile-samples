package com.dynamsoft.dbr.generalsettings.ui.scanner;

import android.view.View;
import android.widget.TextView;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.recyclerview.widget.RecyclerView;

public class ResultsViewHolder extends RecyclerView.ViewHolder {
    TextView tvResultFormat;
    TextView tvResultText;
    TextView tvResultIndex;

    public ResultsViewHolder(@NonNull View itemView, @IdRes int tvResultFormatId, @IdRes int tvResultTextId, @IdRes int tvResultIndexId) {
        super(itemView);
        tvResultFormat = itemView.findViewById(tvResultFormatId);
        tvResultText = itemView.findViewById(tvResultTextId);
        tvResultIndex = itemView.findViewById(tvResultIndexId);
    }

    public void setResultFormat(String text) {
        tvResultFormat.setText(text);
    }

    public void setResultFormat(@StringRes int textId) {
        tvResultFormat.setText(textId);
    }

    public void setResultText(String text) {
        tvResultText.setText(text);
    }

    public void setResultText(@StringRes int textId) {
        tvResultText.setText(textId);
    }

    public void setResultIndex(String text) {
        tvResultIndex.setText(text);
    }

    public void setResultIndex(@StringRes int textId) {
        tvResultIndex.setText(textId);
    }
}
