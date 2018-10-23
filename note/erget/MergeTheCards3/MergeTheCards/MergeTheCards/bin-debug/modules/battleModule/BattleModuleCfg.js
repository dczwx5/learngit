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
var BattleModuleCfg = (function (_super) {
    __extends(BattleModuleCfg, _super);
    function BattleModuleCfg() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    BattleModuleCfg.prototype.getMediatorList = function () {
        return [
            new BattleViewMediator(),
            new BattleMenuWindowMediator(),
            new BattleSettleMediator(),
            new RebirthConfirmMediator()
        ];
    };
    BattleModuleCfg.prototype.getControllerList = function () {
        return [
            new BattleModuleCtrl()
        ];
    };
    return BattleModuleCfg;
}(VoyaMVC.MvcConfigBase));
__reflect(BattleModuleCfg.prototype, "BattleModuleCfg");
//# sourceMappingURL=BattleModuleCfg.js.map