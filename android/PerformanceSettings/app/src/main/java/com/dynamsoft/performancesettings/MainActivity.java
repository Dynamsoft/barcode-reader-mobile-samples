package com.dynamsoft.performancesettings;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.dynamsoft.dbr.EnumPresetTemplate;

public class MainActivity extends AppCompatActivity {
    private ScanFragment scanFragment;
    private LinearLayout viewSelectModes;
    private LinearLayout viewSingleBarcode;
    private LinearLayout viewSpeedFirst;
    private LinearLayout viewReadRateFirst;
    private LinearLayout viewAcurracyFirst;
    private ImageView ivSelectFile;
    private int mode = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.container, ScanFragment.newInstance())
                    .commit();
        }
        viewSelectModes = findViewById(R.id.view_select_modes);
        viewSingleBarcode = findViewById(R.id.view_single_barcode);
        viewSpeedFirst = findViewById(R.id.view_speed_first);
        viewReadRateFirst = findViewById(R.id.view_readrate_first);
        viewAcurracyFirst = findViewById(R.id.view_accuracy_first);
        ivSelectFile = findViewById(R.id.iv_btn_selectfile);
    }


    @SuppressLint("NonConstantResourceId")
    public void onModelClicked(View v) {
        switch (v.getId()) {
            case R.id.view_single_barcode:
                scanFragment.setSingleBarcodeMode();
                viewSingleBarcode.setBackgroundColor(getResources().getColor(R.color.selected_color));
                viewSpeedFirst.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                viewReadRateFirst.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                viewAcurracyFirst.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                ivSelectFile.setVisibility(View.GONE);
                mode = 0;
                break;
            case R.id.view_speed_first:
                scanFragment.setVideoSpeedFirst();
                viewSingleBarcode.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                viewSpeedFirst.setBackgroundColor(getResources().getColor(R.color.selected_color));
                viewReadRateFirst.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                viewAcurracyFirst.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                ivSelectFile.setVisibility(View.VISIBLE);
                mode = 1;
                break;
            case R.id.view_readrate_first:
                scanFragment.setVideoReadRateFirst();
                viewSingleBarcode.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                viewSpeedFirst.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                viewReadRateFirst.setBackgroundColor(getResources().getColor(R.color.selected_color));
                viewAcurracyFirst.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                ivSelectFile.setVisibility(View.VISIBLE);
                mode = 2;
                break;
            case R.id.view_accuracy_first:
                scanFragment.setAccuracyMode();
                viewSingleBarcode.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                viewSpeedFirst.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                viewReadRateFirst.setBackgroundColor(getResources().getColor(R.color.unselected_color));
                viewAcurracyFirst.setBackgroundColor(getResources().getColor(R.color.selected_color));
                ivSelectFile.setVisibility(View.GONE);
                mode = 3;
                break;
            default:
                break;
        }
    }


    public void onImageClicked(View v) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(MainActivity.this);
        switch (v.getId()) {
            case R.id.iv_single_barcode:
                dialog.setTitle(R.string.single_barcode_title)
                        .setMessage(R.string.single_barcode_message)
                        .setPositiveButton("OK",null)
                        .show();
                break;
            case R.id.iv_speed_first:
                dialog.setTitle(R.string.speed_first_title)
                        .setMessage(R.string.speed_first_message)
                        .setPositiveButton("OK",null)
                        .show();
                break;
            case R.id.iv_readrate_first:
                dialog.setTitle(R.string.read_rate_first_title)
                        .setMessage(R.string.read_rate_first_message)
                        .setPositiveButton("OK",null)
                        .show();
                break;
            case R.id.iv_accuracy_first:
                dialog.setTitle(R.string.acurracy_first_title)
                        .setMessage(R.string.acurracy_first_message)
                        .setPositiveButton("OK",null)
                        .show();
                break;
            case R.id.iv_btn_selectfile:
                if (mode == 1) {
                    scanFragment.choicePhotoWrapper(mode);
                } else if (mode == 2) {
                    scanFragment.choicePhotoWrapper(mode);
                }

                break;
            default:
                break;
        }
    }

    public void setScanFragment(ScanFragment scanFragment) {
        this.scanFragment = scanFragment;
    }

    public void hideViewInResultsFg() {
        viewSelectModes.setVisibility(View.GONE);
        ivSelectFile.setVisibility(View.GONE);
    }

    public void showViewInScanFg() {
        viewSelectModes.setVisibility(View.VISIBLE);
        if (mode == 1 || mode == 2)
            ivSelectFile.setVisibility(View.VISIBLE);
    }


}