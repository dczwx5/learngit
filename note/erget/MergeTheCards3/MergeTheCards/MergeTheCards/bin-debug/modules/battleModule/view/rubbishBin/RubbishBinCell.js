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
var RubbishBinCell = (function (_super) {
    __extends(RubbishBinCell, _super);
    function RubbishBinCell() {
        var _this = _super.call(this) || this;
        _this._isEmpty = true;
        _this._isReady = false;
        _this._skinId = 1;
        _this._enableClear = false;
        _this.needUpdate = false;
        _this.skinName = "RubbishBinCellSkin";
        _this.touchChildren = false;
        _this.touchEnabled = true;
        return _this;
    }
    RubbishBinCell.prototype.childrenCreated = function () {
        _super.prototype.childrenCreated.call(this);
        this._isReady = true;
        this.updateIcon();
    };
    RubbishBinCell.prototype.updateIcon = function () {
        var _this = this;
        if (!this._isReady) {
            return;
        }
        if (!this.needUpdate) {
            this.needUpdate = true;
            egret.callLater(function () {
                if (_this._isEmpty) {
                    // this.img_icon.source = "icon_rubbishBin_png";
                    _this.img_icon.source = "icon_rubbishBinDropable_png";
                    _this.rect_bg.fillColor = SkinConfigHelper.getRubbishCellBgColor(_this._skinId);
                }
                else {
                    if (_this._enableClear) {
                        // this.img_icon.source = "icon_playVideo_png";
                        // this.img_icon.source = "icon_share_png";
                        _this.img_icon.source = "icon_clearRubbishBin_png";
                    }
                    else {
                        // this.img_icon.source = "icon_disable_png";
                        _this.img_icon.source = "icon_rubbishBin_disable_png";
                    }
                    _this.rect_bg.fillColor = SkinConfigHelper.getRubbishCellForeColor(_this._skinId);
                }
                _this.needUpdate = false;
            }, this);
        }
    };
    Object.defineProperty(RubbishBinCell.prototype, "isEmpty", {
        get: function () {
            return this._isEmpty;
        },
        set: function (value) {
            if (this._isEmpty == value) {
                return;
            }
            this._isEmpty = value;
            this.updateIcon();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(RubbishBinCell.prototype, "skinId", {
        get: function () {
            return this._skinId;
        },
        set: function (value) {
            this._skinId = value;
            this.updateIcon();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(RubbishBinCell.prototype, "enableClear", {
        get: function () {
            return this._enableClear;
        },
        set: function (value) {
            this._enableClear = value;
            this.updateIcon();
        },
        enumerable: true,
        configurable: true
    });
    return RubbishBinCell;
}(eui.Component));
__reflect(RubbishBinCell.prototype, "RubbishBinCell", ["eui.UIComponent", "egret.DisplayObject"]);
window['RubbishBinCell'] = RubbishBinCell;
//# sourceMappingURL=RubbishBinCell.js.map