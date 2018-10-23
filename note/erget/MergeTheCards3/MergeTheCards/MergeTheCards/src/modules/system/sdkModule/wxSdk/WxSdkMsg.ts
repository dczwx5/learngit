namespace WxSdkMsg{
    /**
     * 向开放数据域发送消息
     */
    export class SendOpenDataContextCmd extends VoyaMVC.Msg<{head:string, body?:any}> {}

    /**
     * 分享
     */
    export class Share extends VoyaMVC.Msg {}

    /**
     * 导流游戏数据变更
     */
    export class OtherGameDataChanged extends VoyaMVC.Msg {}


    /**
     * 导流到其他游戏
     * idx 导流组的索引
     */
    export class ToOtherGame extends VoyaMVC.Msg<{groupIdx:number}> {}

    /**
     * 保存微信用户数据
     */
    export class SetUserCloudStorage extends VoyaMVC.Msg<{
        KVDataList:wx.KVData[],
        success?:()=>void,
        fail?:()=>void,
        complete?:()=>void
    }> {}

    /**
     * 看视频命令
     * flag 看视频做什么事的一个标识，WatchVideo_FeedBack将返回对应的标识
     * showAlertWhenGiveUp 是否在为看完视频就关闭后弹提示窗
     */
    export class WatchVideo_CMD extends VoyaMVC.Msg<{flag:Enum_WxWatchVideoFlag, showAlertWhenGiveUp:boolean}> {}
    /**
     * 看视频结果
     * flag 返回标识来对调用方进行业务区分
     */
    export class WatchVideo_FeedBack extends VoyaMVC.Msg<{result:Enum_WxWatchVideoResult, error?:wx.WxAdError, flag:Enum_WxWatchVideoFlag}> {}

    /**
     * 展示Banner广告
     */
    export class ShowBannerAd extends VoyaMVC.Msg<{style?:wx.BannerAdStyle}> {}
    /**
     * 隐藏Banner广告
     */
    export class HideBannerAd extends VoyaMVC.Msg {}


    export class OpenFriendRankListView extends VoyaMVC.Msg<{odcMsg:WxOpenDataContextMsg}> {}
    export class CloseFriendRankListView extends VoyaMVC.Msg<{odcMsg:WxOpenDataContextMsg}> {}
}
