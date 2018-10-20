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
var VoyaMVC;
(function (VoyaMVC) {
    var Msg = (function (_super) {
        __extends(Msg, _super);
        function Msg() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        Msg.prototype.init = function (vo) {
            if (vo === void 0) { vo = undefined; }
            if (vo != null && vo != undefined) {
                this._body = vo;
            }
            return this;
        };
        Object.defineProperty(Msg.prototype, "body", {
            // public restore(maxCacheCount: number = 1) {
            //     super.restore(maxCacheCount);
            // }
            get: function () {
                return this._body;
            },
            enumerable: true,
            configurable: true
        });
        Msg.prototype.clear = function () {
            this._body = null;
        };
        return Msg;
    }(VL.ObjectCache.CacheableClass));
    VoyaMVC.Msg = Msg;
    __reflect(Msg.prototype, "VoyaMVC.Msg", ["VoyaMVC.IMsg"]);
})(VoyaMVC || (VoyaMVC = {}));
//# sourceMappingURL=Msg.js.map