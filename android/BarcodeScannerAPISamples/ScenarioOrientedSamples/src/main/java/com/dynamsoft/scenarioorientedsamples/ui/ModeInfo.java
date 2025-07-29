package com.dynamsoft.scenarioorientedsamples.ui;

import com.dynamsoft.scenarioorientedsamples.R;

import androidx.annotation.DrawableRes;
import androidx.annotation.StringRes;

import java.util.List;

public class ModeInfo {

    public static final List<ModeInfo> modesForBarcodeTypes = List.of(
            new ModeInfo(R.string.home_title_high_density, R.drawable.high_density),
            new ModeInfo(R.string.home_title_dpm, R.drawable.dpm),
            new ModeInfo(R.string.home_title_dot_code, R.drawable.dotcode),
            new ModeInfo(R.string.home_title_aztec, R.drawable.aztec_code),
            new ModeInfo(R.string.home_title_oned_retail, R.drawable.retail),
            new ModeInfo(R.string.home_title_oned_industrial, R.drawable.industrial)
    );

    @StringRes
    public int titleInHome;

    @DrawableRes
    public int iconInHome;

    public ModeInfo(@StringRes int titleInHome, @DrawableRes int iconInHome) {
        this.titleInHome = titleInHome;
        this.iconInHome = iconInHome;
    }
}
