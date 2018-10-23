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
var BattleSettleView = (function (_super) {
    __extends(BattleSettleView, _super);
    function BattleSettleView() {
        var _this = _super.call(this, "BattleSettleViewSkin") || this;
        _this.resources = [];
        return _this;
    }
    BattleSettleView.prototype.onDestroy = function () {
    };
    return BattleSettleView;
}(App.BaseAutoSizeView));
__reflect(BattleSettleView.prototype, "BattleSettleView");
//# sourceMappingURL=BattleSettleView.js.map