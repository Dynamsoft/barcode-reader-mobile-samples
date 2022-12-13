package com.dynamsoft.generalsettings.settings.barcodesettings.barcodeformats;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.generalsettings.R;
import com.dynamsoft.generalsettings.util.TextAndSwitchViewHolder;

import java.util.List;

public class BarcodeFormatsAdapter extends RecyclerView.Adapter<BarcodeFormatsAdapter.ViewHolder> {
    private final List<Integer> list;
    float textSize = 20f;
    BarcodeFormatsViewModel viewModel;
    Context context;


    public BarcodeFormatsAdapter(BarcodeFormatsViewModel viewModel, List<Integer> list){
        this.viewModel = viewModel;
        this.list = list;
    }

    public BarcodeFormatsAdapter(BarcodeFormatsViewModel viewModel, List<Integer> list, float textSizeBySp){
        this.viewModel = viewModel;
        this.list = list;
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
        holder.setTextView(context.getString(list.get(position)));
        holder.setTextSize(textSize);

        SwitchCompat switchCompat = holder.itemView.findViewById(R.id.switch_filed);
        boolean needCheck;
        if(viewModel.getMapFormats1().get(list.get(position)) != null) {
            needCheck = (viewModel.getMapFormats1().get(list.get(position)) & viewModel.getSettingFormats()) != 0;
        } else  {
            needCheck = (viewModel.getMapFormats2().get(list.get(position)) & viewModel.getSettingFormats_2()) != 0;
        }
        switchCompat.setChecked(needCheck);

        switchCompat.setOnCheckedChangeListener((compoundButton, isChecked) -> viewModel.changeBarcodeFormats(list.get(position), isChecked));
    }

    @Override
    public int getItemCount() {
        return list.size();
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
