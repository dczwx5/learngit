class WxSdkController extends VoyaMVC.Controller {

    activate() {
        this.sdk.dg_onActiveChanged.register(this.onActiveChanged, this);

        this.regMsg(SDKMsg.Login, this.onLogin, this);
        this.regMsg(WxSdkMsg.SendOpenDataContextCmd, this.onSendOpenDataContextCmd, this);
        this.regMsg(WxSdkMsg.SetUserCloudStorage, this.onSetUserCloudStorage, this);
        this.regMsg(WxSdkMsg.Share, this.onShare, this);
        this.regMsg(WxSdkMsg.ToOtherGame, this.onToOtherGame, this);
        this.regMsg(WxSdkMsg.WatchVideo_CMD, this.onWatchVideo, this);

        this.regMsg(WxSdkMsg.ShowBannerAd, this.onShowBannerAd, this);
        this.regMsg(WxSdkMsg.HideBannerAd, this.onHideBannerAd, this);

        this.sdk.init();
    }

    deactivate() {
        this.sdk.dg_onActiveChanged.unregister(this.onActiveChanged);

        this.unregMsg(SDKMsg.Login, this.onLogin, this);
        this.unregMsg(WxSdkMsg.SendOpenDataContextCmd, this.onSendOpenDataContextCmd, this);
        this.unregMsg(WxSdkMsg.SetUserCloudStorage, this.onSetUserCloudStorage, this);
        this.unregMsg(WxSdkMsg.Share, this.onShare, this);
        this.unregMsg(WxSdkMsg.ToOtherGame, this.onToOtherGame, this);
        this.unregMsg(WxSdkMsg.WatchVideo_CMD, this.onWatchVideo, this);

        this.unregMsg(WxSdkMsg.ShowBannerAd, this.onShowBannerAd, this);
        this.unregMsg(WxSdkMsg.HideBannerAd, this.onHideBannerAd, this);

    }

    private onActiveChanged(data: { isActive: boolean, showArgs?: wx.OnShowArgs }) {
        if (data.isActive) {
            this.handleShareQuery(data.showArgs.query);
        }
    }

    private handleShareQuery(newQuery: WxShareQueryData) {
        // console.log("处理分享进入");
        // console.log(this.isHandleShareQuery);
        // console.log(PlayerData.id);
        // console.log(App.query);
        // let appQuery = App.query;
        // if (!appQuery || !appQuery["openId"] || !PlayerData.openId || PlayerData.openId == appQuery["openId"] || (this._lastQuery && this._lastQuery["openId"] == appQuery["openId"])) return;

        let sdk = this.sdk;
        let shareQueryData: WxShareQueryData = sdk.shareQueryData;
        let playerOpenId = sdk.openId;

        let send = false;
        if (newQuery && newQuery.inviteOpenId && newQuery.inviteOpenId != playerOpenId) {
            if (shareQueryData && shareQueryData.inviteOpenId) {
                send = newQuery.inviteOpenId != shareQueryData.inviteOpenId;
            } else {
                send = true;
            }
            sdk.shareQueryData = newQuery;
        }
        if (send) {
            app.appHttp.enterFromShare(shareQueryData.inviteUserId, shareQueryData.inviteOpenId, (data, otherData) => {
                app.log("=== 受邀成功 ===", shareQueryData);
            }, this);
        }

        // if (newQuery && newQuery.inviteOpenId
        //     && shareQueryData && shareQueryData.inviteOpenId
        //     && openId && openId != shareQueryData.inviteOpenId
        //     && shareQueryData.inviteOpenId != newQuery.inviteOpenId)
        // {
        //     sdk.pfInfo.shareQueryData = newQuery;
        //     app.appHttp.enterFromShare(parseInt(shareQueryData.inviteUserId), shareQueryData.inviteOpenId, (data, otherData) => {
        //         app.log("助力成功~~~~~~");
        //     }, this);
        // }

    }

    private onLogin(msg: SDKMsg.Login) {
        app.log(`sdkLogin`);
        // app.log(`systemInfo:`, wx.getSystemInfoSync());
        wx.login({
            success: async (res: { code: string }) => {
                await this.reqLogin(res.code);
                await this.reqExamineStatus();
                await this.reqAboutShare();
                await this.reqGetOtherGamesInfo();
            }
        });
    }

    private async reqLogin(wxResCode: string) {
        let sdk = this.sdk;
        let shareData = sdk.shareQueryData;
        await app.appHttp.login(shareData.inviteOpenId || '', shareData.inviteUserId || 0, sdk.systemPf || 0, shareData.source || '', shareData.source_lv || 0, shareData.contentId || 0, wxResCode,
            (data: any, otherData: any) => {
                app.log("login resp data:", data);
                // {
                //     "code": 1,
                //     "msg": "操作执行成功",
                //     "data":
                //     {
                //         "id": "用户id",//int
                //         "nikename": "昵称",//string
                //         "balloon_id": "炮车皮肤id",//int
                //         "protect_avatar": "守护头像地址",//string
                //         "sex": "性别",//int 0保密 1男 2女
                //         "coin": "红心",//int
                //         "help_card": "复活卡",//int
                //         "speed": "速度",//int
                //         "power": "威力",//int
                //         "invite_sum": "邀请次数",//int
                //         "token": "35cd0bf25c2efd721efb4032b0542842",//string
                //         "expiretime": "token到期时间戳"， //int
                //         "timestamp": "服务器时间戳", //int
                //         "coin_sum": "观看视频送红心次数"， //int
                //         "play_sum": "观看视频接着玩红心次数", //int
                //         "daily_fail_sum": "最新广告失败次数", //int
                //         "daily_fail_max": "广告失败最大次数",//int
                //         "score_max": "历史最大积分", //int
                //         "score_week": "周最大积分", //int
                //         "score_time": "提交积分时间",//int
                //         "lv": "等级",//int
                //         "source": "来源标识符", //string
                //         "source_lv": "来源层级"//int
                //     }
                // }
                let pfUserInfo = this.sdk.pfUserInfo;
                pfUserInfo.nickname = data.nickname;
                pfUserInfo.gender = data.sex;

                this.sdk.openId = data.openid;

                let playerModel = this.playerModel;
                playerModel.uid = data.id;
                let storageData = playerModel.storageData;
                let highScore = parseFloat(data.score_max);
                let lv = parseInt(data.lv);
                storageData.highScore = Math.max(storageData.highScore, highScore);
                storageData.lv = Math.max(storageData.lv, lv);
                if (storageData.lv > lv || storageData.highScore > highScore) {
                    app.appHttp.submitBattleRecord(storageData.lv, storageData.highScore)
                }
                playerModel.storageData = storageData;
                playerModel.highScore = storageData.highScore;
                playerModel.lv = storageData.lv;

                this.handleShareQuery(wx.getLaunchOptionsSync().query);
            });
    }

    private async reqAboutShare() {
        await app.appHttp.getAboutShare((data, otherData) => {
            // {
            //     "code": 1,
            //     "msg": "成功",
            //     "data":
            //     {
            //         "content_list": ["文案1", "文案2"],// 数组
            //         "id_list": [id1, id2],// 文案id数组
            //         "image_list": ["https://cdn.evogames.com.cn/wxgames/shouhuqiqiu/1.jpg", "https://cdn.evogames.com.cn/wxgames/shouhuqiqiu/1.jpg"] //图片数组
            //     }
            // }
            let sdk = this.sdk;
            sdk.shareInfoList = [];
            let content_list = data.content_list;
            let id_list = data.id_list;
            let image_list = data.image_list;
            for (let i = 0, l = id_list.length; i < l; i++) {
                sdk.shareInfoList.push({
                    content: content_list[i],
                    contentId: id_list[i],
                    imgUrl: image_list[i]
                });
            }
        });
    }

    private async reqGetOtherGamesInfo() {
        await app.appHttp.getOtherGamesInfo((data, otherData) => {
            this.sdk.otherGameMng.setInfo([data.image_list, data.image_list_2]);
        });
    }

    private async reqExamineStatus() {
        await app.appHttp.getGameExamineStatus((data, otherData) => {
            // "status": 游戏状态 1正常版本 2审核版本 ,// int
            // "share_type": 是否只能分享到群 1只能分享到群 2个人和群都可以, // int
            this.sdk.isExamine = data.status == 2;
        });
    }

    private onSendOpenDataContextCmd(msg: WxSdkMsg.SendOpenDataContextCmd) {
        let head = msg.body.head;
        let body = msg.body.body;

        switch (head) {
            case WxOpenDataContextMsg.FRIEND_RANK_LIST:
                this.sendMsg(create(WxSdkMsg.OpenFriendRankListView));
                break;
        }

        let odcMsg = new WxOpenDataContextMsg(head, body);
        wx.getOpenDataContext().postMessage(odcMsg);
    }

    private onSetUserCloudStorage(msg: WxSdkMsg.SetUserCloudStorage) {
        wx.setUserCloudStorage(msg.body);
    }

    private async onShare(msg: WxSdkMsg.Share) {
        let userInfo = await this.getUserInfo();
        let shareInfo = this.sdk.getRandomShareInfo();
        app.log(`shareInfo:`, shareInfo);
        let strQuery: WxShareQueryData = {
            source: userInfo.source,
            source_lv: userInfo.source_lv,
            inviteOpenId: userInfo.openid,
            inviteUserId: userInfo.user_id,
            contentId: shareInfo.contentId
        };
        wx.shareAppMessage({
            title: shareInfo.content,
            imageUrl: shareInfo.imgUrl,
            query: Utils.StringUtils.ObjectToQueryFormatString(strQuery)
        });
        app.appHttp.shareStatistics(shareInfo.contentId, null, null);
    }

    private onToOtherGame(msg: WxSdkMsg.ToOtherGame) {
        let groupIdx = msg.body.groupIdx;
        let otherGameMgr = this.sdk.otherGameMng;
        otherGameMgr.toOtherGame(groupIdx);
    }

    private onWatchVideo(msg: WxSdkMsg.WatchVideo_CMD) {
        let videoMng = this.sdk.videoMng;
        let flag = msg.body.flag;
        let showAlertWhenGiveUp = msg.body.showAlertWhenGiveUp;
        let onError = (res: { err: wx.WxAdError }) => {
            this.sendMsg(create(WxSdkMsg.WatchVideo_FeedBack).init({
                result: res.err.code == 0 ? Enum_WxWatchVideoResult.NO_AD_COUNT : Enum_WxWatchVideoResult.ERROR,
                flag: flag,
                error: res.err
            }));
            videoMng.dg_onError.unregister(onError);
        };
        videoMng.dg_onError.register(onError, this);
        videoMng.show((isEnd, otherData) => {
            videoMng.dg_onError.unregister(onError);
            this.sendMsg(create(WxSdkMsg.WatchVideo_FeedBack).init({
                result: isEnd ? Enum_WxWatchVideoResult.COMPLETE : Enum_WxWatchVideoResult.GIVE_UP,
                flag: flag
            }));
            if (!isEnd && showAlertWhenGiveUp) {
                this.sendMsg(create(PopupMsg.ShowPopup).init({content: "要将视频看完才能获得相应奖励哦~！", showClose: true}));
            }
        }, this);
        app.appHttp.sendWatchTVStep(flag, 1, null, null);
    }

    private async getUserInfo(): Promise<{ user_id: number, openid: string, source: string, source_lv: number }> {
        let res: { user_id: number, openid: string, source: string, source_lv: number };
        await app.appHttp.getUseinfo((data, otherData) => {
            //     "coin": "货币",//int
            //     "help_card": "复活卡",//int
            //     "user_id": "用户id",//int
            //     "openid": "用户openid",//string
            //     "source": "来源标识符", //string
            //     "source_lv": "来源层级"//int
            this.sdk.openId = data.openid;
            res = {user_id: data.user_id, openid: data.openid, source: data.source, source_lv: data.source_lv};
        });
        return res;
    }

    private onShowBannerAd(msg: WxSdkMsg.ShowBannerAd) {
        this.sdk.wxBannerAdMng.showBanner(msg.body ? msg.body.style : null);
    }

    private onHideBannerAd(msg: WxSdkMsg.HideBannerAd) {
        this.sdk.wxBannerAdMng.hideBanner();
    }

    private get playerModel(): PlayerModel {
        return this.getModel(PlayerModel);
    }

    private get sdk(): WxSDKModel {
        return this.getModel(WxSDKModel);
    }
}
