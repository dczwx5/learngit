class BattleMenuWindowMediator extends ViewMediator {

    protected view: BattleMenuWindow;

    protected onViewOpen() {
        let view = this.view;
        EventHelper.addTapEvent(view.icon_backHome, this.onTap, this);
        EventHelper.addTapEvent(view.icon_continue, this.onTap, this);
        EventHelper.addTapEvent(view.icon_reset, this.onTap, this);
    }

    protected onViewClose() {
        let view = this.view;
        EventHelper.removeTapEvent(view.icon_backHome, this.onTap, this);
        EventHelper.removeTapEvent(view.icon_continue, this.onTap, this);
        EventHelper.removeTapEvent(view.icon_reset, this.onTap, this);
    }

    private onTap(e:egret.TouchEvent){
        let view = this.view;
        switch (e.currentTarget){
            case view.icon_backHome:
                this.sendMsg(create(BattleMsg.cmd.BackToMainView));
                break;
            case view.icon_reset:
                this.sendMsg(create(BattleMsg.cmd.PlayAgain));
                break;
            case view.icon_continue:
                break;
        }
        this.sendMsg(create(BattleMsg.cmd.CloseBattleMenu));
    }

    protected get viewClass(): new () => BattleMenuWindow {
        return BattleMenuWindow;
    }

    protected get openViewMsg(): new () => VoyaMVC.IMsg {
        return BattleMsg.cmd.OpenBattleMenu;
    }

    protected get closeViewMsg(): new () => VoyaMVC.IMsg {
        return BattleMsg.cmd.CloseBattleMenu;
    }

}
