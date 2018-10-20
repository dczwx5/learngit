class HelpWindowMediator extends ViewMediator{
    protected view: HelpWindow;

    protected onViewOpen() {
        EventHelper.addTapEvent(this.view.btn_close, this.onTap, this);
    }

    protected onViewClose() {
        EventHelper.removeTapEvent(this.view.btn_close, this.onTap, this);
    }

    private onTap(e:egret.TouchEvent){
        switch (e.currentTarget){
            case this.view.btn_close:
                this.sendMsg(create(HelpModuleMsg.CLOSE_HELP_VIEW));
                break;
        }
    }

    protected get viewClass(): new () => HelpWindow{
        return HelpWindow;
    }
    protected get openViewMsg(): new () => VoyaMVC.IMsg{
        return HelpModuleMsg.OPEN_HELP_VIEW;
    }
    protected get closeViewMsg(): new () => VoyaMVC.IMsg{
        return HelpModuleMsg.CLOSE_HELP_VIEW;
    }

}
