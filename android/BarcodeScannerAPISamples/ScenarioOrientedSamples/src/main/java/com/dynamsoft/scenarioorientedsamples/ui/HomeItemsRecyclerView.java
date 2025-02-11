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
import java.util.Objects;

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

		TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.HomeItemsRecyclerView, defStyleAttr, 0);
		String mode = typedArray.getString(R.styleable.HomeItemsRecyclerView_mode);
		typedArray.recycle();

		HomeItemAdapter adapter = null;
		if(Objects.equals(mode, getResources().getString(R.string.for_barcode_types))) {
			adapter = new HomeItemAdapter(ModeInfo.modesForBarcodeTypes, this, R.drawable.shape_home_item1);
		}
		if(adapter == null) {
			return;
		}
		if(context.getResources().getConfiguration().orientation == 1) {
			recyclerView.setLayoutManager(new GridLayoutManager(context, 3));
		} else {
			recyclerView.setLayoutManager(new GridLayoutManager(context, 5));
		}
		recyclerView.setAdapter(adapter);
	}

	public void setOnHomeItemClickListener(HomeItemAdapter.OnHomeItemClickListener listener) {
		this.listener = new WeakReference<>(listener);
	}

	@Override
	public void onHomeItemClick(@NonNull String mode) {
		if(this.listener.get() != null) {
			this.listener.get().onHomeItemClick(mode);
		}
	}
}



