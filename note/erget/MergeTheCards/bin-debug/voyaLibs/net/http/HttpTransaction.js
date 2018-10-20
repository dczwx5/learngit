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
var VL;
(function (VL) {
    var Net;
    (function (Net) {
        var HttpTransaction = (function (_super) {
            __extends(HttpTransaction, _super);
            function HttpTransaction() {
                var _this = _super.call(this) || this;
                _this._isRequesting = false;
                _this._httpReq = new egret.HttpRequest();
                return _this;
            }
            HttpTransaction.prototype.init = function (httpReqPack, onResult) {
                this._reqPack = httpReqPack;
                this._onResult = onResult;
                return this;
            };
            HttpTransaction.prototype.send = function () {
                return __awaiter(this, void 0, void 0, function () {
                    var _this = this;
                    return __generator(this, function (_a) {
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                if (_this._isRequesting) {
                                    app.log("============= 请求未返回，勿重复发送请求 ======================");
                                    resolve(null);
                                }
                                var httpReq = _this._httpReq;
                                var reqPack = _this._reqPack;
                                var serverUrl = reqPack.baseUrl;
                                var sendData;
                                if (reqPack.method == egret.HttpMethod.POST && reqPack.data) {
                                    httpReq.open(serverUrl + reqPack.key, reqPack.method);
                                    sendData = reqPack.data;
                                }
                                else {
                                    httpReq.open(serverUrl + reqPack.key + "?" + reqPack.data, reqPack.method);
                                }
                                var header = reqPack.reqHead;
                                for (var key in header) {
                                    httpReq.setRequestHeader(key, header[key]);
                                    header[key] = header[key];
                                }
                                httpReq.responseType = reqPack.respFormat;
                                _this._isRequesting = true;
                                var onLoaderComplete = function (event) {
                                    httpReq.removeEventListener(egret.Event.COMPLETE, onLoaderComplete, this);
                                    httpReq.removeEventListener(egret.IOErrorEvent.IO_ERROR, onError, this);
                                    this._isRequesting = false;
                                    var respPack = create(Net.HttpRespPack).init(true, httpReq.getAllResponseHeaders(), httpReq.response);
                                    this._onResult(respPack, reqPack.otherData);
                                    resolve(respPack); //因为这句，所以把方法放在函数里面
                                    this.restore();
                                };
                                var onError = function (e) {
                                    httpReq.removeEventListener(egret.Event.COMPLETE, onLoaderComplete, this);
                                    httpReq.removeEventListener(egret.IOErrorEvent.IO_ERROR, onError, this);
                                    this._isRequesting = false;
                                    var respPack = create(Net.HttpRespPack).init(false, httpReq.getAllResponseHeaders(), httpReq.response);
                                    this._onResult(respPack, reqPack.otherData);
                                    resolve(respPack); //因为这句，所以把方法放在函数里面
                                    this.restore();
                                };
                                httpReq.addEventListener(egret.Event.COMPLETE, onLoaderComplete, _this);
                                httpReq.addEventListener(egret.IOErrorEvent.IO_ERROR, onError, _this);
                                httpReq.send(sendData);
                            })];
                    });
                });
            };
            HttpTransaction.prototype.clear = function () {
                this._reqPack =
                    this._onResult = null;
            };
            return HttpTransaction;
        }(VL.ObjectCache.CacheableClass));
        Net.HttpTransaction = HttpTransaction;
        __reflect(HttpTransaction.prototype, "VL.Net.HttpTransaction");
    })(Net = VL.Net || (VL.Net = {}));
})(VL || (VL = {}));
//# sourceMappingURL=HttpTransaction.js.map