var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var GlobalData = (function () {
    function GlobalData() {
        if (GlobalData._instance) {
            throw new Error("\u5355\u5229\u6A21\u5F0F\uFF0C\u522B\u4E71new~~");
        }
    }
    Object.defineProperty(GlobalData, "instance", {
        get: function () {
            if (!this._instance) {
                this._instance = new GlobalData();
            }
            return this._instance;
        },
        enumerable: true,
        configurable: true
    });
    GlobalData.prototype.init = function () {
    };
    return GlobalData;
}());
__reflect(GlobalData.prototype, "GlobalData");
//# sourceMappingURL=GlobalData.js.map