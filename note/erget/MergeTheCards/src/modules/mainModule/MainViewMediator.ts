class MainViewMediator extends ViewMediator {

    protected view: MainView;

    protected onViewOpen() {
        let view = this.view;
        EventHelper.addTapEvent(view.btn_start, this.onBtnStart, this);
        EventHelper.addTapEvent(view.btn_shop, this.onTouch, this);
        EventHelper.addTapEvent(view.btn_rank, this.onTouch, this);
        EventHelper.addTapEvent(view.btn_share, this.onTouch, this);
        EventHelper.addTapEvent(view.getWxOtherGameIcon(0), this.onTouch, this);
        EventHelper.addTapEvent(view.getWxOtherGameIcon(1), this.onTouch, this);

        this.regMsg(WxSdkMsg.OtherGameDataChanged, this.onOtherGameDataChanged, this);

        this.updateOtherGameIcon();

        this.sendMsg(create(WxSdkMsg.ShowBannerAd));
    }

    protected onViewClose() {
        let view = this.view;
        EventHelper.removeTapEvent(view.btn_start, this.onBtnStart, this);
        EventHelper.removeTapEvent(view.btn_shop, this.onTouch, this);
        EventHelper.removeTapEvent(view.btn_rank, this.onTouch, this);
        EventHelper.removeTapEvent(view.btn_share, this.onTouch, this);
        EventHelper.removeTapEvent(view.getWxOtherGameIcon(0), this.onTouch, this);
        EventHelper.removeTapEvent(view.getWxOtherGameIcon(1), this.onTouch, this);

        this.unregMsg(WxSdkMsg.OtherGameDataChanged, this.onOtherGameDataChanged, this);

        this.updateOtherGameIcon(true);

        this.sendMsg(create(WxSdkMsg.HideBannerAd));
    }

    private onShop() {

    }

    private onRank() {
        this.sendMsg(create(WxSdkMsg.SendOpenDataContextCmd).init({head: WxOpenDataContextMsg.FRIEND_RANK_LIST}))
    }

    private onShare() {
        this.sendMsg(create(WxSdkMsg.Share));
    }

    private onTouch(e: egret.TouchEvent) {
        let view = this.view;
        switch (e.currentTarget) {
            case view.btn_share:
                this.onShare();
                break;
            case view.btn_rank:
                this.onRank();
                break;
            case view.btn_shop:
                this.onShop();
                break;
            case view.getWxOtherGameIcon(0):
                this.onOtherGame(0);
                break;
            case view.getWxOtherGameIcon(1):
                this.onOtherGame(1);
                break;
        }
    }

    private onOtherGameDataChanged() {
        this.updateOtherGameIcon();
    }

    private updateOtherGameIcon(setNull: boolean = false) {
        if(app.globalConfig.pf != 'weixin'){
            return;
        }
        let otherGameMng = this.getModel(WxSDKModel).otherGameMng;
        let view = this.view;
        for (let i = 0, l = otherGameMng.groupCount; i < l; i++) {
            view.getWxOtherGameIcon(i).setData(setNull ? null : otherGameMng.getCurrGameData(i));
        }
    }

    private onOtherGame(idx:number){
        this.sendMsg(create(WxSdkMsg.ToOtherGame).init({groupIdx:idx}));
    }

    private onBtnStart(e: egret.TouchEvent) {
        this.sendMsg(create(BattleMsg.cmd.EnterBattle));
        this.sendMsg(create(MainModuleMsg.CloseMainView));
    }

    protected get viewClass(): new() => MainView {
        return MainView;
    }

    protected get openViewMsg(): new() => MainModuleMsg.OpenMainView {
        return MainModuleMsg.OpenMainView;
    }

    protected get closeViewMsg(): new() => MainModuleMsg.OpenMainView {
        return MainModuleMsg.CloseMainView;
    }
}
