package com.dynamsoft.dbr.generalsettings.ui.settings.barcodesettings.barcodeformats;


import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.generalsettings.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BarcodeFormatsUtil {
    private final List<Integer> listOneDStringId;
    private final List<Integer> listGs1DatabarStringId;
    private final List<Integer> listPostalCodeStringId;
    private final List<Integer> listOtherFormatsStringId;

    private final Map<Integer, Long> mapStringId_FormatId = new HashMap<>();

    {
        listOneDStringId = new ArrayList<>();
        listOneDStringId.add(R.string.code_39);
        listOneDStringId.add(R.string.code_128);
        listOneDStringId.add(R.string.code_39_extended);
        listOneDStringId.add(R.string.code_93);
        listOneDStringId.add(R.string.code_11);
        listOneDStringId.add(R.string.codabar);
        listOneDStringId.add(R.string.itf);
        listOneDStringId.add(R.string.ean_13);
        listOneDStringId.add(R.string.ean_8);
        listOneDStringId.add(R.string.upc_a);
        listOneDStringId.add(R.string.upc_e);
        listOneDStringId.add(R.string.industrial_25);
        listOneDStringId.add(R.string.msi_code);

        listGs1DatabarStringId = new ArrayList<>();
        listGs1DatabarStringId.add(R.string.gs1_databar_omnidirectional);
        listGs1DatabarStringId.add(R.string.gs1_databar_truncated);
        listGs1DatabarStringId.add(R.string.gs1_databar_stacked);
        listGs1DatabarStringId.add(R.string.gs1_databar_stacked_omnidirectional);
        listGs1DatabarStringId.add(R.string.gs1_databar_expanded);
        listGs1DatabarStringId.add(R.string.gs1_databar_expanded_stacked);
        listGs1DatabarStringId.add(R.string.gs1_databar_limited);

        listPostalCodeStringId = new ArrayList<>();
        listPostalCodeStringId.add(R.string.uspsintelligentmail);
        listPostalCodeStringId.add(R.string.postnet);
        listPostalCodeStringId.add(R.string.planet);
        listPostalCodeStringId.add(R.string.australianpost);
        listPostalCodeStringId.add(R.string.rm4scc);

        listOtherFormatsStringId = new ArrayList<>();
        listOtherFormatsStringId.add(R.string.pdf417);
        listOtherFormatsStringId.add(R.string.qrcode);
        listOtherFormatsStringId.add(R.string.data_martix);
        listOtherFormatsStringId.add(R.string.aztec);
        listOtherFormatsStringId.add(R.string.maxicode);
        listOtherFormatsStringId.add(R.string.micro_qr);
        listOtherFormatsStringId.add(R.string.micro_pdf417);
        listOtherFormatsStringId.add(R.string.gs1_composite);
        listOtherFormatsStringId.add(R.string.patch_code);
        listOtherFormatsStringId.add(R.string.dot_code);
        listOtherFormatsStringId.add(R.string.pharma_code);
    }


    public BarcodeFormatsUtil() {
        initFormatsMap();
    }

    public void initFormatsMap() {
        mapStringId_FormatId.put(R.string.code_39, EnumBarcodeFormat.BF_CODE_39);
        mapStringId_FormatId.put(R.string.code_128, EnumBarcodeFormat.BF_CODE_128);
        mapStringId_FormatId.put(R.string.code_39_extended, EnumBarcodeFormat.BF_CODE_39_EXTENDED);
        mapStringId_FormatId.put(R.string.code_93, EnumBarcodeFormat.BF_CODE_93);
        mapStringId_FormatId.put(R.string.code_11, EnumBarcodeFormat.BF_CODE_11);
        mapStringId_FormatId.put(R.string.codabar, EnumBarcodeFormat.BF_CODABAR);
        mapStringId_FormatId.put(R.string.itf, EnumBarcodeFormat.BF_ITF);
        mapStringId_FormatId.put(R.string.ean_13, EnumBarcodeFormat.BF_EAN_13);
        mapStringId_FormatId.put(R.string.ean_8, EnumBarcodeFormat.BF_EAN_8);
        mapStringId_FormatId.put(R.string.upc_a, EnumBarcodeFormat.BF_UPC_A);
        mapStringId_FormatId.put(R.string.upc_e, EnumBarcodeFormat.BF_UPC_E);
        mapStringId_FormatId.put(R.string.industrial_25, EnumBarcodeFormat.BF_INDUSTRIAL_25);
        mapStringId_FormatId.put(R.string.msi_code, EnumBarcodeFormat.BF_MSI_CODE);

        mapStringId_FormatId.put(R.string.gs1_databar_omnidirectional, EnumBarcodeFormat.BF_GS1_DATABAR_OMNIDIRECTIONAL);
        mapStringId_FormatId.put(R.string.gs1_databar_truncated, EnumBarcodeFormat.BF_GS1_DATABAR_TRUNCATED);
        mapStringId_FormatId.put(R.string.gs1_databar_stacked, EnumBarcodeFormat.BF_GS1_DATABAR_STACKED);
        mapStringId_FormatId.put(R.string.gs1_databar_stacked_omnidirectional, EnumBarcodeFormat.BF_GS1_DATABAR_STACKED_OMNIDIRECTIONAL);
        mapStringId_FormatId.put(R.string.gs1_databar_expanded, EnumBarcodeFormat.BF_GS1_DATABAR_EXPANDED);
        mapStringId_FormatId.put(R.string.gs1_databar_expanded_stacked, EnumBarcodeFormat.BF_GS1_DATABAR_EXPANDED_STACKED);
        mapStringId_FormatId.put(R.string.gs1_databar_limited, EnumBarcodeFormat.BF_GS1_DATABAR_LIMITED);

        mapStringId_FormatId.put(R.string.uspsintelligentmail, EnumBarcodeFormat.BF_USPSINTELLIGENTMAIL);
        mapStringId_FormatId.put(R.string.postnet, EnumBarcodeFormat.BF_POSTNET);
        mapStringId_FormatId.put(R.string.planet, EnumBarcodeFormat.BF_PLANET);
        mapStringId_FormatId.put(R.string.australianpost, EnumBarcodeFormat.BF_AUSTRALIANPOST);
        mapStringId_FormatId.put(R.string.rm4scc, EnumBarcodeFormat.BF_RM4SCC);

        mapStringId_FormatId.put(R.string.pdf417, EnumBarcodeFormat.BF_PDF417);
        mapStringId_FormatId.put(R.string.qrcode, EnumBarcodeFormat.BF_QR_CODE);
        mapStringId_FormatId.put(R.string.data_martix, EnumBarcodeFormat.BF_DATAMATRIX);
        mapStringId_FormatId.put(R.string.aztec, EnumBarcodeFormat.BF_AZTEC);
        mapStringId_FormatId.put(R.string.maxicode, EnumBarcodeFormat.BF_MAXICODE);
        mapStringId_FormatId.put(R.string.micro_qr, EnumBarcodeFormat.BF_MICRO_QR);
        mapStringId_FormatId.put(R.string.micro_pdf417, EnumBarcodeFormat.BF_MICRO_PDF417);
        mapStringId_FormatId.put(R.string.gs1_composite, EnumBarcodeFormat.BF_GS1_COMPOSITE);
        mapStringId_FormatId.put(R.string.patch_code, EnumBarcodeFormat.BF_PATCHCODE);
        mapStringId_FormatId.put(R.string.dot_code, EnumBarcodeFormat.BF_DOTCODE);
        mapStringId_FormatId.put(R.string.pharma_code, EnumBarcodeFormat.BF_PHARMACODE);
    }

    public List<Integer> getListOneDStringId() {
        return listOneDStringId;
    }

    public List<Integer> getListGs1DatabarStringId() {
        return listGs1DatabarStringId;
    }

    public List<Integer> getListPostalCodeStringId() {
        return listPostalCodeStringId;
    }

    public List<Integer> getListOtherFormatsStringId() {
        return listOtherFormatsStringId;
    }

    public Map<Integer, Long> getMapStringId_FormatId() {
        return mapStringId_FormatId;
    }


}
