package com.dynamsoft.gridbarcodereading;

import com.dynamsoft.core.basic_structures.Quadrilateral;

public class GridBarcodeItem {
    int rowIndex = -1;
    int columnIndex = -1;
    String barcodeText = "";
    String barcodeFormat = "";
    Quadrilateral location = new Quadrilateral();
    EnumGridStatus status = EnumGridStatus.GS_FAILED;
}
