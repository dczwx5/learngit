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
var App;
(function (App) {
    var AppHttp = (function (_super) {
        __extends(AppHttp, _super);
        function AppHttp() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        AppHttp.prototype.init = function (http, clientVersion, httpServer, serverPort) {
            _super.prototype.init.call(this, http, clientVersion, httpServer, serverPort);
            return this;
        };
        /**
         * 登录
         * @param {string} inviteOpenId
         * @param {number} inviteUserId
         * @param {Enum_System} system
         * @param {string} source
         * @param {number} source_lv
         * @param {number} shareId
         * @param {string} code
         * @param {(data: any, otherData: any) => void} onResp
         * @param thisArg
         * @param userData
         * @returns {Promise<VL.Net.HttpRespPack>}
         */
        AppHttp.prototype.login = function (inviteOpenId, inviteUserId, system, source, source_lv, shareId, code, onResp, thisArg, userData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.sendHttp({
                                api_name: "weixin_reg_login",
                                jscode: code,
                                nikename: "",
                                sex: "",
                                avatar: "",
                                content_id: shareId,
                                sys: system,
                                source: source,
                                source_lv: source_lv,
                                invite_openid: inviteOpenId,
                                invite_user_id: inviteUserId,
                            }, function (data, otherData) {
                                // if (data.code == Enum_HttpRespCode.SUCCESS) {
                                this.serverTimestamp = parseInt(data["timestamp"]);
                                this.token = data["token"];
                                onResp.call(thisArg, data, otherData);
                                // }
                            }.bind(this), this, userData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         * 提交战报
         * @param lv
         * @param score
         * @param onResp
         * @param thisArg
         * @param userData
         * @returns {Promise<HttpRespPack>}
         */
        AppHttp.prototype.submitBattleRecord = function (lv, score, onResp, thisArg, userData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            app.log("========= submit battle record =======");
                            return [4 /*yield*/, this.sendHttp({
                                    api_name: "combat",
                                    lv: lv,
                                    score: score
                                }, onResp, this, userData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         * 获取分享文案和图片
         * @param onResp
         * @param thisArg
         * @param userData
         */
        AppHttp.prototype.getAboutShare = function (onResp, thisArg, userData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.sendHttp({
                                api_name: "get_share_content_image_list",
                            }, onResp, this, userData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         * 分享统计
         * @param shareId 分享文案id
         * @param onResp
         * @param thisArg
         * @param userData
         */
        AppHttp.prototype.shareStatistics = function (shareId, onResp, thisArg, userData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.sendHttp({
                                api_name: "share_log",
                                content_id: shareId
                            }, onResp, thisArg, userData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         * 获取游戏审核状态（1正常版本 2审核版本）
         * @param onResp
         * @param thisArg
         * @param userData
         */
        AppHttp.prototype.getGameExamineStatus = function (onResp, thisArg, userData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.sendHttp({
                                api_name: "get_version_status",
                            }, onResp, this, userData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         * 分享进入
         * @param id
         * @param openId
         * @param onResp
         * @param thisArg
         * @param userData
         */
        AppHttp.prototype.enterFromShare = function (id, openId, onResp, thisArg, userData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.sendHttp({
                                api_name: "invite_into_game",
                                invite_openid: openId,
                                invite_user_id: id,
                            }, onResp, thisArg, userData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         *
         * @param onResp
         * @param thisArg
         * @param userData
         * @returns {Promise<HttpRespPack>}
         */
        AppHttp.prototype.getOtherGamesInfo = function (onResp, thisArg, userData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.sendHttp({
                                api_name: "get_guide_image_list_new",
                            }, onResp, thisArg, userData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         * 获取用户信息
         * @param onResp
         * @param thisArg
         * @param otherData
         */
        AppHttp.prototype.getUseinfo = function (onResp, thisArg, otherData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.sendHttp({
                                api_name: "get_base_info",
                            }, onResp, thisArg, otherData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         * 发送统计视频
         * @param type 视频入口
         * @param action_type   1,开始观看；2，完成
         * @param onResp
         * @param thisArg
         * @param otherData
         */
        AppHttp.prototype.sendWatchTVStep = function (type, action_type, onResp, thisArg, otherData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.sendHttp({
                                api_name: "video_log",
                                type: type,
                                action_type: action_type
                            }, onResp, thisArg, otherData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         * 群分享唯一检测
         * @param shareId 分享文案id
         * @param onResp
         * @param thisArg
         * @param otherData
         */
        AppHttp.prototype.checkGroupShare = function (encrypted, iv, onResp, thisArg, otherData) {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.sendHttp({
                                api_name: "check_share_group",
                                encrypted: encrypted,
                                iv: iv
                            }, onResp, thisArg, otherData)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        return AppHttp;
    }(App.AppHttpBase));
    App.AppHttp = AppHttp;
    __reflect(AppHttp.prototype, "App.AppHttp");
})(App || (App = {}));
//# sourceMappingURL=AppHttp.js.map