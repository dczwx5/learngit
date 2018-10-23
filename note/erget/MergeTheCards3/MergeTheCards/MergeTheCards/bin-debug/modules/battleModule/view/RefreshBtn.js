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
var RefreshBtn = (function (_super) {
    __extends(RefreshBtn, _super);
    function RefreshBtn() {
        var _this = _super.call(this) || this;
        _this.needRefresh = false;
        _this.touchEnabled = true;
        _this.touchChildren = false;
        return _this;
    }
    RefreshBtn.prototype.updateShow = function () {
        var _this = this;
        if (!this.needRefresh) {
            this.needRefresh = true;
            egret.callLater(function () {
                if (_this.enableRefresh) {
                    _this.icon_playVideo.visible = false;
                    _this.icon_refresh.visible = true;
                    _this.rect_bg.fillColor = 0x00ff00;
                }
                else {
                    _this.icon_playVideo.visible = true;
                    _this.icon_refresh.visible = false;
                    _this.rect_bg.fillColor = 0xff0000;
                    if (_this.enableReset) {
                        _this.icon_playVideo.source = "icon_playVideo_png";
                    }
                    else {
                        _this.icon_playVideo.source = "icon_disable_png";
                    }
                }
                _this.needRefresh = false;
            }, this);
        }
    };
    Object.defineProperty(RefreshBtn.prototype, "enableRefresh", {
        get: function () {
            return this._enableRefresh;
        },
        set: function (value) {
            this._enableRefresh = value;
            this.updateShow();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(RefreshBtn.prototype, "enableReset", {
        get: function () {
            return this._enableReset;
        },
        set: function (value) {
            this._enableReset = value;
            this.updateShow();
        },
        enumerable: true,
        configurable: true
    });
    return RefreshBtn;
}(eui.Component));
__reflect(RefreshBtn.prototype, "RefreshBtn", ["eui.UIComponent", "egret.DisplayObject"]);
window["RefreshBtn"] = RefreshBtn;
//# sourceMappingURL=RefreshBtn.js.map