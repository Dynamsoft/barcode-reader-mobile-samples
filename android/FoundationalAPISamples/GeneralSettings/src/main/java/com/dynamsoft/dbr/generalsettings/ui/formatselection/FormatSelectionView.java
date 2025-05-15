package com.dynamsoft.dbr.generalsettings.ui.formatselection;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;
import androidx.databinding.BindingAdapter;
import androidx.databinding.InverseBindingAdapter;
import androidx.databinding.InverseBindingListener;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.Map;

public class FormatSelectionView extends LinearLayout {
    private boolean ifAttachToAdapter;
    private RecyclerView recyclerView;
    private FormatSelectionAdapter.OnMultiSelectionCallback callback;

    private InverseBindingListener barcodeFormatsChanged;


    public FormatSelectionView(Context context) {
        this(context, null);
    }

    public FormatSelectionView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FormatSelectionView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context, attrs, defStyleAttr);
    }

    private void initView(Context context, AttributeSet attrs, int defStyleAttr) {
        recyclerView = new RecyclerView(context, attrs, defStyleAttr);
        LayoutParams layoutParams = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        addView(recyclerView, layoutParams);
        recyclerView.setOverScrollMode(OVER_SCROLL_NEVER);
        recyclerView.setLayoutManager(new LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false));
    }

    public void configuration(Map<Long, Integer> formatsMap) {
        FormatSelectionAdapter adapter = new FormatSelectionAdapter(formatsMap, (position, representValue, isThisChecked, allChecked, allUnchecked) -> {
            if (callback != null) {
                callback.onItemSelectedChanged(position, representValue, isThisChecked, allChecked, allUnchecked);
            }
            if (barcodeFormatsChanged != null) {
                barcodeFormatsChanged.onChange();
            }
        });
        recyclerView.setAdapter(adapter);
    }

    public void allChecked() {
        if(recyclerView.getAdapter() != null) {
            ((FormatSelectionAdapter) recyclerView.getAdapter()).allChecked();
        }
    }

    public void allUnchecked() {
        if(recyclerView.getAdapter() != null) {
            ((FormatSelectionAdapter) recyclerView.getAdapter()).allUnchecked();
        }
    }

    public void setOnMultiSelectionCallback(FormatSelectionAdapter.OnMultiSelectionCallback callback) {
        this.callback = callback;
    }

    public long getCurrentFormatIds() {
        if(recyclerView.getAdapter() != null) {
            return ((FormatSelectionAdapter) recyclerView.getAdapter()).getCurrentFormatIds();
        }
        return 0L;
    }

    public static class DataBindingAdapter {
        @BindingAdapter(value = {"formatsMap", "currentFormatIds"})
        public static void configuration(FormatSelectionView view, Map<Long, Integer> formatsMap, long currentFormatIds) {
            view.configuration(formatsMap);
            ((FormatSelectionAdapter) view.recyclerView.getAdapter()).initCurrentFormatIds(currentFormatIds);
        }

        @InverseBindingAdapter(attribute = "currentFormatIds", event = "barcodeFormatsAttrChanged")
        public static long getCurrentFormatIds(FormatSelectionView view) {
            return ((FormatSelectionAdapter) view.recyclerView.getAdapter()).getCurrentFormatIds();
        }

        @BindingAdapter(value = {"barcodeFormatsAttrChanged"}, requireAll = false)
        public static void addListeners(FormatSelectionView view, InverseBindingListener barcodeFormatsChanged) {
            view.barcodeFormatsChanged = barcodeFormatsChanged;
        }
    }
}
