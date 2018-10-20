var SDK;
(function (SDK) {
    var SdkProxy = (function () {
        function SdkProxy() {
        }
        SdkProxy.prototype.init = function (pf) {
            // switch (pf){
            //     case Enum_PF.WX:
            //         let sdk = new WxSDKAPI();
            //         sdk.init();
            //         this._sdk = sdk;
            //         break;
            // }
        };
        SdkProxy.prototype.setStorageData = function (key, data) {
            this._sdk.setStorageData(key, data);
        };
        SdkProxy.prototype.getStorageData = function (key) {
            return this._sdk.getStorageData(key);
        };
        Object.defineProperty(SdkProxy.prototype, "sdk", {
            get: function () {
                return this._sdk;
            },
            enumerable: true,
            configurable: true
        });
        return SdkProxy;
    }());
    SDK.SdkProxy = SdkProxy;
})(SDK || (SDK = {}));
