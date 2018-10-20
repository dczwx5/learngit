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
var SkinModel = (function (_super) {
    __extends(SkinModel, _super);
    function SkinModel() {
        var _this = _super.call(this) || this;
        _this._skinMng = new SkinManager();
        _this._skinMng.skinId = 1;
        return _this;
    }
    Object.defineProperty(SkinModel.prototype, "skinId", {
        get: function () {
            return this._skinMng.skinId;
        },
        set: function (id) {
            this._skinMng.skinId = id;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(SkinModel.prototype, "skinMng", {
        get: function () {
            return this._skinMng;
        },
        enumerable: true,
        configurable: true
    });
    return SkinModel;
}(VoyaMVC.Model));
__reflect(SkinModel.prototype, "SkinModel");
//# sourceMappingURL=SkinModel.js.map