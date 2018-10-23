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
var SC_FriendsRankView = (function (_super) {
    __extends(SC_FriendsRankView, _super);
    function SC_FriendsRankView() {
        var _this = _super !== null && _super.apply(this, arguments) || this;
        _this.resources = [];
        return _this;
    }
    SC_FriendsRankView.prototype.onDestroy = function () {
    };
    return SC_FriendsRankView;
}(ShareCanvasView));
__reflect(SC_FriendsRankView.prototype, "SC_FriendsRankView");
//# sourceMappingURL=SC_FrandsRankView.js.map