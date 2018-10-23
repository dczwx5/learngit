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
var HandCardMediator = (function (_super) {
    __extends(HandCardMediator, _super);
    function HandCardMediator() {
        var _this = _super.call(this) || this;
        _this.gap = 110;
        _this._handCards = [];
        return _this;
    }
    HandCardMediator.prototype.activate = function (grp_HandCard) {
        this.grp_HandCard = grp_HandCard;
        this.regMsg(BattleMsg.feedBack.UnshiftNewHandCard, this.onUnshiftNewHandCardHandler, this);
        this.regMsg(BattleMsg.feedBack.CurrCardAppendedToGroup, this.onCardAppended, this);
        this.regMsg(BattleMsg.feedBack.AbandonedCurrHandCard, this.onAbandonedCurrHandCard, this);
        this.regMsg(BattleMsg.feedBack.RefreshedHandCards, this.onRefreshedHandCards, this);
        this.updateByData();
    };
    HandCardMediator.prototype.deactivate = function () {
        this.unregMsg(BattleMsg.feedBack.UnshiftNewHandCard, this.onUnshiftNewHandCardHandler, this);
        this.unregMsg(BattleMsg.feedBack.CurrCardAppendedToGroup, this.onCardAppended, this);
        this.unregMsg(BattleMsg.feedBack.AbandonedCurrHandCard, this.onAbandonedCurrHandCard, this);
        this.unregMsg(BattleMsg.feedBack.RefreshedHandCards, this.onRefreshedHandCards, this);
        this.grp_HandCard = null;
    };
    HandCardMediator.prototype.updateByData = function () {
        var cards = this._handCards;
        while (cards.length > 0) {
            cards.pop().restore();
        }
        var arrCardsCfg = this.battleModel.handCardList;
        var card;
        for (var i = 0, l = arrCardsCfg.length; i < l; i++) {
            card = create(Card).init(arrCardsCfg[i], this.getModel(PlayerModel).skinMng);
            card.x = i * this.gap;
            this._handCards.push(card);
            this.grp_HandCard.addChild(card);
        }
        this.setLastCardDragable();
    };
    HandCardMediator.prototype.onRefreshedHandCards = function (msg) {
        while (this._handCards.length > 0) {
            this._handCards.pop().restore();
        }
        var cardCfgs = msg.body.cards;
        var card;
        for (var i = cardCfgs.length - 1; i >= 0; i--) {
            card = create(Card).init(cardCfgs[i], this.getModel(PlayerModel).skinMng);
            this.unshiftNewCard(card);
        }
    };
    HandCardMediator.prototype.onAbandonedCurrHandCard = function (msg) {
        var card = this._handCards.pop();
        card.restore();
    };
    HandCardMediator.prototype.onCardAppended = function (msg) {
        var card = this._handCards.pop();
        card.restore();
    };
    HandCardMediator.prototype.onUnshiftNewHandCardHandler = function (msg) {
        var card = create(Card).init(msg.body.card, this.getModel(PlayerModel).skinMng);
        // this._handCards.unshift(card);
        // this.grp_HandCard.addChildAt(card, 0);
        // egret.Tween.get(this.lastCard)
        //     .to({x:this.gap * (this._handCards.length-1)}, 300)
        //     .call(()=>{
        //         this.setLastCardDragable();
        //     });
        this.unshiftNewCard(card);
    };
    HandCardMediator.prototype.unshiftNewCard = function (card) {
        var _this = this;
        this._handCards.unshift(card);
        this.grp_HandCard.addChildAt(card, 0);
        if (this._handCards.length == 1) {
            card.x = 0;
            this.setLastCardDragable();
        }
        else {
            egret.Tween.get(this.lastCard)
                .to({ x: this.gap * (this._handCards.length - 1) }, 300)
                .call(function () {
                _this.setLastCardDragable();
            });
        }
    };
    Object.defineProperty(HandCardMediator.prototype, "battleModel", {
        get: function () {
            return this.getModel(BattleModel);
        },
        enumerable: true,
        configurable: true
    });
    HandCardMediator.prototype.setLastCardDragable = function () {
        app.dragDropManager.regDragItem(this.lastCard);
    };
    Object.defineProperty(HandCardMediator.prototype, "lastCard", {
        get: function () {
            return this._handCards[this._handCards.length - 1];
        },
        enumerable: true,
        configurable: true
    });
    return HandCardMediator;
}(VoyaMVC.Mediator));
__reflect(HandCardMediator.prototype, "HandCardMediator");
//# sourceMappingURL=HandCardMediator.js.map