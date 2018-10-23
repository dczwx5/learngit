var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var SkinManager = (function () {
    function SkinManager() {
        this._skinId = 0;
        this.dg_SkinChanged = new VL.Delegate();
    }
    SkinManager.prototype.getCardColor = function (cardCfg) {
        return SkinConfigHelper.getCardColor(this.skinId, cardCfg);
    };
    SkinManager.prototype.getCardImg = function (cardCfg) {
        return SkinConfigHelper.getCardImg(this.skinId, cardCfg);
    };
    SkinManager.prototype.getLvColor = function (lv) {
        return SkinConfigHelper.getLvColor(this.skinId, lv);
    };
    Object.defineProperty(SkinManager.prototype, "skinId", {
        get: function () {
            if (!this._skinId) {
                var cache = egret.localStorage.getItem("skinId_" + this._uid);
                if (!cache || cache.length == 0) {
                    cache = "1";
                }
                this._skinId = parseInt(cache);
            }
            return this._skinId;
        },
        set: function (value) {
            if (value == this._skinId) {
                return;
            }
            this._skinId = value;
            egret.localStorage.setItem("skinId_" + this._uid, this._skinId.toString());
            this.dg_SkinChanged.boardcast({ skinId: this._skinId });
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(SkinManager.prototype, "uid", {
        set: function (value) {
            this._uid = value;
        },
        enumerable: true,
        configurable: true
    });
    return SkinManager;
}());
__reflect(SkinManager.prototype, "SkinManager");
//# sourceMappingURL=SkinManager.js.map