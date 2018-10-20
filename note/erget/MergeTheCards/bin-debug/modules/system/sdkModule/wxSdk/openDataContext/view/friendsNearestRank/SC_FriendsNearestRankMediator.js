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
var SC_FriendsNearestRankMediator = (function (_super) {
    __extends(SC_FriendsNearestRankMediator, _super);
    function SC_FriendsNearestRankMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    SC_FriendsNearestRankMediator.prototype.onShow = function (msg) {
        _super.prototype.onShow.call(this, msg);
        EventManager.addTouchUpEventListener(this.view.lb_groupRank, this, this.onGroupRank);
    };
    SC_FriendsNearestRankMediator.prototype.onHide = function () {
        _super.prototype.onHide.call(this);
        EventManager.removeEventListener(this.view.lb_groupRank);
    };
    SC_FriendsNearestRankMediator.prototype.onGroupRank = function () {
        this.closeView(SC_FriendsNearestRankView);
        SendOpenDataContextMsgCommand.create(WxOpenDataContextMsg.FRIEND_RANK_LIST).openAsync();
        // SDKProxy.instance.share(function (result:Enum_SDKShareResult, shareTicket:ShareTicket) {
        //     egret.log(`ShareCanvasMediator shareSuccess shareTicket : ${shareTicket}`);
        //     if(shareTicket){
        //         egret.log(`shareTicket : ${shareTicket}`);
        //         SendOpenDataContextMsgCommand.create(WxOpenDataContextMsg.GROUP_RANK_LIST, shareTicket).openAsync();
        //     }
        // }, this);
    };
    Object.defineProperty(SC_FriendsNearestRankMediator.prototype, "view", {
        get: function () {
            return this.m_view;
        },
        enumerable: true,
        configurable: true
    });
    return SC_FriendsNearestRankMediator;
}(ShareCanvasMediator));
