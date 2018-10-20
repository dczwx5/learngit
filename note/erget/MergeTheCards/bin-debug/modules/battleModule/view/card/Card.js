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
var Card = (function (_super) {
    __extends(Card, _super);
    function Card() {
        var _this = _super.call(this) || this;
        _this._isChildCreated = false;
        _this.skinName = "CardSkin";
        _this.touchChildren = false;
        _this.dragItemCtrl = new DragCardCtrl(_this);
        return _this;
    }
    Card.prototype.childrenCreated = function () {
        _super.prototype.childrenCreated.call(this);
        this._isChildCreated = true;
        this.updateByData();
    };
    Card.prototype.updateByData = function () {
        var cfg = this.cfg;
        if (cfg) {
            if (cfg.value == 2) {
                app.log("cardCfg:", cfg);
            }
            this.lb_value.text = this.cfg.value.toString();
            var color = this._skinMng.getCardColor(this.cfg);
            var bgUrl = this._skinMng.getCardImg(this.cfg);
            var bg = bgUrl.length > 0 ? app.resManager.getRes(bgUrl) : null;
            if (bg) {
                this.img_bg.source = bg;
                this.img_bg.visible = true;
                this.rect_bg.visible = false;
            }
            else {
                this.rect_bg.fillColor = color;
                this.img_bg.visible = false;
                this.rect_bg.visible = true;
            }
        }
        else {
            this.lb_value.text = "";
            this.rect_bg.fillColor = 0;
            this.img_bg.source = null;
            this.img_bg.visible = false;
            this.rect_bg.visible = true;
        }
    };
    Card.prototype.init = function (cfg, skinMng) {
        this._skinMng = skinMng;
        this._skinMng.dg_SkinChanged.register(this.onSkinChanged, this);
        this.cfg = cfg;
        return this;
    };
    Card.prototype.onSkinChanged = function (param) {
        this.updateByData();
    };
    Card.prototype.clear = function () {
        this._skinMng.dg_SkinChanged.unregister(this.onSkinChanged);
        this._skinMng = null;
        this.cfg = null;
        app.dragDropManager.unregDragItem(this);
        this.x = this.y = 0;
        if (this.parent) {
            this.parent.removeChild(this);
        }
    };
    Card.prototype.restore = function (maxCacheCount) {
        if (maxCacheCount === void 0) { maxCacheCount = Card.MAX_CACHE_COUNT; }
        restore(this, maxCacheCount);
    };
    Object.defineProperty(Card.prototype, "cfg", {
        get: function () {
            return this._cfg;
        },
        set: function (value) {
            if (this._cfg == value) {
                return;
            }
            this._cfg = value;
            if (this._isChildCreated) {
                this.updateByData();
            }
        },
        enumerable: true,
        configurable: true
    });
    Card.MAX_CACHE_COUNT = 35;
    return Card;
}(eui.Component));
__reflect(Card.prototype, "Card", ["VL.ObjectCache.ICacheable", "VL.DragDrop.IDragItem"]);
window['Card'] = Card;
//# sourceMappingURL=Card.js.map