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
var Img = (function (_super) {
    __extends(Img, _super);
    function Img() {
        var _this = _super.call(this) || this;
        _this.imgLoader = new egret.ImageLoader();
        return _this;
    }
    Object.defineProperty(Img.prototype, "url", {
        get: function () {
            return this._url;
        },
        set: function (url) {
            this._url = url;
            this.imgLoader.addEventListener(egret.Event.COMPLETE, this.onLoadComplete, this);
            this.imgLoader.addEventListener(egret.IOErrorEvent.IO_ERROR, this.onError, this);
            this._isLoading = true;
            this.imgLoader.load(url);
        },
        enumerable: true,
        configurable: true
    });
    Img.prototype.onLoadComplete = function (e) {
        this.imgLoader.removeEventListener(egret.Event.COMPLETE, this.onLoadComplete, this);
        this.imgLoader.removeEventListener(egret.IOErrorEvent.IO_ERROR, this.onError, this);
        var imageLoader = e.currentTarget;
        var texture = new egret.Texture();
        texture._setBitmapData(imageLoader.data);
        this.$setTexture(texture);
        this._isLoading = false;
    };
    Img.prototype.onError = function (e) {
        this.imgLoader.removeEventListener(egret.Event.COMPLETE, this.onLoadComplete, this);
        this.imgLoader.removeEventListener(egret.IOErrorEvent.IO_ERROR, this.onError, this);
        this.$setTexture(null);
        this._isLoading = false;
    };
    Object.defineProperty(Img.prototype, "isLoading", {
        get: function () {
            return this._isLoading;
        },
        enumerable: true,
        configurable: true
    });
    return Img;
}(egret.Bitmap));
__reflect(Img.prototype, "Img");
//# sourceMappingURL=Img.js.map