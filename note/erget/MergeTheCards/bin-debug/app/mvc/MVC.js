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
var App;
(function (App) {
    var MVC = (function (_super) {
        __extends(MVC, _super);
        function MVC() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        MVC.prototype.startup = function () {
            this.configureModuls();
            this.core.sendMsg(create(StartupMsg.Startup));
        };
        MVC.prototype.configureModuls = function () {
            this.configure([
                new TestModuleCfg(),
                new SystemModuleMvcCfg(),
                new MainModuleCfg(),
                new BattleModuleCfg(),
                new HelpModuleMvcCfg()
            ]);
        };
        return MVC;
    }(VoyaMVC.MVC));
    App.MVC = MVC;
    __reflect(MVC.prototype, "App.MVC");
})(App || (App = {}));
//# sourceMappingURL=MVC.js.map