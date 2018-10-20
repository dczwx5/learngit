class RebirthConfirmMediator extends ViewMediator{
    protected view: RebirthConfirmWindow;

    private onClose:()=>void;

    protected onViewOpen(data:{onClose:()=>void}) {
        let view = this.view;
        this.onClose = data.onClose;
        EventHelper.addTapEvent(view.btn_close, this.onTap, this);
        EventHelper.addTapEvent(view.btn_rebirth, this.onTap, this);

        this.sendMsg(create(WxSdkMsg.ShowBannerAd));
    }

    protected onViewClose() {
        let view = this.view;
        this.onClose = null;
        EventHelper.removeTapEvent(view.btn_close, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_rebirth, this.onTap, this);

        this.sendMsg(create(WxSdkMsg.HideBannerAd));
    }

    private onTap(e:egret.TouchEvent){
        let view = this.view;
        switch (e.currentTarget){
            case view.btn_close:
                if(this.onClose){
                    this.onClose();
                }
                this.sendMsg(create(BattleMsg.cmd.CloseRebirthWindow));
                break;
            case view.btn_rebirth:
                this.sendMsg(create(BattleMsg.cmd.Rebirth));
                break;
        }
    }

    protected get viewClass():  new()=>RebirthConfirmWindow  {
        return RebirthConfirmWindow;
    }

    protected get openViewMsg():  new()=>VoyaMVC.IMsg  {
        return BattleMsg.cmd.OpenRebirthWindow;
    }

    protected get closeViewMsg():  new()=>VoyaMVC.IMsg  {
        return BattleMsg.cmd.CloseRebirthWindow;
    }
}
