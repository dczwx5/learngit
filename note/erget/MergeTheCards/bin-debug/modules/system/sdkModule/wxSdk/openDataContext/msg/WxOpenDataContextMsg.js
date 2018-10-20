var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var WxOpenDataContextMsg = (function () {
    function WxOpenDataContextMsg(head, body) {
        this.head = head;
        this.body = body;
    }
    WxOpenDataContextMsg.INIT_DATA = "WxOpenDataContextMsg_INIT_DATA";
    WxOpenDataContextMsg.CLOSE_CONTEXT = "WxOpenDataContextMsg_CLOSE";
    WxOpenDataContextMsg.FRIEND_RANK_LIST = "WxOpenDataContextMsg_FriendRankList";
    WxOpenDataContextMsg.FRIEND_NEAREST_RANK_LIST = "WxOpenDataContextMsg_FRIEND_NEAREST_RANK_LIST";
    WxOpenDataContextMsg.GROUP_RANK_LIST = "WxOpenDataContextMsg_GROUP_RANK_LIST";
    WxOpenDataContextMsg.UPDATE_PLAYER_DATA = "WxOpenDataContextMsg_UPDATE_PLAYER_DATA";
    return WxOpenDataContextMsg;
}());
__reflect(WxOpenDataContextMsg.prototype, "WxOpenDataContextMsg");
//# sourceMappingURL=WxOpenDataContextMsg.js.map