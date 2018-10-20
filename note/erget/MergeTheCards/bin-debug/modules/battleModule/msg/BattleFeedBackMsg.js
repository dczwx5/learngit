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
var BattleMsg;
(function (BattleMsg) {
    var feedBack;
    (function (feedBack) {
        var NewGame = (function (_super) {
            __extends(NewGame, _super);
            function NewGame() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return NewGame;
        }(VoyaMVC.Msg));
        feedBack.NewGame = NewGame;
        __reflect(NewGame.prototype, "BattleMsg.feedBack.NewGame");
        /**
         * 卡牌发生合并
         * 牌组
         */
        var CardMerged = (function (_super) {
            __extends(CardMerged, _super);
            function CardMerged() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return CardMerged;
        }(VoyaMVC.Msg));
        feedBack.CardMerged = CardMerged;
        __reflect(CardMerged.prototype, "BattleMsg.feedBack.CardMerged");
        /**
         * 手牌加入了牌组
         * 牌组 放入的牌
         */
        var CurrCardAppendedToGroup = (function (_super) {
            __extends(CurrCardAppendedToGroup, _super);
            function CurrCardAppendedToGroup() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return CurrCardAppendedToGroup;
        }(VoyaMVC.Msg));
        feedBack.CurrCardAppendedToGroup = CurrCardAppendedToGroup;
        __reflect(CurrCardAppendedToGroup.prototype, "BattleMsg.feedBack.CurrCardAppendedToGroup");
        /**
         * 重置了某个牌组
         * 牌组 原因
         */
        var CardGroupReset = (function (_super) {
            __extends(CardGroupReset, _super);
            function CardGroupReset() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return CardGroupReset;
        }(VoyaMVC.Msg));
        feedBack.CardGroupReset = CardGroupReset;
        __reflect(CardGroupReset.prototype, "BattleMsg.feedBack.CardGroupReset");
        /**
         * 手牌加入了一张卡牌
         * 新牌
         */
        var UnshiftNewHandCard = (function (_super) {
            __extends(UnshiftNewHandCard, _super);
            function UnshiftNewHandCard() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return UnshiftNewHandCard;
        }(VoyaMVC.Msg));
        feedBack.UnshiftNewHandCard = UnshiftNewHandCard;
        __reflect(UnshiftNewHandCard.prototype, "BattleMsg.feedBack.UnshiftNewHandCard");
        /**
         * 刷新所有手牌
         * 新的手牌们
         */
        var RefreshedHandCards = (function (_super) {
            __extends(RefreshedHandCards, _super);
            function RefreshedHandCards() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return RefreshedHandCards;
        }(VoyaMVC.Msg));
        feedBack.RefreshedHandCards = RefreshedHandCards;
        __reflect(RefreshedHandCards.prototype, "BattleMsg.feedBack.RefreshedHandCards");
        /**
         * 刷新手牌次数变更
         */
        var RefreshedHandCardsChanceChanged = (function (_super) {
            __extends(RefreshedHandCardsChanceChanged, _super);
            function RefreshedHandCardsChanceChanged() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return RefreshedHandCardsChanceChanged;
        }(VoyaMVC.Msg));
        feedBack.RefreshedHandCardsChanceChanged = RefreshedHandCardsChanceChanged;
        __reflect(RefreshedHandCardsChanceChanged.prototype, "BattleMsg.feedBack.RefreshedHandCardsChanceChanged");
        /**
         * 重置 刷新手牌机会 的次数变更
         */
        var ResetRefreshedHandCardsChanceChanceChanged = (function (_super) {
            __extends(ResetRefreshedHandCardsChanceChanceChanged, _super);
            function ResetRefreshedHandCardsChanceChanceChanged() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return ResetRefreshedHandCardsChanceChanceChanged;
        }(VoyaMVC.Msg));
        feedBack.ResetRefreshedHandCardsChanceChanceChanged = ResetRefreshedHandCardsChanceChanceChanged;
        __reflect(ResetRefreshedHandCardsChanceChanceChanged.prototype, "BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged");
        /**
         * 清理垃圾桶次数变更
         */
        var ClearRubbishCellChanceChanged = (function (_super) {
            __extends(ClearRubbishCellChanceChanged, _super);
            function ClearRubbishCellChanceChanged() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return ClearRubbishCellChanceChanged;
        }(VoyaMVC.Msg));
        feedBack.ClearRubbishCellChanceChanged = ClearRubbishCellChanceChanged;
        __reflect(ClearRubbishCellChanceChanged.prototype, "BattleMsg.feedBack.ClearRubbishCellChanceChanged");
        /**
         * 当前手牌被丢弃
         */
        var AbandonedCurrHandCard = (function (_super) {
            __extends(AbandonedCurrHandCard, _super);
            function AbandonedCurrHandCard() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return AbandonedCurrHandCard;
        }(VoyaMVC.Msg));
        feedBack.AbandonedCurrHandCard = AbandonedCurrHandCard;
        __reflect(AbandonedCurrHandCard.prototype, "BattleMsg.feedBack.AbandonedCurrHandCard");
        /**
         * 垃圾桶移除了一张卡牌
         * 垃圾桶剩余卡牌数
         */
        var RubbishCountChanged = (function (_super) {
            __extends(RubbishCountChanged, _super);
            function RubbishCountChanged() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return RubbishCountChanged;
        }(VoyaMVC.Msg));
        feedBack.RubbishCountChanged = RubbishCountChanged;
        __reflect(RubbishCountChanged.prototype, "BattleMsg.feedBack.RubbishCountChanged");
        /**
         * 升级了
         */
        var LvUp = (function (_super) {
            __extends(LvUp, _super);
            function LvUp() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return LvUp;
        }(VoyaMVC.Msg));
        feedBack.LvUp = LvUp;
        __reflect(LvUp.prototype, "BattleMsg.feedBack.LvUp");
        /**
         * 复活了
         */
        var Rebirth = (function (_super) {
            __extends(Rebirth, _super);
            function Rebirth() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return Rebirth;
        }(VoyaMVC.Msg));
        feedBack.Rebirth = Rebirth;
        __reflect(Rebirth.prototype, "BattleMsg.feedBack.Rebirth");
    })(feedBack = BattleMsg.feedBack || (BattleMsg.feedBack = {}));
})(BattleMsg || (BattleMsg = {}));
//# sourceMappingURL=BattleFeedBackMsg.js.map