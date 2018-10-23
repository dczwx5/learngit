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
var VL;
(function (VL) {
    var Net;
    (function (Net) {
        /**
         * HTTP请求的信息
         */
        var HttpReqPack = (function (_super) {
            __extends(HttpReqPack, _super);
            function HttpReqPack() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            /**
             * 直接获取并为一个HttpReqMsg赋值
             * @param baseUrl
             * @param key
             * @param data 如果reqFormat参数不为二进制数据，则将reqFormat的键值对形式:{key:value, key:value}转换为 key=value&key=value 的HTTP参数形式
             * @param otherData 一些其他数据，用于回传给回调函数
             * @param reqHead:
             * @param method
             * @param respFormat
             * @param reqFormat
             */
            HttpReqPack.prototype.init = function (baseUrl, key, method, data, otherData, reqHead, respFormat, reqFormat) {
                if (data === void 0) { data = null; }
                if (otherData === void 0) { otherData = null; }
                if (reqHead === void 0) { reqHead = null; }
                if (respFormat === void 0) { respFormat = egret.HttpResponseType.TEXT; }
                if (reqFormat === void 0) { reqFormat = egret.URLLoaderDataFormat.TEXT; }
                this._baseUrl = baseUrl;
                this._key = key;
                this._method = method;
                this._reqHead = reqHead;
                this._respFormat = respFormat;
                this._reqFormat = reqFormat;
                if (reqFormat == egret.URLLoaderDataFormat.TEXT) {
                    // this._data = this.parseURLVariablesStr(data);
                    this._data = Utils.StringUtils.ObjectToQueryFormatString(data);
                }
                else {
                    this._data = data;
                }
                this._otherData = otherData;
                return this;
            };
            HttpReqPack.prototype.clear = function () {
                this._baseUrl
                    = this._key
                        = this._reqHead
                            = this._method
                                = this._respFormat
                                    = this._data
                                        = this._otherData
                                            = this._reqFormat
                                                = null;
            };
            Object.defineProperty(HttpReqPack.prototype, "key", {
                get: function () {
                    return this._key;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(HttpReqPack.prototype, "method", {
                get: function () {
                    return this._method;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(HttpReqPack.prototype, "reqHead", {
                get: function () {
                    return this._reqHead;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(HttpReqPack.prototype, "respFormat", {
                get: function () {
                    return this._respFormat;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(HttpReqPack.prototype, "data", {
                get: function () {
                    return this._data;
                },
                set: function (data) {
                    this._data = data;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(HttpReqPack.prototype, "otherData", {
                get: function () {
                    return this._otherData;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(HttpReqPack.prototype, "reqFormat", {
                get: function () {
                    return this._reqFormat;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(HttpReqPack.prototype, "baseUrl", {
                get: function () {
                    return this._baseUrl;
                },
                enumerable: true,
                configurable: true
            });
            return HttpReqPack;
        }(VL.ObjectCache.CacheableClass));
        Net.HttpReqPack = HttpReqPack;
        __reflect(HttpReqPack.prototype, "VL.Net.HttpReqPack");
        var JsonpReq = (function () {
            function JsonpReq() {
            }
            JsonpReq.process = function (url, callback, callobj) {
                JsonpReq.completeCall["call_" + JsonpReq._regID] = callback.bind(callobj);
                JsonpReq.startLoader(url, JsonpReq._regID++);
            };
            JsonpReq.startLoader = function (url, id) {
                var script = document.createElement('script');
                script.src = url + "JsonpReq.completeCall.call_" + id + "";
                document.body.appendChild(script);
            };
            JsonpReq._regID = 0;
            JsonpReq.completeCall = {};
            return JsonpReq;
        }());
        __reflect(JsonpReq.prototype, "JsonpReq");
    })(Net = VL.Net || (VL.Net = {}));
})(VL || (VL = {}));
//# sourceMappingURL=HttpReqPack.js.map