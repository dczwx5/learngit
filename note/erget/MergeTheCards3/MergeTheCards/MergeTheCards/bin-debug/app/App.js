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
(function (App_1) {
    var App = (function () {
        function App() {
        }
        // private _localTimestamp:number;
        // private _serverTimestamp:number;
        //
        // public  set serverTimestamp(value:number){
        //     app._localTimestamp = egret.getTimer();
        //     app._serverTimestamp = value;
        // }
        //
        // public  get serverTimestamp():number{
        //     let timestamp:number = app._serverTimestamp+Math.floor((egret.getTimer() - app._localTimestamp) * 0.001);
        //     return timestamp;
        // }
        App.prototype.init = function () {
            return __awaiter(this, void 0, void 0, function () {
                var globalConfig, _a, _b;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            this.reflector = new VL.Reflector.EgretReflector();
                            _a = this;
                            _b = App_1.GlobalCfg.bind;
                            return [4 /*yield*/, this.loadGlobalJson()];
                        case 1:
                            globalConfig = _a.globalConfig = new (_b.apply(App_1.GlobalCfg, [void 0, _c.sent()]))();
                            this.logger = new App_1.Logger();
                            if (globalConfig.isDebug) {
                                this.logger.init();
                            }
                            console.log("====================== check info =======================");
                            console.log("client_version:" + globalConfig.client_version);
                            console.log("pf:" + globalConfig.pf);
                            console.log("httpServer:" + globalConfig.httpServer);
                            console.log("serverPort:" + globalConfig.serverPort);
                            console.log("isDebug:" + globalConfig.isDebug);
                            console.log("=========================================================");
                            this.resManager = new VL.Resource.EgretResManager();
                            this.config = new App_1.Config();
                            this.mcHelper = new App_1.MCHelper();
                            this.easyLoadingManager = new App_1.EasyLoadingManager();
                            this.soundManager = new VL.Sound.SoundMgr(VL.Sound.EgretSound);
                            this.dragDropManager = new VL.DragDrop.DragDropManager();
                            this._http = new VL.Net.Http();
                            this.appHttp = new App_1.AppHttp().init(this._http, globalConfig.client_version, globalConfig.httpServer, globalConfig.serverPort);
                            return [2 /*return*/];
                    }
                });
            });
        };
        App.prototype.loadGlobalJson = function () {
            return __awaiter(this, void 0, void 0, function () {
                var _this = this;
                return __generator(this, function (_a) {
                    return [2 /*return*/, new Promise(function (resolve, reject) {
                            var urlReq = new egret.URLRequest("resource/config/global.json");
                            var loader = new egret.URLLoader(urlReq);
                            loader.dataFormat = egret.URLLoaderDataFormat.TEXT;
                            loader.once(egret.Event.COMPLETE, function (e) {
                                var json = JSON.parse(loader.data);
                                resolve(json);
                            }, _this);
                            loader.once(egret.IOErrorEvent.IO_ERROR, function (e) {
                                reject(e.data);
                            }, _this);
                        })];
                });
            });
        };
        App.prototype.getConfig = function (ref) {
            return this.config.getConfig(ref);
        };
        /**
         * 输出一个日志信息到控制台。
         * @param message 要输出到控制台的信息
         * @param optionalParams 要输出到控制台的额外信息
         * @language zh_CN
         */
        App.prototype.log = function (message) {
            var optionalParams = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                optionalParams[_i - 1] = arguments[_i];
            }
            (_a = this.logger).log.apply(_a, [message].concat(optionalParams));
            var _a;
        };
        /**
         * 输出一个警告信息到控制台。
         * @param message 要输出到控制台的信息
         * @param optionalParams 要输出到控制台的额外信息
         * @language zh_CN
         */
        App.prototype.warn = function (message) {
            var optionalParams = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                optionalParams[_i - 1] = arguments[_i];
            }
            (_a = this.logger).warn.apply(_a, [message].concat(optionalParams));
            var _a;
        };
        /**
         * 输出一个错误信息到控制台。
         * @param message 要输出到控制台的信息
         * @param optionalParams 要输出到控制台的额外信息
         * @language zh_CN
         */
        App.prototype.error = function (message) {
            var optionalParams = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                optionalParams[_i - 1] = arguments[_i];
            }
            (_a = this.logger).error.apply(_a, [message].concat(optionalParams));
            var _a;
        };
        return App;
    }());
    App_1.App = App;
    __reflect(App.prototype, "App.App");
})(App || (App = {}));
var app = new App.App();
//# sourceMappingURL=App.js.map