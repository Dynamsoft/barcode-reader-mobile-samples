package com.dynamsoft.readratefirstsettings;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextPaint;
import android.util.Patterns;
import android.view.MenuItem;
import android.view.View;
import android.webkit.URLUtil;
import android.widget.AdapterView;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.TextResult;
import com.pierfrancescosoffritti.slidingdrawer.SlidingDrawer;

import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import uk.co.senab.photoview.PhotoView;

public class DecodeActivity extends AppCompatActivity {
    private BarcodeReader mReader;
    PhotoView pvImg;
    ListView lvCodeList;
    TextView tvBarcodeCount;
    SlidingDrawer slidingDrawer;
    RelativeLayout dragView;
    ImageButton ivHistoryPull;
    TextView tvDragText;
    private ColorAdapter simpleAdapter;
    private List<Map<String, String>> recentCodeList = new ArrayList<>();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ActionBar actionBar = getSupportActionBar();
        if(actionBar != null){
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
        }
        setContentView(R.layout.activity_decode);
        pvImg = findViewById(R.id.pv_photo_detail);
        lvCodeList = findViewById(R.id.lv_barcode_list);
        tvBarcodeCount = findViewById(R.id.result_drag_qty);
        slidingDrawer = findViewById(R.id.result_sliding_drawer);
        dragView = findViewById(R.id.result_drag_view);
        ivHistoryPull = findViewById(R.id.iv_history_pull);
        tvDragText = findViewById(R.id.drag_text);

        slidingDrawer.setDragView(dragView);
        slidingDrawer.addSlideListener(new SlidingDrawer.OnSlideListener() {
            @Override
            public void onSlide(SlidingDrawer slidingDrawer, float currentSlide) {
                if (slidingDrawer.getState() == SlidingDrawer.EXPANDED) {
                    ivHistoryPull.setImageResource(R.drawable.arrow_down);
                    tvDragText.setText(getText(R.string.scroll_down));
                } else if (slidingDrawer.getState() == SlidingDrawer.COLLAPSED) {
                    ivHistoryPull.setImageResource(R.drawable.arrow_up);
                    tvDragText.setText(getText(R.string.more_results));
                }
            }
        });

