package com.dynamsoft.readmultipleuniquebarcodes;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

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
    private final ArrayList<String> results = new ArrayList<>();

    public ResultsAdapter(@NonNull List<String> resultSet) {
        update(resultSet);
    }

    /**
     * Replace current data.
     */
    public void update(@NonNull List<String> resultSet) {
        results.clear();
        results.addAll(resultSet);
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
        String value = results.get(position);
        String[] parts = value.split(SPLITTER, 2);
        String format = parts.length > 0 ? parts[0] : "";
        String text = parts.length > 1 ? parts[1] : "";

        holder.tvIndex.setText(index + ".");
        holder.tvFormat.setText("Format: " + format);
        holder.tvText.setText("Text: " + text);
    }

    @Override
    public int getItemCount() {
        return results.size();
    }

    public static final class ViewHolder extends RecyclerView.ViewHolder {
        final TextView tvIndex;
        final TextView tvFormat;
        final TextView tvText;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvIndex = itemView.findViewById(R.id.tv_index);
            tvFormat = itemView.findViewById(R.id.tv_format);
            tvText = itemView.findViewById(R.id.tv_text);
        }
    }
}
