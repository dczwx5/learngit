abstract class ShareCanvasMediator extends ViewMediator{

    protected view:ShareCanvasView;
    protected viewClass: new () => App.IBaseView;
    protected openViewMsg: new () => VoyaMVC.IMsg;
    protected closeViewMsg: new () => VoyaMVC.IMsg;

    private bitmap:egret.Bitmap;
    private bitmapdata:egret.BitmapData;


    protected onViewOpen() {
        this.initContent();

        let view = this.view;
        EventHelper.addTapEvent(view.btn_back, this.onBack, this);
    }

    protected onViewClose() {
        this.clearCanvas();
        this.clearContent();

        let view = this.view;
        EventHelper.removeTapEvent(view.btn_back, this.onBack, this);
    }

    private initContent(){
        let view = this.view;
        let bitmapdata = this.bitmapdata = new egret.BitmapData(window["sharedCanvas"]);
        bitmapdata.$deleteSource = false;
        const texture = new egret.Texture();
        texture._setBitmapData(bitmapdata);
        this.bitmap = new egret.Bitmap(texture);
        this.bitmap.width = view.width;
        this.bitmap.height = view.height;
        app.log(` ========= Bmp: X:${this.bitmap.x}, Y:${this.bitmap.y}, W:${this.bitmap.width}, H:${this.bitmap.height}`);
        view.grp_canvasLayer.addChild(this.bitmap);
        egret.startTick(this.onTick, this);
    }

    private clearContent(){
        egret.stopTick(this.onTick, this);
        let view = this.view;
        view.grp_canvasLayer.removeChildren();
        this.bitmapdata.$dispose();
        this.bitmapdata = null;
        if(this.bitmap.parent){
            this.bitmap.parent.removeChild(this.bitmap);
        }
        this.bitmap = null;
    }

    private onTick(timeStarmp: number){
        let bitmapdata = this.bitmapdata;
        egret.WebGLUtils.deleteWebGLTexture(bitmapdata.webGLTexture);
        bitmapdata.webGLTexture = null;
        let view = this.view;
        this.bitmap.width = view.width;
        this.bitmap.height = view.height;
        return false;
    }

    private clearCanvas(){
        this.sendMsg(create(WxSdkMsg.SendOpenDataContextCmd).init({head:WxOpenDataContextMsg.CLOSE_CONTEXT}));
    }

    protected abstract onBack();


}