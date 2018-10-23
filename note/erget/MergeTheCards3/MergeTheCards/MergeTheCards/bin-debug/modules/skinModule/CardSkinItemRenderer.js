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
var CardSkinItemRenderer = (function (_super) {
    __extends(CardSkinItemRenderer, _super);
    // public rect_bg: eui.Rect;
    // public icon_locked: eui.Image;
    // public rect_statusBg: eui.Rect;
    // public lb_status: eui.Label;
    function CardSkinItemRenderer() {
        var _this = _super.call(this) || this;
        _this.cardValueList = [64, 32, 16, 8, 4, 2];
        return _this;
    }
    CardSkinItemRenderer.prototype.childrenCreated = function () {
        _super.prototype.childrenCreated.call(this);
        this.touchChildren = false;
        this.touchEnabled = true;
        var cardValueList = this.cardValueList;
        var value;
        for (var i = 0, l = 6; i < l; i++) {
            value = cardValueList[i];
            this.getCardValueLbByIdx(i).text = value.toString();
        }
        this.grp_cards.mask = this.rect_mask;
    };
    CardSkinItemRenderer.prototype.dataChanged = function () {
        var _this = this;
        _super.prototype.dataChanged.call(this);
        var data = this.data;
        if (data.playerLv >= data.skinCfg.unlockLv) {
            if (data.isSelected) {
                this.currentState = CardSkinItemRenderer.STATUS_USING;
            }
            else {
                this.currentState = CardSkinItemRenderer.STATUS_ENABLED;
            }
            var cardValueList = this.cardValueList;
            for (var i = 0, l = 6; i < l; i++) {
                this.getCardBgByIdx(i).fillColor = SkinConfigHelper.getCardColor(data.skinCfg.Id, CardConfigHelper.getNormalCardByValue(cardValueList[i]));
            }
        }
        else {
            this.currentState = CardSkinItemRenderer.STATUS_DISABLED;
            egret.setTimeout(function () {
                _this.lb_status.text = data.skinCfg.unlockLv + "\u7EA7\u89E3\u9501";
            }, this, 20);
        }
    };
    CardSkinItemRenderer.prototype.getCardBgByIdx = function (idx) {
        return this['rect_cardBg' + idx];
    };
    CardSkinItemRenderer.prototype.getCardValueLbByIdx = function (idx) {
        return this['lb_cardValue' + idx];
    };
    CardSkinItemRenderer.STATUS_USING = "using";
    CardSkinItemRenderer.STATUS_ENABLED = "enabled";
    CardSkinItemRenderer.STATUS_DISABLED = "disabled";
    return CardSkinItemRenderer;
}(eui.ItemRenderer));
__reflect(CardSkinItemRenderer.prototype, "CardSkinItemRenderer", ["eui.UIComponent", "egret.DisplayObject"]);
window['CardSkinItemRenderer'] = CardSkinItemRenderer;
//# sourceMappingURL=CardSkinItemRenderer.js.map