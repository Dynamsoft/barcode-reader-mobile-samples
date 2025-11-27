package com.dynamsoft.dbr.generalsettings.ui.formatselection;

import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.generalsettings.R;

import java.util.HashMap;
import java.util.Map;

public class BarcodeFormatConstants {

    public static final Map<Long, Integer> BarcodeFormatOnedMap = new HashMap<>();
    public static final long AllBarcodeFormatOned;

    public static final  Map<Long, Integer> BarcodeFormatTwodMap = new HashMap<>();
    public static final long AllBarcodeFormatTwod;

    public static final Map<Long, Integer> BarcodeFormatPharmacodeMap = new HashMap<>();
    public static final long AllBarcodeFormatPharmacode;

    public static final  Map<Long, Integer> BarcodeFormatOthersMap = new HashMap<>();
    public static final long AllBarcodeFormatOthers;

    static {
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_CODE_39, R.string.code_39);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_CODE_128, R.string.code_128);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_CODE_39_EXTENDED, R.string.code_39_extended);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_CODE_93, R.string.code_93);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_CODE_11, R.string.code_11);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_CODABAR, R.string.codabar);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_ITF, R.string.itf);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_EAN_13, R.string.ean_13);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_EAN_8, R.string.ean_8);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_UPC_A, R.string.upc_a);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_UPC_E, R.string.upc_e);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_INDUSTRIAL_25, R.string.industrial_25);
        BarcodeFormatOnedMap.put(EnumBarcodeFormat.BF_MSI_CODE, R.string.msi_code);

        long valueOned = 0L;
        for (Map.Entry<Long, Integer> entry : BarcodeFormatOnedMap.entrySet()) {
            valueOned |= entry.getKey();
        }
        AllBarcodeFormatOned = valueOned;

        BarcodeFormatTwodMap.put(EnumBarcodeFormat.BF_QR_CODE, R.string.qrcode);
        BarcodeFormatTwodMap.put(EnumBarcodeFormat.BF_PDF417, R.string.pdf417);
        BarcodeFormatTwodMap.put(EnumBarcodeFormat.BF_DATAMATRIX, R.string.data_martix);

        long valueTwod = 0L;
        for (Map.Entry<Long, Integer> entry : BarcodeFormatTwodMap.entrySet()) {
            valueTwod |= entry.getKey();
        }
        AllBarcodeFormatTwod = valueTwod;

        BarcodeFormatPharmacodeMap.put(EnumBarcodeFormat.BF_PHARMACODE_ONE_TRACK, R.string.pharma_code_one_track);
        BarcodeFormatPharmacodeMap.put(EnumBarcodeFormat.BF_PHARMACODE_TWO_TRACK, R.string.pharma_code_two_track);

        long valuePharmacode = 0L;
        for (Map.Entry<Long, Integer> entry : BarcodeFormatPharmacodeMap.entrySet()) {
            valuePharmacode |= entry.getKey();
        }
        AllBarcodeFormatPharmacode = valuePharmacode;

        BarcodeFormatOthersMap.put(EnumBarcodeFormat.BF_AZTEC, R.string.aztec);
        BarcodeFormatOthersMap.put(EnumBarcodeFormat.BF_MAXICODE, R.string.maxicode);
        BarcodeFormatOthersMap.put(EnumBarcodeFormat.BF_PATCHCODE, R.string.patch_code);
        BarcodeFormatOthersMap.put(EnumBarcodeFormat.BF_DOTCODE, R.string.dot_code);
        BarcodeFormatOthersMap.put(EnumBarcodeFormat.BF_POSTALCODE, R.string.postal_code);
        BarcodeFormatOthersMap.put(EnumBarcodeFormat.BF_GS1_DATABAR, R.string.gs1_databar);
        BarcodeFormatOthersMap.put(EnumBarcodeFormat.BF_GS1_COMPOSITE, R.string.gs1_composite);
        BarcodeFormatOthersMap.put(EnumBarcodeFormat.BF_MICRO_PDF417, R.string.micro_pdf417);
        BarcodeFormatOthersMap.put(EnumBarcodeFormat.BF_MICRO_QR, R.string.micro_qr);

        long valueOthers = 0L;
        for (Map.Entry<Long, Integer> entry : BarcodeFormatOthersMap.entrySet()) {
            valueOthers |= entry.getKey();
        }
        AllBarcodeFormatOthers = valueOthers;

    }
}