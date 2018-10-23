var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var CardConfigHelper = (function () {
    function CardConfigHelper() {
    }
    CardConfigHelper.getNormalCardByValue = function (value) {
        var cfgTable = app.config.getConfig(CardConfig);
        var cfg;
        for (var key in cfgTable) {
            cfg = cfgTable[key];
            if (cfg.type == Enum_CardType.NORMAL && cfg.value == value) {
                return cfg;
            }
        }
        return null;
    };
    Object.defineProperty(CardConfigHelper, "maxValueCard", {
        get: function () {
            if (!this._maxValueCard) {
                var normalCards = this.getCardsByType(Enum_CardType.NORMAL);
                var maxValue = 0, card = void 0;
                for (var i = 0, l = normalCards.length; i < l; i++) {
                    card = normalCards[i];
                    if (card.value > maxValue) {
                        maxValue = card.value;
                        this._maxValueCard = card;
                    }
                }
            }
            return this._maxValueCard;
        },
        enumerable: true,
        configurable: true
    });
    CardConfigHelper.getCardsByType = function (type) {
        var result = this._cardsByType[type];
        if (result) {
            return result;
        }
        var cfgTable = app.config.getConfig(CardConfig);
        var cfg;
        result = [];
        for (var key in cfgTable) {
            cfg = cfgTable[key];
            if (cfg.type == type) {
                result.push(cfg);
                if (type != Enum_CardType.NORMAL) {
                    break;
                }
            }
        }
        Object.freeze(result);
        this._cardsByType[type] = result;
        return result;
    };
    CardConfigHelper._cardsByType = {};
    return CardConfigHelper;
}());
__reflect(CardConfigHelper.prototype, "CardConfigHelper");
//# sourceMappingURL=CardConfigHelper.js.map