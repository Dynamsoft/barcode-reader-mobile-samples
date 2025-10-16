package com.dynamsoft.dbr.generalsettings.ui.modeselection;

import android.util.Pair;

import com.dynamsoft.core.basic_structures.EnumGrayscaleEnhancementMode;
import com.dynamsoft.core.basic_structures.EnumGrayscaleTransformationMode;
import com.dynamsoft.dbr.EnumDeblurMode;
import com.dynamsoft.dbr.EnumLocalizationMode;

import java.util.List;

public class ModesMapConstant {
    public static final List<Pair<Integer, String>> LOCATION_MODE_MAP = List.of(
            new Pair<>(EnumLocalizationMode.LM_CONNECTED_BLOCKS, "Connect blocks"),
            new Pair<>(EnumLocalizationMode.LM_STATISTICS, "Statistics"),
            new Pair<>(EnumLocalizationMode.LM_LINES, "Lines"),
            new Pair<>(EnumLocalizationMode.LM_SCAN_DIRECTLY, "Scan directly"),
            new Pair<>(EnumLocalizationMode.LM_STATISTICS_MARKS, "Statistics masks"),
            new Pair<>(EnumLocalizationMode.LM_STATISTICS_POSTAL_CODE, "Statistics postal code"),
            new Pair<>(EnumLocalizationMode.LM_CENTRE, "Center"),
            new Pair<>(EnumLocalizationMode.LM_ONED_FAST_SCAN, "OneD fast scan"),
            new Pair<>(EnumLocalizationMode.LM_END, "End")
    );

    public static final List<Pair<Integer, String>> DEBLUR_MODE_MAP = List.of(
            new Pair<>(EnumDeblurMode.DM_DIRECT_BINARIZATION, "Direct binarization"),
            new Pair<>(EnumDeblurMode.DM_THRESHOLD_BINARIZATION, "Threshold binarization"),
            new Pair<>(EnumDeblurMode.DM_GRAY_EQUALIZATION, "Gray equalization"),
            new Pair<>(EnumDeblurMode.DM_SMOOTHING, "Smoothing"),
            new Pair<>(EnumDeblurMode.DM_MORPHING, "Morphing"),
            new Pair<>(EnumDeblurMode.DM_DEEP_ANALYSIS, "Deep analysis"),
            new Pair<>(EnumDeblurMode.DM_SHARPENING, "Sharpening"),
            new Pair<>(EnumDeblurMode.DM_BASED_ON_LOC_BIN, "Based on loc bin"),
            new Pair<>(EnumDeblurMode.DM_SHARPENING_SMOOTHING, "Sharpening smoothing"),
            new Pair<>(EnumDeblurMode.DM_NEURAL_NETWORK, "Neural network"),
            new Pair<>(EnumDeblurMode.DM_END, "End")
    );

    public static final List<Pair<Integer, String>> GRAY_SCALE_TRANS_MODE_MAP = List.of(
            new Pair<>(EnumGrayscaleTransformationMode.GTM_INVERTED, "Inverted"),
            new Pair<>(EnumGrayscaleTransformationMode.GTM_ORIGINAL, "Original"),
            new Pair<>(EnumGrayscaleTransformationMode.GTM_AUTO, "Auto"),
            new Pair<>(EnumGrayscaleTransformationMode.GTM_END, "End")
    );

    public static final List<Pair<Integer, String>> GRAY_SCALE_ENHANCEMENT_MODE_MAP = List.of(
            new Pair<>(EnumGrayscaleEnhancementMode.GEM_AUTO, "Auto"),
            new Pair<>(EnumGrayscaleEnhancementMode.GEM_GENERAL, "General"),
            new Pair<>(EnumGrayscaleEnhancementMode.GEM_GRAY_EQUALIZE, "Gray equalize"),
            new Pair<>(EnumGrayscaleEnhancementMode.GEM_GRAY_SMOOTH, "Gray smooth"),
            new Pair<>(EnumGrayscaleEnhancementMode.GEM_SHARPEN_SMOOTH, "Sharpen smooth"),
            new Pair<>(EnumGrayscaleEnhancementMode.GEM_END, "End")
    );

}
