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
var MainView = (function (_super) {
    __extends(MainView, _super);
    function MainView() {
        return _super.call(this, "MainViewSkin") || this;
    }
    MainView.prototype.onInit = function () {
        _super.prototype.onInit.call(this);
        this.sp_bg = new egret.Shape();
        var bg = this.sp_bg;
        bg.width = this.width;
        bg.height = this.height;
        var mt = this.bgMatrix = new egret.Matrix();
        mt.rotate(90);
        //this.drawBg();
        this.addChildAt(bg, 0);
    };
    MainView.prototype.updateLayout = function () {
        _super.prototype.updateLayout.call(this);
        this.drawBg();
    };
    MainView.prototype.drawBg = function () {
        var bg = this.sp_bg;
        bg.width = this.width;
        bg.height = this.height;
        var g = this.sp_bg.graphics;
        g.clear();
        g.beginGradientFill(GradientType.LINEAR, [0x8963C3, 0xD893FF], [1, 1], [0, 255], this.bgMatrix);
        g.drawRect(0, 0, bg.width, bg.height);
        g.endFill();
    };
    MainView.prototype.open = function () {
        _super.prototype.open.call(this);
    };
    MainView.prototype.close = function () {
        _super.prototype.close.call(this);
    };
    MainView.prototype.getWxOtherGameIcon = function (idx) {
        return this['wxOtherGameIcon' + idx];
    };
    MainView.prototype.onDestroy = function () {
    };
    Object.defineProperty(MainView.prototype, "resources", {
        get: function () {
            return [];
        },
        enumerable: true,
        configurable: true
    });
    return MainView;
}(App.BaseAutoSizeView));
__reflect(MainView.prototype, "MainView");
//# sourceMappingURL=MainView.js.map