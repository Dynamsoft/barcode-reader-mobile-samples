package com.dynamsoft.dbr.decodewithcamerax.ui.resultsview;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.decodewithcamerax.R;

public class ResultsRecyclerView extends RecyclerView {

    private BarcodeResultItem[] barcodeResultItems = new BarcodeResultItem[0];
    private final ResultAdapter resultAdapter = new ResultAdapter(barcodeResultItems);

    public ResultsRecyclerView(Context context) {
        this(context, null);
    }

    public ResultsRecyclerView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ResultsRecyclerView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setLayoutManager(new LinearLayoutManager(context));
        setItemAnimator(null);
        setAdapter(resultAdapter);
    }

    public void updateResults(@Nullable BarcodeResultItem[] newResultItems) {
        barcodeResultItems = newResultItems != null ? newResultItems : new BarcodeResultItem[0];
        resultAdapter.updateResults(barcodeResultItems);
    }

    private static class ResultAdapter extends Adapter<ResultAdapter.ViewHolder> {
        private BarcodeResultItem[] barcodeResultItems;

        public ResultAdapter(BarcodeResultItem[] barcodeResultItems) {
            this.barcodeResultItems = barcodeResultItems;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_result, parent, false);
            return new ViewHolder(view);
        }

        @SuppressLint("SetTextI18n")
        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            BarcodeResultItem barcodeResultItem = barcodeResultItems[position];
            holder.tvFormat.setText("Format: " + barcodeResultItem.getFormatString());
            holder.tvText.setText("Text: " + barcodeResultItem.getText());
            holder.tvIndex.setText(String.valueOf(position + 1));
        }

        @Override
        public int getItemCount() {
            return barcodeResultItems.length;
        }

        @SuppressLint("NotifyDataSetChanged")
        public void updateResults(@NonNull BarcodeResultItem[] newResultItems) {
            this.barcodeResultItems = newResultItems;
            notifyDataSetChanged();
        }

        static class ViewHolder extends RecyclerView.ViewHolder {
            TextView tvFormat;
            TextView tvText;
            TextView tvIndex;

            public ViewHolder(@NonNull View itemView) {
                super(itemView);
                tvFormat = itemView.findViewById(R.id.tv_code_format);
                tvText = itemView.findViewById(R.id.tv_code_text);
                tvIndex = itemView.findViewById(R.id.tv_index);
            }
        }
    }
}