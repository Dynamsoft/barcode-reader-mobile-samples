package com.dynamsoft.dbr.decodefromanimage;

import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.dynamsoft.core.basic_structures.EnumErrorCode;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.CapturedResult;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.dbr.DecodedBarcodesResult;
import com.dynamsoft.dbr.decodefromanimage.databinding.ActivityMainBinding;
import com.dynamsoft.dbr.decodefromanimage.ui.ThumbnailsRecyclerView;
import com.dynamsoft.dbr.decodefromanimage.utils.BitmapUtils;
import com.dynamsoft.dbr.decodefromanimage.utils.UriUtils;
import com.dynamsoft.license.LicenseManager;

import java.util.Arrays;
import java.util.Locale;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends AppCompatActivity implements ThumbnailsRecyclerView.OnItemSelectedListener {
    private static final String TAG = "MainActivity";
    private static final int REQUEST_CAMERA_CODE = 1024;
    private ActivityMainBinding binding;
    private CaptureVisionRouter mRouter;
    private final ExecutorService mDecodeThreadExecutor = Executors.newSingleThreadExecutor();

    private final ActivityResultLauncher<String> galleryLauncher
            = registerForActivityResult(new ActivityResultContracts.GetContent(), uri -> {
        if (uri != null) {
            binding.thumbnailsView.addUriAndSelect(uri);
        }
    });

    private Uri mCameraPhotoUri = null;
    private final ActivityResultLauncher<Uri> takePhotoLauncher
            = registerForActivityResult(new ActivityResultContracts.TakePicture(), isPhotoTaken -> {
        if (isPhotoTaken) {
            binding.thumbnailsView.addUriAndSelect(mCameraPhotoUri);
        }
    });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        ViewCompat.setOnApplyWindowInsetsListener(binding.getRoot(), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        if (savedInstanceState == null) {
            // Initialize the license.
            // The license string here is a trial license. Note that network connection is required for this license to work.
            // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=android
            LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", (isSuccess, error) -> {
                if (!isSuccess) {
                    error.printStackTrace();
                    runOnUiThread(() -> binding.tvLicenseError.setText("License initialization failed: " + error.getMessage()));
                }
            });
        }

        mRouter = new CaptureVisionRouter();
        try {
            //See template file in assets/Templates.
            mRouter.initSettingsFromFile("ReadFromAnImage.json");
        } catch (CaptureVisionRouterException e) {
            e.printStackTrace();
        }
        //See specific decoding methods in decodeSelectedUri(Uri uri).

        initView();

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_CAMERA_CODE && grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            takePhoto();
        }
    }


    private void decodeSelectedUri(Uri uri) {
        binding.pbDecoding.setVisibility(View.VISIBLE);
        mDecodeThreadExecutor.submit(() -> {

            byte[] selectedImageBytes = UriUtils.toBytes(this, uri);
            // Decode barcodes from the file byte.
            // The method returns a CapturedResult object that contains an array of CapturedResultItems.
            // CapturedResultItem is the basic unit from which you can get the basic info of the barcode like the barcode text and barcode format.
            CapturedResult capturedResult = mRouter.capture(selectedImageBytes, "ReadFromAnImage");

            runOnUiThread(() -> showBarcodeResult(capturedResult, uri));
        });
    }

    @Override
    public void onItemSelected(@NonNull Uri uri) {
        binding.btnTakePhotoTop.setVisibility(View.VISIBLE);
        binding.btnGalleryTop.setVisibility(View.VISIBLE);
        binding.btnTakePhotoCenter.setVisibility(View.GONE);
        binding.btnGalleryCenter.setVisibility(View.GONE);
        binding.tvSelectTip.setVisibility(View.GONE);

        Glide.with(MainActivity.this)
                .asBitmap()
                .skipMemoryCache(true)
                .load(uri)
                .into(binding.imageView);
        binding.resultsView.updateResults(null); //Reset resultsView
        decodeSelectedUri(uri);
    }

    private void initView() {
        binding.btnGalleryCenter.setOnClickListener(v -> loadGalleryImage());
        binding.btnGalleryTop.setOnClickListener(v -> loadGalleryImage());
        binding.btnTakePhotoCenter.setOnClickListener(v -> ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.CAMERA}, REQUEST_CAMERA_CODE));
        binding.btnTakePhotoTop.setOnClickListener(v -> ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.CAMERA}, REQUEST_CAMERA_CODE));

        binding.thumbnailsView.setOnItemSelectedListener(this);
    }

    private void loadGalleryImage() {
        galleryLauncher.launch("image/*");
    }

    private void takePhoto() {
        String cameraPath = Objects.requireNonNull(getExternalCacheDir()).getAbsolutePath() + "/Dysnamsoft/" + System.currentTimeMillis() + ".jpg";
        mCameraPhotoUri = UriUtils.getUriFromFile(this, cameraPath);
        takePhotoLauncher.launch(mCameraPhotoUri);
    }

    @MainThread
    // This is the method that extract the barcodes info from the CapturedResult.
    private void showBarcodeResult(CapturedResult result, Uri uri) {
        binding.pbDecoding.setVisibility(View.GONE);
        if (result == null) {
            binding.resultsView.updateResults(null);
            binding.resultsView.setVisibility(View.VISIBLE);
            return;
        }
        if(result.getErrorCode() != 0) {
            new AlertDialog.Builder(this)
                    .setMessage(String.format(Locale.getDefault(), "ErrorCode: %d %nErrorMessage: %s", result.getErrorCode(), result.getErrorMessage()))
                    .show();
        }

        DecodedBarcodesResult decodedBarcodesResult = result.getDecodedBarcodesResult();
        if (result.getErrorCode() == 0 || result.getErrorCode() == EnumErrorCode.EC_TIMEOUT) {
            binding.resultsView.updateResults(decodedBarcodesResult != null ? decodedBarcodesResult.getItems() : null);
            binding.resultsView.setVisibility(View.VISIBLE);
        } else {
            Log.e(TAG, "errorCode: "+result.getErrorCode()+", errorMessage: "+result.getErrorMessage());
        }
        getBitmapAndDraw(binding.imageView, uri, decodedBarcodesResult);
    }

    private void getBitmapAndDraw(ImageView imageView, Uri uri, DecodedBarcodesResult decodedBarcodesResult) {
        Drawable drawable = imageView.getDrawable();
        if (drawable != null) {
            if(!(drawable instanceof BitmapDrawable)) {
                return;
            }
            Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
            float scale = (float) UriUtils.getRotatedSize(this, uri).getWidth() / (float) bitmap.getWidth();
            BitmapUtils.drawResultsOnBitmap(this, bitmap, decodedBarcodesResult, scale);
        } else {
            imageView.postDelayed(() -> getBitmapAndDraw(imageView, uri, decodedBarcodesResult), 200);
        }
    }
}