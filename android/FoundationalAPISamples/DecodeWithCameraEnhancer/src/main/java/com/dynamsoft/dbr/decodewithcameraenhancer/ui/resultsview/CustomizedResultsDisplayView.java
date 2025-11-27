package com.dynamsoft.dbr.decodewithcameraenhancer.ui.resultsview;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.decodewithcameraenhancer.R;

import java.util.Locale;

/**
 * A custom view for displaying barcode scanning results.
 * This view contains a RecyclerView to list the results,
 * a TextView to show the total count and allow hiding the CustomizedResultsDisplayView when clicked,
 * and an optional export button for exporting results.
 */
public class CustomizedResultsDisplayView extends LinearLayout {

    // RecyclerView to display the list of results.
    private final ResultsRecyclerView rvResults;

    // TextView to display the total count of results and allow hiding the CustomizedResultsDisplayView when clicked.
    private final TextView tvTotal;

    // Button for exporting the results, visibility is configurable.
    private final Button btnExport;

    public CustomizedResultsDisplayView(Context context) {
        this(context, null);
    }

    public CustomizedResultsDisplayView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CustomizedResultsDisplayView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        LayoutInflater.from(context).inflate(R.layout.results_view, this, true);

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.CustomizedResultsDisplayView, defStyleAttr, 0);
        boolean needBtnExport = typedArray.getBoolean(R.styleable.CustomizedResultsDisplayView_needBtnExport, false);
        typedArray.recycle();

        rvResults = findViewById(R.id.rv_results);
        tvTotal = findViewById(R.id.tv_total_count);
        btnExport = findViewById(R.id.btn_export);
        btnExport.setVisibility(needBtnExport ? VISIBLE : GONE);

        tvTotal.setOnClickListener(v -> setVisibility(GONE));

        btnExport.setOnClickListener(v -> {
            //TODO: Export results
        });
    }

    /**
     * Updates the results displayed in the view.
     * <p>
     * Description:
     * - Displays the count of new results in the title.
     * - Updates the RecyclerView to display the list of new results.
     * - Resets the view if `newResultItems` is null.
     *
     * @param newResultItems An array of BarcodeResultItem representing the new scan results.
     */
    public void updateResults(@Nullable BarcodeResultItem[] newResultItems) {
        // Update the total count displayed in the TextView.
        tvTotal.setText(String.format(Locale.getDefault(),"Total: %d", newResultItems != null ? newResultItems.length : 0));

        // Update the RecyclerView with the new results.
        rvResults.updateResults(newResultItems);
    }
}