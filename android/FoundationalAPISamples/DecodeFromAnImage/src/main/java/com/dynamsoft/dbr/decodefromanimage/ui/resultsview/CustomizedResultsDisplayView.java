package com.dynamsoft.dbr.decodefromanimage.ui.resultsview;


import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.decodefromanimage.R;

import java.util.Locale;

/**
 * A custom view for displaying barcode scanning results.
 * This view contains a RecyclerView to list the results,
 * a TextView to show the total count,
 * and another TextView to allow hiding the rvResults when clicked,
 * and an optional export button for exporting results.
 */
public class CustomizedResultsDisplayView extends LinearLayout {

    // RecyclerView to display the list of results.
    private final ResultsRecyclerView rvResults;

    // TextView to display the total count of results.
    private final TextView tvTotal;

    // TextView to allow hiding the rvResults when clicked.
    private final TextView tvShowAndHide;

    // Button for exporting the results, visibility is configurable.
    private final Button btnExport;
    private float animPercent = 1f;
    private boolean isOpen = true;


    public CustomizedResultsDisplayView(Context context) {
        this(context, null);
    }

    public CustomizedResultsDisplayView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CustomizedResultsDisplayView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.CustomizedResultsDisplayView, defStyleAttr, 0);
        boolean needBtnExport = typedArray.getBoolean(R.styleable.CustomizedResultsDisplayView_needBtnExport, false);
        typedArray.recycle();

        LayoutInflater.from(context).inflate(R.layout.results_view, this, true);
        rvResults = findViewById(R.id.rv_results);
        tvTotal = findViewById(R.id.tv_total_count);
        btnExport = findViewById(R.id.btn_export);
        btnExport.setVisibility(needBtnExport ? VISIBLE : GONE);

        tvShowAndHide = findViewById(R.id.tv_show_and_hide);
        tvShowAndHide.setText(isOpen ? R.string.view_less : R.string.view_more);

        if (!needBtnExport) {
            btnExport.setVisibility(GONE);
        }

        tvTotal.setOnClickListener(v -> {
            setOpen(!isOpen);
        });

        btnExport.setOnClickListener(v -> {
            //TODO: Export results
        });
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int tvTotalHeight = tvTotal.getMeasuredHeight()
                + ((MarginLayoutParams) tvTotal.getLayoutParams()).topMargin
                + ((MarginLayoutParams) tvTotal.getLayoutParams()).bottomMargin
                + getPaddingTop() + getPaddingBottom();
        int rvResultHeight = rvResults.getMeasuredHeight()
                + ((MarginLayoutParams) rvResults.getLayoutParams()).topMargin
                + ((MarginLayoutParams) rvResults.getLayoutParams()).bottomMargin;
        int btnExportHeight = btnExport.getMeasuredHeight()
                + ((MarginLayoutParams) btnExport.getLayoutParams()).topMargin
                + ((MarginLayoutParams) btnExport.getLayoutParams()).bottomMargin;
        int totalHeight = tvTotalHeight + rvResultHeight + btnExportHeight;
        if (isOpen) {
            setMeasuredDimension(getMeasuredWidth(), tvTotalHeight + (int) ((totalHeight - tvTotalHeight) * animPercent));
        } else {
            setMeasuredDimension(getMeasuredWidth(), totalHeight - (int) ((totalHeight - tvTotalHeight) * animPercent));
        }
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
    public void updateResults(BarcodeResultItem[] newResultItems) {
        tvTotal.setText(String.format(Locale.getDefault(),"Total: %d", newResultItems != null ? newResultItems.length : 0));
        rvResults.updateResults(newResultItems);
        setOpen(true);
    }

    public void setOpen(boolean open) {
        if(open == isOpen) {
            return;
        }
        tvShowAndHide.setText(open ? R.string.view_less : R.string.view_more);
        isOpen = open;
        startAnim();
    }

    private void startAnim() {
        ObjectAnimator animator = ObjectAnimator.ofFloat(this, "animPercent", 0f, 1f);
        animator.setDuration(Math.max((getChildCount() - 1) * 100L, 200));
        animator.start();
    }

    private float getAnimPercent() {
        return animPercent;
    }

    //For ObjectAnimator
    private void setAnimPercent(float animPercent) {
        this.animPercent = animPercent;
        requestLayout();
    }
}