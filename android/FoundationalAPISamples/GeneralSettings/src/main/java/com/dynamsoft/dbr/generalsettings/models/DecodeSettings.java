package com.dynamsoft.dbr.generalsettings.models;

import android.util.Range;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.dynamsoft.core.basic_structures.EnumErrorCode;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.cvr.EnumPresetTemplate;
import com.dynamsoft.cvr.SimplifiedCaptureVisionSettings;
import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.EnumDeblurMode;
import com.dynamsoft.dbr.EnumLocalizationMode;
import com.dynamsoft.dbr.generalsettings.BR;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

public class DecodeSettings extends BaseObservable {
    public static final Range<Integer> expectedBarcodesCountRange = new Range<>(0, 99999);
    public static final Range<Integer> minResultConfidenceRange = new Range<>(0, 100);
    public static final Range<Integer> scaleDownThresholdRange = new Range<>(512, Integer.MAX_VALUE);
    public static final Range<Integer> minBarcodeTextLengthRange = new Range<>(0, 999);
    public static final Range<Integer> timeoutRange = new Range<>(0, 100000);
    public static final Range<Integer> minDecodeIntervalRange = new Range<>(0, 100000);

    @Bindable
    private String selectedPresetTemplateName = EnumPresetTemplate.PT_READ_BARCODES_SPEED_FIRST;
    @Bindable
    private String importedTemplateContent = null;
    @Bindable
    public boolean ifUseImportedTemplate;
    @Bindable
    public boolean ifImportedTemplateIsComplex;
    private int timeout;
    private int minDecodeInterval;
    private long barcodeFormat;
    private int expectedBarcodesCount;
    @EnumLocalizationMode
    private int[] localizationModes;
    @EnumDeblurMode
    private int[] deblurModes;
    private int[] grayscaleEnhancementModes;
    private int[] grayscaleTransformationModes;
    private int minResultConfidence;
    private int scaleDownThreshold;
    private String barcodeTextRegExPattern;
    private int minBarcodeTextLength;

    public DecodeSettings() {
        init();
    }

    public void init() {
        try {
            CaptureVisionRouter router = new CaptureVisionRouter();
            if (ifUseImportedTemplate) {
                router.initSettings(importedTemplateContent);
            }
            SimplifiedCaptureVisionSettings settings = router.getSimplifiedSettings(selectedPresetTemplateName);
            assert settings.barcodeSettings != null;
            timeout = settings.timeout;
            minDecodeInterval = settings.minImageCaptureInterval;
            barcodeFormat = settings.barcodeSettings.barcodeFormatIds;
            expectedBarcodesCount = settings.barcodeSettings.expectedBarcodesCount;
            localizationModes = settings.barcodeSettings.localizationModes;
            deblurModes = settings.barcodeSettings.deblurModes;
            grayscaleEnhancementModes = settings.barcodeSettings.grayscaleEnhancementModes;
            grayscaleTransformationModes = settings.barcodeSettings.grayscaleTransformationModes;
            minResultConfidence = settings.barcodeSettings.minResultConfidence;
            scaleDownThreshold = settings.barcodeSettings.scaleDownThreshold;
            barcodeTextRegExPattern = settings.barcodeSettings.barcodeTextRegExPattern;
            minBarcodeTextLength = settings.barcodeSettings.minBarcodeTextLength;
            setImportedTemplateIsComplex(false);
        } catch (CaptureVisionRouterException e) {
            if(e.getErrorCode() == EnumErrorCode.EC_CONVERT_COMPLEX_TEMPLATE_ERROR) {
                setImportedTemplateIsComplex(true);
            }
        }
    }

    public String getSelectedPresetTemplateName() {
        return selectedPresetTemplateName;
    }

    public void setSelectedPresetTemplateName(String selectedPresetTemplate) {
        if(!this.selectedPresetTemplateName.equals(selectedPresetTemplate)) {
            this.selectedPresetTemplateName = selectedPresetTemplate;
            init();
            notifyPropertyChanged(BR.selectedPresetTemplateName);
        }
    }

    public String getImportedTemplateContent() {
        return importedTemplateContent;
    }

    public void setImportedTemplateContent(String importedTemplateContent) {
        if (importedTemplateContent != null) {
            setUseImportedTemplate(true);
        }
        this.importedTemplateContent = importedTemplateContent;
    }

    @Bindable
    public boolean isUseImportedTemplate() {
        return ifUseImportedTemplate;
    }

    @Bindable
    public void setUseImportedTemplate(boolean useImportedTemplate) {
        this.ifUseImportedTemplate = useImportedTemplate;
        notifyPropertyChanged(BR.useImportedTemplate);
    }

    @Bindable
    public boolean isImportedTemplateIsComplex() {
        return ifImportedTemplateIsComplex;
    }

