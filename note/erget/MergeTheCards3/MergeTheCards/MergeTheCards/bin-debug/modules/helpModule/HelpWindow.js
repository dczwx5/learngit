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
var HelpWindow = (function (_super) {
    __extends(HelpWindow, _super);
    function HelpWindow() {
        var _this = _super.call(this, "HelpWindowSkin") || this;
        _this.resources = [];
        return _this;
    }
    HelpWindow.prototype.partAdded = function (partName, instance) {
        _super.prototype.partAdded.call(this, partName, instance);
    };
    HelpWindow.prototype.childrenCreated = function () {
        _super.prototype.childrenCreated.call(this);
    };
    HelpWindow.prototype.onInit = function () {
    };
    HelpWindow.prototype.onDestroy = function () {
    };
    return HelpWindow;
}(App.BaseWindow));
__reflect(HelpWindow.prototype, "HelpWindow");
//# sourceMappingURL=HelpWindow.js.map