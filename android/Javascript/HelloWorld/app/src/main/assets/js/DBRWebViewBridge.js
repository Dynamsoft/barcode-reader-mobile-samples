class DBRWebViewBridge {

    constructor() {
        this.methodsMap = window.DBR_Android;

        this.setCameraUI = (list) => {
            this.methodsMap.setCameraUI(list);
        };
        this.switchFlashlight = (state) => {
            this.methodsMap.switchFlashlight(state.toString());
        };
        this.startScanning = () => {
            this.methodsMap.startScanning();
        };
        this.stopScanning = () => {
            this.methodsMap.stopScanning();
        };
        this.getRuntimeSettings = () => new Promise((resolve, reject) => {
            try {
                const res = this.methodsMap.getRuntimeSettings();
                resolve(JSON.parse(res));
            } catch (ex) {
                reject(ex);
            }
        });
        this.getEnumBarcodeFormat = () => new Promise((resolve, reject) => {
            try {
                const res = this.methodsMap.getEnumBarcodeFormat();
                resolve(JSON.parse(res));
            } catch (ex) {
                reject(ex);
            }
        });
        this.updateRuntimeSettings = (settings) => new Promise((resolve, reject) => {
            try {
                this.methodsMap.updateRuntimeSettings(settings);
                resolve();
            } catch (ex) {
                reject(ex);
            }
        });
        // callback when the barcode results are returned
        this.onBarcodeRead = () => { };
    }

    setBarcodeReadCallback(callback) {
        this.onBarcodeRead = callback;
    }
}
