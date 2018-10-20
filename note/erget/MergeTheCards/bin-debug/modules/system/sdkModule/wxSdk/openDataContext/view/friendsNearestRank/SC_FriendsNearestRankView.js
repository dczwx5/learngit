var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var SC_FriendsNearestRankView = (function (_super) {
    __extends(SC_FriendsNearestRankView, _super);
    function SC_FriendsNearestRankView() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    SC_FriendsNearestRankView.prototype.initUI = function () {
        _super.prototype.initUI.call(this);
        var lb = this.lb_groupRank = new eui.Label;
        lb.text = "查看完整排行>>";
        lb.textColor = 0xFFFFFF;
        lb.size = 40;
        lb.bottom = 20;
        lb.horizontalCenter = 0;
        this.grp_topLayer.addChild(lb);
    };
    return SC_FriendsNearestRankView;
}(ShareCanvasView));
window['SC_FriendsNearestRankView'] = SC_FriendsNearestRankView;
