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
        var HttpRespPack = (function (_super) {
            __extends(HttpRespPack, _super);
            function HttpRespPack() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            HttpRespPack.prototype.init = function (isSuccess, header, data) {
                this._isSuccess = isSuccess;
                this._header = header;
                this._data = data;
                return this;
            };
            HttpRespPack.prototype.clear = function () {
                this._isSuccess = null;
                this._header = null;
                this._data = null;
            };
            Object.defineProperty(HttpRespPack.prototype, "isSuccess", {
                /**
                 * 是否成功
                 * @returns {boolean}
                 */
                get: function () {
                    return this._isSuccess;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(HttpRespPack.prototype, "data", {
                get: function () {
                    return this._data;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(HttpRespPack.prototype, "header", {
                // public get code():number {
                //     return this._code;
                // }
                get: function () {
                    return this._header;
                },
                enumerable: true,
                configurable: true
            });
            return HttpRespPack;
        }(VL.ObjectCache.CacheableClass));
        Net.HttpRespPack = HttpRespPack;
        __reflect(HttpRespPack.prototype, "VL.Net.HttpRespPack");
    })(Net = VL.Net || (VL.Net = {}));
})(VL || (VL = {}));
//# sourceMappingURL=HttpRespPack.js.map