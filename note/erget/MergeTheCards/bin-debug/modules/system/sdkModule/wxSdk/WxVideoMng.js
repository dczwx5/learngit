var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
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
var WxVideoMng = (function () {
    function WxVideoMng() {
        this._isPlaying = false;
        this._isError = false;
        this.loadVideoFailCount = 0;
        this._video = wx.createRewardedVideoAd({ adUnitId: app.globalConfig.videoAdUnitId });
        this.dg_onError = new VL.Delegate();
    }
    WxVideoMng.prototype.init = function () {
        var _this = this;
        // this._video.onLoad(() => {
        //     egret.log('激励视频 广告加载成功');
        // });
        var video = this._video;
        video.onError(function (res) {
            _this._isPlaying = false;
            _this._isError = true;
            var err = wx.WxAdErrorMap[res.errCode];
            _this.dg_onError.boardcast({ err: err });
            egret.log("\u6FC0\u52B1\u89C6\u9891\u9519\u8BEF\uFF1A" + err.code + "\n \u63CF\u8FF0\uFF1A" + err.desc + " \n \u539F\u56E0\uFF1A" + err.reason + "\n \u89E3\u51B3\u65B9\u6848\uFF1A" + err.solution);
        });
    };
    WxVideoMng.prototype.show = function (onVideoClose, thisObj, otherData) {
        if (otherData === void 0) { otherData = null; }
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            var video, isPlaying, _a, onClose;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        app.log("show isPlaying:" + this._isPlaying);
                        if (this._isPlaying) {
                            return [2 /*return*/];
                        }
                        video = this._video;
                        this.loadVideoFailCount = 0;
                        this._isError = false;
                        app.log("before showVideo isPlaying:" + this._isPlaying);
                        _a = this;
                        return [4 /*yield*/, this.showVideo()];
                    case 1:
                        isPlaying = _a._isPlaying = _b.sent();
                        app.log("after showVideo isPlaying:" + this._isPlaying);
                        if (!isPlaying) {
                            return [2 /*return*/];
                        }
                        onClose = function (res) {
                            // 用户点击了【关闭广告】按钮
                            // 小于 2.1.0 的基础库版本，res 是一个 undefined
                            var isEnd = false;
                            if (res && res.isEnded || res === undefined) {
                                // 正常播放结束，可以下发游戏奖励
                                isEnd = true;
                            }
                            video.offClose(onClose);
                            _this._isPlaying = false;
                            _this._isError = false;
                            onVideoClose.call(thisObj, isEnd, otherData);
                        };
                        video.onClose(onClose);
                        return [2 /*return*/];
                }
            });
        });
    };
    WxVideoMng.prototype.showVideo = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            var video, res;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        video = this._video;
                        res = true;
                        return [4 /*yield*/, video.show().catch(function (err) { return __awaiter(_this, void 0, void 0, function () {
                                return __generator(this, function (_a) {
                                    switch (_a.label) {
                                        case 0:
                                            res = false;
                                            if (!(!this._isError || this.loadVideoFailCount++ < 3)) return [3 /*break*/, 3];
                                            return [4 /*yield*/, video.load()];
                                        case 1:
                                            _a.sent();
                                            return [4 /*yield*/, this.showVideo()];
                                        case 2:
                                            res = _a.sent();
                                            _a.label = 3;
                                        case 3: return [2 /*return*/];
                                    }
                                });
                            }); })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, res];
                }
            });
        });
    };
    return WxVideoMng;
}());
__reflect(WxVideoMng.prototype, "WxVideoMng");
//# sourceMappingURL=WxVideoMng.js.map