package com.dynamsoft.scenarioorientedsamples.ui;

import androidx.annotation.DrawableRes;
import androidx.annotation.StringRes;

import com.dynamsoft.scenarioorientedsamples.R;

import java.util.List;

public class ModeInfo {

    public static final List<ModeInfo> modesByBarcodeFormats = List.of(
            new ModeInfo(R.string.home_title_oned_retail, R.drawable.retail, "ReadOneDRetail.json"),
            new ModeInfo(R.string.home_title_oned_industrial, R.drawable.industrial, "ReadOneDIndustrial.json"),
            new ModeInfo(R.string.home_title_qr_code, R.drawable.qr_code, "ReadQR.json"),
            new ModeInfo(R.string.home_title_data_matrix, R.drawable.data_matrix, "ReadDataMatrix.json"),
            new ModeInfo(R.string.home_title_common_2d, R.drawable.common_2d, "ReadCommon2D.json"),
            new ModeInfo(R.string.home_title_any_codes, R.drawable.any_codes, null/*use default template*/),
            new ModeInfo(R.string.home_title_aztec, R.drawable.aztec_code, "ReadAztec.json"),
            new ModeInfo(R.string.home_title_dpm, R.drawable.dpm, "ReadDPM.json"),
            new ModeInfo(R.string.home_title_dot_code, R.drawable.dot_code, "ReadDotCode.json")
    );

    public static final List<ModeInfo> modesByScenario = List.of(
            new ModeInfo(R.string.home_title_high_density_codes, R.drawable.high_density, "ReadDenseBarcodes.json")
    );

    @StringRes
    public int titleInHome;

    @DrawableRes
    public int iconInHome;

    public String templateFileInAsset;

    public ModeInfo(@StringRes int titleInHome, @DrawableRes int iconInHome, String templateFileInAsset) {
        this.titleInHome = titleInHome;
        this.iconInHome = iconInHome;
        this.templateFileInAsset = templateFileInAsset;
    }
}
