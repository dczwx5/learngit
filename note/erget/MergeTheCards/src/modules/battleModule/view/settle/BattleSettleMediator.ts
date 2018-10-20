class BattleSettleMediator extends ViewMediator{

    protected view: BattleSettleView;

    protected onViewOpen() {
        let view = this.view;
        let battleModel = this.getModel(BattleModel);
        let playerModel = this.getModel(PlayerModel);
        view.lb_lv.text = `等级 ${playerModel.lv}`;
        view.lb_highScore.text = Utils.NumberToUnitStringUtil.convert(playerModel.highScore);
        view.lb_battleScore.text = Utils.NumberToUnitStringUtil.convert(battleModel.currScore);

        EventHelper.addTapEvent(view.btn_playAgain, this.onTap, this);
        EventHelper.addTapEvent(view.btn_backHome, this.onTap, this);

        this.sendMsg(create(WxSdkMsg.ShowBannerAd));
    }

    protected onViewClose() {
        let view = this.view;
        EventHelper.removeTapEvent(view.btn_playAgain, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_backHome, this.onTap, this);

        this.sendMsg(create(WxSdkMsg.HideBannerAd));
    }

    private onTap(e:egret.TouchEvent){
        let view = this.view;
        switch (e.currentTarget){
            case view.btn_playAgain:
                this.sendMsg(create(BattleMsg.cmd.PlayAgain));
                this.sendMsg(create(BattleMsg.cmd.OpenBattleView));
                this.sendMsg(create(BattleMsg.cmd.CloseBattleSettleView));
                break;
            case view.btn_backHome:
                this.sendMsg(create(BattleMsg.cmd.BackToMainView));
                this.sendMsg(create(BattleMsg.cmd.CloseBattleSettleView));
                break;
        }

    }

    protected get viewClass():  new()=>BattleSettleView  {
        return BattleSettleView;
    }

    protected get openViewMsg():  new()=>BattleMsg.cmd.OpenBattleSettleView  {
        return BattleMsg.cmd.OpenBattleSettleView;
    }

    protected get closeViewMsg():  new()=>BattleMsg.cmd.CloseBattleSettleView  {
        return BattleMsg.cmd.CloseBattleSettleView;
    }
}