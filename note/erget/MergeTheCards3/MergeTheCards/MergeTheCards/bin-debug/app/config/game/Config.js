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
    var Config = (function () {
        function Config() {
        }
        /**
         * 初始化
         * @param data  JSONObject
         */
        // public async init() {
        //     let data = await this.loadConfig();
        //     this.s_configs = {};
        //     for (let key in data) {
        //         let clazz = egret.getDefinitionByName(key);
        //         if (!clazz) {
        //             app.warn(`${name}在ConfigBase文件中未定义`);
        //             continue;
        //         }
        //         let values: any[] = data[key].data;
        //         let size: number = values.length;
        //         let dic = {};
        //         this.s_configs[key] = dic;
        //         for (let i: number = 0; i < size; i++) {
        //             let config = new clazz();
        //             let attrs: string[] = config.attrs();
        //             let value: any[] = values[i];
        //             for (let j: number = 0, jLen: number = attrs.length; j < jLen; j++) {
        //                 config[attrs[j]] = value[j];
        //             }
        //             dic[config[attrs[0]]] = config;
        //         }
        //     }
        //
        // }
        /**
         * 初始化
         */
        Config.prototype.init = function () {
            return __awaiter(this, void 0, void 0, function () {
                var _this = this;
                var data;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, this.loadConfig()];
                        case 1:
                            data = _a.sent();
                            this.s_configs = {};
                            data.map(function (item) {
                                var clazz = egret.getDefinitionByName(item.name);
                                if (!clazz) {
                                    egret.log(name + "\u5728ConfigBase\u6587\u4EF6\u4E2D\u672A\u5B9A\u4E49");
                                }
                                else {
                                    var values = item.data;
                                    var size = values.length;
                                    var dic = {};
                                    _this.s_configs[item.name] = dic;
                                    for (var i = 0; i < size; i++) {
                                        var config = new clazz();
                                        var attrs = config.attrs();
                                        var value = values[i];
                                        for (var j = 0, jLen = attrs.length; j < jLen; j++) {
                                            config[attrs[j]] = value[j];
                                        }
                                        dic[config[attrs[0]]] = config;
                                    }
                                }
                            });
                            return [2 /*return*/];
                    }
                });
            });
        };
        Config.prototype.loadConfig = function () {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, RES.getResAsync("config_json")];
                        case 1: return [2 /*return*/, _a.sent()];
                    }
                });
            });
        };
        /**
         * 获取配置文件
         * 示例：let configs:Dictionary<HeadConfig> = Config.getConfig(HeadConfig);
         * let configs:Dictionary<HeadConfig> = Config.getConfig(HeadConfig);
         * configs.get('1').emojiID;
         */
        // public static getConfig<T extends {attrs():string[]}>(ref: new ()=>T): Dictionary<T> {
        Config.prototype.getConfig = function (ref) {
            var name = egret.getQualifiedClassName(ref);
            return this.s_configs[name];
        };
        return Config;
    }());
    App.Config = Config;
    __reflect(Config.prototype, "App.Config");
})(App || (App = {}));
//# sourceMappingURL=Config.js.map