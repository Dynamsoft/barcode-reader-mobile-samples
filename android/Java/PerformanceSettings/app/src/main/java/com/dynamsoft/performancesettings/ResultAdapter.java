package com.dynamsoft.performancesettings;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;


import java.util.ArrayList;
import java.util.Map;


public class ResultAdapter extends RecyclerView.Adapter<ResultAdapter.ViewHolder> {
    ArrayList<Map<String, String>> resultsMap;
    public ResultAdapter(ArrayList<Map<String, String>> resultsMap){
        this.resultsMap = resultsMap;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        return new ViewHolder(inflater.inflate(R.layout.item_results_list, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.setResultIndex(resultsMap.get(position).get("Index"));
        holder.setResultFormat(resultsMap.get(position).get("Format"));
        holder.setResultText(resultsMap.get(position).get("Text"));
    }

    @Override
    public int getItemCount() {
        return resultsMap.size();
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
