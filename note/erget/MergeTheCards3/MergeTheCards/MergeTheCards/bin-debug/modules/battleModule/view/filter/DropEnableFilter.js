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
var DropEnableFilter = (function (_super) {
    __extends(DropEnableFilter, _super);
    function DropEnableFilter() {
        return _super.call(this, 0, 1, 20, 20, 2) || this;
    }
    Object.defineProperty(DropEnableFilter, "instance", {
        get: function () {
            if (!this._instance) {
                this._instance = new DropEnableFilter();
            }
            return this._instance;
        },
        enumerable: true,
        configurable: true
    });
    return DropEnableFilter;
}(egret.GlowFilter));
__reflect(DropEnableFilter.prototype, "DropEnableFilter");
//# sourceMappingURL=DropEnableFilter.js.map