// class WxPfInfo implements SDK.IpfInfo{
var WxPfInfo = (function () {
    function WxPfInfo() {
    }
    Object.defineProperty(WxPfInfo.prototype, "launchOptions", {
        get: function () {
            return wx.getLaunchOptionsSync();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(WxPfInfo.prototype, "systemPf", {
        /**系统平台*/
        get: function () {
            if (!this._systemPf) {
                var system = wx.getSystemInfoSync().system.toLowerCase();
                if (system.indexOf("android") > 0) {
                    this._systemPf = Enum_System.ANDROID;
                }
                else if (system.indexOf("ios") > 0) {
                    this._systemPf = Enum_System.IOS;
                }
            }
            return this._systemPf;
        },
        enumerable: true,
        configurable: true
    });
    return WxPfInfo;
}());
