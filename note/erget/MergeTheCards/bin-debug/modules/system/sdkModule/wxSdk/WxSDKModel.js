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
var WxSDKModel = (function (_super) {
    __extends(WxSDKModel, _super);
    function WxSDKModel() {
        var _this = _super.call(this) || this;
        /**程序前后台切换事件*/
        _this.dg_onActiveChanged = new VL.Delegate();
        /**
         * 是否审核中
         * @type {boolean}
         */
        _this.isExamine = false;
        _this.pfUserInfo = new WxUserInfo();
        _this._otherGameMng = new WxOtherGameManager();
        _this._otherGameMng.dg_dataChanged.register(_this.onOtherGameDataChanged, _this);
        _this._videoMng = new WxVideoMng();
        _this._wxBannerAdMng = new WxBannerAdMng(_this.systemInfo);
        return _this;
    }
    WxSDKModel.prototype.init = function () {
        var _this = this;
        this.initLaunchOptions();
        this.initActiveChange();
        this.initAppUpdateMng();
        wx.onShareAppMessage(function (res) {
            console.log("onShareAppMessage:", res);
            var info = _this.getRandomShareInfo();
            return {
                title: info.content,
                imageUrl: info.imgUrl,
                query: "shareContentId=" + info.contentId
            };
        });
        this._videoMng.init();
    };
    WxSDKModel.prototype.initLaunchOptions = function () {
        var launchOptions = wx.getLaunchOptionsSync();
        this.shareQueryData = launchOptions.query;
    };
    WxSDKModel.prototype.initActiveChange = function () {
        var _this = this;
        wx.onShow(function (res) {
            _this.dg_onActiveChanged.boardcast({ isActive: true, showArgs: res });
        });
        wx.onHide(function () {
            app.log("app进入后台~~~~~~~~~~~~~~~~~~~~~~~~");
            _this.dg_onActiveChanged.boardcast({ isActive: false });
        });
    };
    WxSDKModel.prototype.initAppUpdateMng = function () {
        var updateManager = wx.getUpdateManager();
        updateManager.onCheckForUpdate(function (res) {
            // 请求完新版本信息的回调
            console.log("请求完新版本信息的回调", res.hasUpdate);
        });
        updateManager.onUpdateReady(function () {
            wx.showModal({
                title: '更新提示',
                content: '新版本已经准备好，是否重启应用？',
                success: function (res) {
                    if (res.confirm) {
                        // 新的版本已经下载好，调用 applyUpdate 应用新版本并重启
                        updateManager.applyUpdate();
                    }
                }
            });
        });
        updateManager.onUpdateFailed(function () {
            // 新的版本下载失败
            console.log("新的版本下载失败");
        });
    };
    WxSDKModel.prototype.onShareAppMessage = function (res) {
        // private onShareAppMessage() {
        app.log("onShareAppMessage:", res);
        // let res = {};
        var info = this.getRandomShareInfo();
        return {
            title: info.content,
            imageUrl: info.imgUrl,
            query: "shareContentId=" + info.contentId
        };
    };
    /**
     * 随机获取一条分享信息
     * @returns {WxShareInfo}
     */
    WxSDKModel.prototype.getRandomShareInfo = function () {
        return Utils.ArrayUtils.randomElement(this.shareInfoList);
    };
    WxSDKModel.prototype.onOtherGameDataChanged = function () {
        this.sendMsg(create(WxSdkMsg.OtherGameDataChanged));
    };
    Object.defineProperty(WxSDKModel.prototype, "systemPf", {
        /**系统平台*/
        get: function () {
            if (!this._systemPf) {
                var system = this.systemInfo.system.toLowerCase();
                if (system.indexOf("android") > 0) {
                    this._systemPf = Enum_System.ANDROID;
                }
                else if (system.indexOf("ios") > 0) {
                    this._systemPf = Enum_System.IOS;
                }
            }
            return this._systemPf;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(WxSDKModel.prototype, "systemInfo", {
        get: function () {
            if (!this._systemInfo) {
                this._systemInfo = wx.getSystemInfoSync();
            }
            return this._systemInfo;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(WxSDKModel.prototype, "otherGameMng", {
        get: function () {
            return this._otherGameMng;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(WxSDKModel.prototype, "videoMng", {
        get: function () {
            return this._videoMng;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(WxSDKModel.prototype, "wxBannerAdMng", {
        get: function () {
            return this._wxBannerAdMng;
        },
        enumerable: true,
        configurable: true
    });
    return WxSDKModel;
}(VoyaMVC.Model));
__reflect(WxSDKModel.prototype, "WxSDKModel");
//# sourceMappingURL=WxSDKModel.js.map