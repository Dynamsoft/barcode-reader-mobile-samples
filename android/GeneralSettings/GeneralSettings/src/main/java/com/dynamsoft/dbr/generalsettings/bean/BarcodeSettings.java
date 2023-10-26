package com.dynamsoft.dbr.generalsettings.bean;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.generalsettings.BR;

public class BarcodeSettings extends BaseObservable {
    @EnumBarcodeFormat
    private long barcodeFormat = EnumBarcodeFormat.BF_DEFAULT;
    private int expectedCount = 1;
    private boolean isContinuousScan = true;
    private int minResultConfidence = 30;
    private boolean isResultCrossVerificationEnabled = false;
    private boolean isResultDeduplicationEnabled = false;
    private int duplicationForgetTime = 3000;
    private boolean isDecodeInvertedBarcodesEnabled = false;
    private String barcodeTextRegExPattern = null;

    @Bindable
    public long getBarcodeFormat() {
        return barcodeFormat;
    }

    public void setBarcodeFormat(long barcodeFormat) {
        this.barcodeFormat = barcodeFormat;
        notifyPropertyChanged(BR.barcodeFormat);
    }

    @Bindable
    public int getExpectedCount() {
        return expectedCount;
    }

    public void setExpectedCount(int expectedCount) {
        this.expectedCount = expectedCount;
        notifyPropertyChanged(BR.expectedCount);
    }

    @Bindable
    public boolean isContinuousScan() {
        return isContinuousScan;
    }

    public void setContinuousScan(boolean continuousScan) {
        isContinuousScan = continuousScan;
        notifyPropertyChanged(BR.continuousScan);
    }

    @Bindable
    public int getMinResultConfidence() {
        return minResultConfidence;
    }

    public void setMinResultConfidence(int minResultConfidence) {
        this.minResultConfidence = minResultConfidence;
        notifyPropertyChanged(BR.minResultConfidence);
    }

    @Bindable
    public boolean isResultCrossVerificationEnabled() {
        return isResultCrossVerificationEnabled;
    }

    public void setResultCrossVerificationEnabled(boolean resultCrossVerificationEnabled) {
        isResultCrossVerificationEnabled = resultCrossVerificationEnabled;
        notifyPropertyChanged(BR.resultCrossVerificationEnabled);
    }

    @Bindable
    public boolean isResultDeduplicationEnabled() {
        return isResultDeduplicationEnabled;
    }

    public void setResultDeduplicationEnabled(boolean resultDeduplicationEnabled) {
        isResultDeduplicationEnabled = resultDeduplicationEnabled;
        notifyPropertyChanged(BR.resultDeduplicationEnabled);
    }

    @Bindable
    public int getDuplicationForgetTime() {
        return duplicationForgetTime;
    }

    public void setDuplicationForgetTime(int duplicationForgetTime) {
        this.duplicationForgetTime = duplicationForgetTime;
        notifyPropertyChanged(BR.duplicationForgetTime);
    }

    @Bindable
    public boolean isDecodeInvertedBarcodesEnabled() {
        return isDecodeInvertedBarcodesEnabled;
    }

    public void setDecodeInvertedBarcodesEnabled(boolean decodeInvertedBarcodesEnabled) {
        isDecodeInvertedBarcodesEnabled = decodeInvertedBarcodesEnabled;
        notifyPropertyChanged(BR.decodeInvertedBarcodesEnabled);
    }

    @Bindable
    public String getBarcodeTextRegExPattern() {
        return barcodeTextRegExPattern;
    }

    public void setBarcodeTextRegExPattern(String barcodeTextRegExPattern) {
        this.barcodeTextRegExPattern = barcodeTextRegExPattern;
        notifyPropertyChanged(BR.barcodeTextRegExPattern);
    }
}
