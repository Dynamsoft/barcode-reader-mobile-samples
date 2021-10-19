//This sample shows how to reach the best coverage on barcode reading when using Dynamsoft Barcode Reader.

package com.dynamsoft.readratefirstsettings;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRDLSLicenseVerificationListener;
import com.dynamsoft.dbr.DMDLSConnectionParameters;
import com.dynamsoft.dbr.EnumBarcodeFormat;
import com.dynamsoft.dbr.EnumBarcodeFormat_2;
import com.dynamsoft.dbr.EnumBinarizationMode;
import com.dynamsoft.dbr.EnumDPMCodeReadingMode;
import com.dynamsoft.dbr.EnumDeblurMode;
import com.dynamsoft.dbr.EnumGrayscaleTransformationMode;
import com.dynamsoft.dbr.EnumLocalizationMode;
import com.dynamsoft.dbr.EnumScaleUpMode;
import com.dynamsoft.dbr.PublicRuntimeSettings;

public class MainActivity extends AppCompatActivity {
    public static BarcodeReader reader;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        askForStoragePermissions();
        setContentView(R.layout.activity_main);
        if (null == savedInstanceState) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.container, Camera2BasicFragment.newInstance())
                    .commit();
        }
    }

    private void askForStoragePermissions() {
        String[] perms = {Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE};
        int permission = ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        if (permission != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, perms, 1);
        }
    }

    @Override
    public void onResume() {
        if(reader == null){
            try {
                // Create an instance of Dynamsoft Barcode Reader.
                reader = new BarcodeReader();

                // Initialize license for Dynamsoft Barcode Reader.
                // The organization id 200001 here will grant you a public trial license good for 7 days. Note that network connection is required for this license to work.
                // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
                // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
                DMDLSConnectionParameters dbrParameters = new DMDLSConnectionParameters();
                dbrParameters.organizationID = "200001";
                reader.initLicenseFromDLS(dbrParameters, new DBRDLSLicenseVerificationListener() {
                    @Override
                    public void DLSLicenseVerificationCallback(boolean isSuccessful, Exception e) {
                        if (!isSuccessful) {
                            e.printStackTrace();
                        }
                    }
                });

                // Read rate first settings for barcode scanning.
                this.configReadRateFirst();

            } catch (BarcodeReaderException e) {
                e.printStackTrace();
            }
        }
        super.onResume();
    }

    private void configReadRateFirst() throws BarcodeReaderException {
        PublicRuntimeSettings settings = reader.getRuntimeSettings();

        // Parameter 1. Set expected barcode formats
        settings.barcodeFormatIds = EnumBarcodeFormat.BF_ALL;
        settings.barcodeFormatIds_2 = EnumBarcodeFormat_2.BF2_DOTCODE | EnumBarcodeFormat_2.BF2_POSTALCODE;

        // Parameter 2. Set expected barcode count.
        // Here the barcode scanner will try to find 64 barcodes.
        // If the result count does not reach the expected amount, the barcode scanner will try other algorithms in the setting list to find enough barcodes.
        settings.expectedBarcodesCount = 64;

        // Parameter 3. Set more binarization modes.
        settings.binarizationModes = new int[]{EnumBinarizationMode.BM_LOCAL_BLOCK,EnumBinarizationMode.BM_THRESHOLD,0,0,0,0,0,0};

        // Parameter 4. Set more localization modes.
        // LocalizationModes are all enabled as default. Barcode reader will automatically switch between the modes and try decoding continuously until timeout or the expected barcode count is reached.
        // Please manually update the enabled modes list or change the expected barcode count to promote the barcode scanning speed.
        // Read more about localization mode members: https://www.dynamsoft.com/barcode-reader/parameters/enum/parameter-mode-enums.html?ver=latest#localizationmode
        settings.localizationModes = new int[]{EnumLocalizationMode.LM_CONNECTED_BLOCKS,EnumLocalizationMode.LM_SCAN_DIRECTLY,EnumLocalizationMode.LM_STATISTICS,
                EnumLocalizationMode.LM_LINES,EnumLocalizationMode.LM_STATISTICS_MARKS,EnumLocalizationMode.LM_STATISTICS_POSTAL_CODE,0,0};

        // Parameter 5. Set more deblur modes.
        // DeblurModes are all enabled as default. Barcode reader will automatically switch between the modes and try decoding continuously until timeout or the expected barcode count is reached.
        // Please manually update the enabled modes list or change the expected barcode count to promote the barcode scanning speed.
        //Read more about deblur mode members: https://www.dynamsoft.com/barcode-reader/parameters/enum/parameter-mode-enums.html#deblurmode
        settings.deblurModes = new int[]{EnumDeblurMode.DM_DIRECT_BINARIZATION,EnumDeblurMode.DM_THRESHOLD_BINARIZATION,EnumDeblurMode.DM_GRAYE_EQULIZATION,
                EnumDeblurMode.DM_SMOOTHING,EnumDeblurMode.DM_MORPHING,EnumDeblurMode.DM_DEEP_ANALYSIS,EnumDeblurMode.DM_SHARPENING,0,0,0};

        // Parameter 6. Set scale up modes.
        // It is a parameter to control the process for scaling up an image used for detecting barcodes with small module size
        settings.scaleUpModes = new int[]{EnumScaleUpMode.SUM_AUTO,0,0,0,0,0,0,0};

        // Parameter 7. Set grayscale transformation modes.
        // By default, the library can only locate the dark barcodes that stand on a light background. "GTM_INVERTED":The image will be transformed into inverted grayscale.
        settings.furtherModes.grayscaleTransformationModes = new int[]{EnumGrayscaleTransformationMode.GTM_ORIGINAL,EnumGrayscaleTransformationMode.GTM_INVERTED,0,0,0,0,0,0};

        // Parameter 8. Enable dpm modes.
        // It is a parameter to control how to read direct part mark (DPM) barcodes.
        settings.furtherModes.dpmCodeReadingModes = new int[]{EnumDPMCodeReadingMode.DPMCRM_GENERAL,0,0,0,0,0,0,0};

        // Parameter 9. Increase timeout(ms). The barcode scanner will have more chances to find the expected barcode until it times out
        settings.timeout = 30000;

        reader.updateRuntimeSettings(settings);
    }
}
