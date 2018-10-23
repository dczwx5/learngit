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
var BattleMenuWindow = (function (_super) {
    __extends(BattleMenuWindow, _super);
    function BattleMenuWindow() {
        var _this = _super.call(this, "BattleMenuWindowSkin") || this;
        _this.resources = [];
        return _this;
    }
    BattleMenuWindow.prototype.onInit = function () {
    };
    BattleMenuWindow.prototype.onDestroy = function () {
    };
    return BattleMenuWindow;
}(App.BaseWindow));
__reflect(BattleMenuWindow.prototype, "BattleMenuWindow");
//# sourceMappingURL=BattleMenuWindow.js.map