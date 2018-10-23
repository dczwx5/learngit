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
var RebirthConfirmWindow = (function (_super) {
    __extends(RebirthConfirmWindow, _super);
    function RebirthConfirmWindow() {
        var _this = _super.call(this, 'RebirthConfirmWindowSkin') || this;
        _this.resources = [];
        return _this;
    }
    RebirthConfirmWindow.prototype.onInit = function () {
    };
    RebirthConfirmWindow.prototype.onDestroy = function () {
    };
    return RebirthConfirmWindow;
}(App.BaseWindow));
__reflect(RebirthConfirmWindow.prototype, "RebirthConfirmWindow");
//# sourceMappingURL=RebirthConfirmWindow.js.map