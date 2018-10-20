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
    var AppHttpRespChecker = (function (_super) {
        __extends(AppHttpRespChecker, _super);
        function AppHttpRespChecker() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        AppHttpRespChecker.prototype.onCheck = function (packData) {
            if (packData.code != 1) {
                app.warn("====== http resp exception =======  code:" + packData.code + "  msg:" + packData.msg);
            }
            return { pass: true };
        };
        return AppHttpRespChecker;
    }(App.HttpRespChecker));
    App.AppHttpRespChecker = AppHttpRespChecker;
    __reflect(AppHttpRespChecker.prototype, "App.AppHttpRespChecker");
})(App || (App = {}));
//# sourceMappingURL=AppHttpRespChecker.js.map