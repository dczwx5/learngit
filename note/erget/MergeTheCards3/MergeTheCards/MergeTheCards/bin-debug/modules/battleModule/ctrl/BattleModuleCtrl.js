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
var BattleModuleCtrl = (function (_super) {
    __extends(BattleModuleCtrl, _super);
    function BattleModuleCtrl() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    BattleModuleCtrl.prototype.activate = function () {
        this.regMsg(BattleMsg.cmd.EnterBattle, this.onEnterBattleHandler, this);
        this.regMsg(BattleMsg.cmd.AppendHandCardToGroup, this.onAppendHandCardToGroup, this);
        this.regMsg(BattleMsg.cmd.DropCurrCardToRubbishBin, this.onDropCurrCardToRubbishBin, this);
        this.regMsg(BattleMsg.cmd.ClearOneRubbishCell, this.onClearOneRubbishCell, this);
        this.regMsg(BattleMsg.cmd.RefreshHandCard, this.onRefreshHandCard, this);
        this.regMsg(BattleMsg.cmd.PlayAgain, this.onPlayAgain, this);
        this.regMsg(BattleMsg.cmd.BackToMainView, this.onBackToMainView, this);
        this.regMsg(BattleMsg.cmd.Rebirth, this.onRebirth, this);
        this.regMsg(BattleMsg.feedBack.LvUp, this.onLvUp, this);
        this.regMsg(WxSdkMsg.WatchVideo_FeedBack, this.onWxWatchVideoResult, this);
    };
    BattleModuleCtrl.prototype.deactivate = function () {
        this.unregMsg(BattleMsg.cmd.EnterBattle, this.onEnterBattleHandler, this);
        this.unregMsg(BattleMsg.cmd.AppendHandCardToGroup, this.onAppendHandCardToGroup, this);
        this.unregMsg(BattleMsg.cmd.DropCurrCardToRubbishBin, this.onDropCurrCardToRubbishBin, this);
        this.unregMsg(BattleMsg.cmd.ClearOneRubbishCell, this.onClearOneRubbishCell, this);
        this.unregMsg(BattleMsg.cmd.RefreshHandCard, this.onRefreshHandCard, this);
        this.unregMsg(BattleMsg.cmd.PlayAgain, this.onPlayAgain, this);
        this.unregMsg(BattleMsg.cmd.BackToMainView, this.onBackToMainView, this);
        this.unregMsg(BattleMsg.cmd.Rebirth, this.onRebirth, this);
        this.unregMsg(BattleMsg.feedBack.LvUp, this.onLvUp, this);
        this.unregMsg(WxSdkMsg.WatchVideo_FeedBack, this.onWxWatchVideoResult, this);
    };
    BattleModuleCtrl.prototype.onEnterBattleHandler = function (msg) {
        this.battleModel.newGame(this.playerModel.lv);
        this.sendMsg(create(BattleMsg.cmd.OpenBattleView));
    };
    BattleModuleCtrl.prototype.onAppendHandCardToGroup = function (msg) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            var battleModel, group, isGameOver;
            return __generator(this, function (_a) {
                battleModel = this.battleModel;
                group = battleModel.getCardGroupByIdx(msg.body.groupId);
                // let card = msg.body.card;
                // switch (card.cfg.type) {
                //     case Enum_CardType.NORMAL:
                group.appendCard(battleModel.handCardList.pop());
                group.mergCard();
                isGameOver = battleModel.checkGameOver();
                battleModel.unshiftNewHandCard();
                if (isGameOver) {
                    this.saveBattleRecord();
                    if (battleModel.rebirthEnable) {
                        this.sendMsg(create(BattleMsg.cmd.OpenRebirthWindow).init({ onClose: function () {
                                _this.sendMsg(create(BattleMsg.cmd.CloseBattleView));
                                _this.sendMsg(create(BattleMsg.cmd.OpenBattleSettleView));
                            } }));
                    }
                    else {
                        this.sendMsg(create(BattleMsg.cmd.CloseBattleView));
                        this.sendMsg(create(BattleMsg.cmd.OpenBattleSettleView));
                    }
                    // }
                    // break;
                    // case Enum_CardType.BOMB:
                    //
                    //     break;
                }
                return [2 /*return*/];
            });
        });
    };
    BattleModuleCtrl.prototype.onDropCurrCardToRubbishBin = function (msg) {
        this.battleModel.abandonCurrHandCard();
    };
    BattleModuleCtrl.prototype.onClearOneRubbishCell = function (msg) {
        var model = this.battleModel;
        if (model.rubbishCount > 0) {
            //分享先再清理垃圾
            if (model.clearRubbishCellChance > 0 && !this.getModel(WxSDKModel).isExamine) {
                this.sendMsg(create(WxSdkMsg.Share));
                egret.setTimeout(function () {
                    model.removeOneRubbish();
                }, this, 3000);
            }
        }
    };
    BattleModuleCtrl.prototype.onRefreshHandCard = function (msg) {
        var model = this.battleModel;
        if (model.enableRefreshAllHandCards) {
            model.refreshAllHandCards();
        }
        else {
            //如果有重置刷新手牌机会次数
            if (model.resetRefreshHandCardChanceChance > 0) {
                //看视频先再加刷新次数
                this.sendMsg(create(WxSdkMsg.WatchVideo_CMD).init({
                    flag: Enum_WxWatchVideoFlag.REFRESH_HAND_CARD,
                    showAlertWhenGiveUp: false
                }));
            }
        }
    };
    BattleModuleCtrl.prototype.onPlayAgain = function (msg) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this.saveBattleRecord();
                this.battleModel.newGame(this.playerModel.lv);
                return [2 /*return*/];
            });
        });
    };
    BattleModuleCtrl.prototype.onBackToMainView = function (msg) {
        this.saveBattleRecord();
        this.sendMsg(create(BattleMsg.cmd.CloseBattleView));
        this.sendMsg(create(MainModuleMsg.OpenMainView));
    };
    BattleModuleCtrl.prototype.onRebirth = function (msg) {
        this.sendMsg(create(WxSdkMsg.WatchVideo_CMD).init({
            flag: Enum_WxWatchVideoFlag.REBIRTH,
            showAlertWhenGiveUp: false
        }));
    };
    BattleModuleCtrl.prototype.onLvUp = function (msg) {
        var battleModel = this.battleModel;
        // battleModel.removeAllRubbish();
        battleModel.resetClearRubbishBinChance();
        if (!battleModel.enableRefreshAllHandCards) {
            battleModel.resetRefreshHandCardChance();
        }
        battleModel.resetResetRefreshHandCardChanceChance();
        var playerModel = this.playerModel;
        playerModel.lv = battleModel.currLv;
        playerModel.saveBattleRecord(battleModel.currLv, battleModel.currScore);
    };
    BattleModuleCtrl.prototype.onWxWatchVideoResult = function (msg) {
        var flag = msg.body.flag;
        var result = msg.body.result;
        var error = msg.body.error;
        var battleModel = this.battleModel;
        switch (result) {
            case Enum_WxWatchVideoResult.COMPLETE: {
                app.appHttp.sendWatchTVStep(flag, 2, null, null);
                switch (flag) {
                    case Enum_WxWatchVideoFlag.REFRESH_HAND_CARD:
                        // battleModel.costResetRefreshHandCardChanceChance();
                        battleModel.resetRefreshHandCardChance();
                        break;
                    case Enum_WxWatchVideoFlag.REBIRTH:
                        battleModel.rebirth();
                        this.sendMsg(create(BattleMsg.cmd.CloseRebirthWindow));
                        break;
                }
                break;
            }
            case Enum_WxWatchVideoResult.NO_AD_COUNT: {
                this.sendMsg(create(PopupMsg.ShowPopup).init({ content: '今日广告奖励机会已耗尽，无法享受相应福利', showClose: true }));
                break;
            }
            case Enum_WxWatchVideoResult.GIVE_UP: {
                // this.sendMsg(create(PopupMsg.ShowPopup).init({content:'今日广告奖励机会已耗尽，无法享受相应福利',showClose:true}));
                break;
            }
        }
    };
    BattleModuleCtrl.prototype.saveBattleRecord = function () {
        var playerModel = this.playerModel;
        var battleModel = this.battleModel;
        playerModel.saveBattleRecord(battleModel.currLv, battleModel.currScore);
    };
    Object.defineProperty(BattleModuleCtrl.prototype, "battleModel", {
        get: function () {
            return this.getModel(BattleModel);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleModuleCtrl.prototype, "playerModel", {
        get: function () {
            return this.getModel(PlayerModel);
        },
        enumerable: true,
        configurable: true
    });
    return BattleModuleCtrl;
}(VoyaMVC.Controller));
__reflect(BattleModuleCtrl.prototype, "BattleModuleCtrl");
//# sourceMappingURL=BattleModuleCtrl.js.map