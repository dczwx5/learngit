class BattleRecordMediator extends VoyaMVC.Mediator{

    private panel:BattleRecordPanel;

    private _currScore:number;

    private _isActive:boolean = false;

    activate(panel:BattleRecordPanel) {
        this._isActive = true;
        this.panel = panel;

        this.regMsg(BattleMsg.feedBack.CardMerged, this.onCardMerged, this);
        this.regMsg(BattleMsg.feedBack.CardGroupReset, this.onCardGroupReset, this);
        this.regMsg(BattleMsg.feedBack.NewGame, this.onNewGame, this);

        this.updateByData();

    }

    deactivate() {
        this.unregMsg(BattleMsg.feedBack.CardMerged, this.onCardMerged, this);
        this.unregMsg(BattleMsg.feedBack.CardGroupReset, this.onCardGroupReset, this);
        this.unregMsg(BattleMsg.feedBack.NewGame, this.onNewGame, this);

        this.panel = null;
        this._isActive = false;
    }

    private updateByData(){
        let panel = this.panel;
        let battleModel = this.getModel(BattleModel);
        let playerModel = this.getModel(PlayerModel);
        panel.updateSkin(playerModel.skinId);
        this._currScore = panel.currScore = battleModel.currScore;
        panel.currExp = battleModel.exp;
        panel.highScore = playerModel.highScore;
        this.panel.scoreMultiple = battleModel.scoreMultiple;
    }

    private onNewGame(msg:BattleMsg.feedBack.NewGame){
        this.updateByData();
    }

    private onCardMerged(msg:BattleMsg.feedBack.CardMerged){
        let scoreList = msg.body.scoreList;
        app.log(`scoreList:`, scoreList);
        this.addSubScore(scoreList, 0);
    }

    private onCardGroupReset(msg:BattleMsg.feedBack.CardGroupReset){
        this.panel.scoreMultiple = this.getModel(BattleModel).scoreMultiple;
    }

    private addSubScore(scoreList:number[], currIdx:number){
        // if(currIdx >= scoreList.length){
        //     return;
        // }
        if(!this._isActive){
            return;
        }

        let battleModel = this.getModel(BattleModel);
        let playerModel = this.getModel(PlayerModel);

        let scoreAdd = scoreList[currIdx];

        let currScore = this._currScore += scoreAdd;
        this.panel.currScore = currScore;
        if(currScore >= playerModel.highScore){
            this.panel.highScore = currScore;
        }
        this.panel.currExp = Math.min(Math.max(battleModel.baseExp + currScore), LvConfigHelper.getExpByLv(LvConfigHelper.maxLv)-1);

        if(++currIdx >= scoreList.length){
            return;
        }
        egret.setTimeout(this.addSubScore, this, 450, scoreList, currIdx);
    }
}
