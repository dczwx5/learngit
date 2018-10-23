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
var ShareCanvasView = (function (_super) {
    __extends(ShareCanvasView, _super);
    function ShareCanvasView() {
        return _super.call(this, "ShareCanvasViewSkin") || this;
    }
    ShareCanvasView.prototype.onInit = function () {
        _super.prototype.onInit.call(this);
        this.rect_bg.touchEnabled = true;
    };
    return ShareCanvasView;
}(App.BaseAutoSizeView));
__reflect(ShareCanvasView.prototype, "ShareCanvasView");
//# sourceMappingURL=ShareCanvasView.js.map