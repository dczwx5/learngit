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
var LvBlock = (function (_super) {
    __extends(LvBlock, _super);
    function LvBlock() {
        var _this = _super.call(this) || this;
        _this._lv = 1;
        _this._skinId = 1;
        _this._isReady = false;
        _this.touchChildren = _this.touchEnabled = false;
        return _this;
    }
    LvBlock.prototype.childrenCreated = function () {
        _super.prototype.childrenCreated.call(this);
        this._isReady = true;
        this.updateShow();
    };
    LvBlock.prototype.updateShow = function () {
        if (!this._isReady) {
            return;
        }
        this.rect_bg.fillColor = SkinConfigHelper.getLvColor(this._skinId, this.lv);
        this.lb_lv.text = this.lv.toString();
    };
    Object.defineProperty(LvBlock.prototype, "lv", {
        get: function () {
            return this._lv;
        },
        set: function (value) {
            this._lv = value;
            this.updateShow();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LvBlock.prototype, "skinId", {
        set: function (value) {
            this._skinId = value;
            this.updateShow();
        },
        enumerable: true,
        configurable: true
    });
    return LvBlock;
}(eui.Component));
__reflect(LvBlock.prototype, "LvBlock", ["eui.UIComponent", "egret.DisplayObject"]);
window['LvBlock'] = LvBlock;
//# sourceMappingURL=LvBlock.js.map