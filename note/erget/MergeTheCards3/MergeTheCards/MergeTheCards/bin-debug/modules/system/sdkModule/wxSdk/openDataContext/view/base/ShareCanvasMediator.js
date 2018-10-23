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
var ShareCanvasMediator = (function (_super) {
    __extends(ShareCanvasMediator, _super);
    function ShareCanvasMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    ShareCanvasMediator.prototype.onViewOpen = function () {
        this.initContent();
        var view = this.view;
        EventHelper.addTapEvent(view.btn_back, this.onBack, this);
    };
    ShareCanvasMediator.prototype.onViewClose = function () {
        this.clearCanvas();
        this.clearContent();
        var view = this.view;
        EventHelper.removeTapEvent(view.btn_back, this.onBack, this);
    };
    ShareCanvasMediator.prototype.initContent = function () {
        var view = this.view;
        var bitmapdata = this.bitmapdata = new egret.BitmapData(window["sharedCanvas"]);
        bitmapdata.$deleteSource = false;
        var texture = new egret.Texture();
        texture._setBitmapData(bitmapdata);
        this.bitmap = new egret.Bitmap(texture);
        this.bitmap.width = view.width;
        this.bitmap.height = view.height;
        app.log(" ========= Bmp: X:" + this.bitmap.x + ", Y:" + this.bitmap.y + ", W:" + this.bitmap.width + ", H:" + this.bitmap.height);
        view.grp_canvasLayer.addChild(this.bitmap);
        egret.startTick(this.onTick, this);
    };
    ShareCanvasMediator.prototype.clearContent = function () {
        egret.stopTick(this.onTick, this);
        var view = this.view;
        view.grp_canvasLayer.removeChildren();
        this.bitmapdata.$dispose();
        this.bitmapdata = null;
        if (this.bitmap.parent) {
            this.bitmap.parent.removeChild(this.bitmap);
        }
        this.bitmap = null;
    };
    ShareCanvasMediator.prototype.onTick = function (timeStarmp) {
        var bitmapdata = this.bitmapdata;
        egret.WebGLUtils.deleteWebGLTexture(bitmapdata.webGLTexture);
        bitmapdata.webGLTexture = null;
        var view = this.view;
        this.bitmap.width = view.width;
        this.bitmap.height = view.height;
        return false;
    };
    ShareCanvasMediator.prototype.clearCanvas = function () {
        this.sendMsg(create(WxSdkMsg.SendOpenDataContextCmd).init({ head: WxOpenDataContextMsg.CLOSE_CONTEXT }));
    };
    return ShareCanvasMediator;
}(ViewMediator));
__reflect(ShareCanvasMediator.prototype, "ShareCanvasMediator");
//# sourceMappingURL=ShareCanvasMediator.js.map