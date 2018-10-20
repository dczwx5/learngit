var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var WxBannerAdMng = (function () {
    function WxBannerAdMng(systemInfo) {
        this._isShow = false;
        this._systemInfo = systemInfo;
        this.dg_onError = new VL.Delegate();
    }
    WxBannerAdMng.prototype.showBanner = function (style) {
        var _this = this;
        if (style === void 0) { style = null; }
        var systemInfo = this._systemInfo;
        if (this._isShow) {
            return;
        }
        var ad = this._bannerAd = wx.createBannerAd({
            adUnitId: app.globalConfig.bannerAdUnitId,
            style: {
                left: 0,
                top: 0,
                width: Math.min(this.maxAdWidth, style ? style.width : systemInfo.windowWidth),
                height: 0,
            }
        });
        ad.onError(function (res) {
            var err = wx.WxAdErrorMap[res.errCode];
            _this.dg_onError.boardcast({ err: err });
            egret.log("Banner\u5E7F\u544A\u9519\u8BEF\uFF1A" + err.code + "\n \u63CF\u8FF0\uFF1A" + err.desc + " \n \u539F\u56E0\uFF1A" + err.reason + "\n \u89E3\u51B3\u65B9\u6848\uFF1A" + err.solution);
        });
        ad.onResize(function (res) {
            ad.style.left = style ? style.left : (systemInfo.windowWidth - res.width) >> 1;
            ad.style.top = style ? style.top : systemInfo.windowHeight - res.height;
        });
        ad.show();
        this._isShow = true;
        return ad;
    };
    WxBannerAdMng.prototype.hideBanner = function () {
        if (!this._isShow) {
            return;
        }
        this._isShow = false;
        var ad = this._bannerAd;
        if (ad) {
            ad.destroy();
            ad = null;
        }
    };
    Object.defineProperty(WxBannerAdMng.prototype, "maxAdWidth", {
        get: function () {
            return 1080 / this._systemInfo.pixelRatio;
        },
        enumerable: true,
        configurable: true
    });
    return WxBannerAdMng;
}());
__reflect(WxBannerAdMng.prototype, "WxBannerAdMng");
//# sourceMappingURL=WxBannerAdMng.js.map