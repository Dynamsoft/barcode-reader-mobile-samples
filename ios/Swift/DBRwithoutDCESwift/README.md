# Using DBR without DCE

**Important Note**
Please note that this is currently not doable with v8.9 of the Barcode Reader SDK. **v8.8 of DBR must be used in this sample for now.**

In this sample, we demonstrate how to bets configure DBR for use in an interactive video scenario, but without the use of the Camera Enhancer SDK which is mainly responsible for the UI and camera control.

In order to build and deploy the sample, the `DynamsoftBarcodeReader` framework or xcframework must be added to the project.

Please follow the instructions mentioned on the main page on how to include the framework manually. However, please only select the Dynamsoft Barcode Reader and ignore the Dynamsoft Camera Enhancer as this sample doesn't use it.