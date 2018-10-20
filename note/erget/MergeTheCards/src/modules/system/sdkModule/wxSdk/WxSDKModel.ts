class WxSDKModel extends VoyaMVC.Model {
    /**程序前后台切换事件*/
    public readonly dg_onActiveChanged: VL.Delegate<{ isActive: boolean, showArgs?: wx.OnShowArgs }> = new VL.Delegate<{ isActive: boolean, showArgs?: wx.OnShowArgs }>();

    openId: string;

    pfUserInfo: WxUserInfo;

    public shareInfoList: WxShareInfo[];

    /**
     * 是否审核中
     * @type {boolean}
     */
    public isExamine: boolean = false;

    public shareQueryData: WxShareQueryData;

    private _otherGameMng:WxOtherGameManager;

    private _videoMng:WxVideoMng;

    private _wxBannerAdMng:WxBannerAdMng;

    private _systemInfo:wx.SystemInfo;

    constructor() {
        super();
        this.pfUserInfo = new WxUserInfo();
        this._otherGameMng = new WxOtherGameManager();
        this._otherGameMng.dg_dataChanged.register(this.onOtherGameDataChanged, this);
        this._videoMng = new WxVideoMng();
        this._wxBannerAdMng = new WxBannerAdMng(this.systemInfo);
    }

    public init() {
        this.initLaunchOptions();
        this.initActiveChange();
        this.initAppUpdateMng();
        wx.onShareAppMessage((res: { title: string, imageUrl: string, query: string }) => {
            console.log("onShareAppMessage:", res);
            let info = this.getRandomShareInfo();
            return {
                title: info.content,
                imageUrl: info.imgUrl,
                query: `shareContentId=${info.contentId}`
            }
        });
        this._videoMng.init();
    }

    private initLaunchOptions() {
        let launchOptions = wx.getLaunchOptionsSync();
        this.shareQueryData = launchOptions.query;
    }

    private initActiveChange() {
        wx.onShow((res) => {
            this.dg_onActiveChanged.boardcast({isActive: true, showArgs: res});
        });

        wx.onHide(() => {
            app.log("app进入后台~~~~~~~~~~~~~~~~~~~~~~~~");
            this.dg_onActiveChanged.boardcast({isActive: false});
        });
    }

    private initAppUpdateMng() {
        const updateManager = wx.getUpdateManager();
        updateManager.onCheckForUpdate((res: { hasUpdate: boolean }) => {
            // 请求完新版本信息的回调
            console.log("请求完新版本信息的回调", res.hasUpdate);
        });

        updateManager.onUpdateReady(function () {
            wx.showModal({
                title: '更新提示',
                content: '新版本已经准备好，是否重启应用？',
                success: res => {
                    if (res.confirm) {
                        // 新的版本已经下载好，调用 applyUpdate 应用新版本并重启
                        updateManager.applyUpdate();
                    }
                }
            })
        });

        updateManager.onUpdateFailed(() => {
            // 新的版本下载失败
            console.log("新的版本下载失败");
        });
    }


    private onShareAppMessage(res: { title: string, imageUrl: string, query: string }) {
        // private onShareAppMessage() {
        app.log("onShareAppMessage:", res);
        // let res = {};
        let info = this.getRandomShareInfo();
        return {
            title: info.content,
            imageUrl: info.imgUrl,
            query: `shareContentId=${info.contentId}`
        }
    }

    /**
     * 随机获取一条分享信息
     * @returns {WxShareInfo}
     */
    public getRandomShareInfo(): WxShareInfo {
        return Utils.ArrayUtils.randomElement(this.shareInfoList);
    }

    private onOtherGameDataChanged(){
        this.sendMsg(create(WxSdkMsg.OtherGameDataChanged));
    }



    private _systemPf: Enum_System;
    /**系统平台*/
    public get systemPf(): Enum_System {
        if (!this._systemPf) {
            let system = this.systemInfo.system.toLowerCase();
            if (system.indexOf("android") > 0) {
                this._systemPf = Enum_System.ANDROID;
            }
            else if (system.indexOf("ios") > 0) {
                this._systemPf = Enum_System.IOS;
            }
        }
        return this._systemPf;
    }

    get systemInfo(){
        if(!this._systemInfo){
            this._systemInfo = wx.getSystemInfoSync();
        }
        return this._systemInfo;
    }

    get otherGameMng(): WxOtherGameManager {
        return this._otherGameMng;
    }

    get videoMng(){
        return this._videoMng;
    }

    get wxBannerAdMng(): WxBannerAdMng {
        return this._wxBannerAdMng;
    }
}