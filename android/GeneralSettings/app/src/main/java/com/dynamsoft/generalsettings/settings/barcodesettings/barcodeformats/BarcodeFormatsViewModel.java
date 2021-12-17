package com.dynamsoft.generalsettings.settings.barcodesettings.barcodeformats;


import androidx.annotation.StringRes;
import androidx.lifecycle.ViewModel;

import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.EnumBarcodeFormat_2;
import com.dynamsoft.generalsettings.R;
import com.dynamsoft.generalsettings.util.SettingsCache;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BarcodeFormatsViewModel extends ViewModel {
    private final List<Integer> listOned;
    private final List<Integer> listGs1Databar;
    private final List<Integer> listPostalCode;
    private final List<Integer> listOtherFormats;

    private int settingFormats = SettingsCache.getCurrentSettings().getBarcodeFormats();
    private int settingFormats_2 = SettingsCache.getCurrentSettings().getBarcodeFormats_2();


    Map<Integer, Integer> mapFormats1 = new HashMap<>();
    Map<Integer, Integer> mapFormats2 = new HashMap<>();

    {
        listOned = new ArrayList<>();
        listOned.add(R.string.code_39);
        listOned.add(R.string.code_128);
        listOned.add(R.string.code_39_extended);
        listOned.add(R.string.code_93);
        listOned.add(R.string.codabar);
        listOned.add(R.string.itf);
        listOned.add(R.string.ean_13);
        listOned.add(R.string.ean_8);
        listOned.add(R.string.upc_a);
        listOned.add(R.string.upc_e);
        listOned.add(R.string.industrial_25);
        listOned.add(R.string.msi_code);

        listGs1Databar = new ArrayList<>();
        listGs1Databar.add(R.string.gs1_databar_omnidirectional);
        listGs1Databar.add(R.string.gs1_databar_truncated);
        listGs1Databar.add(R.string.gs1_databar_stacked);
        listGs1Databar.add(R.string.gs1_databar_stacked_omnidirectional);
        listGs1Databar.add(R.string.gs1_databar_expanded);
        listGs1Databar.add(R.string.gs1_databar_expanded_stacked);
        listGs1Databar.add(R.string.gs1_databar_limited);

        listPostalCode = new ArrayList<>();
        listPostalCode.add(R.string.uspsintelligentmail);
        listPostalCode.add(R.string.postnet);
        listPostalCode.add(R.string.planet);
        listPostalCode.add(R.string.australianpost);
        listPostalCode.add(R.string.rm4scc);

        listOtherFormats = new ArrayList<>();
        listOtherFormats.add(R.string.pdf417);
        listOtherFormats.add(R.string.qrcode);
        listOtherFormats.add(R.string.data_martix);
        listOtherFormats.add(R.string.aztec);
        listOtherFormats.add(R.string.maxicode);
        listOtherFormats.add(R.string.micro_qr);
        listOtherFormats.add(R.string.micro_pdf417);
        listOtherFormats.add(R.string.gs1_composite);
        listOtherFormats.add(R.string.patch_code);
        listOtherFormats.add(R.string.dot_code);
    }

    public void initFormatsMap() {
        mapFormats1.put(R.string.code_39, EnumBarcodeFormat.BF_CODE_39);
        mapFormats1.put(R.string.code_128, EnumBarcodeFormat.BF_CODE_128);
        mapFormats1.put(R.string.code_39_extended, EnumBarcodeFormat.BF_CODE_39_EXTENDED);
        mapFormats1.put(R.string.code_93, EnumBarcodeFormat.BF_CODE_93);
        mapFormats1.put(R.string.codabar, EnumBarcodeFormat.BF_CODABAR);
        mapFormats1.put(R.string.itf, EnumBarcodeFormat.BF_ITF);
        mapFormats1.put(R.string.ean_13, EnumBarcodeFormat.BF_EAN_13);
        mapFormats1.put(R.string.ean_8, EnumBarcodeFormat.BF_EAN_8);
        mapFormats1.put(R.string.upc_a, EnumBarcodeFormat.BF_UPC_A);
        mapFormats1.put(R.string.upc_e, EnumBarcodeFormat.BF_UPC_E);
        mapFormats1.put(R.string.industrial_25, EnumBarcodeFormat.BF_INDUSTRIAL_25);
        mapFormats1.put(R.string.msi_code, EnumBarcodeFormat.BF_MSI_CODE);

        mapFormats1.put(R.string.gs1_databar_omnidirectional, EnumBarcodeFormat.BF_GS1_DATABAR_OMNIDIRECTIONAL);
        mapFormats1.put(R.string.gs1_databar_truncated, EnumBarcodeFormat.BF_GS1_DATABAR_TRUNCATED);
        mapFormats1.put(R.string.gs1_databar_stacked, EnumBarcodeFormat.BF_GS1_DATABAR_STACKED);
        mapFormats1.put(R.string.gs1_databar_stacked_omnidirectional, EnumBarcodeFormat.BF_GS1_DATABAR_STACKED_OMNIDIRECTIONAL);
        mapFormats1.put(R.string.gs1_databar_expanded, EnumBarcodeFormat.BF_GS1_DATABAR_EXPANDED);
        mapFormats1.put(R.string.gs1_databar_expanded_stacked, EnumBarcodeFormat.BF_GS1_DATABAR_EXPANDED_STACKED);
        mapFormats1.put(R.string.gs1_databar_limited, EnumBarcodeFormat.BF_GS1_DATABAR_LIMITED);

        mapFormats2.put(R.string.uspsintelligentmail, EnumBarcodeFormat_2.BF2_USPSINTELLIGENTMAIL);
        mapFormats2.put(R.string.postnet, EnumBarcodeFormat_2.BF2_POSTNET);
        mapFormats2.put(R.string.planet, EnumBarcodeFormat_2.BF2_PLANET);
        mapFormats2.put(R.string.australianpost, EnumBarcodeFormat_2.BF2_AUSTRALIANPOST);
        mapFormats2.put(R.string.rm4scc, EnumBarcodeFormat_2.BF2_RM4SCC);

        mapFormats1.put(R.string.pdf417, EnumBarcodeFormat.BF_PDF417);
        mapFormats1.put(R.string.qrcode, EnumBarcodeFormat.BF_QR_CODE);
        mapFormats1.put(R.string.data_martix, EnumBarcodeFormat.BF_DATAMATRIX);
        mapFormats1.put(R.string.aztec, EnumBarcodeFormat.BF_AZTEC);
        mapFormats1.put(R.string.maxicode, EnumBarcodeFormat.BF_MAXICODE);
        mapFormats1.put(R.string.micro_qr, EnumBarcodeFormat.BF_MICRO_QR);
        mapFormats1.put(R.string.micro_pdf417, EnumBarcodeFormat.BF_MICRO_PDF417);
        mapFormats1.put(R.string.gs1_composite, EnumBarcodeFormat.BF_GS1_COMPOSITE);
        mapFormats1.put(R.string.patch_code, EnumBarcodeFormat.BF_PATCHCODE);
        mapFormats2.put(R.string.dot_code, EnumBarcodeFormat_2.BF2_DOTCODE);
    }

    public List<Integer> getListOned() {
        return listOned;
    }

    public List<Integer> getListGs1Databar() {
        return listGs1Databar;
    }

    public List<Integer> getListPostalCode() {
        return listPostalCode;
    }

    public List<Integer> getListOtherFormats() {
        return listOtherFormats;
    }

    public int getSettingFormats() {
        settingFormats = SettingsCache.getCurrentSettings().getBarcodeFormats();
        return settingFormats;
    }

    public int getSettingFormats_2() {
        settingFormats_2 = SettingsCache.getCurrentSettings().getBarcodeFormats_2();
        return settingFormats_2;
    }

    public Map<Integer, Integer> getMapFormats1() {
        return mapFormats1;
    }

    public Map<Integer, Integer> getMapFormats2() {
        return mapFormats2;
    }

    public void changeBarcodeFormats(@StringRes int format, boolean isChecked) {
        if (mapFormats1.get(format) != null) {
            settingFormats = isChecked ? settingFormats | mapFormats1.get(format) : settingFormats & (~mapFormats1.get(format));
            SettingsCache.getCurrentSettings().setBarcodeFormats(settingFormats);
        } else {
            settingFormats_2 = isChecked ? settingFormats_2 | mapFormats2.get(format) : settingFormats_2 & (~mapFormats2.get(format));
            SettingsCache.getCurrentSettings().setBarcodeFormats_2(settingFormats_2);
        }
    }
}
