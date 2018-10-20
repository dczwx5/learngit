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
            return this._skinId;
        },
        set: function (value) {
            if (value == this._skinId) {
                return;
            }
            this._skinId = value;
            this.dg_SkinChanged.boardcast({ skinId: this._skinId });
        },
        enumerable: true,
        configurable: true
    });
    return SkinManager;
}());
__reflect(SkinManager.prototype, "SkinManager");
//# sourceMappingURL=SkinManager.js.map