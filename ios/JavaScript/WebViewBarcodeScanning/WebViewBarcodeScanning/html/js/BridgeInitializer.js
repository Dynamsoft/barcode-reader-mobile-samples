let dbrWebViewBridge = null;
if (window.DBR_Android) {
    class DBRWebViewBridge {
        constructor() {
            // The following field 'DBR_Android' is specified in the relevant code of the WKWebView
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
            // handle callback when the barcode results are returned
            this.onBarcodeRead = () => { };
        }

        setBarcodeReadCallback(callback) {
            this.onBarcodeRead = callback;
        }
    }
    dbrWebViewBridge = new DBRWebViewBridge();
} else if (window.webkit) {
    class DBRWKWebViewBridge {
        constructor() {
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
                const id = this.generateRandomId();
                return new Promise((resolve, reject) => {
                    this.msgHandlersQueue[id] = { resolve, reject };
                    this.methodsMap.getRuntimeSettings.postMessage(id);
                });
            }
            this.getEnumBarcodeFormat = () => {
                const id = this.generateRandomId();
                return new Promise((resolve, reject) => {
                    this.msgHandlersQueue[id] = { resolve, reject };
                    this.methodsMap.getEnumBarcodeFormat.postMessage(id);
                });
            }
            this.updateBarcodeFormatIds = (value) => {
                const id = this.generateRandomId();
                return new Promise((resolve, reject) => {
                    this.msgHandlersQueue[id] = { resolve, reject };
                    this.methodsMap.updateBarcodeFormatIds.postMessage(JSON.stringify({ value, id }));
                });
            }
            this.updateExpectedBarcodesCount = (value) => {
                const id = this.generateRandomId();
                return new Promise((resolve, reject) => {
                    this.msgHandlersQueue[id] = { resolve, reject };
                    this.methodsMap.updateExpectedBarcodesCount.postMessage(JSON.stringify({ value, id }));
                });
            }

            this.postMessage = (id, data) => {
                this.msgHandlersQueue["" + id].resolve(data);
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
    dbrWebViewBridge = new DBRWKWebViewBridge();
} else {
    alert("Failed to initialize DBRWebViewBridge");
}
