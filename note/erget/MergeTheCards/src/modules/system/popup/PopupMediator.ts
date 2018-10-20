class PopupMediator extends ViewMediator{

    protected view: PopupWindow;

    private _customOnClose:()=>void;

    protected onViewOpen(data:PopupWindowData) {
        app.log(`PopupWindowData:`, data);
        let view = this.view;

        if(data.title && data.title.length > 0){
            if(!view.lb_title.parent){
                view.addChild(view.lb_title);
            }
            view.lb_title.text = data.title
        }else{
            if(view.lb_title.parent){
                view.removeChild(view.lb_title);
            }
        }

        view.btn_close.visible = data.showClose;
        EventHelper.addTapEvent(view.btn_close, this.onTap, this);
        this._customOnClose = data.onClose;

        view.lb_content.text = data.content;
    }

    protected onViewClose() {
        let view = this.view;
        EventHelper.removeTapEvent(view.btn_close, this.onTap, this);
        this._customOnClose = null;
    }


    private onTap(e:egret.TouchEvent){
        let view = this.view;
        switch (e.currentTarget){
            case view.btn_close:
                this.sendMsg(create(PopupMsg.HidePopup));
                if(this._customOnClose){
                    this._customOnClose();
                }
                break;
        }
    }

    protected get viewClass(): new () => PopupWindow{
        return PopupWindow;
    }
    protected get openViewMsg(): new () => PopupMsg.ShowPopup{
        return PopupMsg.ShowPopup;
    }
    protected get closeViewMsg(): new () => PopupMsg.HidePopup{
        return PopupMsg.HidePopup;
    }
}
