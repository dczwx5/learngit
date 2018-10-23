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
var App;
(function (App) {
    var AppHttpBase = (function () {
        function AppHttpBase() {
            this._loginTs_ms = 0;
            this._serverTs_ms = 0;
            this.respChecker = new App.AppHttpRespChecker();
        }
        AppHttpBase.prototype.init = function (http, clientVersion, httpServer, serverPort, gameId) {
            if (gameId === void 0) { gameId = 1; }
            this.http = http;
            this.httpServer = httpServer;
            this.httpServerPort = serverPort;
            this.clientVersion = clientVersion;
            this.gameId = gameId;
            return this;
        };
        Object.defineProperty(AppHttpBase.prototype, "serverTimestamp", {
            set: function (value) {
                this._loginTs_ms = egret.getTimer();
                this._serverTs_ms = value;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(AppHttpBase.prototype, "serverTs_s", {
            get: function () {
                return this._serverTs_ms + Math.floor((egret.getTimer() - this._loginTs_ms) * 0.001);
            },
            enumerable: true,
            configurable: true
        });
        AppHttpBase.prototype.createReqPack = function (data, otherData) {
            data = this.ensurePackData(data);
            var headObj = {
                "Content-Type": "application/x-www-form-urlencoded" //这是键值对形式
                // "Content-Type": "multipart/form-data";//这是把数据合成一条
            };
            // return create(VL.Net.HttpReqPack).init(this.httpServer, this.httpServerPort, egret.HttpMethod.GET, data, otherData, headObj);
            return create(VL.Net.HttpReqPack).init(this.httpServer, this.httpServerPort, egret.HttpMethod.POST, data, otherData, headObj);
        };
        AppHttpBase.prototype.ensurePackData = function (data) {
            if (!data) {
                return;
            }
            if (this.token) {
                data['token'] = this.token;
            }
            data['version'] = this.clientVersion;
            data['game_id'] = this.gameId;
            data['timestamp'] = this.serverTs_s;
            data['sig'] = new Utils.md5().hex_md5(this.token + this.serverTs_s);
            return data;
        };
        AppHttpBase.prototype.sendHttp = function (data, onResp, thisArg, otherData) {
            return __awaiter(this, void 0, void 0, function () {
                var _this = this;
                var onHttpResp;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            onHttpResp = function (packData, otherData) {
                                var data = JSON.parse(packData);
                                if (onResp) {
                                    if (_this.respChecker.check(data).pass) {
                                        onResp(data.data, otherData);
                                    }
                                }
                            };
                            return [4 /*yield*/, this.http.send(this.createReqPack(data, otherData), onHttpResp, thisArg)];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        return AppHttpBase;
    }());
    App.AppHttpBase = AppHttpBase;
    __reflect(AppHttpBase.prototype, "App.AppHttpBase");
})(App || (App = {}));
//# sourceMappingURL=AppHttpBase.js.map