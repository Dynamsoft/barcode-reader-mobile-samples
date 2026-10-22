package com.dynamsoft.dbr.barcodereadersettings.ui.formatselection;

import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.barcodereadersettings.R;

import java.util.HashMap;
import java.util.Map;

public class BarcodeFormatConstants {

    public static final Map<Long, Integer> BARCODE_FORMAT_ONED_MAP = new HashMap<>();
    public static final long ALL_BARCODE_FORMAT_ONED;

    public static final Map<Long, Integer> BARCODE_FORMAT_TWOD_MAP = new HashMap<>();
    public static final long ALL_BARCODE_FORMAT_TWOD;

    public static final Map<Long, Integer> BARCODE_FORMAT_PHARMACODE_MAP = new HashMap<>();
    public static final long ALL_BARCODE_FORMAT_PHARMACODE;

    public static final Map<Long, Integer> BARCODE_FORMAT_OTHERS_MAP = new HashMap<>();
    public static final long ALL_BARCODE_FORMAT_OTHERS;

    static {
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_CODE_39, R.string.code_39);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_CODE_128, R.string.code_128);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_CODE_39_EXTENDED, R.string.code_39_extended);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_CODE_93, R.string.code_93);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_CODE_11, R.string.code_11);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_CODABAR, R.string.codabar);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_ITF, R.string.itf);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_EAN_13, R.string.ean_13);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_EAN_8, R.string.ean_8);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_UPC_A, R.string.upc_a);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_UPC_E, R.string.upc_e);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_INDUSTRIAL_25, R.string.industrial_25);
        BARCODE_FORMAT_ONED_MAP.put(EnumBarcodeFormat.BF_MSI_CODE, R.string.msi_code);

        long valueOned = 0L;
        for (Map.Entry<Long, Integer> entry : BARCODE_FORMAT_ONED_MAP.entrySet()) {
            valueOned |= entry.getKey();
        }
        ALL_BARCODE_FORMAT_ONED = valueOned;

        BARCODE_FORMAT_TWOD_MAP.put(EnumBarcodeFormat.BF_QR_CODE, R.string.qrcode);
        BARCODE_FORMAT_TWOD_MAP.put(EnumBarcodeFormat.BF_PDF417, R.string.pdf417);
        BARCODE_FORMAT_TWOD_MAP.put(EnumBarcodeFormat.BF_DATAMATRIX, R.string.data_martix);

        long valueTwod = 0L;
        for (Map.Entry<Long, Integer> entry : BARCODE_FORMAT_TWOD_MAP.entrySet()) {
            valueTwod |= entry.getKey();
        }
        ALL_BARCODE_FORMAT_TWOD = valueTwod;

        BARCODE_FORMAT_PHARMACODE_MAP.put(EnumBarcodeFormat.BF_PHARMACODE_ONE_TRACK, R.string.pharma_code_one_track);
        BARCODE_FORMAT_PHARMACODE_MAP.put(EnumBarcodeFormat.BF_PHARMACODE_TWO_TRACK, R.string.pharma_code_two_track);

        long valuePharmacode = 0L;
        for (Map.Entry<Long, Integer> entry : BARCODE_FORMAT_PHARMACODE_MAP.entrySet()) {
            valuePharmacode |= entry.getKey();
        }
        ALL_BARCODE_FORMAT_PHARMACODE = valuePharmacode;

        BARCODE_FORMAT_OTHERS_MAP.put(EnumBarcodeFormat.BF_AZTEC, R.string.aztec);
        BARCODE_FORMAT_OTHERS_MAP.put(EnumBarcodeFormat.BF_MAXICODE, R.string.maxicode);
        BARCODE_FORMAT_OTHERS_MAP.put(EnumBarcodeFormat.BF_PATCHCODE, R.string.patch_code);
        BARCODE_FORMAT_OTHERS_MAP.put(EnumBarcodeFormat.BF_DOTCODE, R.string.dot_code);
        BARCODE_FORMAT_OTHERS_MAP.put(EnumBarcodeFormat.BF_POSTALCODE, R.string.postal_code);
        BARCODE_FORMAT_OTHERS_MAP.put(EnumBarcodeFormat.BF_GS1_DATABAR, R.string.gs1_databar);
        BARCODE_FORMAT_OTHERS_MAP.put(EnumBarcodeFormat.BF_GS1_COMPOSITE, R.string.gs1_composite);
        BARCODE_FORMAT_OTHERS_MAP.put(EnumBarcodeFormat.BF_MICRO_PDF417, R.string.micro_pdf417);
        BARCODE_FORMAT_OTHERS_MAP.put(EnumBarcodeFormat.BF_MICRO_QR, R.string.micro_qr);

        long valueOthers = 0L;
        for (Map.Entry<Long, Integer> entry : BARCODE_FORMAT_OTHERS_MAP.entrySet()) {
            valueOthers |= entry.getKey();
        }
        ALL_BARCODE_FORMAT_OTHERS = valueOthers;

    }
}