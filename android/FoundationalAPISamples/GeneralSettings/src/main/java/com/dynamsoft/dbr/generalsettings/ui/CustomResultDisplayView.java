package com.dynamsoft.dbr.generalsettings.ui;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.generalsettings.R;

public class CustomResultDisplayView extends LinearLayout {

    private final ResultsRecyclerView rvResult;
    private final TextView tvTotal;
    private final Button btnExport;

    public CustomResultDisplayView(Context context) {
        this(context, null);
    }

    public CustomResultDisplayView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CustomResultDisplayView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        LayoutInflater.from(context).inflate(R.layout.results_view, this, true);

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.CustomResultDisplayView, defStyleAttr, 0);
        boolean needBtnExport = typedArray.getBoolean(R.styleable.CustomResultDisplayView_needBtnExport, false);
        typedArray.recycle();

        rvResult = findViewById(R.id.rv_result);
        tvTotal = findViewById(R.id.tv_total_count);
        btnExport = findViewById(R.id.btn_export);
        btnExport.setVisibility(needBtnExport ? VISIBLE : GONE);

        tvTotal.setOnClickListener(v -> setVisibility(GONE));

        btnExport.setOnClickListener(v -> {
            //TODO: Export results
        });
    }

    @SuppressLint("SetTextI18n")
    public void updateResults(BarcodeResultItem[] newResultItems) {
        tvTotal.setText("Total: " + (newResultItems != null ? newResultItems.length : 0));
        rvResult.updateResults(newResultItems);
    }
}