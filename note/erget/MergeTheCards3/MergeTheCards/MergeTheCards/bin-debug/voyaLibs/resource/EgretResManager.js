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
var VL;
(function (VL) {
    var Resource;
    (function (Resource) {
        var EgretResManager = (function () {
            function EgretResManager(tempGroupBaseName) {
                if (tempGroupBaseName === void 0) { tempGroupBaseName = "tempLoadTask"; }
                this.tempGroupIdx = 0;
                this.taskCanceled = false;
                this.tempGroupBaseName = tempGroupBaseName;
                this.loadTaskQueue = [];
                this.taskReporter = { onProgress: this.onProgress.bind(this), onCancel: this.onCancel.bind(this) };
            }
            EgretResManager.prototype.loadConfig = function (url, resourceRoot) {
                return __awaiter(this, void 0, void 0, function () {
                    return __generator(this, function (_a) {
                        return [2 /*return*/, RES.loadConfig(url, resourceRoot)];
                    });
                });
            };
            EgretResManager.prototype.loadResTask = function (loadTask) {
                var groupName = this.tempGroupBaseName + this.tempGroupIdx;
                loadTask.taskName = loadTask.taskName || groupName;
                this.loadTaskQueue.push(loadTask);
                this.loadNextTask();
            };
            EgretResManager.prototype.loadNextTask = function () {
                return __awaiter(this, void 0, void 0, function () {
                    var task, keys, taskName, groupName;
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0:
                                if (this.isRunningTask) {
                                    return [2 /*return*/];
                                }
                                task = this.loadTaskQueue.shift();
                                if (!task) {
                                    return [2 /*return*/];
                                }
                                this.currTask = task;
                                keys = task.keys, taskName = task.taskName;
                                groupName = this.tempGroupBaseName + this.tempGroupIdx++;
                                taskName = taskName || groupName;
                                if (!(keys && keys.length > 0)) return [3 /*break*/, 4];
                                if (!RES.createGroup(groupName, keys, true)) return [3 /*break*/, 2];
                                app.log("\u52A0\u8F7D\u4EFB\u52A1 taskName:" + taskName + "  keys:" + keys);
                                return [4 /*yield*/, RES.loadGroup(groupName, 0, this.taskReporter)];
                            case 1:
                                _a.sent();
                                this.onTaskOver();
                                return [3 /*break*/, 3];
                            case 2:
                                app.warn("\u8D44\u6E90\u7EC4\u521B\u5EFA\u5931\u8D25 taskName:" + taskName + ",  keys:" + keys);
                                this.onCancel();
                                this.onTaskOver();
                                _a.label = 3;
                            case 3: return [3 /*break*/, 5];
                            case 4:
                                this.onTaskOver();
                                _a.label = 5;
                            case 5: return [2 /*return*/];
                        }
                    });
                });
            };
            EgretResManager.prototype.onTaskOver = function () {
                var task = this.currTask;
                this.currTask = null;
                if (this.taskCanceled) {
                    this.taskCanceled = false;
                    if (task.onCancel) {
                        app.warn("\u52A0\u8F7D\u4EFB\u52A1\u88AB\u53D6\u6D88 taskName:" + task.taskName);
                        task.onCancel(task);
                    }
                }
                else {
                    if (task.onComplete) {
                        app.log("\u52A0\u8F7D\u4EFB\u52A1\u7ED3\u675F taskName:" + task.taskName);
                        task.onComplete(task);
                    }
                }
                this.loadNextTask();
            };
            /**
             * 进度回调
             */
            EgretResManager.prototype.onProgress = function (current, total) {
                var task = this.currTask;
                app.log(current + ' / ' + total);
                if (task.onProgress) {
                    task.onProgress(task, current, total);
                }
            };
            /**
             * 取消回调
             */
            EgretResManager.prototype.onCancel = function () {
                this.taskCanceled = true;
            };
            EgretResManager.prototype.getRes = function (key) {
                return RES.getRes(key);
            };
            EgretResManager.prototype.getResAsync_promise = function (key) {
                return __awaiter(this, void 0, void 0, function () {
                    return __generator(this, function (_a) {
                        return [2 /*return*/, RES.getResAsync(key)];
                    });
                });
            };
            EgretResManager.prototype.getResAsync_callback = function (key, compFunc, thisObject) {
                return RES.getResAsync(key, compFunc, thisObject);
            };
            EgretResManager.prototype.destroyRes = function (name, force) {
                if (force === void 0) { force = true; }
                return __awaiter(this, void 0, void 0, function () {
                    return __generator(this, function (_a) {
                        return [2 /*return*/, !RES.getRes(name) || RES.destroyRes(name, force)];
                    });
                });
            };
            EgretResManager.prototype.destroyReses = function (names, force) {
                if (force === void 0) { force = true; }
                for (var i = 0, l = names.length; i < l; i++) {
                    this.destroyRes(names[i], force);
                }
            };
            /**
             * 根据URL加载资源
             * @param url 资源URL
             * @param dataFormat 可用 egret.URLLoaderDataFormat 里的成员
             *  控制是以文本 (URLLoaderDataFormat.TEXT)、原始二进制数据 (URLLoaderDataFormat.BINARY) 还是 URL 编码变量 (URLLoaderDataFormat.VARIABLES) 接收下载的数据。
             如果 dataFormat 属性的值是 URLLoaderDataFormat.TEXT，则所接收的数据是一个包含已加载文件文本的字符串。
             如果 dataFormat 属性的值是 URLLoaderDataFormat.BINARY，则所接收的数据是一个包含原始二进制数据的 ByteArray 对象。
             如果 dataFormat 属性的值是 URLLoaderDataFormat.TEXTURE，则所接收的数据是一个包含位图数据的Texture对象。
             如果 dataFormat 属性的值是 URLLoaderDataFormat.VARIABLES，则所接收的数据是一个包含 URL 编码变量的 URLVariables 对象。
             */
            EgretResManager.prototype.loadResByURL = function (url, dataFormat) {
                if (dataFormat === void 0) { dataFormat = egret.URLLoaderDataFormat.TEXTURE; }
                return __awaiter(this, void 0, void 0, function () {
                    var _this = this;
                    return __generator(this, function (_a) {
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                var urlReq = new egret.URLRequest(url);
                                var loader = new egret.URLLoader(urlReq);
                                loader.dataFormat = dataFormat;
                                loader.once(egret.Event.COMPLETE, function (e) {
                                    resolve(e.data);
                                }, _this);
                                loader.once(egret.IOErrorEvent.IO_ERROR, function (e) {
                                    reject(e.data);
                                }, _this);
                            })];
                    });
                });
            };
            Object.defineProperty(EgretResManager.prototype, "isRunningTask", {
                get: function () {
                    return !!this.currTask;
                },
                enumerable: true,
                configurable: true
            });
            return EgretResManager;
        }());
        Resource.EgretResManager = EgretResManager;
        __reflect(EgretResManager.prototype, "VL.Resource.EgretResManager");
    })(Resource = VL.Resource || (VL.Resource = {}));
})(VL || (VL = {}));
//# sourceMappingURL=EgretResManager.js.map