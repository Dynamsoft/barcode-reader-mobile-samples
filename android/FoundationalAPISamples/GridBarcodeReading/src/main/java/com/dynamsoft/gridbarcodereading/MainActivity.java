package com.dynamsoft.gridbarcodereading;

import android.app.AlertDialog;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Point;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.util.Range;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TableLayout;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.FileProvider;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CapturedResult;
import com.dynamsoft.cvr.SimplifiedCaptureVisionSettings;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.utility.EnumLayoutElementSource;
import com.dynamsoft.utility.EnumLayoutPattern;
import com.dynamsoft.utility.LayoutAnalysisParameter;
import com.dynamsoft.utility.LayoutAnalysisResult;
import com.dynamsoft.utility.LayoutAnalyzer;
import com.dynamsoft.utility.LayoutElement;
import com.dynamsoft.license.LicenseManager;

import java.io.File;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";
    private static final float EXPAND_FACTOR = 2f;
    private Uri mCameraPhotoUri = null;
    private ImageView mIvImage;
    private ProgressBar mPbDecoding;
    private TableLayout mTlResults;
    private TextView mTvResultsSummary;
    private static final int REQUEST_CAMERA_CODE = 1024;
    private final ExecutorService mDecodeThreadExecutor = Executors.newSingleThreadExecutor();


    private final ActivityResultLauncher<String> galleryLauncher
            = registerForActivityResult(new ActivityResultContracts.GetContent(), uri -> {
        if (uri != null) {
            mIvImage.setImageURI(uri);
            decodeFromUriAndShowResults(uri);
        }
    });

    private final ActivityResultLauncher<Uri> takePhotoLauncher
            = registerForActivityResult(new ActivityResultContracts.TakePicture(), isPhotoTaken -> {
        if (isPhotoTaken) {
            mIvImage.setImageURI(null); // clear cache so same URI forces reload
            mIvImage.setImageURI(mCameraPhotoUri);
            decodeFromUriAndShowResults(mCameraPhotoUri);
        }
    });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccess, error) -> {
            if (!isSuccess && error != null) {
                runOnUiThread(()-> new AlertDialog.Builder(this)
                        .setTitle("License Verification Failed")
                        .setMessage(error.getMessage())
                        .setPositiveButton("OK", null)
                        .show());
            }
        });

        mIvImage = findViewById(R.id.iv_image);
        mPbDecoding = findViewById(R.id.pb_decoding);
        mTlResults = findViewById(R.id.tl_results);
        mTvResultsSummary = findViewById(R.id.tv_results_summary);

        findViewById(R.id.btn_sample_image).setOnClickListener(v -> decodeFromAssetAndShowResults("sample_grid.png"));
        findViewById(R.id.btn_take_photo).setOnClickListener(v -> ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.CAMERA}, REQUEST_CAMERA_CODE));
        findViewById(R.id.btn_gallery_import).setOnClickListener(v -> galleryLauncher.launch("image/*"));

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_CAMERA_CODE && grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            File cameraFile = new File(getExternalCacheDir(), "camera_photo_cache.jpg");
            mCameraPhotoUri = FileProvider.getUriForFile(this, getPackageName(), cameraFile);
            takePhotoLauncher.launch(mCameraPhotoUri);
        }
    }

    private void decodeFromAssetAndShowResults(String assetFileName) {
        runOnUiThread(() -> mPbDecoding.setVisibility(ProgressBar.VISIBLE));
        runOnUiThread(() -> mTlResults.setVisibility(TableLayout.GONE));
        runOnUiThread(() -> mTvResultsSummary.setVisibility(TextView.GONE));
        mDecodeThreadExecutor.execute(() -> {
            byte[] bytes = null;
            try {
                InputStream is = getAssets().open(assetFileName);
                bytes = new byte[is.available()];
                is.read(bytes);
                is.close();
            } catch (Exception e) {
                Log.e(TAG, "Failed to read asset: " + assetFileName, e);
                runOnUiThread(() -> mPbDecoding.setVisibility(ProgressBar.GONE));
                return;
            }
            int orientation = PhotoOrientationUtil.getOrientation(bytes);
            Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
            if(orientation != 0 && bitmap != null) {
                Bitmap originalBitmap = bitmap;
                Matrix matrix = new Matrix();
                matrix.postRotate(orientation);
                bitmap = Bitmap.createBitmap(originalBitmap, 0, 0, originalBitmap.getWidth(), originalBitmap.getHeight(), matrix, true);
                originalBitmap.recycle();
            }
            if (bitmap != null) {
                final Bitmap finalBitmap = bitmap;
                runOnUiThread(() -> mIvImage.setImageBitmap(finalBitmap));
            }
            List<GridBarcodeItem> gridBarcodeItems = decodeFromBytes(bytes);
            if (gridBarcodeItems != null && bitmap != null) {
                final Bitmap finalBitmap = bitmap;
                runOnUiThread(() -> showResults(gridBarcodeItems, finalBitmap));
            }
            runOnUiThread(() -> mPbDecoding.setVisibility(ProgressBar.GONE));
        });
    }

    private void decodeFromUriAndShowResults(Uri uri) {
        runOnUiThread(() -> mPbDecoding.setVisibility(ProgressBar.VISIBLE));
        runOnUiThread(() -> mTlResults.setVisibility(TableLayout.GONE));
        runOnUiThread(() -> mTvResultsSummary.setVisibility(TextView.GONE));
        mDecodeThreadExecutor.execute(() -> {
            byte[] bytes = null;
            try {
                InputStream is = getContentResolver().openInputStream(uri);
                if (is != null) {
                    bytes = new byte[is.available()];
                    int count = is.read(bytes);
                    is.close();
                }
            } catch (Exception e) {
                //Failed to read image bytes.
                runOnUiThread(() -> mPbDecoding.setVisibility(ProgressBar.GONE));
                return;
            }

            List<GridBarcodeItem> gridBarcodeItems = decodeFromBytes(bytes);
            Bitmap bitmap = bytes != null ? BitmapFactory.decodeByteArray(bytes, 0, bytes.length) : null;
            int orientation = PhotoOrientationUtil.getOrientation(bytes);
            if(orientation != 0 && bitmap != null) {
                Bitmap originalBitmap = bitmap;
                Matrix matrix = new Matrix();
                matrix.postRotate(orientation);
                bitmap = Bitmap.createBitmap(originalBitmap, 0, 0, originalBitmap.getWidth(), originalBitmap.getHeight(), matrix, true);
                originalBitmap.recycle();
            }
            if (gridBarcodeItems != null && bitmap != null) {
                Bitmap finalBitmap = bitmap;
                runOnUiThread(() -> showResults(gridBarcodeItems, finalBitmap));
            }
            runOnUiThread(() -> mPbDecoding.setVisibility(ProgressBar.GONE));
        });
    }

    private void showResults(List<GridBarcodeItem> items, Bitmap sourceBitmap) {
        // Draw quad overlays on the image
        Bitmap mutable = sourceBitmap.copy(Bitmap.Config.ARGB_8888, true);
        Canvas canvas = new Canvas(mutable);
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.STROKE);
        float strokeWidth = new Range<Float>(5f, 30f).clamp(mutable.getWidth() / 200f); // Adjust stroke width based on image size
        paint.setStrokeWidth(strokeWidth);
        paint.setAntiAlias(true);
        int decodedCount = 0;
        int deepDecodedCount = 0;
        int failedCount = 0;
        for (GridBarcodeItem item : items) {
            switch (item.status) {
                case GS_DECODED: //Green for barcodes decoded in the fast scan phase
                    paint.setColor(Color.GREEN);
                    decodedCount++;
                    break;
                case GS_DEEP_DECODED://Blue for barcodes decoded in the deep decode phase
                    paint.setColor(Color.BLUE);
                    deepDecodedCount++;
                    break;
                case GS_FAILED: //Red for items that failed to decode (either detected in fast scan but failed to decode, or inferred from layout analysis but failed to decode)
                default:
                    paint.setColor(Color.RED);
                    failedCount++;
            }
            android.graphics.Point[] pts = item.location.points;
            if (pts != null && pts.length >= 4) {
                Path path = new Path();
                path.moveTo(pts[0].x, pts[0].y);
                for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].x, pts[i].y);
                path.close();
                canvas.drawPath(path, paint);
            }
        }
        mIvImage.setImageBitmap(mutable);

        // Show summary
        mTvResultsSummary.setVisibility(View.VISIBLE);
        mTvResultsSummary.setText(String.format(getString(R.string.results_summary), decodedCount + deepDecodedCount, failedCount, items.size()));

        // Populate table
        mTlResults.setVisibility(TableLayout.VISIBLE);
        while (mTlResults.getChildCount() > 1) {
            mTlResults.removeViewAt(1);
        }
        for (GridBarcodeItem item : items) {
            GridBarcodeItemView row = new GridBarcodeItemView(this);
            row.bind(item);
            mTlResults.addView(row);
        }
    }

    private static List<GridBarcodeItem> decodeFromBytes(byte[] bytes) {
        if(bytes == null) {
            return new ArrayList<>();
        }
        CaptureVisionRouter router = new CaptureVisionRouter();
        try {
            router.initSettingsFromFile("gridBarcodeReading.json");

            //Phase1: Fast Scan.
            long time1 = System.currentTimeMillis();
            CapturedResult capturedResult = router.capture(bytes, "GridFastScan");
            DecodedBarcodesResult decodedBarcodesResult = capturedResult.getDecodedBarcodesResult();
            if (decodedBarcodesResult == null) {
                Log.i(TAG, "Phase1: Fast Scan, duration: " + (System.currentTimeMillis() - time1) + " ms. No barcodes decoded.");
                return new ArrayList<>();
            }
            BarcodeResultItem[] barcodeItems = decodedBarcodesResult.getItems();
            ArrayList<GridBarcodeItem> gridBarcodeItems = new ArrayList<>();
            for (BarcodeResultItem item : barcodeItems) {
                GridBarcodeItem gridBarcodeItem = new GridBarcodeItem();
                gridBarcodeItem.barcodeText = item.getText();
                gridBarcodeItem.barcodeFormat = item.getFormatString();
                gridBarcodeItem.location = item.getLocation();
                gridBarcodeItem.status = EnumGridStatus.GS_DECODED;
                gridBarcodeItems.add(gridBarcodeItem);
            }
            int phase1DecodedCount = gridBarcodeItems.size();
            time1 = System.currentTimeMillis() - time1;
            Log.i(TAG, "Phase1: Fast Scan, duration: " + time1 + " ms. " + phase1DecodedCount + " barcodes decoded.");

            //Phase2: Layout Analysis.
            long time2 = System.currentTimeMillis();
            LayoutAnalysisParameter layoutAnalysisParameter = new LayoutAnalysisParameter();
            layoutAnalysisParameter.pattern = EnumLayoutPattern.LP_MATRIX;
            Quadrilateral[] phase1Quads = new Quadrilateral[gridBarcodeItems.size()];
            for (int i = 0; i < gridBarcodeItems.size(); i++) {
                gridBarcodeItems.get(i).location.id = i; // Set id for later matching
                phase1Quads[i] = gridBarcodeItems.get(i).location;
            }
            LayoutAnalysisResult analysisResult = LayoutAnalyzer.analyze(phase1Quads, layoutAnalysisParameter);
            if (analysisResult == null || analysisResult.elements == null) {
                // If layout analysis fails, we still return the barcodes decoded in the fast scan phase.
                time2 = System.currentTimeMillis() - time2;
                Log.i(TAG, "Phase2: Layout Analysis failed, duration: " + time2 + " ms. Return results from Phase1 only.");
                return gridBarcodeItems;
            }
            for (int row = 0; row < analysisResult.elements.length; row++) {
                for (int col = 0; col < analysisResult.elements[row].length; col++) {
                    LayoutElement element = analysisResult.elements[row][col];
                    if (element.source == EnumLayoutElementSource.LES_INPUT) {
                        for (GridBarcodeItem item : gridBarcodeItems) {
                            assert element.quad != null;
                            if (item.location.id == element.quad.id && item.status == EnumGridStatus.GS_DECODED) {
                                item.rowIndex = row;
                                item.columnIndex = col;
                                break;
                            }
                        }
                    } else if (element.source == EnumLayoutElementSource.LES_INFERRED) {
                        GridBarcodeItem item = new GridBarcodeItem();
                        item.rowIndex = row;
                        item.columnIndex = col;
                        item.location = element.quad;
                        gridBarcodeItems.add(item);
                    }
                }
            }
            time2 = System.currentTimeMillis() - time2;
            Log.i(TAG, "Phase2: Layout Analysis, duration: " + time2 + " ms. Total " + gridBarcodeItems.size() + "(" + analysisResult.rowCount + "x" + analysisResult.colCount + ")" + " items after layout analysis. (+" + (gridBarcodeItems.size() - barcodeItems.length) + " inferred)");

            //Phase3: Deep decode
            long time3 = System.currentTimeMillis();
            int addedDecodedCount = 0;
            SimplifiedCaptureVisionSettings simplifiedSettings = router.getSimplifiedSettings("GridDeepDecode");
            simplifiedSettings.roiMeasuredInPercentage = false;
            for (GridBarcodeItem gridBarcodeItem : gridBarcodeItems) {
                if (gridBarcodeItem.status == EnumGridStatus.GS_DECODED) {
                    continue;
                }

                //Set ROI to slightly larger than the inferred quad to improve decoding success rate.
                Quadrilateral expandedQuad = expandQuad(gridBarcodeItem.location, EXPAND_FACTOR);
                simplifiedSettings.roi = expandedQuad;
                router.updateSettings("GridDeepDecode", simplifiedSettings);

                long timeForThisItem = System.currentTimeMillis();
                CapturedResult singleResult = router.capture(bytes, "GridDeepDecode");
                timeForThisItem = System.currentTimeMillis() - timeForThisItem;
                Log.i(TAG, "Deep decode for item at row " + gridBarcodeItem.rowIndex + ", column " + gridBarcodeItem.columnIndex + " took " + timeForThisItem + " ms. Quad area: " + expandedQuad.getArea() + ".");
                DecodedBarcodesResult singleDecodedResult = singleResult.getDecodedBarcodesResult();
                if (singleDecodedResult != null && singleDecodedResult.getItems().length > 0) {
                    BarcodeResultItem item = singleDecodedResult.getItems()[0];
                    gridBarcodeItem.barcodeText = item.getText();
                    gridBarcodeItem.barcodeFormat = item.getFormatString();
                    gridBarcodeItem.status = EnumGridStatus.GS_DEEP_DECODED;
                    addedDecodedCount++;
                }
            }
            time3 = System.currentTimeMillis() - time3;
            Log.i(TAG, "Phase3: Deep Decode, duration: " + time3 + " ms. Total decoded " + (phase1DecodedCount + addedDecodedCount) + " barcodes. " + addedDecodedCount + " additional barcodes decoded in deep decode phase.");

            //sort by row and then column
            GridBarcodeItem[] itemsArray = gridBarcodeItems.toArray(new GridBarcodeItem[0]);
            Arrays.sort(itemsArray, (a, b) -> {
                if (a.rowIndex != b.rowIndex) {
                    return Integer.compare(a.rowIndex, b.rowIndex);
                } else {
                    return Integer.compare(a.columnIndex, b.columnIndex);
                }
            });
            return Arrays.asList(itemsArray);
        } catch (Exception e) {
            return null;
        }
    }

    private static Quadrilateral expandQuad(Quadrilateral quad, float factor) {
        if(factor <= 1f) {
            return quad;
        }
        Point[] pts = quad.points;
        double cx = 0, cy = 0;
        for (Point pt : pts) {
            cx += pt.x;
            cy += pt.y;
        }
        cx /= pts.length;
        cy /= pts.length;
        Point[] expanded = new Point[pts.length];
        for (int i = 0; i < pts.length; i++) {
            expanded[i] = new Point(
                    (int) ((pts[i].x - cx) * factor + cx),
                    (int) ((pts[i].y - cy) * factor + cy)
            );
        }
        return new Quadrilateral(expanded[0], expanded[1], expanded[2], expanded[3]);
    }
}