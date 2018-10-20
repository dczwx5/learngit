class WxVideoMng {
    private _video: wx.RewardedVideoAd;

    private _isPlaying: boolean = false;

    private _isError:boolean = false;

    public readonly dg_onError: VL.Delegate<{ err: wx.WxAdError }>;


    constructor() {
        this._video = wx.createRewardedVideoAd({adUnitId: app.globalConfig.videoAdUnitId});
        this.dg_onError = new VL.Delegate<{ err: wx.WxAdError }>();
    }

    init() {
        // this._video.onLoad(() => {
        //     egret.log('激励视频 广告加载成功');
        // });
        let video = this._video;
        video.onError((res: { errMsg: string, errCode: number }) => {
            this._isPlaying = false;
            this._isError = true;
            let err = wx.WxAdErrorMap[res.errCode];
            this.dg_onError.boardcast({err: err});
            egret.log(`激励视频错误：${err.code}\n 描述：${err.desc} \n 原因：${err.reason}\n 解决方案：${err.solution}`);
        });
    }

    private loadVideoFailCount: number = 0;

    public async show(onVideoClose: (isEnd: boolean, otherData?: any) => void, thisObj: any, otherData: any = null) {

        app.log(`show isPlaying:${this._isPlaying}`);
        if (this._isPlaying) {
            return;
        }
        let video = this._video;

        this.loadVideoFailCount = 0;
        this._isError = false;
        app.log(`before showVideo isPlaying:${this._isPlaying}`);
        let isPlaying = this._isPlaying = await this.showVideo();
        app.log(`after showVideo isPlaying:${this._isPlaying}`);
        if (!isPlaying) {
            return;
        }

        let onClose = (res: { isEnded: boolean }) => {
            // 用户点击了【关闭广告】按钮
            // 小于 2.1.0 的基础库版本，res 是一个 undefined
            let isEnd: boolean = false;
            if (res && res.isEnded || res === undefined) {
                // 正常播放结束，可以下发游戏奖励
                isEnd = true;
            }
            video.offClose(onClose);
            this._isPlaying = false;
            this._isError = false;
            onVideoClose.call(thisObj, isEnd, otherData);
        };
        video.onClose(onClose);
    }

    private async showVideo() {
        let video = this._video;
        let res = true;
        await video.show().catch(async err => {
            res = false;
            if (!this._isError || this.loadVideoFailCount++ < 3) {
                await video.load();
                res = await this.showVideo();
            }
        });
        return res;
    }
}
