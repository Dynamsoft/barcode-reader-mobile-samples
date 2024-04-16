package com.dynamsoft.dbr.generalsettings.ui.settings;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.bean.BarcodeSettings;

import java.util.List;

public class BarcodeFormatsAdapter extends RecyclerView.Adapter<BarcodeFormatsAdapter.ViewHolder> {
    private final List<Integer> stringIdList;
    private float textSize = 20f;
    private final BarcodeFormatsUtil bfUtil;
    private Context context;
    private final BarcodeSettings barcodeSettings;


    public BarcodeFormatsAdapter(BarcodeSettings barcodeSettings, BarcodeFormatsUtil bfUtil, List<Integer> stringIdList) {
        this.barcodeSettings = barcodeSettings;
        this.bfUtil = bfUtil;
        this.stringIdList = stringIdList;
    }

    public BarcodeFormatsAdapter(BarcodeSettings barcodeSettings, BarcodeFormatsUtil bfUtil, List<Integer> stringIdList, float textSizeBySp) {
        this(barcodeSettings, bfUtil, stringIdList);
        this.textSize = textSizeBySp;
    }


    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        context = parent.getContext();
        return new ViewHolder(inflater.inflate(R.layout.text_and_switch, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.setTextView(context.getString(stringIdList.get(position)));
        holder.setTextSize(textSize);

        long formatIdOfThisPosition = bfUtil.getMapStringId_FormatId().get(stringIdList.get(position));

        SwitchCompat switchCompat = holder.itemView.findViewById(R.id.switch_filed);
        boolean needCheck = (formatIdOfThisPosition & barcodeSettings.getBarcodeFormat()) != 0;
        switchCompat.setChecked(needCheck);

        switchCompat.setOnCheckedChangeListener((compoundButton, isChecked) -> {
            if (isChecked) {
                barcodeSettings.setBarcodeFormat(barcodeSettings.getBarcodeFormat() | formatIdOfThisPosition);
            } else {
                barcodeSettings.setBarcodeFormat(barcodeSettings.getBarcodeFormat() & ~formatIdOfThisPosition);
            }
        });
    }

    @Override
    public void onViewRecycled(@NonNull ViewHolder holder) {
        super.onViewRecycled(holder);
        context = null;
    }

    @Override
    public int getItemCount() {
        return stringIdList.size();
    }

    protected static class ViewHolder extends TextAndSwitchViewHolder {
        ViewHolder(@NonNull View itemView) {
            super(itemView, R.id.text_filed, R.id.switch_filed);
        }

        @Override
        public void setTextView(String text) {
            super.setTextView(text);
        }

        @Override
        public void setTextSize(float spSize) {
            super.setTextSize(spSize);
        }
    }
}
