package com.dynamsoft.dbr.scanvin;

import androidx.annotation.Nullable;

import com.dynamsoft.dcp.ParsedResultItem;

import java.io.Serializable;
import java.util.HashMap;

public class VINData implements Serializable {
    public String vinString;
    public String WMI;
    public String region;
    public String VDS;
    public String checkDigit;
    public String modelYear;
    public String serialNumber;
    public String plantCode;

    @Nullable
    public static VINData fromParsedItem(@Nullable ParsedResultItem item) {
        if (item == null || item.getParsedFields().isEmpty() || !"VIN".equals(item.getCodeType())) {
            return null;
        }
        VINData vinData = new VINData();
        HashMap<String, String> parsedFields = item.getParsedFields();
        vinData.vinString = parsedFields.get("vinString");
        vinData.WMI = parsedFields.get("WMI");
        vinData.region = parsedFields.get("region");
        vinData.VDS = parsedFields.get("VDS");
        vinData.checkDigit = parsedFields.get("checkDigit");
        vinData.modelYear = parsedFields.get("modelYear");
        vinData.serialNumber = parsedFields.get("serialNumber");
        vinData.plantCode = parsedFields.get("plantCode");
        return vinData;
    }
}
