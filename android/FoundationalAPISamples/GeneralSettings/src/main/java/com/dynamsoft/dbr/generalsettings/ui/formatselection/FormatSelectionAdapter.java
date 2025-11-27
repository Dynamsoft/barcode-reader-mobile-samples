package com.dynamsoft.dbr.generalsettings.ui.formatselection;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.ui.SingleLineLayout;

import java.util.Map;

public class FormatSelectionAdapter extends RecyclerView.Adapter<FormatSelectionAdapter.ViewHolder> {

    private Integer[] formatStringIdArray;
    private Long[] formatIdArray;
    private OnMultiSelectionCallback callback;

    private boolean hasFormatsIdInitialized = false;
    private long currentFormatIds = 0L;
    private long allCheckedFormatIds = 0L;

    public FormatSelectionAdapter(Map<Long, Integer> formatsMap, OnMultiSelectionCallback callback) {
        formatIdArray = formatsMap.keySet().toArray(new Long[0]);
        formatStringIdArray = formatsMap.values().toArray(new Integer[0]);
        for (Long formatId : formatIdArray) {
            allCheckedFormatIds |= formatId;
        }

        this.callback = callback;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.format_selection, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        SingleLineLayout singleLineLayout = (SingleLineLayout) holder.itemView;
        singleLineLayout.tvTitle.setText(formatStringIdArray[position]);

        singleLineLayout.switchCompat.setChecked((currentFormatIds & formatIdArray[position]) != 0L);
        callback.onItemSelectedChanged(position,
                currentFormatIds,
                singleLineLayout.switchCompat.isChecked(),
                (currentFormatIds & allCheckedFormatIds) == allCheckedFormatIds,
                (currentFormatIds & allCheckedFormatIds) == 0L);

        singleLineLayout.switchCompat.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                currentFormatIds |= formatIdArray[position];
            } else {
                currentFormatIds &= ~formatIdArray[position];
            }
            callback.onItemSelectedChanged(position,
                    currentFormatIds,
                    isChecked,
                    (currentFormatIds & allCheckedFormatIds) == allCheckedFormatIds,
                    (currentFormatIds & allCheckedFormatIds) == 0L);
        });
    }

    @Override
    public int getItemCount() {
        return formatIdArray.length;
    }

    public void initCurrentFormatIds(long value) {
        if (!hasFormatsIdInitialized) {
            hasFormatsIdInitialized = true;
            currentFormatIds = value;
            for (int i = 0; i < getItemCount(); i++) {
                if ((currentFormatIds & formatIdArray[i]) != 0L) {
                    notifyItemChanged(i);
                }
            }
        }
    }

    public long getCurrentFormatIds() {
        return currentFormatIds;
    }

    public void allChecked() {
        resetCurrentFormatIds(allCheckedFormatIds);
    }

    public void allUnchecked() {
        resetCurrentFormatIds(currentFormatIds & ~allCheckedFormatIds);
    }

    public void resetCurrentFormatIds(long value) {
        long xorValues = currentFormatIds ^ value;
        currentFormatIds = value;
        for (int i = 0; i < getItemCount(); i++) {
            if ((xorValues & formatIdArray[i]) != 0L) {
                notifyItemChanged(i, (value & formatIdArray[i]) != 0L);
            }
        }
    }


    public static class ViewHolder extends RecyclerView.ViewHolder {
        private SwitchCompat switchCompat;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            switchCompat = itemView.findViewById(R.id.switch_compat);
        }
    }


    public interface OnMultiSelectionCallback {
        void onItemSelectedChanged(int position, long representValue, boolean isThisChecked, boolean allChecked, boolean allUnchecked);
    }

}
