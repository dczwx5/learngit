var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var WxOpenDataContextMsg = (function () {
    function WxOpenDataContextMsg(head, body) {
        this.head = head;
        this.body = body;
    }
    WxOpenDataContextMsg.CLOSE_CONTEXT = "WxOpenDataContextMsg_CLOSE";
    WxOpenDataContextMsg.FRIEND_RANK_LIST = "WxOpenDataContextMsg_FriendRankList";
    WxOpenDataContextMsg.UPDATE_PLAYER_DATA = "WxOpenDataContextMsg_UPDATE_PLAYER_DATA";
    return WxOpenDataContextMsg;
}());
__reflect(WxOpenDataContextMsg.prototype, "WxOpenDataContextMsg");
//# sourceMappingURL=WxOpenDataContextMsg.js.map