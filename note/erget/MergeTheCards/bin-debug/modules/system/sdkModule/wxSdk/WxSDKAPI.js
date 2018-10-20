"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
// namespace SDK {
//     export class WxSDKAPI implements ISDKAPI {
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
    /**
     * 缓存
     * @param key
     * @param data
     */
    WxSDKModel.prototype.setStorageData = function (key, data) {
        wx.setStorageSync(key, data);
    };
    /**
     *
     * @param key
     */
    WxSDKModel.prototype.getStorageData = function (key) {
        return wx.getStorageSync(key);
    };
    Object.defineProperty(WxSDKModel.prototype, "systemPf", {
        /**系统平台*/
        get: function () {
            if (!this._systemPf) {
                var system = wx.getSystemInfoSync().system.toLowerCase();
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
    return WxSDKModel;
}(VoyaMVC.Model));
exports.WxSDKModel = WxSDKModel;
// } 