        simpleAdapter = new ColorAdapter(this, recentCodeList,
                R.layout.item_listview_detail_code_list, new String[]{"Index", "Format", "Text", "Copy"},
                new int[]{R.id.tv_index, R.id.tv_code_format_content, R.id.tv_code_text_content, R.id.tv_copy}, R.id.tv_code_text_content);
        lvCodeList.setAdapter(simpleAdapter);
        lvCodeList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                String o = recentCodeList.get(position).get("Text");
                if (Patterns.WEB_URL.matcher(o).matches() || URLUtil.isValidUrl(o)) {
                    Intent intent = new Intent();
                    intent.setAction("android.intent.action.VIEW");
                    if ((!o.contains("http://")) || (!o.contains("https://"))) {
                        o = "http://" + o;
                    }
                    Uri contentUrl = Uri.parse(o);
                    intent.setData(contentUrl);
                    startActivity(intent);
                } else {
                    ClipboardManager clipboardManager = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
                    ClipData clipData = ClipData.newPlainText("", o);
                    clipboardManager.setPrimaryClip(clipData);
                    Toast.makeText(DecodeActivity.this, getText(R.string.text_has_been), Toast.LENGTH_SHORT).show();
                }
            }
        });
        ivHistoryPull.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (slidingDrawer.getState() == SlidingDrawer.EXPANDED) {
                    slidingDrawer.setState(SlidingDrawer.COLLAPSED);
                    slidingDrawer.setVisibility(View.GONE);
                    slidingDrawer.setVisibility(View.VISIBLE);
                } else if (slidingDrawer.getState() == SlidingDrawer.COLLAPSED){
                    slidingDrawer.setState(SlidingDrawer.EXPANDED);
                }
            }
        });
        tvDragText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (slidingDrawer.getState() == SlidingDrawer.EXPANDED) {
                    slidingDrawer.setState(SlidingDrawer.COLLAPSED);
                    slidingDrawer.setVisibility(View.GONE);
                    slidingDrawer.setVisibility(View.VISIBLE);
                } else if (slidingDrawer.getState() == SlidingDrawer.COLLAPSED){
                    slidingDrawer.setState(SlidingDrawer.EXPANDED);
                }
            }
        });

        decodeAndShow();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                this.finish();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void decodeAndShow(){
        mReader = MainActivity.reader;
        String fileName = getIntent().getStringExtra("fileName");
        Bitmap bitmap = BitmapFactory.decodeFile(fileName);
        bitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true);
        pvImg.setImageBitmap(bitmap);
        int scale = 1;
        Path path = new Path();
        Canvas canvas = new Canvas(bitmap);
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(5f);
        paint.setColor(getResources().getColor(R.color.aboutOK));
        paint.setAntiAlias(true);
        int width = (bitmap.getWidth() <= bitmap.getHeight()) ? bitmap.getWidth() : bitmap.getHeight();
        float r = width / 70 / scale;
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
        TextResult[] textResults = null;
        try {
            textResults = mReader.decodeFile(fileName,"");
            if (textResults != null && textResults.length > 0) {
                for (int i = 0; i < textResults.length; i++) {
                    path.reset();
                    path.moveTo(textResults[i].localizationResult.resultPoints[0].x / scale, textResults[i].localizationResult.resultPoints[0].y / scale);
                    path.lineTo(textResults[i].localizationResult.resultPoints[1].x / scale, textResults[i].localizationResult.resultPoints[1].y / scale);
                    path.lineTo(textResults[i].localizationResult.resultPoints[2].x / scale, textResults[i].localizationResult.resultPoints[2].y / scale);
                    path.lineTo(textResults[i].localizationResult.resultPoints[3].x / scale, textResults[i].localizationResult.resultPoints[3].y / scale);
                    path.close();
                    canvas.drawPath(path, paint);
                    float x = (textResults[i].localizationResult.resultPoints[0].x / scale + textResults[i].localizationResult.resultPoints[1].x / scale +
                            textResults[i].localizationResult.resultPoints[2].x / scale + textResults[i].localizationResult.resultPoints[3].x / scale) / 4;
                    float y = (textResults[i].localizationResult.resultPoints[0].y / scale + textResults[i].localizationResult.resultPoints[1].y / scale +
                            textResults[i].localizationResult.resultPoints[2].y / scale + textResults[i].localizationResult.resultPoints[3].y / scale) / 4;
                    canvas.drawCircle(x, y , r, roundPaint);
                    if ((i + 1) < 10) {
                        canvas.drawText(String.valueOf(i + 1), x - 0.63f * r, y + 0.92f * r, textPaint);
                    } else {
                        canvas.drawText(String.valueOf(i + 1), x - 1.53f * r, y + 0.92f * r, textPaint);
                    }
                    Map<String, String> item = new HashMap<>();
                    item.put("Index", i + 1 + "");
                    if (textResults[i].barcodeFormat_2 != 0) {
                        item.put("Format", textResults[i].barcodeFormatString_2);
                    }else {
                        item.put("Format", textResults[i].barcodeFormatString);
                    }
                    item.put("Text", textResults[i].barcodeText);
                    if ((Patterns.WEB_URL.matcher(textResults[i].barcodeText).matches() || URLUtil.isValidUrl(textResults[i].barcodeText))) {
                        item.put("Copy", "");
                    } else {
                        item.put("Copy", getString(R.string.copy));
                    }
                    recentCodeList.add(item);
                }
                tvBarcodeCount.setText(getText(R.string.Total) + String.valueOf(recentCodeList.size()));
            }
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }
    }
}
