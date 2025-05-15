package com.dynamsoft.dbr.generalsettings.ui.modeselection;

public interface ItemTouchHelperInter {
    void onItemChange(int fromPos, int toPos);
    void onItemDelete(int pos);
    void onActionIdle();
}
