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
var SdkModuleController = (function (_super) {
    __extends(SdkModuleController, _super);
    function SdkModuleController() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    SdkModuleController.prototype.activate = function () {
        this.regMsg(SDKMsg.InitSdk, this.onInitSdk, this);
    };
    SdkModuleController.prototype.deactivate = function () {
        this.unregMsg(SDKMsg.InitSdk, this.onInitSdk, this);
    };
    SdkModuleController.prototype.onInitSdk = function (msg) {
        // wanba_ts/yingyongbao/空字符串表示本地/weixin/h5sdk
        switch (msg.body.pf) {
            case "weixin":
                this.registerController(new WxSdkController());
                this.registerMediator(new SC_FriendsRankMediator());
                break;
            default:
                this.registerController(new LocalSdkController());
                break;
        }
    };
    return SdkModuleController;
}(VoyaMVC.Controller));
__reflect(SdkModuleController.prototype, "SdkModuleController");
//# sourceMappingURL=SdkModuleController.js.map