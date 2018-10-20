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
var BattleRecordMediator = (function (_super) {
    __extends(BattleRecordMediator, _super);
    function BattleRecordMediator() {
        var _this = _super !== null && _super.apply(this, arguments) || this;
        _this._isActive = false;
        return _this;
    }
    BattleRecordMediator.prototype.activate = function (panel) {
        this._isActive = true;
        this.panel = panel;
        this.regMsg(BattleMsg.feedBack.CardMerged, this.onCardMerged, this);
        this.regMsg(BattleMsg.feedBack.CardGroupReset, this.onCardGroupReset, this);
        this.regMsg(BattleMsg.feedBack.NewGame, this.onNewGame, this);
        this.updateByData();
    };
    BattleRecordMediator.prototype.deactivate = function () {
        this.unregMsg(BattleMsg.feedBack.CardMerged, this.onCardMerged, this);
        this.unregMsg(BattleMsg.feedBack.CardGroupReset, this.onCardGroupReset, this);
        this.unregMsg(BattleMsg.feedBack.NewGame, this.onNewGame, this);
        this.panel = null;
        this._isActive = false;
    };
    BattleRecordMediator.prototype.updateByData = function () {
        var panel = this.panel;
        var battleModel = this.getModel(BattleModel);
        var playerModel = this.getModel(PlayerModel);
        panel.updateSkin(playerModel.skinId);
        this._currScore = panel.currScore = battleModel.currScore;
        panel.currExp = battleModel.exp;
        panel.highScore = playerModel.highScore;
        this.panel.scoreMultiple = battleModel.scoreMultiple;
    };
    BattleRecordMediator.prototype.onNewGame = function (msg) {
        this.updateByData();
    };
    BattleRecordMediator.prototype.onCardMerged = function (msg) {
        var scoreList = msg.body.scoreList;
        app.log("scoreList:", scoreList);
        this.addSubScore(scoreList, 0);
    };
    BattleRecordMediator.prototype.onCardGroupReset = function (msg) {
        this.panel.scoreMultiple = this.getModel(BattleModel).scoreMultiple;
    };
    BattleRecordMediator.prototype.addSubScore = function (scoreList, currIdx) {
        // if(currIdx >= scoreList.length){
        //     return;
        // }
        if (!this._isActive) {
            return;
        }
        var battleModel = this.getModel(BattleModel);
        var playerModel = this.getModel(PlayerModel);
        var scoreAdd = scoreList[currIdx];
        var currScore = this._currScore += scoreAdd;
        this.panel.currScore = currScore;
        if (currScore >= playerModel.highScore) {
            this.panel.highScore = currScore;
        }
        this.panel.currExp = Math.min(Math.max(battleModel.baseExp + currScore), LvConfigHelper.getExpByLv(LvConfigHelper.maxLv) - 1);
        if (++currIdx >= scoreList.length) {
            return;
        }
        egret.setTimeout(this.addSubScore, this, 450, scoreList, currIdx);
    };
    return BattleRecordMediator;
}(VoyaMVC.Mediator));
__reflect(BattleRecordMediator.prototype, "BattleRecordMediator");
//# sourceMappingURL=BattleRecordMediator.js.map