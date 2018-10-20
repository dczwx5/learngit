var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var __extends = this && this.__extends || function __extends(t, e) { 
 function r() { 
 this.constructor = t;
}
for (var i in e) e.hasOwnProperty(i) && (t[i] = e[i]);
r.prototype = e.prototype, t.prototype = new r();
};
var LocalSdkController = (function (_super) {
    __extends(LocalSdkController, _super);
    function LocalSdkController() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    LocalSdkController.prototype.activate = function () {
        this.regMsg(SDKMsg.Login, this.onLogin, this);
    };
    LocalSdkController.prototype.deactivate = function () {
        this.unregMsg(SDKMsg.Login, this.onLogin, this);
    };
    LocalSdkController.prototype.onLogin = function (msg) {
    };
    Object.defineProperty(LocalSdkController.prototype, "playerModel", {
        get: function () {
            return this.getModel(PlayerModel);
        },
        enumerable: true,
        configurable: true
    });
    return LocalSdkController;
}(VoyaMVC.Controller));
__reflect(LocalSdkController.prototype, "LocalSdkController");
//# sourceMappingURL=LocalSdkController.js.map