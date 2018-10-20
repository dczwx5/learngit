var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var App;
(function (App) {
    var BaseTipManager = (function () {
        function BaseTipManager() {
            this.tipItemList = [];
        }
        BaseTipManager.prototype.onTipItemRestore = function (tipItem) {
            this.tipItemList.splice(this.tipItemList.indexOf(tipItem), 1);
            tipItem.dg_onRestore.unregister(this.onTipItemRestore);
        };
        Object.defineProperty(BaseTipManager.prototype, "gap", {
            get: function () {
                return 3;
            },
            enumerable: true,
            configurable: true
        });
        return BaseTipManager;
    }());
    App.BaseTipManager = BaseTipManager;
    __reflect(BaseTipManager.prototype, "App.BaseTipManager", ["App.ITipManager"]);
})(App || (App = {}));
//# sourceMappingURL=BaseTipManager.js.map