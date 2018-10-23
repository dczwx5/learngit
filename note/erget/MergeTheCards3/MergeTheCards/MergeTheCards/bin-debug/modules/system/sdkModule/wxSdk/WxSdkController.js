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
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = y[op[0] & 2 ? "return" : op[0] ? "throw" : "next"]) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [0, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var WxSdkController = (function (_super) {
    __extends(WxSdkController, _super);
    function WxSdkController() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    WxSdkController.prototype.activate = function () {
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
    };
    WxSdkController.prototype.deactivate = function () {
        this.sdk.dg_onActiveChanged.unregister(this.onActiveChanged);
        this.unregMsg(SDKMsg.Login, this.onLogin, this);
        this.unregMsg(WxSdkMsg.SendOpenDataContextCmd, this.onSendOpenDataContextCmd, this);
        this.unregMsg(WxSdkMsg.SetUserCloudStorage, this.onSetUserCloudStorage, this);
        this.unregMsg(WxSdkMsg.Share, this.onShare, this);
        this.unregMsg(WxSdkMsg.ToOtherGame, this.onToOtherGame, this);
        this.unregMsg(WxSdkMsg.WatchVideo_CMD, this.onWatchVideo, this);
        this.unregMsg(WxSdkMsg.ShowBannerAd, this.onShowBannerAd, this);
        this.unregMsg(WxSdkMsg.HideBannerAd, this.onHideBannerAd, this);
    };
    WxSdkController.prototype.onActiveChanged = function (data) {
        if (data.isActive) {
            this.handleShareQuery(data.showArgs.query);
        }
    };
    WxSdkController.prototype.handleShareQuery = function (newQuery) {
        // console.log("处理分享进入");
        // console.log(this.isHandleShareQuery);
        // console.log(PlayerData.id);
        // console.log(App.query);
        // let appQuery = App.query;
        // if (!appQuery || !appQuery["openId"] || !PlayerData.openId || PlayerData.openId == appQuery["openId"] || (this._lastQuery && this._lastQuery["openId"] == appQuery["openId"])) return;
        var sdk = this.sdk;
        var shareQueryData = sdk.shareQueryData;
        var playerOpenId = sdk.openId;
        var send = false;
        if (newQuery && newQuery.inviteOpenId && newQuery.inviteOpenId != playerOpenId) {
            if (shareQueryData && shareQueryData.inviteOpenId) {
                send = newQuery.inviteOpenId != shareQueryData.inviteOpenId;
            }
            else {
                send = true;
            }
            sdk.shareQueryData = newQuery;
        }
        if (send) {
            app.appHttp.enterFromShare(shareQueryData.inviteUserId, shareQueryData.inviteOpenId, function (data, otherData) {
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
    };
    WxSdkController.prototype.onLogin = function (msg) {
        var _this = this;
        app.log("sdkLogin");
        // app.log(`systemInfo:`, wx.getSystemInfoSync());
        wx.login({
            success: function (res) { return __awaiter(_this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.reqLogin(res.code)];
                        case 1:
                            _a.sent();
                            return [4 /*yield*/, this.reqExamineStatus()];
                        case 2:
                            _a.sent();
                            return [4 /*yield*/, this.reqAboutShare()];
                        case 3:
                            _a.sent();
                            return [4 /*yield*/, this.reqGetOtherGamesInfo()];
                        case 4:
                            _a.sent();
                            return [2 /*return*/];
                    }
                });
            }); }
        });
    };
    WxSdkController.prototype.reqLogin = function (wxResCode) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            var sdk, shareData;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        sdk = this.sdk;
                        shareData = sdk.shareQueryData;
                        return [4 /*yield*/, app.appHttp.login(shareData.inviteOpenId || '', shareData.inviteUserId || 0, sdk.systemPf || 0, shareData.source || '', shareData.source_lv || 0, shareData.contentId || 0, wxResCode, function (data, otherData) {
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
                                var pfUserInfo = _this.sdk.pfUserInfo;
                                pfUserInfo.nickname = data.nickname;
                                pfUserInfo.gender = data.sex;
                                _this.sdk.openId = data.openid;
                                var playerModel = _this.playerModel;
                                playerModel.uid = data.id;
                                var storageData = playerModel.storageData;
                                var highScore = parseFloat(data.score_max);
                                var lv = parseInt(data.lv);
                                storageData.highScore = Math.max(storageData.highScore, highScore);
                                storageData.lv = Math.max(storageData.lv, lv);
                                if (storageData.lv > lv || storageData.highScore > highScore) {
                                    app.appHttp.submitBattleRecord(storageData.lv, storageData.highScore);
                                }
                                playerModel.storageData = storageData;
                                playerModel.highScore = storageData.highScore;
                                playerModel.lv = storageData.lv;
                                _this.handleShareQuery(wx.getLaunchOptionsSync().query);
                            })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    WxSdkController.prototype.reqAboutShare = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, app.appHttp.getAboutShare(function (data, otherData) {
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
                            var sdk = _this.sdk;
                            sdk.shareInfoList = [];
                            var content_list = data.content_list;
                            var id_list = data.id_list;
                            var image_list = data.image_list;
                            for (var i = 0, l = id_list.length; i < l; i++) {
                                sdk.shareInfoList.push({
                                    content: content_list[i],
                                    contentId: id_list[i],
                                    imgUrl: image_list[i]
                                });
                            }
                        })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    WxSdkController.prototype.reqGetOtherGamesInfo = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, app.appHttp.getOtherGamesInfo(function (data, otherData) {
                            _this.sdk.otherGameMng.setInfo([data.image_list, data.image_list_2]);
                        })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    WxSdkController.prototype.reqExamineStatus = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, app.appHttp.getGameExamineStatus(function (data, otherData) {
                            // "status": 游戏状态 1正常版本 2审核版本 ,// int
                            // "share_type": 是否只能分享到群 1只能分享到群 2个人和群都可以, // int
                            _this.sdk.isExamine = data.status == 2;
                        })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    WxSdkController.prototype.onSendOpenDataContextCmd = function (msg) {
        var head = msg.body.head;
        var body = msg.body.body;
        switch (head) {
            case WxOpenDataContextMsg.FRIEND_RANK_LIST:
                this.sendMsg(create(WxSdkMsg.OpenFriendRankListView));
                break;
        }
        var odcMsg = new WxOpenDataContextMsg(head, body);
        wx.getOpenDataContext().postMessage(odcMsg);
    };
    WxSdkController.prototype.onSetUserCloudStorage = function (msg) {
        wx.setUserCloudStorage(msg.body);
    };
    WxSdkController.prototype.onShare = function (msg) {
        return __awaiter(this, void 0, void 0, function () {
            var userInfo, shareInfo, strQuery;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.getUserInfo()];
                    case 1:
                        userInfo = _a.sent();
                        shareInfo = this.sdk.getRandomShareInfo();
                        app.log("shareInfo:", shareInfo);
                        strQuery = {
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
                        return [2 /*return*/];
                }
            });
        });
    };
    WxSdkController.prototype.onToOtherGame = function (msg) {
        var groupIdx = msg.body.groupIdx;
        var otherGameMgr = this.sdk.otherGameMng;
        otherGameMgr.toOtherGame(groupIdx);
    };
    WxSdkController.prototype.onWatchVideo = function (msg) {
        var _this = this;
        var videoMng = this.sdk.videoMng;
        var flag = msg.body.flag;
        var showAlertWhenGiveUp = msg.body.showAlertWhenGiveUp;
        var onError = function (res) {
            _this.sendMsg(create(WxSdkMsg.WatchVideo_FeedBack).init({
                result: res.err.code == 0 ? Enum_WxWatchVideoResult.NO_AD_COUNT : Enum_WxWatchVideoResult.ERROR,
                flag: flag,
                error: res.err
            }));
            videoMng.dg_onError.unregister(onError);
        };
        videoMng.dg_onError.register(onError, this);
        videoMng.show(function (isEnd, otherData) {
            videoMng.dg_onError.unregister(onError);
            _this.sendMsg(create(WxSdkMsg.WatchVideo_FeedBack).init({
                result: isEnd ? Enum_WxWatchVideoResult.COMPLETE : Enum_WxWatchVideoResult.GIVE_UP,
                flag: flag
            }));
            if (!isEnd && showAlertWhenGiveUp) {
                _this.sendMsg(create(PopupMsg.ShowPopup).init({ content: "要将视频看完才能获得相应奖励哦~！", showClose: true }));
            }
        }, this);
        app.appHttp.sendWatchTVStep(flag, 1, null, null);
    };
    WxSdkController.prototype.getUserInfo = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            var res;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, app.appHttp.getUseinfo(function (data, otherData) {
                            //     "coin": "货币",//int
                            //     "help_card": "复活卡",//int
                            //     "user_id": "用户id",//int
                            //     "openid": "用户openid",//string
                            //     "source": "来源标识符", //string
                            //     "source_lv": "来源层级"//int
                            _this.sdk.openId = data.openid;
                            res = { user_id: data.user_id, openid: data.openid, source: data.source, source_lv: data.source_lv };
                        })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, res];
                }
            });
        });
    };
    WxSdkController.prototype.onShowBannerAd = function (msg) {
        this.sdk.wxBannerAdMng.showBanner(msg.body ? msg.body.style : null);
    };
    WxSdkController.prototype.onHideBannerAd = function (msg) {
        this.sdk.wxBannerAdMng.hideBanner();
    };
    Object.defineProperty(WxSdkController.prototype, "playerModel", {
        get: function () {
            return this.getModel(PlayerModel);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(WxSdkController.prototype, "sdk", {
        get: function () {
            return this.getModel(WxSDKModel);
        },
        enumerable: true,
        configurable: true
    });
    return WxSdkController;
}(VoyaMVC.Controller));
__reflect(WxSdkController.prototype, "WxSdkController");
//# sourceMappingURL=WxSdkController.js.map