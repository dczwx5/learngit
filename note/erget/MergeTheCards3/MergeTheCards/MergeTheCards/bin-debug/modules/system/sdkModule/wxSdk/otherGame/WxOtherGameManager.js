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
var WxOtherGameManager = (function () {
    function WxOtherGameManager() {
        this.dg_dataChanged = new VL.Delegate;
        /**每个组当前轮到的数据的索引*/
        this._currGroupDataIdx = [];
    }
    WxOtherGameManager.prototype.setInfo = function (otherGameDataGroups) {
        this._otherGameDataGroups = otherGameDataGroups;
        for (var i = 0, l = otherGameDataGroups.length; i < l; i++) {
            this._currGroupDataIdx.push(0);
        }
        this.dg_dataChanged.boardcast();
    };
    /**
     * 获指定组的当前数据
     * @param groupIdx 从0开始
     * @returns {WxOtherGameData}
     */
    WxOtherGameManager.prototype.getCurrGameData = function (groupIdx) {
        var group = this._otherGameDataGroups[groupIdx];
        var dataIdx = this._currGroupDataIdx[groupIdx];
        return group[dataIdx];
    };
    Object.defineProperty(WxOtherGameManager.prototype, "groupCount", {
        get: function () {
            if (!this._otherGameDataGroups) {
                return 0;
            }
            return this._otherGameDataGroups.length;
        },
        enumerable: true,
        configurable: true
    });
    /**
     * 跳转至指定导流组的当前游戏，并将该组数据更新至下一个游戏
     * @param groupIdx
     * @returns {Promise<T>}
     */
    WxOtherGameManager.prototype.toOtherGame = function (groupIdx) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        var otherGameData = _this.getCurrGameData(groupIdx);
                        wx.navigateToMiniProgram({
                            appId: otherGameData.game_appid,
                            success: function () {
                                app.log("\u8DF3\u8F6C\u81F3\u5176\u4ED6\u6E38\u620F\u6210\u529F appid\uFF1A" + otherGameData.game_appid);
                            },
                            complete: function () {
                                if (++_this._currGroupDataIdx[groupIdx] >= _this._otherGameDataGroups[groupIdx].length) {
                                    _this._currGroupDataIdx[groupIdx] = 0;
                                }
                                _this.dg_dataChanged.boardcast();
                                resolve();
                            },
                            fail: function () {
                                app.log("\u8DF3\u8F6C\u81F3\u5176\u4ED6\u6E38\u620F\u5931\u8D25\u2026\u2026 appid\uFF1A" + otherGameData.game_appid);
                            }
                        });
                    })];
            });
        });
    };
    return WxOtherGameManager;
}());
__reflect(WxOtherGameManager.prototype, "WxOtherGameManager");
//# sourceMappingURL=WxOtherGameManager.js.map