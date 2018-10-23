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
var SystemModuleMvcCfg = (function (_super) {
    __extends(SystemModuleMvcCfg, _super);
    function SystemModuleMvcCfg() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    SystemModuleMvcCfg.prototype.getMediatorList = function () {
        return [
            new LoadMediator(),
            new MainSceneMediator(),
            new TestSceneMediator(),
            new PopupMediator()
        ];
    };
    SystemModuleMvcCfg.prototype.getControllerList = function () {
        return [
            new LoadResController(),
            new StartupController(),
            new SdkModuleController(),
        ];
    };
    return SystemModuleMvcCfg;
}(VoyaMVC.MvcConfigBase));
__reflect(SystemModuleMvcCfg.prototype, "SystemModuleMvcCfg");
//# sourceMappingURL=SystemModuleMvcCfg.js.map