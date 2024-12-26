package com.dynamsoft.dbr.generalsettings.bean;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.dynamsoft.dbr.generalsettings.BR;

public class ViewSettings extends BaseObservable {
    private boolean isHighlightBarcode = true;
    private boolean isTorchButtonVisible = false;

    @Bindable
    public boolean isHighlightBarcode() {
        return isHighlightBarcode;
    }

    public void setHighlightBarcode(boolean highlightBarcode) {
        isHighlightBarcode = highlightBarcode;
        notifyPropertyChanged(BR.highlightBarcode);
    }

    @Bindable
    public boolean isTorchButtonVisible() {
        return isTorchButtonVisible;
    }

    public void setTorchButtonVisible(boolean torchButtonVisible) {
        isTorchButtonVisible = torchButtonVisible;
        notifyPropertyChanged(BR.torchButtonVisible);
    }
}
