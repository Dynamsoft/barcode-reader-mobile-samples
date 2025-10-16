package com.dynamsoft.scenarioorientedsamples.ui;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.dynamsoft.scenarioorientedsamples.R;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;


import java.lang.ref.WeakReference;

public class HomeItemsRecyclerView extends LinearLayout implements HomeItemAdapter.OnHomeItemClickListener {
	private RecyclerView recyclerView;
	private WeakReference<HomeItemAdapter.OnHomeItemClickListener> listener = new WeakReference<>(null);

	public HomeItemsRecyclerView(@NonNull Context context) {
		this(context, null);
	}

	public HomeItemsRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs) {
		this(context, attrs, 0);
	}

	public HomeItemsRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		initView(context, attrs, defStyleAttr);
	}

	private void initView(Context context, AttributeSet attrs, int defStyleAttr) {
		recyclerView = new RecyclerView(context, attrs, defStyleAttr);
		recyclerView.setId(getId()+hashCode());
		recyclerView.setNestedScrollingEnabled(false);
		LayoutParams layoutParams = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
		addView(recyclerView, layoutParams);

		try(TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.HomeItemsRecyclerView, defStyleAttr, 0)) {
			int mode = typedArray.getInt(R.styleable.HomeItemsRecyclerView_mode, 0);
			HomeItemAdapter adapter;
			if(mode == 0) {
				adapter = new HomeItemAdapter(ModeInfo.modesByBarcodeFormats, this, R.drawable.shape_home_item1);
			} else {
				adapter = new HomeItemAdapter(ModeInfo.modesByScenario, this, R.drawable.shape_home_item2);
			}
			recyclerView.setAdapter(adapter);
		}


		if(context.getResources().getConfiguration().orientation == 1) {
			recyclerView.setLayoutManager(new GridLayoutManager(context, 3));
		} else {
			recyclerView.setLayoutManager(new GridLayoutManager(context, 5));
		}
	}

	public void setOnHomeItemClickListener(HomeItemAdapter.OnHomeItemClickListener listener) {
		this.listener = new WeakReference<>(listener);
	}

	@Override
	public void onHomeItemClick(@NonNull ModeInfo modeInfo) {
		if(this.listener.get() != null) {
			this.listener.get().onHomeItemClick(modeInfo);
		}
	}
}



