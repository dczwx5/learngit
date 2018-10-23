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
var CardGroupModel = (function (_super) {
    __extends(CardGroupModel, _super);
    function CardGroupModel(groupIdx) {
        var _this = _super.call(this) || this;
        _this._cardList = [];
        _this.dg_cardsMerged = new VL.Delegate();
        _this.groupIdx = groupIdx;
        return _this;
    }
    /**
     * 添加一张卡牌
     * @param card
     */
    CardGroupModel.prototype.appendCard = function (card) {
        if (this.cardList.length >= PublicConfigHelper.MAX_GROUP_CARDS_COUNT) {
            switch (card.type) {
                case Enum_CardType.NORMAL:
                case Enum_CardType.BOMB:
                    if (card.value != this.lastCard.value) {
                        return false;
                    }
                    break;
            }
        }
        this._cardList.push(card);
        this.sendMsg(create(BattleMsg.feedBack.CurrCardAppendedToGroup).init({ groupIdx: this.groupIdx, card: card }));
        return true;
    };
    /**
     * 合并所有能合并的卡牌
     * @returns {CardConfig[]} 合并完成后的卡牌
     */
    CardGroupModel.prototype.mergCard = function () {
        var distCards = [];
        var card;
        while (true) {
            card = this.checkMergeCard();
            if (card) {
                switch (card.type) {
                    case Enum_CardType.NORMAL: {
                        // case Enum_CardType.UNIVERSAL:{
                        distCards.push(card);
                        break;
                    }
                    case Enum_CardType.BOMB: {
                        while (this.cardList.length > 0) {
                            var distCard = this.cardList.pop();
                            if (distCard.type == Enum_CardType.UNIVERSAL) {
                                distCard = CardConfigHelper.getNormalCardByValue(card.value);
                            }
                            distCards.push(distCard);
                        }
                        break;
                    }
                }
            }
            else {
                if (distCards.length > 0) {
                    this.dg_cardsMerged.boardcast({ groupIdx: this.groupIdx, distCards: distCards });
                }
                break;
            }
        }
        return distCards;
    };
    /**
     * 合并一张卡牌
     * @returns {CardConfig}
     */
    CardGroupModel.prototype.checkMergeCard = function () {
        var list = this._cardList;
        if (list.length >= 2) {
            var from = this.lastCard;
            var to = this.lastButOneCard;
            var distCard = void 0;
            if (to.type == Enum_CardType.NORMAL && (to.value == from.value || from.type == Enum_CardType.UNIVERSAL)) {
                if ((from.type == Enum_CardType.NORMAL)
                    || from.type == Enum_CardType.UNIVERSAL) {
                    distCard = CardConfigHelper.getNormalCardByValue(to.value << 1);
                    if (distCard) {
                        list[list.length - 2] = distCard;
                        list.pop();
                    }
                    return distCard;
                }
                else if (from.type == Enum_CardType.BOMB) {
                    return from;
                }
            }
            else if (to.type == Enum_CardType.BOMB && (to.value == from.value || from.type == Enum_CardType.UNIVERSAL)) {
                return to;
            }
            else if (to.type == Enum_CardType.UNIVERSAL) {
                if (from.type == Enum_CardType.NORMAL) {
                    distCard = CardConfigHelper.getNormalCardByValue(from.value << 1);
                    list[list.length - 2] = distCard;
                    list.pop();
                    return distCard;
                }
                else if (from.type == Enum_CardType.UNIVERSAL) {
                    return null;
                }
                else if (from.type == Enum_CardType.BOMB) {
                    return from;
                }
            }
            return null;
        }
        else {
            return null;
        }
    };
    CardGroupModel.prototype.reset = function (reason) {
        var remainCards = [];
        while (this._cardList.length > 0) {
            remainCards.push(this._cardList.pop());
        }
        this.sendMsg(create(BattleMsg.feedBack.CardGroupReset).init({ groupIdx: this.groupIdx, reason: reason }));
    };
    Object.defineProperty(CardGroupModel.prototype, "cardList", {
        get: function () {
            return this._cardList;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(CardGroupModel.prototype, "cardsCount", {
        get: function () {
            return this._cardList.length;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(CardGroupModel.prototype, "lastButOneCard", {
        get: function () {
            return this._cardList[this._cardList.length - 2];
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(CardGroupModel.prototype, "lastCard", {
        get: function () {
            return this._cardList[this._cardList.length - 1];
        },
        enumerable: true,
        configurable: true
    });
    return CardGroupModel;
}(VoyaMVC.Model));
__reflect(CardGroupModel.prototype, "CardGroupModel");
//# sourceMappingURL=CardGroupModel.js.map