    @Bindable
    public void setImportedTemplateIsComplex(boolean importedTemplateIsComplex) {
        this.ifImportedTemplateIsComplex = importedTemplateIsComplex;
        notifyPropertyChanged(BR.importedTemplateIsComplex);
    }

    @EnumBarcodeFormat
    public long getBarcodeFormat() {
        return barcodeFormat;
    }

    public void setBarcodeFormat(long barcodeFormat) {
        this.barcodeFormat = barcodeFormat;
    }

    public int getExpectedBarcodesCount() {
        return expectedBarcodesCount;
    }

    public void setExpectedBarcodesCount(int expectedBarcodesCount) {
        this.expectedBarcodesCount = expectedBarcodesCount;
    }

    @EnumLocalizationMode
    public int[] getLocalizationModes() {
        return localizationModes;
    }

    public void setLocalizationModes(@EnumLocalizationMode int[] localizationModes) {
        this.localizationModes = localizationModes;
    }

    @EnumDeblurMode
    public int[] getDeblurModes() {
        return deblurModes;
    }

    public void setDeblurModes(@EnumDeblurMode int[] deblurModes) {
        this.deblurModes = deblurModes;
    }

    public int[] getGrayscaleEnhancementModes() {
        return grayscaleEnhancementModes;
    }

    public void setGrayscaleEnhancementModes(int[] grayscaleEnhancementModes) {
        this.grayscaleEnhancementModes = grayscaleEnhancementModes;
    }

    public int[] getGrayscaleTransformationModes() {
        return grayscaleTransformationModes;
    }

    public void setGrayscaleTransformationModes(int[] grayscaleTransformationModes) {
        this.grayscaleTransformationModes = grayscaleTransformationModes;
    }

    public int getMinResultConfidence() {
        return minResultConfidence;
    }

    public void setMinResultConfidence(int minResultConfidence) {
        this.minResultConfidence = minResultConfidence;
    }

    public int getScaleDownThreshold() {
        return scaleDownThreshold;
    }

    public void setScaleDownThreshold(int scaleDownThreshold) {
        this.scaleDownThreshold = scaleDownThreshold;
    }

    public String getBarcodeTextRegExPattern() {
        return barcodeTextRegExPattern;
    }

    public void setBarcodeTextRegExPattern(String barcodeTextRegExPattern) {
        this.barcodeTextRegExPattern = barcodeTextRegExPattern;
    }

    public int getMinBarcodeTextLength() {
        return minBarcodeTextLength;
    }

    public void setMinBarcodeTextLength(int minBarcodeTextLength) {
        this.minBarcodeTextLength = minBarcodeTextLength;
    }

    public int getTimeout() {
        return timeout;
    }

    public void setTimeout(int timeout) {
        this.timeout = timeout;
    }

    public int getMinDecodeInterval() {
        return minDecodeInterval;
    }

    public void setMinDecodeInterval(int minDecodeInterval) {
        this.minDecodeInterval = minDecodeInterval;
    }

    //For export
    public void updateToCvr(CaptureVisionRouter router) {
        if (ifUseImportedTemplate) {
            try {
                router.initSettings(importedTemplateContent);
            } catch (CaptureVisionRouterException e) {
                //no-op
                e.printStackTrace();
            }
        }
        if (ifUseImportedTemplate) {
            return;
        }
        try {
            SimplifiedCaptureVisionSettings settings = router.getSimplifiedSettings(selectedPresetTemplateName);
            settings.timeout = timeout;
            settings.minImageCaptureInterval = minDecodeInterval;
            assert settings.barcodeSettings != null;
            settings.barcodeSettings.barcodeFormatIds = barcodeFormat;
            settings.barcodeSettings.expectedBarcodesCount = expectedBarcodesCount;
            settings.barcodeSettings.localizationModes = localizationModes;
            settings.barcodeSettings.deblurModes = deblurModes;
            settings.barcodeSettings.grayscaleEnhancementModes = grayscaleEnhancementModes;
            settings.barcodeSettings.grayscaleTransformationModes = grayscaleTransformationModes;
            settings.barcodeSettings.minResultConfidence = minResultConfidence;
            settings.barcodeSettings.scaleDownThreshold = scaleDownThreshold;
            settings.barcodeSettings.barcodeTextRegExPattern = barcodeTextRegExPattern;
            settings.barcodeSettings.minBarcodeTextLength = minBarcodeTextLength;

            router.updateSettings(selectedPresetTemplateName, settings);
        } catch (CaptureVisionRouterException e) {
            //no-op
            e.printStackTrace();
        }
    }

    public void reset() {
        DecodeSettings newSettings = new DecodeSettings();
        for (Field declaredField : getClass().getDeclaredFields()) {
            try {
                if(!Modifier.isFinal(declaredField.getModifiers())) {
                    Object newValue = declaredField.get(newSettings);
                    declaredField.set(this, newValue);
                }
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }
        notifyChange();
    }

}
