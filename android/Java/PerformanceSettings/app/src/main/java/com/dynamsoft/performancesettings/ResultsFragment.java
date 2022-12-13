package com.dynamsoft.performancesettings;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.TextPaint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.dbr.TextResult;
import com.pierfrancescosoffritti.slidingdrawer.SlidingDrawer;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class ResultsFragment extends Fragment {

    TextResult[] results = null;
    String path;

    ImageView ivImg;
    TextView tvBarcodeCount;
    RecyclerView resultsRecyclerView;

    public static ResultsFragment newInstance() {
        return new ResultsFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_result, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ivImg = view.findViewById(R.id.iv_photo_detail);
        tvBarcodeCount = view.findViewById(R.id.result_drag_qty);
        resultsRecyclerView = view.findViewById(R.id.rv_results_list);

        SlidingDrawer slidingDrawer = view.findViewById(R.id.result_sliding_drawer);
        RelativeLayout dragView = view.findViewById(R.id.result_drag_view);
        ImageView ivHistoryPull = view.findViewById(R.id.iv_history_pull);
        TextView tvDragText = view.findViewById(R.id.drag_text);

        slidingDrawer.setDragView(dragView);
        slidingDrawer.addSlideListener((drawer, currentSlide) -> {
            if (drawer.getState() == SlidingDrawer.EXPANDED) {
                ivHistoryPull.setImageResource(R.drawable.arrow_down);
                tvDragText.setText(getText(R.string.scroll_down));
            } else if (drawer.getState() == SlidingDrawer.COLLAPSED) {
                ivHistoryPull.setImageResource(R.drawable.arrow_up);
                tvDragText.setText(getText(R.string.more_results));
            }
        });

        dragView.setOnClickListener(v -> {
            if (slidingDrawer.getState() == SlidingDrawer.EXPANDED) {
                slidingDrawer.setState(SlidingDrawer.COLLAPSED);
                slidingDrawer.setVisibility(View.GONE);
                slidingDrawer.setVisibility(View.VISIBLE);
            } else if (slidingDrawer.getState() == SlidingDrawer.COLLAPSED) {
                slidingDrawer.setState(SlidingDrawer.EXPANDED);
            }
        });

        showResults(results);

    }

    public void setPathAndTextResults(String path, TextResult[] results) {
        this.path = path;
        this.results = results;
    }

    @SuppressLint("SetTextI18n")
    private void showResults(TextResult[] results) {
        if(path == null){
            return;
        }
        Bitmap bitmap = BitmapFactory.decodeFile(path);
        int scale;
        BitmapFactory.Options opt = new BitmapFactory.Options();
        if (bitmap.getWidth() > 8000 || bitmap.getHeight() > 8000) {
            opt.inSampleSize = 5;
            scale = 5;
        } else if (bitmap.getWidth() > 6000 || bitmap.getHeight() > 6000) {
            opt.inSampleSize = 4;
            scale = 4;
        } else if (bitmap.getWidth() > 4000 || bitmap.getHeight() > 4000) {
            opt.inSampleSize = 3;
            scale = 3;
        } else if (bitmap.getWidth() > 2000 || bitmap.getHeight() > 2000) {
            opt.inSampleSize = 2;
            scale = 2;
        } else {
            opt.inSampleSize = 1;
            scale = 1;
        }
        if(scale != 1)
            bitmap = BitmapFactory.decodeFile(path,opt);
        bitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true);
        ivImg.setImageBitmap(bitmap);
        Path path = new Path();
        Canvas canvas = new Canvas(bitmap);
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(5f);
        paint.setColor(getResources().getColor(R.color.aboutOK));
        paint.setAntiAlias(true);
        int width = Math.min(bitmap.getWidth(), bitmap.getHeight());
        float r = (float)width / 70 / scale;
        TextPaint textPaint = new TextPaint(Paint.ANTI_ALIAS_FLAG | Paint.DEV_KERN_TEXT_FLAG);
        textPaint.setTextSize(2.5f * r);
        textPaint.setTypeface(Typeface.DEFAULT_BOLD);
        textPaint.setColor(getResources().getColor(R.color.white));
        textPaint.setTypeface(Typeface.SANS_SERIF);
        textPaint.setAntiAlias(true);
        Paint roundPaint = new Paint();
        roundPaint.setStyle(Paint.Style.STROKE);
        roundPaint.setStrokeWidth(2 * r);
        roundPaint.setColor(getResources().getColor(R.color.aboutOK));
        roundPaint.setAntiAlias(true);

        if (results != null && results.length > 0) {
            for (int i = 0; i < results.length; i++) {
                path.reset();
                path.moveTo((float)results[i].localizationResult.resultPoints[0].x / scale, (float)results[i].localizationResult.resultPoints[0].y / scale);
                path.lineTo((float)results[i].localizationResult.resultPoints[1].x / scale, (float)results[i].localizationResult.resultPoints[1].y / scale);
                path.lineTo((float)results[i].localizationResult.resultPoints[2].x / scale, (float)results[i].localizationResult.resultPoints[2].y / scale);
                path.lineTo((float)results[i].localizationResult.resultPoints[3].x / scale, (float)results[i].localizationResult.resultPoints[3].y / scale);
                path.close();
                canvas.drawPath(path, paint);
                float x = (float) (results[i].localizationResult.resultPoints[0].x / scale + results[i].localizationResult.resultPoints[1].x / scale +
                        results[i].localizationResult.resultPoints[2].x / scale + results[i].localizationResult.resultPoints[3].x / scale) / 4;
                float y = (float) (results[i].localizationResult.resultPoints[0].y / scale + results[i].localizationResult.resultPoints[1].y / scale +
                        results[i].localizationResult.resultPoints[2].y / scale + results[i].localizationResult.resultPoints[3].y / scale) / 4;
                canvas.drawCircle(x, y , r, roundPaint);
                if ((i + 1) < 10) {
                    canvas.drawText(String.valueOf(i + 1), x - 0.63f * r, y + 0.92f * r, textPaint);
                } else {
                    canvas.drawText(String.valueOf(i + 1), x - 1.53f * r, y + 0.92f * r, textPaint);
                }
            }
        }

        final ArrayList<Map<String, String>> resultMapList = new ArrayList<>();
        if (results != null && results.length > 0) {
            for (int i = 0; i < results.length; i++) {
                Map<String, String> temp = new HashMap<>();
                temp.put("Index", String.valueOf(i + 1));
                temp.put("Format", results[i].barcodeFormatString);
                temp.put("Text", results[i].barcodeText);
                resultMapList.add(temp);
            }
        }
        tvBarcodeCount.setText(getText(R.string.Total) + String.valueOf(resultMapList.size()));
        ResultAdapter resultAdapter = new ResultAdapter(resultMapList);
        resultsRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        resultsRecyclerView.setAdapter(resultAdapter);
    }
}
