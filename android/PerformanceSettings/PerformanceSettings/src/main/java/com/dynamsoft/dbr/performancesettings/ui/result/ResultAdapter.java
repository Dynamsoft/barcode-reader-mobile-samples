package com.dynamsoft.dbr.performancesettings.ui.result;

import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.dbr.performancesettings.R;

import java.util.ArrayList;


public class ResultAdapter extends RecyclerView.Adapter<ResultAdapter.ViewHolder> {
    private final ArrayList<Pair<String, String>> arrayFormatText;

    public ResultAdapter(ArrayList<Pair<String, String>> arrayFormatText) {
        this.arrayFormatText = arrayFormatText;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        return new ViewHolder(inflater.inflate(R.layout.item_results_list, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.setResultIndex(String.valueOf(position + 1));
        holder.setResultFormat(arrayFormatText.get(position).first);
        holder.setResultText(arrayFormatText.get(position).second);
    }

    @Override
    public int getItemCount() {
        return arrayFormatText.size();
    }

    protected static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvResultFormat;
        TextView tvResultText;
        TextView tvResultIndex;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvResultFormat = itemView.findViewById(R.id.tv_result_format);
            tvResultText = itemView.findViewById(R.id.tv_result_text);
            tvResultIndex = itemView.findViewById(R.id.tv_result_index);
        }

        public void setResultFormat(String text) {
            tvResultFormat.setText(text);
        }

        public void setResultText(String text) {
            tvResultText.setText(text);
        }

        public void setResultIndex(String text) {
            tvResultIndex.setText(text);
        }

    }
}
