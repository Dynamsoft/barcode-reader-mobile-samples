package com.dynamsoft.dbr.decodemultiplebarcodes;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Point;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dce.DrawingItem;
import com.dynamsoft.dce.DrawingLayer;
import com.dynamsoft.dce.DrawingStyleManager;
import com.dynamsoft.dce.EnumCoordinateBase;
import com.dynamsoft.dce.ImageEditorView;
import com.dynamsoft.dce.QuadDrawingItem;
import com.dynamsoft.dce.TextDrawingItem;

import java.io.File;
import java.util.ArrayList;

import androidx.appcompat.app.AppCompatActivity;

/**
 * @author dynamsoft
 */
public class ResultActivity extends AppCompatActivity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_result);
		ImageEditorView image = findViewById(R.id.iv_image);
		LinearLayout list = findViewById(R.id.ll_result);

		File cacheFile = new File(getCacheDir(), "original_image.jpg");
		Bitmap bitmap = BitmapFactory.decodeFile(cacheFile.getAbsolutePath());

		image.setOriginalImage(bitmap);

		DecodedBarcodesResult result = MainActivity.weakResults.get();
		if (result != null) {
			DrawingLayer layer = image.getDrawingLayer(DrawingLayer.DDN_LAYER_ID);
			DrawingLayer textLayer = image.getDrawingLayer(DrawingLayer.DBR_LAYER_ID);
			layer.setDefaultStyle(DrawingStyleManager.createDrawingStyle(Color.TRANSPARENT, 0, Color.parseColor("#55F59A49"), Color.WHITE));
			textLayer.setDefaultStyle(DrawingStyleManager.createDrawingStyle(Color.TRANSPARENT, 0, Color.TRANSPARENT, Color.WHITE));
			int i = 1;
			for (BarcodeResultItem item : result.getItems()) {
				list.addView(childView(String.valueOf(i), item.getFormatString(), item.getText()));
				Quadrilateral quad = item.getLocation();
				QuadDrawingItem quadItem = new QuadDrawingItem(quad, EnumCoordinateBase.CB_IMAGE);
				Point topLeft = item.getLocation().points[0];
				TextDrawingItem textItem = new TextDrawingItem(String.valueOf(i),
						new Point(topLeft.x, topLeft.y - 15), 100, 100, EnumCoordinateBase.CB_IMAGE);
				ArrayList<DrawingItem> quadItems = new ArrayList<>();
				ArrayList<DrawingItem> textItems = new ArrayList<>();
				textItems.add(textItem);
				textLayer.addDrawingItems(textItems);
				quadItems.add(quadItem);
				layer.addDrawingItems(quadItems);
				i++;
			}
		}
	}

	private View childView(String index, String label, String text) {
		TextView labelView = new TextView(this);
		String content = index + ".  " + label + ", " + text;
		labelView.setTextSize(16);
		labelView.setPadding(12, 14, 12, 0);
		labelView.setText(content);
		return labelView;
	}
}