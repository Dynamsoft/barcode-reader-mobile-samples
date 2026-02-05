package com.dynamsoft.cartbuilder.ui;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.cartbuilder.R;
import com.dynamsoft.dbr.BarcodeResultItem;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;

public class CartAdapter extends RecyclerView.Adapter<CartAdapter.ViewHolder> {
    private final LinkedHashMap<String, Integer> data = new LinkedHashMap<>();

    public CartAdapter() {
    }

    public void addBarcodes(@NonNull BarcodeResultItem[] barcodes) {
        for (BarcodeResultItem barcode : barcodes) {
            String text = barcode.getText();
            Integer count = data.remove(text);
            // Re-insert to maintain order, new items at the end
            data.put(text, count == null ? 1 : count + 1);
        }
        notifyDataSetChanged();
    }

    public void clear() {
        data.clear();
        notifyDataSetChanged();
    }


    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_cart, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        List<String> keys = new ArrayList<>(data.keySet());
        String key = keys.get(keys.size() - 1 - position); // data is in reverse order, so we reverse the index
        Integer qty = data.get(key);
        if (qty == null) qty = 0;
        holder.tvItem.setText(key);
        holder.tvQty.setText(String.valueOf(qty));
        holder.tvPrice.setText("$" + getPriceForItem(key) * qty);

    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    private float getPriceForItem(String item) {
        // In a real application, prices would be fetched from a database or API.
        return 0.0f;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvItem, tvQty, tvPrice;

        public ViewHolder(View itemView) {
            super(itemView);
            tvItem = itemView.findViewById(R.id.tv_item);
            tvQty = itemView.findViewById(R.id.tv_qty);
            tvPrice = itemView.findViewById(R.id.tv_price);
        }
    }
}
