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
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = y[op[0] & 2 ? "return" : op[0] ? "throw" : "next"]) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [0, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var BattleViewMediator = (function (_super) {
    __extends(BattleViewMediator, _super);
    function BattleViewMediator() {
        var _this = _super.call(this) || this;
        _this._groupReset = -1;
        _this._handCardMediator = new HandCardMediator();
        _this._recordMediator = new BattleRecordMediator();
        return _this;
    }
    BattleViewMediator.prototype.onViewOpen = function () {
        var view = this.view;
        view.rect_bg.fillColor = SkinConfigHelper.getGameBgColor(this.getModel(PlayerModel).skinId);
        var groupCount = PublicConfigHelper.CARD_GROUP_COUNT;
        var group;
        var skinMng = this.getModel(PlayerModel).skinMng;
        for (var i = 0; i < groupCount; i++) {
            group = view.getCardGroup(i);
            group.activate(i, skinMng);
            group.dg_onDropIn.register(this.onCardDropToGroup, this);
        }
        view.rubbishBin.activate(this.getModel(PlayerModel).skinId);
        this._handCardMediator.activate(view.grp_handCards);
        this._recordMediator.activate(view.battlePanel);
        view.rubbishBin.dg_onDropIn.register(this.onCardDropToRubbishBin, this);
        EventHelper.addTapEvent(view.rubbishBin, this.onTap, this);
        EventHelper.addTapEvent(view.btn_refreshHandCard, this.onTap, this);
        EventHelper.addTapEvent(view.btn_menu, this.onTap, this);
        EventHelper.addTapEvent(view.btn_help, this.onTap, this);
        this.regMsg(BattleMsg.feedBack.NewGame, this.onNewGame, this);
        this.regMsg(BattleMsg.feedBack.CardGroupReset, this.onCardGroupReset, this);
        this.regMsg(BattleMsg.feedBack.CurrCardAppendedToGroup, this.onCurrCardAppendedToGroup, this);
        this.regMsg(BattleMsg.feedBack.CardMerged, this.onCardMerged, this);
        this.regMsg(BattleMsg.feedBack.AbandonedCurrHandCard, this.onAbandonedCurrHandCard, this);
        this.regMsg(BattleMsg.feedBack.RubbishCountChanged, this.onRubbishCountChanged, this);
        this.regMsg(BattleMsg.feedBack.RefreshedHandCards, this.onRefreshedHandCards, this);
        this.regMsg(BattleMsg.feedBack.RefreshedHandCardsChanceChanged, this.onRefreshedHandCardsChanceChanged, this);
        this.regMsg(BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged, this.onResetRefreshedHandCardsChanceChanceChanged, this);
        this.regMsg(BattleMsg.feedBack.ClearRubbishCellChanceChanged, this.onClearRubbishCellChanceChanged, this);
        this.regMsg(BattleMsg.feedBack.Rebirth, this.onRebirth, this);
        this.updateByData();
    };
    BattleViewMediator.prototype.onViewClose = function () {
        var view = this.view;
        var groupCount = PublicConfigHelper.CARD_GROUP_COUNT;
        var group;
        for (var i = 0; i < groupCount; i++) {
            group = view.getCardGroup(i);
            group.dg_onDropIn.unregister(this.onCardDropToGroup);
            group.deactivate();
        }
        view.rubbishBin.deactivate();
        this._handCardMediator.deactivate();
        this._recordMediator.deactivate();
        view.rubbishBin.dg_onDropIn.unregister(this.onCardDropToRubbishBin);
        EventHelper.removeTapEvent(view.rubbishBin, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_refreshHandCard, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_menu, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_help, this.onTap, this);
        this.unregMsg(BattleMsg.feedBack.NewGame, this.onNewGame, this);
        this.unregMsg(BattleMsg.feedBack.CardGroupReset, this.onCardGroupReset, this);
        this.unregMsg(BattleMsg.feedBack.CurrCardAppendedToGroup, this.onCurrCardAppendedToGroup, this);
        this.unregMsg(BattleMsg.feedBack.CardMerged, this.onCardMerged, this);
        this.unregMsg(BattleMsg.feedBack.AbandonedCurrHandCard, this.onAbandonedCurrHandCard, this);
        this.unregMsg(BattleMsg.feedBack.RubbishCountChanged, this.onRubbishCountChanged, this);
        this.unregMsg(BattleMsg.feedBack.RefreshedHandCards, this.onRefreshedHandCards, this);
        this.unregMsg(BattleMsg.feedBack.RefreshedHandCardsChanceChanged, this.onRefreshedHandCardsChanceChanged, this);
        this.unregMsg(BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged, this.onResetRefreshedHandCardsChanceChanceChanged, this);
        this.unregMsg(BattleMsg.feedBack.ClearRubbishCellChanceChanged, this.onClearRubbishCellChanceChanged, this);
        this.unregMsg(BattleMsg.feedBack.Rebirth, this.onRebirth, this);
    };
    BattleViewMediator.prototype.updateByData = function () {
        var battleModel = this.battleModel;
        var view = this.view;
        //-----------更新牌组------------
        var skinMng = this.getModel(PlayerModel).skinMng;
        var groupCount = PublicConfigHelper.CARD_GROUP_COUNT;
        var groupModel;
        var group;
        var cardCfgs;
        var card;
        for (var i = 0; i < groupCount; i++) {
            group = view.getCardGroup(i);
            group.removeAllCards();
            groupModel = battleModel.getCardGroupByIdx(i);
            cardCfgs = groupModel.cardList;
            for (var j = 0, jl = cardCfgs.length; j < jl; j++) {
                card = create(Card).init(cardCfgs[i], skinMng);
                group.appendCard(card);
            }
        }
        view.btn_refreshHandCard.enableRefresh = this.battleModel.refreshHandCardChance > 0;
        this.updateRubbishBin();
    };
    BattleViewMediator.prototype.onTap = function (e) {
        var view = this.view;
        switch (e.currentTarget) {
            case view.rubbishBin:
                this.sendMsg(create(BattleMsg.cmd.ClearOneRubbishCell));
                break;
            case view.btn_refreshHandCard:
                this.sendMsg(create(BattleMsg.cmd.RefreshHandCard));
                break;
            case view.btn_menu:
                this.sendMsg(create(BattleMsg.cmd.OpenBattleMenu));
                break;
            case view.btn_help:
                this.sendMsg(create(HelpModuleMsg.OPEN_HELP_VIEW));
                break;
        }
    };
    BattleViewMediator.prototype.onCardDropToRubbishBin = function (data) {
        this.sendMsg(create(BattleMsg.cmd.DropCurrCardToRubbishBin).init({ card: data.dragItem }));
    };
    BattleViewMediator.prototype.onCardDropToGroup = function (data) {
        var group = data.container;
        this.sendMsg(create(BattleMsg.cmd.AppendHandCardToGroup).init({ groupId: group.groupId, card: data.dragItem }));
    };
    BattleViewMediator.prototype.onCardMerged = function (msg) {
        return __awaiter(this, void 0, void 0, function () {
            var group, cards, scoreList, i;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        group = this.view.getCardGroup(msg.body.groupIdx);
                        cards = msg.body.distCards;
                        scoreList = msg.body.scoreList;
                        i = 0;
                        _a.label = 1;
                    case 1:
                        if (!(i < cards.length)) return [3 /*break*/, 4];
                        return [4 /*yield*/, group.mergeCard(cards[i], scoreList[i])];
                    case 2:
                        if (_a.sent()) {
                            return [3 /*break*/, 4];
                        }
                        _a.label = 3;
                    case 3:
                        i++;
                        return [3 /*break*/, 1];
                    case 4:
                        if (!(this._groupReset == group.groupId)) return [3 /*break*/, 6];
                        return [4 /*yield*/, group.removeAllCardsAsync()];
                    case 5:
                        _a.sent();
                        this._groupReset = -1;
                        _a.label = 6;
                    case 6: return [2 /*return*/];
                }
            });
        });
    };
    BattleViewMediator.prototype.onCurrCardAppendedToGroup = function (msg) {
        // let card = msg.body.card;
        var group = this.view.getCardGroup(msg.body.groupIdx);
        // let card = create(Card).init(msg.body.card, this.getModel(SkinModel).skinMng);
        var card = create(Card).init(msg.body.card, this.getModel(PlayerModel).skinMng);
        group.appendCard(card);
    };
    BattleViewMediator.prototype.onNewGame = function (msg) {
        // this.updateRubbishBin();
        // this.updateRefreshHandCardsChance();
    };
    BattleViewMediator.prototype.onCardGroupReset = function (msg) {
        var groupIdx = msg.body.groupIdx;
        var reason = msg.body.reason;
        switch (reason) {
            case Enum_ResetCardGroupReason.NEW_GAME:
                this.view.getCardGroup(groupIdx).removeAllCards();
                break;
            case Enum_ResetCardGroupReason.MAX_CARD_VALUE:
                this._groupReset = groupIdx;
                break;
        }
    };
    BattleViewMediator.prototype.onAbandonedCurrHandCard = function (msg) {
        this.updateRubbishBin();
    };
    BattleViewMediator.prototype.onRubbishCountChanged = function (msg) {
        this.updateRubbishBin();
    };
    BattleViewMediator.prototype.onClearRubbishCellChanceChanged = function (msg) {
        this.updateRubbishBin();
    };
    BattleViewMediator.prototype.updateRubbishBin = function () {
        var rubbishBin = this.view.rubbishBin;
        var battleModel = this.battleModel;
        var wxModel = this.getModel(WxSDKModel);
        rubbishBin.rubbishCount = battleModel.rubbishCount;
        rubbishBin.clearCellChance = wxModel.isExamine ? 0 : battleModel.clearRubbishCellChance;
    };
    BattleViewMediator.prototype.onRefreshedHandCards = function (msg) {
        this.updateRefreshHandCardsChance();
    };
    BattleViewMediator.prototype.onRefreshedHandCardsChanceChanged = function (msg) {
        this.updateRefreshHandCardsChance();
    };
    BattleViewMediator.prototype.onResetRefreshedHandCardsChanceChanceChanged = function (msg) {
        this.updateRefreshHandCardsChance();
    };
    BattleViewMediator.prototype.updateRefreshHandCardsChance = function () {
        this.view.btn_refreshHandCard.enableRefresh = this.battleModel.enableRefreshAllHandCards;
        this.view.btn_refreshHandCard.enableReset = this.battleModel.resetRefreshHandCardChanceChance > 0;
    };
    BattleViewMediator.prototype.onRebirth = function (msg) {
        var removeCardsCount = PublicConfigHelper.MAX_GROUP_CARDS_COUNT >> 1;
        for (var i = 0, l = PublicConfigHelper.CARD_GROUP_COUNT; i < l; i++) {
            this.view.getCardGroup(i).removeCards(removeCardsCount);
        }
    };
    Object.defineProperty(BattleViewMediator.prototype, "viewClass", {
        get: function () {
            return BattleView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleViewMediator.prototype, "openViewMsg", {
        get: function () {
            return BattleMsg.cmd.OpenBattleView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleViewMediator.prototype, "closeViewMsg", {
        get: function () {
            return BattleMsg.cmd.CloseBattleView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleViewMediator.prototype, "battleModel", {
        get: function () {
            return this.getModel(BattleModel);
        },
        enumerable: true,
        configurable: true
    });
    return BattleViewMediator;
}(ViewMediator));
__reflect(BattleViewMediator.prototype, "BattleViewMediator");
//# sourceMappingURL=BattleViewMediator.js.map