class WxBannerAdMng {

    private _bannerAd: wx.BannerAd;
    private _systemInfo: wx.SystemInfo;

    public readonly dg_onError: VL.Delegate<{ err: wx.WxAdError }>;

    private _isShow:boolean = false;

    constructor(systemInfo: wx.SystemInfo) {
        this._systemInfo = systemInfo;
        this.dg_onError = new VL.Delegate<{ err: wx.WxAdError }>();
    }

    showBanner(style: wx.BannerAdStyle = null) {
        let systemInfo = this._systemInfo;
        if(this._isShow){
            return;
        }
        let ad = this._bannerAd = wx.createBannerAd({
            adUnitId: app.globalConfig.bannerAdUnitId,
            style: {
                left: 0,
                top: 0,
                width: Math.min(this.maxAdWidth, style ? style.width : systemInfo.windowWidth),
                height: 0,
            }
        });
        ad.onError(res => {
            let err = wx.WxAdErrorMap[res.errCode];
            this.dg_onError.boardcast({err: err});
            egret.log(`Banner广告错误：${err.code}\n 描述：${err.desc} \n 原因：${err.reason}\n 解决方案：${err.solution}`);
        });

        ad.onResize(res => {
            ad.style.left = style ? style.left : (systemInfo.windowWidth - res.width) >> 1;
            ad.style.top = style ? style.top : systemInfo.windowHeight - res.height;
        });

        ad.show();
        this._isShow = true;
        return ad;
    }

    hideBanner() {
        if(!this._isShow){
            return;
        }
        this._isShow = false;
        let ad = this._bannerAd;
        if (ad) {
            ad.destroy();
            ad = null;
        }
    }

    private get maxAdWidth():number{
        return 1080 / this._systemInfo.pixelRatio;
    }
}
