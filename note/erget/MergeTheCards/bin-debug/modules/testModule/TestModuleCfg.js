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
var TestModuleCfg = (function (_super) {
    __extends(TestModuleCfg, _super);
    function TestModuleCfg() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    TestModuleCfg.prototype.getMediatorList = function () {
        return [
            new TestMediator()
        ];
    };
    TestModuleCfg.prototype.getControllerList = function () {
        return [
            new TestController()
        ];
    };
    return TestModuleCfg;
}(VoyaMVC.MvcConfigBase));
__reflect(TestModuleCfg.prototype, "TestModuleCfg");
//# sourceMappingURL=TestModuleCfg.js.map