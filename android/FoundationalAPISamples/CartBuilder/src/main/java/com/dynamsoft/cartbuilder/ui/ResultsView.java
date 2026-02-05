package com.dynamsoft.cartbuilder.ui;

import static android.os.Looper.getMainLooper;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.cartbuilder.R;
import com.dynamsoft.dbr.BarcodeResultItem;

public class ResultsView extends ConstraintLayout {

    private final RecyclerView rvResults;
    private final CartAdapter adapter;

    public ResultsView(@NonNull Context context) {
        this(context, null);
    }

    public ResultsView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ResultsView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        LayoutInflater.from(context).inflate(R.layout.results_view, this, true);

        rvResults = findViewById(R.id.rv_results);
        rvResults.setLayoutManager(new LinearLayoutManager(context));
        adapter = new CartAdapter();
        rvResults.setAdapter(adapter);
    }

    public void addBarcodes(@NonNull BarcodeResultItem[] barcodes) {
        if (Thread.currentThread() != getMainLooper().getThread()) {
            post(() -> addBarcodes(barcodes));
            return;
        }
        if (barcodes.length != 0) {
            adapter.addBarcodes(barcodes);
        }
        rvResults.setVisibility(adapter.getItemCount() == 0 ? GONE : VISIBLE);
    }

    public void clearBarcodes() {
        if (Thread.currentThread() != getMainLooper().getThread()) {
            post(this::clearBarcodes);
            return;
        }
        adapter.clear();
        rvResults.setVisibility(GONE);
    }

    @NonNull
    public CartAdapter getAdapter() {
        return adapter;
    }

    @NonNull
    public RecyclerView getRecyclerView() {
        return rvResults;
    }
}
