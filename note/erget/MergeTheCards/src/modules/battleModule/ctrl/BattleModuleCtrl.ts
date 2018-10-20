class BattleModuleCtrl extends VoyaMVC.Controller {

    activate() {
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
    }

    deactivate() {
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
    }

    private onEnterBattleHandler(msg: BattleMsg.cmd.EnterBattle) {
        this.battleModel.newGame(this.playerModel.lv);
        this.sendMsg(create(BattleMsg.cmd.OpenBattleView));
    }

    private async onAppendHandCardToGroup(msg: BattleMsg.cmd.AppendHandCardToGroup) {
        let battleModel = this.battleModel;
        let group = battleModel.getCardGroupByIdx(msg.body.groupId);
        let card = msg.body.card;
        switch (card.cfg.type) {
            case Enum_CardType.NORMAL:
                group.appendCard(battleModel.handCardList.pop());
                group.mergCard();
                let isGameOver = battleModel.checkGameOver();
                battleModel.unshiftNewHandCard();
                if (isGameOver) {
                    this.saveBattleRecord();
                    if (battleModel.rebirthEnable) {
                        this.sendMsg(create(BattleMsg.cmd.OpenRebirthWindow).init({onClose:()=>{
                            this.sendMsg(create(BattleMsg.cmd.CloseBattleView));
                            this.sendMsg(create(BattleMsg.cmd.OpenBattleSettleView));
                        }}));
                    } else {
                        this.sendMsg(create(BattleMsg.cmd.CloseBattleView));
                        this.sendMsg(create(BattleMsg.cmd.OpenBattleSettleView));
                    }
                }
                break;
            case Enum_CardType.BOMB:

                break;
        }
    }

    private onDropCurrCardToRubbishBin(msg: BattleMsg.cmd.DropCurrCardToRubbishBin) {
        this.battleModel.abandonCurrHandCard();
    }

    private onClearOneRubbishCell(msg: BattleMsg.cmd.ClearOneRubbishCell) {
        let model = this.battleModel;
        if (model.rubbishCount > 0) {
            //分享先再清理垃圾
            if (model.clearRubbishCellChance > 0 && !this.getModel(WxSDKModel).isExamine) {
                this.sendMsg(create(WxSdkMsg.Share));
                egret.setTimeout(() => {
                    model.removeOneRubbish();
                }, this, 3000);
            }
        }
    }

    private onRefreshHandCard(msg: BattleMsg.cmd.RefreshHandCard) {
        let model = this.battleModel;
        if (model.enableRefreshAllHandCards) {
            model.refreshAllHandCards();
        } else {
            //如果有重置刷新手牌机会次数
            if(model.resetRefreshHandCardChanceChance > 0){
                //看视频先再加刷新次数
                this.sendMsg(create(WxSdkMsg.WatchVideo_CMD).init({
                    flag: Enum_WxWatchVideoFlag.REFRESH_HAND_CARD,
                    showAlertWhenGiveUp: false
                }));
            }
        }
    }

    private async onPlayAgain(msg: BattleMsg.cmd.PlayAgain) {
        this.saveBattleRecord();
        this.battleModel.newGame(this.playerModel.lv);
    }

    private onBackToMainView(msg: BattleMsg.cmd.BackToMainView) {
        this.saveBattleRecord();
        this.sendMsg(create(BattleMsg.cmd.CloseBattleView));
        this.sendMsg(create(MainModuleMsg.OpenMainView));
    }

    private onRebirth(msg: BattleMsg.cmd.Rebirth){
        this.sendMsg(create(WxSdkMsg.WatchVideo_CMD).init({
            flag: Enum_WxWatchVideoFlag.REBIRTH,
            showAlertWhenGiveUp: false
        }));
    }

    private onLvUp(msg: BattleMsg.feedBack.LvUp) {
        let battleModel = this.battleModel;
        // battleModel.removeAllRubbish();
        battleModel.resetClearRubbishBinChance();
        if (!battleModel.enableRefreshAllHandCards) {
            battleModel.resetRefreshHandCardChance();
        }
        battleModel.resetResetRefreshHandCardChanceChance();

        let playerModel = this.playerModel;
        playerModel.lv = battleModel.currLv;

        playerModel.saveBattleRecord(battleModel.currLv, battleModel.currScore);
    }

    private onWxWatchVideoResult(msg: WxSdkMsg.WatchVideo_FeedBack) {
        let flag = msg.body.flag;
        let result = msg.body.result;
        let error = msg.body.error;
        let battleModel = this.battleModel;
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
                this.sendMsg(create(PopupMsg.ShowPopup).init({content:'今日广告奖励机会已耗尽，无法享受相应福利',showClose:true}));
                break;
            }
            case Enum_WxWatchVideoResult.GIVE_UP:{
                // this.sendMsg(create(PopupMsg.ShowPopup).init({content:'今日广告奖励机会已耗尽，无法享受相应福利',showClose:true}));
                break;
            }
        }
    }

    private saveBattleRecord(){
        let playerModel = this.playerModel;
        let battleModel = this.battleModel;
        playerModel.saveBattleRecord(battleModel.currLv, battleModel.currScore);
    }

    private get battleModel(): BattleModel {
        return this.getModel(BattleModel);
    }

    private get playerModel(): PlayerModel {
        return this.getModel(PlayerModel);
    }
}
