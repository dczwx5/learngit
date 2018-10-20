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
var CardGroupDropCtrl = (function (_super) {
    __extends(CardGroupDropCtrl, _super);
    function CardGroupDropCtrl() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    CardGroupDropCtrl.prototype.checkEnableDrop = function (dragItem) {
        if (this.cardGroup.cardCount < PublicConfigHelper.MAX_GROUP_CARDS_COUNT) {
            return true;
        }
        else {
            return this.cardGroup.lastCard.cfg.value == dragItem.cfg.value;
        }
    };
    Object.defineProperty(CardGroupDropCtrl.prototype, "cardGroup", {
        get: function () {
            return this._container;
        },
        enumerable: true,
        configurable: true
    });
    return CardGroupDropCtrl;
}(DropCardContainerCtrl));
__reflect(CardGroupDropCtrl.prototype, "CardGroupDropCtrl");
//# sourceMappingURL=CardGroupDropCtrl.js.map