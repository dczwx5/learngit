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
var WxSdkMsg;
(function (WxSdkMsg) {
    /**
     * 向开放数据域发送消息
     */
    var SendOpenDataContextCmd = (function (_super) {
        __extends(SendOpenDataContextCmd, _super);
        function SendOpenDataContextCmd() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return SendOpenDataContextCmd;
    }(VoyaMVC.Msg));
    WxSdkMsg.SendOpenDataContextCmd = SendOpenDataContextCmd;
    __reflect(SendOpenDataContextCmd.prototype, "WxSdkMsg.SendOpenDataContextCmd");
    /**
     * 分享
     */
    var Share = (function (_super) {
        __extends(Share, _super);
        function Share() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return Share;
    }(VoyaMVC.Msg));
    WxSdkMsg.Share = Share;
    __reflect(Share.prototype, "WxSdkMsg.Share");
    /**
     * 导流游戏数据变更
     */
    var OtherGameDataChanged = (function (_super) {
        __extends(OtherGameDataChanged, _super);
        function OtherGameDataChanged() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OtherGameDataChanged;
    }(VoyaMVC.Msg));
    WxSdkMsg.OtherGameDataChanged = OtherGameDataChanged;
    __reflect(OtherGameDataChanged.prototype, "WxSdkMsg.OtherGameDataChanged");
    /**
     * 导流到其他游戏
     * idx 导流组的索引
     */
    var ToOtherGame = (function (_super) {
        __extends(ToOtherGame, _super);
        function ToOtherGame() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return ToOtherGame;
    }(VoyaMVC.Msg));
    WxSdkMsg.ToOtherGame = ToOtherGame;
    __reflect(ToOtherGame.prototype, "WxSdkMsg.ToOtherGame");
    /**
     * 保存微信用户数据
     */
    var SetUserCloudStorage = (function (_super) {
        __extends(SetUserCloudStorage, _super);
        function SetUserCloudStorage() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return SetUserCloudStorage;
    }(VoyaMVC.Msg));
    WxSdkMsg.SetUserCloudStorage = SetUserCloudStorage;
    __reflect(SetUserCloudStorage.prototype, "WxSdkMsg.SetUserCloudStorage");
    /**
     * 看视频命令
     * flag 看视频做什么事的一个标识，WatchVideo_FeedBack将返回对应的标识
     * showAlertWhenGiveUp 是否在为看完视频就关闭后弹提示窗
     */
    var WatchVideo_CMD = (function (_super) {
        __extends(WatchVideo_CMD, _super);
        function WatchVideo_CMD() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return WatchVideo_CMD;
    }(VoyaMVC.Msg));
    WxSdkMsg.WatchVideo_CMD = WatchVideo_CMD;
    __reflect(WatchVideo_CMD.prototype, "WxSdkMsg.WatchVideo_CMD");
    /**
     * 看视频结果
     * flag 返回标识来对调用方进行业务区分
     */
    var WatchVideo_FeedBack = (function (_super) {
        __extends(WatchVideo_FeedBack, _super);
        function WatchVideo_FeedBack() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return WatchVideo_FeedBack;
    }(VoyaMVC.Msg));
    WxSdkMsg.WatchVideo_FeedBack = WatchVideo_FeedBack;
    __reflect(WatchVideo_FeedBack.prototype, "WxSdkMsg.WatchVideo_FeedBack");
    /**
     * 展示Banner广告
     */
    var ShowBannerAd = (function (_super) {
        __extends(ShowBannerAd, _super);
        function ShowBannerAd() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return ShowBannerAd;
    }(VoyaMVC.Msg));
    WxSdkMsg.ShowBannerAd = ShowBannerAd;
    __reflect(ShowBannerAd.prototype, "WxSdkMsg.ShowBannerAd");
    /**
     * 隐藏Banner广告
     */
    var HideBannerAd = (function (_super) {
        __extends(HideBannerAd, _super);
        function HideBannerAd() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return HideBannerAd;
    }(VoyaMVC.Msg));
    WxSdkMsg.HideBannerAd = HideBannerAd;
    __reflect(HideBannerAd.prototype, "WxSdkMsg.HideBannerAd");
    var OpenFriendRankListView = (function (_super) {
        __extends(OpenFriendRankListView, _super);
        function OpenFriendRankListView() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OpenFriendRankListView;
    }(VoyaMVC.Msg));
    WxSdkMsg.OpenFriendRankListView = OpenFriendRankListView;
    __reflect(OpenFriendRankListView.prototype, "WxSdkMsg.OpenFriendRankListView");
    var CloseFriendRankListView = (function (_super) {
        __extends(CloseFriendRankListView, _super);
        function CloseFriendRankListView() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return CloseFriendRankListView;
    }(VoyaMVC.Msg));
    WxSdkMsg.CloseFriendRankListView = CloseFriendRankListView;
    __reflect(CloseFriendRankListView.prototype, "WxSdkMsg.CloseFriendRankListView");
})(WxSdkMsg || (WxSdkMsg = {}));
//# sourceMappingURL=WxSdkMsg.js.map