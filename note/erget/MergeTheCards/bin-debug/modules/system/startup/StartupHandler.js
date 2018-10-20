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
var StartupController = (function (_super) {
    __extends(StartupController, _super);
    function StartupController() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    StartupController.prototype.activate = function () {
        this.regMsg(StartupMsg.Startup, this.onStartup, this);
    };
    StartupController.prototype.deactivate = function () {
        this.unregMsg(StartupMsg.Startup, this.onStartup, this);
    };
    StartupController.prototype.onStartup = function (msg) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        // app.init(await this.loadGlobalJson());
                        this.sendMsg(create(SystemMsg.EnterScene).init({ scene: MainScene }));
                        return [4 /*yield*/, this.loadCfg()];
                    case 1:
                        _a.sent();
                        this.regMsg(LoadMsg.OnTaskComplete, this.onLoadResComplete, this);
                        this.sendMsg(create(LoadMsg.OpenLoadingView).init({ taskName: "preload", closeAfterComplete: false }));
                        this.sendMsg(create(LoadMsg.LoadRes).init({ sources: ['preload'], taskName: "preload" }));
                        return [2 /*return*/];
                }
            });
        });
    };
    // public async loadGlobalJson(): Promise<App.IGlobalJson> {
    //     return new Promise<App.IGlobalJson>((resolve, reject) => {
    //         let urlReq = new egret.URLRequest("resource/config/global.json");
    //         let loader = new egret.URLLoader(urlReq);
    //         loader.dataFormat = egret.URLLoaderDataFormat.TEXT;
    //         loader.once(egret.Event.COMPLETE, function (e: egret.Event) {
    //             let json = JSON.parse(loader.data);
    //             resolve(json);
    //         }, this);
    //         loader.once(egret.IOErrorEvent.IO_ERROR, function(e: egret.IOErrorEvent){
    //             reject(e.data);
    //         }, this);
    //     });
    // }
    StartupController.prototype.loadCfg = function () {
        return __awaiter(this, void 0, void 0, function () {
            var resRoot, e_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 4, , 5]);
                        resRoot = app.globalConfig.resRoot;
                        return [4 /*yield*/, RES.loadConfig(resRoot + "default.res.json", resRoot)];
                    case 1:
                        _a.sent();
                        return [4 /*yield*/, this.loadTheme()];
                    case 2:
                        _a.sent();
                        return [4 /*yield*/, app.config.init()];
                    case 3:
                        _a.sent();
                        return [3 /*break*/, 5];
                    case 4:
                        e_1 = _a.sent();
                        console.error(e_1);
                        return [3 /*break*/, 5];
                    case 5: return [2 /*return*/];
                }
            });
        });
    };
    StartupController.prototype.loadTheme = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve, reject) {
                        // load skin theme configuration file, you can manually modify the file. And replace the default skin.
                        //加载皮肤主题配置文件,可以手动修改这个文件。替换默认皮肤。
                        var theme = new eui.Theme("resource/default.thm.json", StageUtils.getStage());
                        theme.addEventListener(eui.UIEvent.COMPLETE, function () {
                            resolve();
                        }, _this);
                    })];
            });
        });
    };
    StartupController.prototype.onLoadResComplete = function (msg) {
        if (msg.body.taskName == 'preload') {
            this.unregMsg(LoadMsg.OnTaskComplete, this.onLoadResComplete, this);
            this.sendMsg(create(LoadMsg.CloseLoadingView));
            // this.sendMsg(create(TestModuleMsg.OpenTestView));
            // this.sendMsg(create(TestModuleMsg.SetTfContent).init({num:1, str:'hello world~!'}));
            // this.sendMsg(create(TestModuleMsg.SetTfVisible).init({visible:true}));
            this.sendMsg(create(SDKMsg.InitSdk).init({ pf: app.globalConfig.pf }));
            this.sendMsg(create(SDKMsg.Login));
            this.sendMsg(create(MainModuleMsg.OpenMainView));
        }
    };
    return StartupController;
}(VoyaMVC.Controller));
__reflect(StartupController.prototype, "StartupController");
//# sourceMappingURL=StartupHandler.js.map