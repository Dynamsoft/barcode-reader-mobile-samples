package com.dynamsoft.readadriverlicense;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

public class DBRDriverLicenseUtil {
    /*
     * https://www.aamva.org/DL-ID-Card-Design-Standard/
     */
    public static final String CITY = "DAI";
    public static final String STATE = "DAJ";
    public static final String STREET = "DAG";
    public static final String ZIP = "DAK";
    public static final String BIRTH_DATE = "DBB";
    public static final String EXPIRY_DATE = "DBA";
    public static final String FIRST_NAME = "DAC";
    public static final String GENDER = "DBC";
    public static final String ISSUE_DATE = "DBD";
    public static final String ISSUING_COUNTRY = "DCG";
    public static final String LAST_NAME = "DCS";
    public static final String LICENSE_NUMBER = "DAQ";
    public static final String MIDDLE_NAME = "DAD";
    public static final String DCF = "DCF";
    public static final String DCA = "DCA";
    public static final String DCB = "DCB";
    public static final String DCD = "DCD";
    public static final String DDE = "DDE";
    public static final String DDF = "DDF";
    public static final String DDG = "DDG";
    public static final String DAY = "DAY";
    public static final String DAU = "DAU";
    public static final String DAH = "DAH";
    public static final String DAZ = "DAZ";
    public static final String DCI = "DCI";
    public static final String DCJ = "DCJ";
    public static final String DCK = "DCK";
    public static final String DBN = "DBN";
    public static final String DBG = "DBG";
    public static final String DBS = "DBS";
    public static final String DCU = "DCU";
    public static final String DCE = "DCE";
    public static final String DCL = "DCL";
    public static final String DCM = "DCM";
    public static final String DCN = "DCN";
    public static final String DCO = "DCO";
    public static final String DCP = "DCP";
    public static final String DCQ = "DCQ";
    public static final String DCR = "DCR";
    public static final String DDA = "DDA";
    public static final String DDB = "DDB";
    public static final String DDC = "DDC";
    public static final String DDD = "DDD";
    public static final String DAW = "DAW";
    public static final String DAX = "DAX";
    public static final String DDH = "DDH";
    public static final String DDI = "DDI";
    public static final String DDJ = "DDJ";
    public static final String DDK = "DDK";
    public static final String DDL = "DDL";
    public static final String DAE = "DAE";
    public static final String DAF = "DAF";
    public static final String DAL = "DAL";
    public static final String DAM = "DAM";
    public static final String DAN = "DAN";
    public static final String DAO = "DAO";
    public static final String DAP = "DAP";
    public static final String DAR = "DAR";
    public static final String DAS = "DAS";
    public static final String DAT = "DAT";
    public static final String DAV = "DAV";
    public static final String DBE = "DBE";
    public static final String DBF = "DBF";
    public static final String DBH = "DBH";
    public static final String DBI = "DBI";
    public static final String DBJ = "DBJ";
    public static final String DBK = "DBK";
    public static final String DBL = "DBL";
    public static final String DBM = "DBM";
    public static final String DCH = "DCH";
    public static final String DBO = "DBO";
    public static final String DBP = "DBP";
    public static final String DBQ = "DBQ";
    public static final String DBR = "DBR";
    public static final String PAA = "PAA";
    public static final String PAB = "PAB";
    public static final String PAC = "PAC";
    public static final String PAD = "PAD";
    public static final String PAE = "PAE";
    public static final String PAF = "PAF";
    public static final String ZVA = "ZVA";

