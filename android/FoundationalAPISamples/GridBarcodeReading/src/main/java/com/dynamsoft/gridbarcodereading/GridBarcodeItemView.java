package com.dynamsoft.gridbarcodereading;

import android.content.Context;
import android.graphics.Color;
import android.view.Gravity;
import android.widget.TableRow;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

public class GridBarcodeItemView extends TableRow {

    private final TextView tvRow;
    private final TextView tvCol;
    private final TextView tvStatus;
    private final TextView tvText;

    public GridBarcodeItemView(Context context) {
        super(context);

        tvRow = makeCell(context);
        tvCol = makeCell(context);
        tvStatus = makeCell(context);
        tvText = makeCell(context);

        addView(tvRow);
        addView(tvCol);
        addView(tvStatus);
        addView(tvText);
    }

    public void bind(GridBarcodeItem item) {
        tvRow.setText(String.valueOf(item.rowIndex + 1));
        tvCol.setText(String.valueOf(item.columnIndex + 1));
        tvText.setText(item.barcodeText);
        tvText.setTextIsSelectable(true); //Allow barcode text to be selectable for copying
        switch (item.status) {
            case GS_DECODED:
                tvStatus.setTextColor(Color.GREEN);
                break;
            case GS_DEEP_DECODED:
                tvStatus.setTextColor(Color.BLUE);
                break;
            case GS_FAILED:
            default:
                tvStatus.setTextColor(Color.RED);
                break;
        }
        tvStatus.setText(item.status.getDescription());
    }

    private TextView makeCell(Context context) {
        TextView tv = new TextView(context);
        TableRow.LayoutParams params = new TableRow.LayoutParams(
                TableRow.LayoutParams.WRAP_CONTENT,
                TableRow.LayoutParams.MATCH_PARENT);
        tv.setLayoutParams(params);
        tv.setGravity(Gravity.CENTER);
        tv.setPadding(8, 24, 8, 24);
        tv.setBackground(ContextCompat.getDrawable(context, R.drawable.cell_border));
        return tv;
    }
}

