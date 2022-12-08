class DBRWKWebViewBridge {

    constructor() {
        // The following two properties 'startScanning' and 'stopScanning' are specified in the relevant code of the WKWebView
        if (window.webkit) {
            this.methodsMap = window.webkit.messageHandlers;
            this.msgHandlersQueue = {};

            this.setCameraUI = (list) => {
                this.methodsMap.setCameraUI.postMessage(list);
            };
            this.switchFlashlight = (state) => {
                this.methodsMap.switchFlashlight.postMessage(state);
            };
            this.startScanning = () => {
                this.methodsMap.startScanning.postMessage("");
            };
            this.stopScanning = () => {
                this.methodsMap.stopScanning.postMessage("");
            };
            this.getRuntimeSettings = (callback) => {
                const randomId = this.generateRandomId();
                this.msgHandlersQueue[randomId] = callback;
                this.methodsMap.getRuntimeSettings.postMessage(randomId);
            };
            this.getEnumBarcodeFormat = (callback) => {
                const randomId = this.generateRandomId();
                this.msgHandlersQueue[randomId] = callback;
                this.methodsMap.getEnumBarcodeFormat.postMessage(randomId);
            };
            this.updateBarcodeFormatIds = (value) => {
                this.methodsMap.updateBarcodeFormatIds.postMessage(value);
            };
            this.updateExpectedBarcodesCount = (value) => {
                this.methodsMap.updateExpectedBarcodesCount.postMessage(value);
            };
        }
        else {
            this.methodsMap = null;
        }
        this.postMessage = (id, data) => {
            this.msgHandlersQueue[""+id](data);
            Reflect.deleteProperty(this.msgHandlersQueue, id);
        };
        // callback when the barcode results are returned
        this.onBarcodeRead = () => { };
    }

    setBarcodeReadCallback(callback) {
        this.onBarcodeRead = callback;
    }

    generateRandomId() {
        let id = "id" + new Date().getTime().toString();
        for (let i = 0; i < 4; i++) {
            id += Math.floor(Math.random() * 9).toString();
        }
        return id;
    }
}
