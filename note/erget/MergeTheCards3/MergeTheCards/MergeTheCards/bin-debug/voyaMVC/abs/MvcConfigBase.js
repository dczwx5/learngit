var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VoyaMVC;
(function (VoyaMVC) {
    var MvcConfigBase = (function () {
        function MvcConfigBase() {
        }
        Object.defineProperty(MvcConfigBase.prototype, "mediatorList", {
            get: function () {
                if (!this._mediatorList) {
                    this._mediatorList = this.getMediatorList();
                }
                return this._mediatorList;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(MvcConfigBase.prototype, "handlerList", {
            get: function () {
                if (!this._handlerList) {
                    this._handlerList = this.getControllerList();
                }
                return this._handlerList;
            },
            enumerable: true,
            configurable: true
        });
        return MvcConfigBase;
    }());
    VoyaMVC.MvcConfigBase = MvcConfigBase;
    __reflect(MvcConfigBase.prototype, "VoyaMVC.MvcConfigBase", ["VoyaMVC.IMvcConfig"]);
})(VoyaMVC || (VoyaMVC = {}));
//# sourceMappingURL=MvcConfigBase.js.map