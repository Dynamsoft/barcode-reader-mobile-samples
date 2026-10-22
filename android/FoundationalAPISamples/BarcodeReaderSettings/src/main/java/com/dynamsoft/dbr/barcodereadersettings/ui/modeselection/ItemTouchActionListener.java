package com.dynamsoft.dbr.barcodereadersettings.ui.modeselection;

public interface ItemTouchActionListener {
    void onItemChange(int fromPos, int toPos);
    void onItemDelete(int pos);
    void onActionIdle();
}
