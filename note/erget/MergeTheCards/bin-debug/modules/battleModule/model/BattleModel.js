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
var BattleModel = (function (_super) {
    __extends(BattleModel, _super);
    function BattleModel() {
        var _this = _super.call(this) || this;
        _this._handCardList = [];
        _this._cardGroupList = [];
        var group;
        for (var i = 0; i < PublicConfigHelper.CARD_GROUP_COUNT; i++) {
            group = new CardGroupModel(i);
            group.dg_cardsMerged.register(_this.onCardMerged, _this);
            _this._cardGroupList.push(group);
        }
        return _this;
    }
    BattleModel.prototype.newGame = function (playerLv) {
        this._score = 0;
        this._baseExp = LvConfigHelper.getExpByLv(playerLv);
        this._scoreMultiple = 1;
        this._rebirthChance = 1;
        // this._rubbishCount = 0;
        // this._clearRubbishCellChance = PublicConfigHelper.MAX_RUBBISH_COUNT;
        this.removeAllRubbish();
        this.resetClearRubbishBinChance();
        for (var i = 0, l = this._cardGroupList.length; i < l; i++) {
            this._cardGroupList[i].reset(Enum_ResetCardGroupReason.NEW_GAME);
        }
        this.refreshAllHandCards();
        this._refreshHandCardChance = PublicConfigHelper.INITIAL_REFRESH_HAND_CARD_CHANCE;
        this.resetResetRefreshHandCardChanceChance();
        this.sendMsg(create(BattleMsg.feedBack.NewGame));
    };
    /**
     * 生成一张新牌加入手牌列表后面
     * @returns 新进的牌
     */
    BattleModel.prototype.unshiftNewHandCard = function () {
        if (this._handCardList.length < 2) {
            var cfg = this.getRandomCard();
            this._handCardList.unshift(cfg);
            this.sendMsg(create(BattleMsg.feedBack.UnshiftNewHandCard).init({ card: cfg }));
            return cfg;
        }
        else {
            return null;
        }
    };
    BattleModel.prototype.getRandomCard = function () {
        var cfgs = app.config.getConfig(CardConfig);
        var cfg;
        var lv = this.currLv;
        var cardPool = [];
        var weight = 0;
        for (var key in cfgs) {
            cfg = cfgs[key];
            // if (lv >= cfg.unlock) {//TODO: 配置文件将特殊牌权值改为0后用这行代码
            if (lv >= cfg.unlock && cfg.type == Enum_CardType.NORMAL) {
                weight += cfg.weight;
                cardPool.push({ lessThan: weight, cfg: cfg });
            }
        }
        Utils.ArrayUtils.quickSort(cardPool, function (a, b) {
            return a.lessThan - b.lessThan;
        });
        var random = Math.random() * weight;
        for (var i = 0, l = cardPool.length; i < l; i++) {
            if (random <= cardPool[i].lessThan) {
                return cardPool[i].cfg;
            }
        }
        return null;
    };
    Object.defineProperty(BattleModel.prototype, "enableAbandonCurrHandCard", {
        //------------------------垃圾桶------------------------Begin
        /**是否能将当前卡牌丢到垃圾桶*/
        get: function () {
            return this._rubbishCount < PublicConfigHelper.MAX_RUBBISH_COUNT;
        },
        enumerable: true,
        configurable: true
    });
    /**
     * 将当前手牌丢到垃圾桶
     */
    BattleModel.prototype.abandonCurrHandCard = function () {
        if (!this.enableAbandonCurrHandCard) {
            return false;
        }
        this._handCardList.pop();
        this._rubbishCount++;
        this.sendMsg(create(BattleMsg.feedBack.AbandonedCurrHandCard));
        this.unshiftNewHandCard();
        return true;
    };
    BattleModel.prototype.removeOneRubbish = function () {
        if (this._rubbishCount > 0) {
            --this._rubbishCount;
            --this._clearRubbishCellChance;
            this.sendMsg(create(BattleMsg.feedBack.RubbishCountChanged).init({ remainRubbishCount: this._rubbishCount }));
        }
        return this._rubbishCount;
    };
    BattleModel.prototype.removeAllRubbish = function () {
        this._rubbishCount = 0;
        this.sendMsg(create(BattleMsg.feedBack.RubbishCountChanged).init({ remainRubbishCount: this._rubbishCount }));
    };
    /**
     * 重置清理垃圾桶次数
     */
    BattleModel.prototype.resetClearRubbishBinChance = function () {
        this._clearRubbishCellChance = PublicConfigHelper.MAX_RUBBISH_COUNT;
        this.sendMsg(create(BattleMsg.feedBack.ClearRubbishCellChanceChanged).init({ chanceCount: this._clearRubbishCellChance }));
    };
    Object.defineProperty(BattleModel.prototype, "clearRubbishCellChance", {
        get: function () {
            return this._clearRubbishCellChance;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModel.prototype, "rubbishCount", {
        get: function () {
            return this._rubbishCount;
        },
        enumerable: true,
        configurable: true
    });
    //------------------------垃圾桶------------------------End
    //------------------------刷新所有手牌------------------------Begin
    /**
     * 重置刷新手牌机会
     */
    BattleModel.prototype.resetRefreshHandCardChance = function () {
        this._refreshHandCardChance = PublicConfigHelper.INITIAL_REFRESH_HAND_CARD_CHANCE;
        this.sendMsg(create(BattleMsg.feedBack.RefreshedHandCardsChanceChanged).init({ chanceCount: this._refreshHandCardChance }));
    };
    /**
     * 消耗一次 重置 刷新手牌机会 次数
     */
    BattleModel.prototype.costResetRefreshHandCardChanceChance = function () {
        this._resetRefreshHandCardChanceChance--;
        this.sendMsg(create(BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged).init({ chanceCount: this._resetRefreshHandCardChanceChance }));
    };
    /**
     * 重置 刷新手牌机会 次数
     */
    BattleModel.prototype.resetResetRefreshHandCardChanceChance = function () {
        this._resetRefreshHandCardChanceChance = 1;
        this.sendMsg(create(BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged).init({ chanceCount: this._resetRefreshHandCardChanceChance }));
    };
    /**
     * 刷新所有手牌
     */
    BattleModel.prototype.refreshAllHandCards = function () {
        this._refreshHandCardChance--;
        for (var i = 0; i < PublicConfigHelper.MAX_HAND_CARD_COUNT; i++) {
            this._handCardList[i] = this.getRandomCard();
        }
        this.sendMsg(create(BattleMsg.feedBack.RefreshedHandCards).init({ cards: this._handCardList }));
        return true;
    };
    Object.defineProperty(BattleModel.prototype, "refreshHandCardChance", {
        /**剩余的刷新手牌机会*/
        get: function () {
            return this._refreshHandCardChance;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModel.prototype, "enableRefreshAllHandCards", {
        get: function () {
            return this._refreshHandCardChance > 0;
        },
        enumerable: true,
        configurable: true
    });
    //------------------------刷新所有手牌------------------------End
    BattleModel.prototype.onCardMerged = function (data) {
        var cards = data.distCards;
        var arrScore = this.calculateAddScore(cards);
        this.addScore(arrScore);
        //合成2048
        if (cards[cards.length - 1].value == CardConfigHelper.maxValueCard.value) {
            this.scoreMultiple++;
            this.getCardGroupByIdx(data.groupIdx).reset(Enum_ResetCardGroupReason.MAX_CARD_VALUE);
            this.resetClearRubbishBinChance();
            this.resetRefreshHandCardChance();
            this.resetResetRefreshHandCardChanceChance();
        }
        this.sendMsg(create(BattleMsg.feedBack.CardMerged).init({ groupIdx: data.groupIdx, distCards: cards, scoreList: arrScore }));
    };
    BattleModel.prototype.calculateAddScore = function (distCards) {
        // 每次合成得分=总面值*（连击数+1）*（合成最大面值次数+1）
        // 设，合成过2次2048，即合成最大面值次数为2；
        // 第一步，32+32，连击数为0，该次合成得分=（32+32）*（0+1）*（2+1）=192
        // 第二步，64+64，连击数为1，该次合成得分=（64+64）*（1+1）*（2+1）=768
        // 第三步，128+128，连击数为2，该次合成得分=（128+128）*（2+1）*（2+1）=2304
        // 总得分=192+768+2304=3264
        var scoreList = [];
        for (var i = 0, l = distCards.length; i < l; i++) {
            scoreList.push(distCards[i].value * (i + 1) * this.scoreMultiple);
        }
        return scoreList;
    };
    BattleModel.prototype.addScore = function (scoreList) {
        var tempLv = this.currLv;
        for (var i = 0; i < scoreList.length; i++) {
            this._score += scoreList[i];
        }
        var currLv = this.currLv;
        if (currLv > tempLv) {
            this.sendMsg(create(BattleMsg.feedBack.LvUp).init({ currLv: currLv }));
        }
        app.log("currScore:", this._score);
        // this.sendMsg(create(BattleMsg.feedBack.ScoreChanged).init({ currScore: this._score, scoreList:scoreList }));
    };
    //------------------------游戏结束--------------------------Begin
    BattleModel.prototype.checkGameOver = function () {
        var group;
        var isOver = true;
        for (var i = 0, l = this._cardGroupList.length; i < l; i++) {
            group = this._cardGroupList[i];
            if (group.cardsCount < PublicConfigHelper.MAX_GROUP_CARDS_COUNT) {
                isOver = false;
            }
        }
        return isOver;
    };
    BattleModel.prototype.rebirth = function () {
        this._rebirthChance--;
        var group;
        var cardsRemain = PublicConfigHelper.MAX_GROUP_CARDS_COUNT >> 1;
        for (var i = 0, l = PublicConfigHelper.CARD_GROUP_COUNT; i < l; i++) {
            group = this.getCardGroupByIdx(i);
            if (group.cardList.length > cardsRemain) {
                group.cardList.length = cardsRemain;
            }
        }
        this.sendMsg(create(BattleMsg.feedBack.Rebirth));
    };
    Object.defineProperty(BattleModel.prototype, "rebirthEnable", {
        get: function () {
            return this._rebirthChance > 0;
        },
        enumerable: true,
        configurable: true
    });
    //------------------------游戏结束--------------------------End
    /**
     * 获取牌组
     * @param idx
     * @returns {CardGroupModel}
     */
    BattleModel.prototype.getCardGroupByIdx = function (idx) {
        return this._cardGroupList[idx];
    };
    Object.defineProperty(BattleModel.prototype, "currScore", {
        get: function () {
            return this._score;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModel.prototype, "currLv", {
        get: function () {
            var lv = LvConfigHelper.getLvByExp(this.exp);
            if (lv == LvConfigHelper.maxLv) {
                lv -= 1;
            }
            return lv;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModel.prototype, "baseExp", {
        get: function () {
            return this._baseExp;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModel.prototype, "exp", {
        get: function () {
            return Math.min(Math.max(this._baseExp + this._score, 0), LvConfigHelper.getExpByLv(LvConfigHelper.maxLv) - 1);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModel.prototype, "scoreMultiple", {
        // set score(value: number) {
        //     this._score = value;
        //     this.sendMsg(create(BattleMsg.feedBack.ScoreChanged).init({ currScore:value }));
        // }
        get: function () {
            return this._scoreMultiple;
        },
        set: function (value) {
            this._scoreMultiple = value;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModel.prototype, "currHandCard", {
        get: function () {
            return this._handCardList[this._handCardList.length - 1];
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModel.prototype, "handCardList", {
        get: function () {
            return this._handCardList;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModel.prototype, "resetRefreshHandCardChanceChance", {
        /**重置 刷新手牌机会 的次数*/
        get: function () {
            return this._resetRefreshHandCardChanceChance;
        },
        enumerable: true,
        configurable: true
    });
    return BattleModel;
}(VoyaMVC.Model));
__reflect(BattleModel.prototype, "BattleModel");
//# sourceMappingURL=BattleModel.js.map