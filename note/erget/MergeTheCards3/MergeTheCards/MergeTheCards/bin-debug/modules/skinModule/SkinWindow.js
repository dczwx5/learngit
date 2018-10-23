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
var SkinWindow = (function (_super) {
    __extends(SkinWindow, _super);
    function SkinWindow() {
        var _this = _super.call(this, "SkinWindowSkin") || this;
        _this.resources = [];
        return _this;
    }
    SkinWindow.prototype.updateLayout = function () {
        if (this._centerH) {
            this.x = StageUtils.getStageWidth() - this.width >> 1;
        }
        if (this._centerV) {
            this.y = (StageUtils.getStageHeight() - this.height >> 1) - 70;
        }
        this.updateMask();
    };
    SkinWindow.prototype.onInit = function () {
        this.dGroup_cardSkins.itemRenderer = CardSkinItemRenderer;
    };
    SkinWindow.prototype.onDestroy = function () {
    };
    return SkinWindow;
}(App.BaseWindow));
__reflect(SkinWindow.prototype, "SkinWindow");
//# sourceMappingURL=SkinWindow.js.map