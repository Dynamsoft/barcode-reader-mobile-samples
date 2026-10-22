package com.dynamsoft.dbr.decodefromanimage;

import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.core.app.ActivityCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.dynamsoft.core.basic_structures.EnumErrorCode;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResult;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.decodefromanimage.ui.ThumbnailsRecyclerView;
import com.dynamsoft.dbr.decodefromanimage.ui.resultsview.CustomizedResultsDisplayView;
import com.dynamsoft.dbr.decodefromanimage.utils.BitmapUtils;
import com.dynamsoft.dbr.decodefromanimage.utils.UriUtils;
import com.dynamsoft.license.LicenseManager;

import java.util.Locale;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";
    private static final int REQUEST_CAMERA_CODE = 1024;

    private ThumbnailsRecyclerView thumbnailsView;
    private AppCompatImageView imageView;
    private CustomizedResultsDisplayView resultsView;
    private FrameLayout pbDecoding;
    private TextView tvLicenseError;
    private CaptureVisionRouter router;
    private final ExecutorService decodeThreadExecutor = Executors.newSingleThreadExecutor();

    private final ActivityResultLauncher<String> galleryLauncher
            = registerForActivityResult(new ActivityResultContracts.GetContent(), uri -> {
        if (uri != null) {
            thumbnailsView.addUriAndSelect(uri);
        }
    });

    private Uri cameraPhotoUri = null;
    private final ActivityResultLauncher<Uri> takePhotoLauncher
            = registerForActivityResult(new ActivityResultContracts.TakePicture(), isPhotoTaken -> {
        if (isPhotoTaken) {
            thumbnailsView.addUriAndSelect(cameraPhotoUri);
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

        thumbnailsView = findViewById(R.id.thumbnails_view);
        imageView = findViewById(R.id.image_view);
        resultsView = findViewById(R.id.results_view);
        pbDecoding = findViewById(R.id.pb_decoding);
        tvLicenseError = findViewById(R.id.tv_license_error);
        findViewById(R.id.btn_gallery_center).setOnClickListener(v -> loadGalleryImage());
        findViewById(R.id.btn_gallery_top).setOnClickListener(v -> loadGalleryImage());
        findViewById(R.id.btn_take_photo_center).setOnClickListener(v -> ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.CAMERA}, REQUEST_CAMERA_CODE));
        findViewById(R.id.btn_take_photo_top).setOnClickListener(v -> ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.CAMERA}, REQUEST_CAMERA_CODE));

        if (savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                    runOnUiThread(() -> tvLicenseError.setText("License initialization failed: " + error.getMessage()));
                }
            });
        }
        router = new CaptureVisionRouter();
        try {
            //See template file in assets/Templates.
            router.initSettingsFromFile("ReadFromAnImage.json");
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }

        thumbnailsView.setOnItemSelectedListener(uri -> {
            findViewById(R.id.btn_take_photo_top).setVisibility(View.VISIBLE);
            findViewById(R.id.btn_gallery_top).setVisibility(View.VISIBLE);
            findViewById(R.id.btn_take_photo_center).setVisibility(View.GONE);
            findViewById(R.id.btn_gallery_center).setVisibility(View.GONE);
            findViewById(R.id.tv_select_tip).setVisibility(View.GONE);

            Glide.with(MainActivity.this)
                    .asBitmap()
                    .skipMemoryCache(true)
                    .load(uri)
                    .into(imageView);
            resultsView.updateResults(null); //Reset resultsView
            pbDecoding.setVisibility(View.VISIBLE);

            //See specific decoding methods in decodeSelectedUri(Uri uri).
            decodeSelectedUri(uri);
        });
    }

    private void decodeSelectedUri(Uri uri) {
        decodeThreadExecutor.submit(() -> {
            byte[] selectedImageBytes = UriUtils.toBytes(this, uri);
            // Decode barcodes from the file byte.
            // The method returns a CapturedResult object that contains an array of CapturedResultItems.
            // CapturedResultItem is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
            CapturedResult capturedResult = router.capture(selectedImageBytes, "ReadFromAnImage");

            runOnUiThread(() -> showBarcodeResult(capturedResult, uri));
        });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_CAMERA_CODE && grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            takePhoto();
        }
    }

    private void loadGalleryImage() {
        galleryLauncher.launch("image/*");
    }

    private void takePhoto() {
        String cameraPath = Objects.requireNonNull(getExternalCacheDir()).getAbsolutePath() + "/Dynamsoft/" + System.currentTimeMillis() + ".jpg";
        cameraPhotoUri = UriUtils.getUriFromFile(this, cameraPath);
        takePhotoLauncher.launch(cameraPhotoUri);
    }

    @MainThread
    // This is the method that extract the barcodes info from the CapturedResult.
    private void showBarcodeResult(CapturedResult result, Uri uri) {
        pbDecoding.setVisibility(View.GONE);
        if (result == null) {
            resultsView.updateResults(null);
            resultsView.setVisibility(View.VISIBLE);
            return;
        }
        if (result.getErrorCode() != 0) {
            new AlertDialog.Builder(this)
                    .setMessage(String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", result.getErrorCode(), result.getErrorMessage()))
                    .show();
        }

        DecodedBarcodesResult decodedBarcodesResult = result.getDecodedBarcodesResult();
        if (result.getErrorCode() == 0 || result.getErrorCode() == EnumErrorCode.EC_TIMEOUT) {
            resultsView.updateResults(decodedBarcodesResult != null ? decodedBarcodesResult.getItems() : null);
            resultsView.setVisibility(View.VISIBLE);
        } else {
            Log.e(TAG, "errorCode: " + result.getErrorCode() + ", errorMessage: " + result.getErrorMessage());
        }
        getBitmapAndDraw(imageView, uri, decodedBarcodesResult);
    }

    private void getBitmapAndDraw(AppCompatImageView targetView, Uri uri, DecodedBarcodesResult decodedBarcodesResult) {
        Drawable drawable = targetView.getDrawable();
        if (drawable != null) {
            if (!(drawable instanceof BitmapDrawable)) {
                return;
            }
            Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
            float scale = (float) UriUtils.getRotatedSize(this, uri).getWidth() / (float) bitmap.getWidth();
            BitmapUtils.drawResultsOnBitmap(this, bitmap, decodedBarcodesResult, scale);
        } else {
            targetView.postDelayed(() -> getBitmapAndDraw(targetView, uri, decodedBarcodesResult), 200);
        }
    }
}