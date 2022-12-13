package com.dynamsoft.generalsettings.scan;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.generalsettings.R;
import com.dynamsoft.generalsettings.util.ResultsViewHolder;

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

    protected static class ViewHolder extends ResultsViewHolder {
        public ViewHolder(@NonNull View itemView) {
            super(itemView, R.id.tv_result_format, R.id.tv_result_text, R.id.tv_result_index);
        }

        @Override
        public void setResultFormat(String text) {
            super.setResultFormat(text);
        }

        @Override
        public void setResultText(String text) {
            super.setResultText(text);
        }

        @Override
        public void setResultIndex(String text) {
            super.setResultIndex(text);
        }
    }
}
