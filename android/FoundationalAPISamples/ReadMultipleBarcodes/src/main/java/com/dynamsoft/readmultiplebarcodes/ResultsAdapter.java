package com.dynamsoft.readmultiplebarcodes;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.HashMap;
import java.util.Map;

/**
 * RecyclerView adapter used by ResultsActivity to display a list of unique barcodes.
 * <p>
 * Input contract:
 * - Each entry is a single String in the form: "{format}___{text}".
 * - The splitter is "___".
 */
public class ResultsAdapter extends RecyclerView.Adapter<ResultsAdapter.ViewHolder> {

    private static final String SPLITTER = "___";

    @NonNull
    private final HashMap<String, Integer> results = new HashMap<>();

    public ResultsAdapter(@NonNull Map<String, Integer> results) {
        update(results);
    }

    /**
     * Replace current data.
     */
    public void update(@NonNull Map<String, Integer> results) {
        this.results.clear();
        this.results.putAll(results);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_result, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        int index = position + 1;
        String key = results.keySet().toArray(new String[0])[position];
        String[] parts = key.split(SPLITTER, 2);
        String format = parts.length > 0 ? parts[0] : "";
        String text = parts.length > 1 ? parts[1] : "";

        holder.tvIndex.setText(index + ".");
        holder.tvFormat.setText("Format: " + format);
        holder.tvText.setText("Text: " + text);
        holder.tvQty.setText("Qty " + results.get(key));
    }

    @Override
    public int getItemCount() {
        return results.size();
    }

    public static final class ViewHolder extends RecyclerView.ViewHolder {
        final TextView tvIndex;
        final TextView tvFormat;
        final TextView tvText;

        final TextView tvQty;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvIndex = itemView.findViewById(R.id.tv_index);
            tvFormat = itemView.findViewById(R.id.tv_format);
            tvText = itemView.findViewById(R.id.tv_text);
            tvQty = itemView.findViewById(R.id.tv_qty);
        }
    }
}
