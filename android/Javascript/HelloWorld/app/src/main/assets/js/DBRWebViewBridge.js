class DBRWebviewBridge {

    constructor() {
        // The following field 'DBR_Android' and these methods are specified in the relevant code of the WebView
        if (window.DBR_Android) {
            this.methodsMap = window.DBR_Android;
            this.setCameraUI = (list) => {
                this.methodsMap.setCameraUI(list);
            };
            this.startScanning = () => {
                this.methodsMap.startScanning();
            };
            this.stopScanning = () => {
                this.methodsMap.stopScanning();
            };
            this.getRuntimeSettings = () => {
                return this.methodsMap.getRuntimeSettings();
            };
            this.getEnumBarcodeFormat = () => {
                return this.methodsMap.getEnumBarcodeFormat();
            };
            this.updateRuntimeSettings = (settings) => {
                this.methodsMap.updateRuntimeSettings(settings);
            };
        } else {
            this.methodsMap = null;
        }
        // callback when the barcode results are returned
        this.onBarcodeRead = () => { };
    }

    setBarcodeReadCallback(callback) {
        this.onBarcodeRead = callback;
    }
}