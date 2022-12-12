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
            this.getRuntimeSettings = () => {
                const randomId = this.generateRandomId();
                const promise = new Promise((resolve, reject) => {
                    this.msgHandlersQueue[randomId] = {
                        reject: reject,
                        resolve: resolve
                    };
                    this.methodsMap.getRuntimeSettings.postMessage(randomId);
                });
                return promise;
            }
            this.getEnumBarcodeFormat = () => {
                const randomId = this.generateRandomId();
                const promise = new Promise((resolve, reject) => {
                    this.msgHandlersQueue[randomId] = {
                        reject: reject,
                        resolve: resolve
                    };
                    this.methodsMap.getEnumBarcodeFormat.postMessage(randomId);
                });
                return promise;
            }
            this.updateBarcodeFormatIds = (value) => {
                const randomId = this.generateRandomId();
                const promise = new Promise((resolve, reject) => {
                    this.msgHandlersQueue[randomId] = {
                        reject: reject,
                        resolve: resolve
                    };
                    this.methodsMap.updateBarcodeFormatIds.postMessage(value);
                });
                return promise;
            }
            this.updateExpectedBarcodesCount = (value) => {
                const randomId = this.generateRandomId();
                const promise = new Promise((resolve, reject) => {
                    this.msgHandlersQueue[randomId] = {
                        reject: reject,
                        resolve: resolve
                    };
                    this.methodsMap.updateExpectedBarcodesCount.postMessage(value);
                });
                return promise;
            }
        }
        else {
            this.methodsMap = null;
        }
        this.postMessage = (id, data) => {
            this.msgHandlersQueue[""+id].resolve((data));
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
