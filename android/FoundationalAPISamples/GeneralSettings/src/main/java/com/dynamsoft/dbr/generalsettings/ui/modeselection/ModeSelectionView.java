package com.dynamsoft.dbr.generalsettings.ui.modeselection;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Pair;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;
import androidx.databinding.BindingAdapter;
import androidx.databinding.InverseBindingAdapter;
import androidx.databinding.InverseBindingListener;
import androidx.recyclerview.widget.ItemTouchHelper;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

public class ModeSelectionView extends LinearLayout {
    public static final int LOCATION_MODE_TYPE = 0;
    public static final int DEBLUR_MODE_TYPE = 1;
    public static final int GRAY_SCALE_TRANS_MODE_TYPE = 2;
    public static final int GRAY_SCALE_ENHANCEMENT_MODE_TYPE = 3;

    private boolean ifAttachToAdapter;
    private RecyclerView recyclerView;
    private int[] modesArray;
    private InverseBindingListener modesArrayChanged;

    public ModeSelectionView(Context context) {
        this(context, null);
    }

    public ModeSelectionView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ModeSelectionView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
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

    private void configuration(List<Pair<Integer, String>> pairs, int[] modesArray, int maxItemCount) {
        if (!ifAttachToAdapter) {
            ifAttachToAdapter = true;
            this.modesArray = modesArray.clone();
            ModeSelectionAdapter adapter = new ModeSelectionAdapter(pairs, modesArray, maxItemCount, modesArrayAfterChanged -> {
                this.modesArray = modesArrayAfterChanged.clone();
                modesArrayChanged.onChange();
            });
            recyclerView.setAdapter(adapter);
            new ItemTouchHelper(new MyTouchHelperCallBack(adapter)).attachToRecyclerView(recyclerView);
        }
    }

    private List<Pair<Integer, String>> getPairsMap(int modeType) {
        if (modeType == LOCATION_MODE_TYPE) {
            return ModesMapConstant.LOCATION_MODE_MAP;
        } else if (modeType == DEBLUR_MODE_TYPE) {
            return ModesMapConstant.DEBLUR_MODE_MAP;
        } else if (modeType == GRAY_SCALE_TRANS_MODE_TYPE) {
            return ModesMapConstant.GRAY_SCALE_TRANS_MODE_MAP;
        } else if (modeType == GRAY_SCALE_ENHANCEMENT_MODE_TYPE) {
            return ModesMapConstant.GRAY_SCALE_ENHANCEMENT_MODE_MAP;
        } else {
            return null;
        }
    }

    public static class DataBindingAdapters {
        @BindingAdapter(value = {"modeType", "modesArray", "maxItemCount"}, requireAll = false)
        public static void configuration(ModeSelectionView view, int modeType, int[] modesArray, Integer maxItemCount) {
            List<Pair<Integer, String>> pairsMap = view.getPairsMap(modeType);
            if (pairsMap != null) {
                view.configuration(pairsMap, modesArray.clone(), maxItemCount != null ? maxItemCount : modesArray.length);
            }
            view.modesArray = modesArray.clone();
        }

        @InverseBindingAdapter(attribute = "modesArray", event = "modeArrayAttrChanged")
        public static int[] getModeArray(ModeSelectionView view) {
            return view.modesArray;
        }

        @BindingAdapter(value = {"modeArrayAttrChanged"}, requireAll = false)
        public static void addListeners(ModeSelectionView view, InverseBindingListener modeArrayChanged) {
            view.modesArrayChanged = modeArrayChanged;
        }
    }
}
