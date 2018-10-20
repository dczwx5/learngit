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
var ExpPgBar = (function (_super) {
    __extends(ExpPgBar, _super);
    function ExpPgBar() {
        return _super.call(this) || this;
    }
    ExpPgBar.prototype.setProgress = function (curr, max) {
        var percent = curr / max;
        this.rect_value.width = this.width * percent;
    };
    Object.defineProperty(ExpPgBar.prototype, "displayColor", {
        set: function (color) {
            this.rect_value.fillColor = color;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ExpPgBar.prototype, "bgColor", {
        set: function (color) {
            this.rect_bg.fillColor = color;
        },
        enumerable: true,
        configurable: true
    });
    return ExpPgBar;
}(eui.Component));
__reflect(ExpPgBar.prototype, "ExpPgBar", ["eui.UIComponent", "egret.DisplayObject"]);
window['ExpPgBar'] = ExpPgBar;
//# sourceMappingURL=ExpPgBar.js.map