    private static final HashMap<String, String> DRIVER_LICENSE_INFO = new LinkedHashMap<String, String>() {
        {
            put(EXPIRY_DATE, "Document Expiration Date:");
            put(LAST_NAME, "Customer Last Name:");
            put(FIRST_NAME, "Customer First Name:");
            put(MIDDLE_NAME, "Customer Middle Name(s):");
            put(ISSUE_DATE, "Document Issue Date:");
            put(BIRTH_DATE, "Date of Birth:");
            put(GENDER, "Physical Description – Sex:");
            put(STREET, "Address – Street 1:");
            put(CITY, "Address – City:");
            put(STATE, "Address – Jurisdiction Code:");
            put(ZIP, "Address – Postal Code:");
            put(LICENSE_NUMBER, "Customer ID Number:");
            put(ISSUING_COUNTRY, "Country Identification:");

            put(DCF, "Document Discriminator:");
            put(DCA, "Jurisdiction-specific vehicle class:");
            put(DCB, "Jurisdiction-specific restriction codes:");
            put(DCD, "Jurisdiction-specific endorsement codes:");
            put(DDE, "Family Name Truncation:");
            put(DDF, "First Names Truncation:");
            put(DDG, "Middle Names Truncation:");
            put(DAY, "Physical Description – Eye Color:");
            put(DAU, "Physical Description – Height:");
            put(DAH, "Address – Street 2:");
            put(DAZ, "Hair Color:");
            put(DCI, "Place of birth:");
            put(DCJ, "Audit information:");
            put(DCK, "Inventory Control Number:");
            put(DBN, "Alias / AKA Family Name:");
            put(DBG, "Alias / AKA Given Name:");
            put(DBS, "Alias / AKA Suffix Name:");
            put(DCU, "Name Suffix:");
            put(DCE, "Physical Description Weight Range:");
            put(DCL, "Race / Ethnicity:");
            put(DCM, "Standard vehicle classification:");
            put(DCN, "Standard endorsement code:");
            put(DCO, "Standard restriction code:");
            put(DCP, "Jurisdiction-specific vehicle classification description:");
            put(DCQ, "Jurisdiction-specific endorsement code description:");
            put(DCR, "Jurisdiction-specific restriction code description:");
            put(DDA, "Compliance Type:");
            put(DDB, "Card Revision Date:");
            put(DDC, "HazMat Endorsement Expiration Date:");
            put(DDD, "Limited Duration Document Indicator:");
            put(DAW, "Weight(pounds):");
            put(DAX, "Weight(kilograms):");
            put(DDH, "Under 18 Until:");
            put(DDI, "Under 19 Until:");
            put(DDJ, "Under 21 Until:");
            put(DDK, "Organ Donor Indicator:");
            put(DDL, "Veteran Indicator:");

            // Old standard
            put(DAE, "Name Suffix:");
            put(DAF, "Name Prefix:");
            put(DAL, "Residence Street Address1:");
            put(DAM, "Residence Street Address2:");
            put(DAN, "Residence City:");
            put(DAO, "Residence Jurisdiction Code:");
            put(DAP, "Residence Postal Code:");
            put(DAR, "License Classification Code:");
            put(DAS, "License Restriction Code:");
            put(DAT, "License Endorsements Code:");
            put(DAV, "Height in CM:");
            put(DBE, "Issue Timestamp:");
            put(DBF, "Number of Duplicates:");
            put(DBH, "Organ Donor:");
            put(DBI, "Non-Resident Indicator:");
            put(DBJ, "Unique Customer Identifier:");
            put(DBK, "Social Security Number:");
            put(DBL, "Date Of Birth:");
            put(DBM, "Social Security Number:");
            put(DCH, "Federal Commercial Vehicle Codes:");
            put(DBO, "Customer Last Name:");
            put(DBP, "Customer First Name:");
            put(DBQ, "Customer Middle Name(s):");
            put(DBR, "Name Suffix:");
            put(PAA, "Permit Classification Code:");
            put(PAB, "Permit Expiration Date:");
            put(PAC, "Permit Identifier:");
            put(PAD, "Permit IssueDate:");
            put(PAE, "Permit Restriction Code:");
            put(PAF, "Permit Endorsement Code:");
            put(ZVA, "Court Restriction Code:");
        }
    };

    public static HashMap<String, String> readUSDriverLicense(String resultText) {
        HashMap<String, String> resultMap = new HashMap<String, String>();
        resultText = resultText.substring(resultText.indexOf("\n") + 1);
        int end = resultText.indexOf("\n");
        String firstLine = resultText.substring(0, end + 1);
        boolean findFirstLine = false;
        for (Map.Entry<String, String> entry : DRIVER_LICENSE_INFO.entrySet()) {
            try {
                int startIndex = resultText.indexOf("\n" + entry.getKey());
                if (startIndex != -1) {
                    int endIndex = resultText.indexOf("\n", startIndex + entry.getKey().length() + 1);
                    if(endIndex != -1) {
                        String value = resultText.substring(startIndex + entry.getKey().length() + 1, endIndex);
                        resultMap.put(entry.getKey(), value);
                    }
                } else if (!findFirstLine) {
                    int index = firstLine.indexOf(entry.getKey());
                    if (index != -1) {
                        int endIndex = firstLine.indexOf("\n", entry.getKey().length() + 1);
                        String value = firstLine.substring(index + entry.getKey().length(), endIndex);
                        resultMap.put(entry.getKey(), value);
                        findFirstLine = true;
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
        return resultMap;
    }

    public static boolean ifDriverLicense(String barcodeText) {
        if (barcodeText == null || barcodeText.length() < 21) {
            return false;
        }
        String str = barcodeText.trim().replace("\r", "\n");
        String[] strArray = str.split("\n");
        ArrayList<String> strList = new ArrayList<>();
        for (String s : strArray) {
            if (s.length() != 0) {
                strList.add(s);
            }
        }
        if (strList.get(0).equals("@")) {
            byte[] data = strList.get(2).getBytes();
            return ((data[0] == 'A' && data[1] == 'N' && data[2] == 'S' && data[3] == 'I' && data[4] == ' ') || (data[0] == 'A' && data[1] == 'A' && data[2] == 'M' && data[3] == 'V' && data[4] == 'A'))
                    && (data[5] >= '0' && data[5] <= '9') && (data[6] >= '0' && data[6] <= '9') && (data[7] >= '0' && data[7] <= '9')
                    && (data[8] >= '0' && data[8] <= '9') && (data[9] >= '0' && data[9] <= '9') && (data[10] >= '0' && data[10] <= '9')
                    && (data[11] >= '0' && data[11] <= '9') && (data[12] >= '0' && data[12] <= '9')
                    && (data[13] >= '0' && data[13] <= '9') && (data[14] >= '0' && data[14] <= '9');
        }
        return false;
    }
}
