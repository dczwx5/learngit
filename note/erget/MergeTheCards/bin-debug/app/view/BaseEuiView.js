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
    var BaseEuiView = (function (_super) {
        __extends(BaseEuiView, _super);
        /**
         *
         * @param skinName 皮肤类名
         * @param parent 父级容器
         */
        function BaseEuiView(skinName, parent) {
            var _this = _super.call(this) || this;
            _this._isOpened = false;
            _this._isInited = false;
            _this.dg_inited = new VL.Delegate();
            _this.skinName = skinName;
            _this.myParent = parent;
            return _this;
        }
        BaseEuiView.prototype.createChildren = function () {
            _super.prototype.createChildren.call(this);
            this.init();
        };
        BaseEuiView.prototype.init = function () {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            if (!(this.resources.length > 0)) return [3 /*break*/, 2];
                            return [4 /*yield*/, this.loadRes()];
                        case 1:
                            _a.sent();
                            _a.label = 2;
                        case 2:
                            this.onInit();
                            this._isInited = true;
                            this.dg_inited.boardcast();
                            return [2 /*return*/];
                    }
                });
            });
        };
        BaseEuiView.prototype.loadRes = function () {
            return __awaiter(this, void 0, void 0, function () {
                var _this = this;
                return __generator(this, function (_a) {
                    return [2 /*return*/, new Promise(function (resolve) {
                            app.resManager.loadResTask({
                                keys: _this.resources,
                                taskName: getClassName(_this),
                                onComplete: function (task) {
                                    resolve();
                                }
                            });
                        })];
                });
            });
        };
        /**
         * 面板开启执行函数
         */
        BaseEuiView.prototype.open = function (param) {
            if (param === void 0) { param = null; }
            StageUtils.getStage().addEventListener(egret.Event.RESIZE, this.onResize, this);
            this.addEventListener(egret.Event.RESIZE, this.onResize, this);
            this.updateLayout();
            this.addToParent();
            this._isOpened = true;
        };
        /**
         * 面板关闭执行函数
         */
        BaseEuiView.prototype.close = function (param) {
            if (param === void 0) { param = null; }
            this.removeFromParent();
            this._isOpened = false;
            StageUtils.getStage().removeEventListener(egret.Event.RESIZE, this.onResize, this);
            this.removeEventListener(egret.Event.RESIZE, this.onResize, this);
        };
        BaseEuiView.prototype.onResize = function (e) {
            this.updateLayout();
        };
        BaseEuiView.prototype.updateLayout = function () {
            this.width = StageUtils.getStageWidth();
            this.height = StageUtils.getStageHeight();
        };
        /**
         * 添加到父级
         */
        BaseEuiView.prototype.addToParent = function () {
            this._myParent.addChild(this);
        };
        /**
         * 从父级移除
         */
        BaseEuiView.prototype.removeFromParent = function () {
            if (this.parent) {
                this.parent.removeChild(this);
            }
        };
        /**
         * 销毁
         */
        BaseEuiView.prototype.destroy = function () {
            this.onDestroy();
            this.removeFromParent();
            this._isInited = false;
        };
        Object.defineProperty(BaseEuiView.prototype, "myParent", {
            /**
             * 获取我的父级
             * @returns {egret.DisplayObjectContainer}
             */
            get: function () {
                return this._myParent;
            },
            set: function (parent) {
                this._myParent = parent;
                if (this.isOpened) {
                    this.addToParent();
                }
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(BaseEuiView.prototype, "isOpened", {
            get: function () {
                return this._isOpened;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(BaseEuiView.prototype, "isInited", {
            get: function () {
                return this._isInited;
            },
            enumerable: true,
            configurable: true
        });
        return BaseEuiView;
    }(eui.Component));
    App.BaseEuiView = BaseEuiView;
    __reflect(BaseEuiView.prototype, "App.BaseEuiView", ["App.IBaseView", "IBaseComponent"]);
})(App || (App = {}));
//# sourceMappingURL=BaseEuiView.js.map