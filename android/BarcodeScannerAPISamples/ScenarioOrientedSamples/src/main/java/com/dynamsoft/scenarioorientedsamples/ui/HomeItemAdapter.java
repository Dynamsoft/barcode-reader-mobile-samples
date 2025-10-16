package com.dynamsoft.scenarioorientedsamples.ui;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.dynamsoft.scenarioorientedsamples.R;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

public class HomeItemAdapter extends RecyclerView.Adapter<HomeItemAdapter.ViewHolder> {

	private final List<ModeInfo> modeInfoList;
	private final OnHomeItemClickListener listener;
	@DrawableRes
	private int firstBackgroundId;
	@DrawableRes
	private int secondBackgroundId;

	public HomeItemAdapter(List<ModeInfo> modeInfoList, OnHomeItemClickListener listener, @DrawableRes int startBackgroundId) {
		this.modeInfoList = modeInfoList;
		this.listener = listener;
		this.firstBackgroundId = startBackgroundId;
		if (firstBackgroundId == R.drawable.shape_home_item1) {
			this.secondBackgroundId = R.drawable.shape_home_item2;
		} else {
			this.secondBackgroundId = R.drawable.shape_home_item1;
		}
	}

	@NonNull
	@Override
	public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
		return new ViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_home_item, parent, false));
	}

	@Override
	public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
		if (position % 2 == 0) {
			holder.clHomeItem.setBackgroundResource(firstBackgroundId);
		} else {
			holder.clHomeItem.setBackgroundResource(secondBackgroundId);
		}
		holder.tvItem.setText(modeInfoList.get(position).titleInHome);
		holder.ivItem.setImageResource(modeInfoList.get(position).iconInHome);
		holder.itemView.setOnClickListener(v -> listener.onHomeItemClick(modeInfoList.get(position)));
	}

	@Override
	public int getItemCount() {
		return modeInfoList.size();
	}

	public static class ViewHolder extends RecyclerView.ViewHolder {
		private final ConstraintLayout clHomeItem;
		private final TextView tvItem;
		private final ImageView ivItem;

		public ViewHolder(@NonNull View itemView) {
			super(itemView);
			clHomeItem = itemView.findViewById(R.id.cl_home_item);
			tvItem = itemView.findViewById(R.id.item_title);
			ivItem = itemView.findViewById(R.id.item_image);
		}
	}

	public interface OnHomeItemClickListener {
		void onHomeItemClick(@NonNull ModeInfo modeInfo);
	}
}
